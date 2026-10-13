# Gift artwork: AI image prompts

Generate one image per gift, save it with the file name shown, and put it in `assets/gifts/`.
The app picks each file up automatically; until a file exists, the gift's emoji is shown.

## Premium 3D gifts (do these first)

These 11 gifts carry the 3D animations. Their current pictures were cut from a small poster
(only about 300 px of real detail), which is why they look soft on a phone. Replace them with
HD versions using **exactly** these file names:

| File | Prompt (add the shared style below) |
|---|---|
| `assets/gifts/premium/royal_crown.png` | A majestic royal golden crown with red velvet, studded with blue sapphires and rubies, glowing gold light |
| `assets/gifts/premium/angel_vehicle.png` | A white and gold angel carriage pulled by two white winged pegasus horses, an angel girl riding, soft divine glow |
| `assets/gifts/premium/golden_horse.png` | A galloping white horse with a flowing golden mane and golden armour, trails of golden sparkles behind it |
| `assets/gifts/premium/luxury_car.png` | A gold and black luxury supercar with glowing neon light trails, three-quarter front view, headlights on |
| `assets/gifts/premium/love_castle.png` | A pink fairytale castle with golden spires and glowing heart windows on a floating cloud island, pink hearts around it |
| `assets/gifts/premium/galaxy_rocket.png` | A translucent glowing blue and purple crystal space rocket flying diagonally upward with a bright blue flame |
| `assets/gifts/premium/diamond_wings.png` | A pair of large iridescent crystal diamond angel wings, blue and purple prismatic facets, sparkling |
| `assets/gifts/premium/flower_chariot.png` | A golden carriage covered in pink roses pulled by two white horses with rose garlands, rose petals around it |
| `assets/gifts/premium/ocean_whale.png` | A giant glowing blue whale made of sparkling bioluminescent particles, swimming, water droplets around it |
| `assets/gifts/premium/meteor_shower.png` | A big golden glowing star followed by a curved trail of smaller golden stars, shooting-star shape |
| `assets/gif1.png` (Rose Bouquet) | A luxury bouquet of red roses and baby's breath wrapped in black and gold paper with a red satin bow |

Best results: **2048 × 2048 px** (1024 px minimum), transparent background, object centred.
After you add them, tell Claude: the premium gifts are currently set up as "picture" art
(edges faded into the effects), and with true cut-outs they should be switched to floating
3D objects with real reflections.

## Requirements for every image

- **Format:** PNG with a **transparent background** (no checkerboard drawn into the image, no white/black backdrop).
- **Size:** 1024 × 1024 px or larger, square.
- **Framing:** object centred, filling about 85% of the canvas, nothing cut off at the edges.
- **No** text, watermark, logo, frame, floor or ground shadow.
- **Shared style** (add to every prompt):
  `glossy 3D render, luxury mobile live-streaming app gift icon, soft studio lighting with pink and blue neon rim light, vibrant saturated colours, high detail, ultra sharp, isolated object, transparent background, 8k`

If your generator cannot output transparency, generate on a plain solid background and remove it with a background-removal tool before saving as PNG.

## Prompts

| File name | Prompt (add the shared style at the end) |
|---|---|
| `cosmic_fire_rose.png` | A single magical red rose wrapped in swirling golden fire and purple cosmic stardust, glowing embers floating around the petals |
| `flowers.png` | A luxurious bouquet of pink and red roses wrapped in shiny pink paper with a satin ribbon bow, a few sparkles |
| `love.png` | A glossy red 3D heart with a golden ring orbiting around it, small floating pink hearts and sparkles |
| `kitty.png` | A cute chubby white kitten with big shiny eyes hugging a red heart, pink cheeks, kawaii style |
| `teddy.png` | A cute fluffy panda teddy bear holding a glossy red heart, kawaii style, soft fur detail |
| `tiki_love.png` | Bold 3D lettering-free emblem: two glossy pink hearts intertwined with a small golden crown on top, neon glow |
| `cake.png` | A three-tier chocolate birthday cake with pink frosting, strawberries, lit candles and gold sprinkles |
| `crown.png` | A royal golden crown studded with red rubies and blue sapphires, polished metal reflections |
| `angel_wings.png` | A pair of large glowing white angel wings with iridescent blue-pink feather tips and a small golden halo above |
| `diamond.png` | A huge brilliant-cut blue diamond with prismatic rainbow light reflections and sparkling facets |
| `super_car.png` | A red luxury supercar, three-quarter front view, glossy paint, chrome rims, headlights on |
| `rocket.png` | A sleek white and red space rocket launching diagonally upward with a bright orange flame and smoke trail |
| `yacht.png` | A white luxury super-yacht, three-quarter view, on a small splash of turquoise water |
| `castle.png` | A fairytale pink and lavender castle with golden spires and glowing windows, floating hearts around it |
| `world_tour.png` | A glossy 3D globe of planet Earth with a small white airplane circling it on a golden dotted path |

## After adding the images

1. Make sure the names match exactly (lower case, underscores, `.png`).
2. Run `flutter pub get` (only needed once, if the app was running before the `assets/gifts/` folder existed).
3. Restart the app (a full restart, not hot reload, so new assets are bundled).
