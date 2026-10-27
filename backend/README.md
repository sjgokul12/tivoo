# Tivoo backend (video uploads)

Without this server, uploaded videos are saved **only on the phone that uploaded them**.
Run this server and build the app with its URL, and every phone with the APK shares
one feed: a video you upload shows on your profile and in everyone's Explore.

## Run it

Requires Node.js 18+. The app converts videos to MP4 and sends a thumbnail, so the server needs nothing else.

```bash
cd backend
npm install
npm start            # listens on port 8080 (set PORT to change)
```

Videos and `videos.json` are stored in `backend/data/` (set `DATA_DIR` to change it).
On a cloud host, point `DATA_DIR` at a persistent disk or the videos are lost on redeploy.

## Build the app against it

```bash
flutter build apk --release --dart-define=TIVOO_API_URL=http://192.168.1.20:8080
```

- Testing on your Wi-Fi: use your PC's LAN IP (run `ipconfig`); phone and PC must be on the same network.
- Sharing with people outside your Wi-Fi: deploy the server (Render, Railway, a VPS, …)
  and use its `https://` URL.

Without `--dart-define` the app stays in local mode.

## API

| Method | Path | Body / headers | Returns |
|---|---|---|---|
| GET | `/api/videos` | none | `{ "videos": [VideoPost] }`, newest first |
| POST | `/api/videos` | multipart: `video` (file), `thumbnail` (image, optional), `authorId`, `authorName`, `authorUsername`, `authorAvatar`, `caption` | `VideoPost` (201) |
| DELETE | `/api/videos/:id` | header `X-Device-Id` = author id | 204; 403 if it isn't your video |
| GET | `/uploads/<file>` | none | the video or thumbnail (supports streaming) |

`VideoPost`: `id, authorId, authorName, authorUsername, authorAvatar, videoUrl, thumbnailUrl, caption, createdAt, likes, views`

## Not done yet (needed before a public launch)

- **Login:** the author is a random id saved on each install (`authorId`). After login is
  built, send the user's token and check it on the server instead of trusting `authorId` /
  `X-Device-Id`.
- **Database and storage:** the JSON file and local disk are fine for testing. For real
  traffic, use a database (PostgreSQL, MongoDB, Firebase) and object storage (S3, Cloudflare R2,
  Firebase Storage) with a CDN.
- **Moderation and reports** and per-user upload limits.
- Likes, views and comments are only counted on the phone for now. They need API endpoints.
