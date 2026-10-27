// Tivoo video backend: stores uploaded videos and serves the shared feed.
//
//   GET    /api/videos            -> { videos: [VideoPost] } newest first
//   POST   /api/videos            -> multipart: video (file), authorId, authorName,
//                                     authorUsername, authorAvatar, caption -> VideoPost
//   DELETE /api/videos/:id        -> only the author (X-Device-Id header) can delete
//   GET    /uploads/<file>        -> the video / thumbnail files (supports Range for streaming)

const express = require('express');
const multer = require('multer');
const cors = require('cors');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 8080;
const DATA_DIR = process.env.DATA_DIR || path.join(__dirname, 'data');
const UPLOAD_DIR = path.join(DATA_DIR, 'uploads');
const DB_FILE = path.join(DATA_DIR, 'videos.json');
const MAX_BYTES = 2 * 1024 * 1024 * 1024; // 2 GB, same as the app
// The app re-encodes uploads to MP4, but accept any common video container.
const VIDEO_EXT = new Set(['.mp4', '.mov', '.m4v', '.3gp', '.mkv', '.webm', '.avi']);
const IMAGE_EXT = new Set(['.jpg', '.jpeg', '.png', '.webp']);

fs.mkdirSync(UPLOAD_DIR, { recursive: true });

// --- tiny JSON "database" ---------------------------------------------------
function readDb() {
  try {
    return JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
  } catch {
    return [];
  }
}
function writeDb(videos) {
  const tmp = `${DB_FILE}.tmp`;
  fs.writeFileSync(tmp, JSON.stringify(videos, null, 2));
  fs.renameSync(tmp, DB_FILE);
}

// --- app ---------------------------------------------------------------------
const app = express();
app.use(cors());
app.use('/uploads', express.static(UPLOAD_DIR, { maxAge: '7d' }));

const upload = multer({
  storage: multer.diskStorage({
    destination: UPLOAD_DIR,
    filename: (_req, file, cb) => {
      const ext = path.extname(file.originalname || '').toLowerCase() || '.mp4';
      cb(null, `${Date.now()}_${crypto.randomBytes(6).toString('hex')}${ext}`);
    },
  }),
  limits: { fileSize: MAX_BYTES },
  fileFilter: (_req, file, cb) => {
    const ext = path.extname(file.originalname || '').toLowerCase();
    const ok =
      file.fieldname === 'thumbnail'
        ? IMAGE_EXT.has(ext) || file.mimetype.startsWith('image/')
        : VIDEO_EXT.has(ext) || file.mimetype.startsWith('video/');
    cb(ok ? null : new Error(file.fieldname === 'thumbnail' ? 'Thumbnail must be an image' : 'Unsupported video file'), ok);
  },
});

const clean = (v, max) => String(v ?? '').trim().slice(0, max);

app.get('/health', (_req, res) => res.json({ ok: true }));

app.get('/api/videos', (_req, res) => {
  const videos = readDb().sort((a, b) => b.createdAt.localeCompare(a.createdAt));
  res.json({ videos });
});

const uploadFields = upload.fields([
  { name: 'video', maxCount: 1 },
  { name: 'thumbnail', maxCount: 1 },
]);

app.post('/api/videos', uploadFields, (req, res) => {
  const video = req.files?.video?.[0];
  const thumb = req.files?.thumbnail?.[0];
  const authorId = clean(req.body.authorId || req.get('X-Device-Id'), 64);
  if (!video || !authorId) {
    for (const f of [video, thumb]) if (f) fs.unlink(f.path, () => {});
    return res.status(400).json({ error: video ? 'authorId is required' : 'No video file in "video" field' });
  }

  const id = `post_${Date.now()}_${crypto.randomBytes(4).toString('hex')}`;

  const post = {
    id,
    authorId,
    authorName: clean(req.body.authorName, 60) || 'Tivoo user',
    authorUsername: clean(req.body.authorUsername, 40) || 'tivoo_user',
    authorAvatar: clean(req.body.authorAvatar, 500),
    videoUrl: `/uploads/${video.filename}`,
    thumbnailUrl: thumb ? `/uploads/${thumb.filename}` : null,
    caption: clean(req.body.caption, 200),
    createdAt: new Date().toISOString(),
    likes: 0,
    views: 0,
  };
  const videos = readDb();
  videos.push(post);
  writeDb(videos);
  res.status(201).json(post);
});

app.delete('/api/videos/:id', (req, res) => {
  const videos = readDb();
  const post = videos.find((v) => v.id === req.params.id);
  if (!post) return res.status(404).json({ error: 'Video not found' });
  if (post.authorId !== req.get('X-Device-Id')) return res.status(403).json({ error: 'Not your video' });

  writeDb(videos.filter((v) => v.id !== post.id));
  for (const url of [post.videoUrl, post.thumbnailUrl]) {
    if (url) fs.unlink(path.join(UPLOAD_DIR, path.basename(url)), () => {});
  }
  res.status(204).end();
});

// Upload errors (size limit, wrong type) as JSON so the app can show them.
app.use((err, _req, res, _next) => {
  const tooBig = err && err.code === 'LIMIT_FILE_SIZE';
  res.status(tooBig ? 413 : 400).json({ error: tooBig ? 'Video is larger than 2 GB' : err.message });
});

const server = app.listen(PORT, () => console.log(`Tivoo backend listening on http://0.0.0.0:${PORT}`));
// Large uploads on slow mobile networks can take a while.
server.requestTimeout = 0;
server.headersTimeout = 120000;
