# 🖼️ CS50x Week 4 — Volume, Filter & Recover

> 📝 **Blog Post:** [CS50 Week 4 C — Volume Scaling, Image Filters and JPEG Recovery](https://www.parsadev.co.uk/post/cs50-week-4-c-volume-scaling-image-filters-and-jpeg-recovery)
> 📚 **CS50x Series:** [All CS50x posts on ParsaDev](https://www.parsadev.co.uk/blog/categories/cs50x)
> 🌐 **Developer:** [parsadev.co.uk](https://www.parsadev.co.uk)

Three problem sets from CS50x Week 4, all written in C. This is the week the course goes low-level — reading and writing binary file formats directly, working with raw memory buffers, and understanding exactly how data sits on disk. Volume, Filter, and Recover each tackle a different kind of binary file: WAV audio, BMP images, and raw JPEG data on a memory card.

---

## 📌 What It Does

**Volume** — Reads a WAV audio file, copies the 44-byte header unchanged to an output file, then reads each 16-bit audio sample, multiplies it by a command-line scaling factor, and writes the result. Increasing the factor amplifies the audio; decreasing it reduces it. Uses `int16_t` to correctly represent signed audio sample data.

**Filter (`helpers.c`)** — Implements four BMP image filter functions:
- **Grayscale** — Averages each pixel's RGB values and sets all three channels to the result
- **Reflect** — Mirrors the image horizontally by swapping pixels across the centre of each row
- **Blur** — Applies a box blur by averaging each pixel's 3×3 neighbourhood, handling edge pixels by counting only valid neighbours
- **Edges** — Applies the Sobel operator to detect edges, computing horizontal (Gx) and vertical (Gy) gradients per colour channel and combining them as `sqrt(Gx² + Gy²)`, capped at 255

**Recover** — Scans a raw memory card image file 512 bytes at a time, detects JPEG file signatures (`0xff 0xd8 0xff 0xe_`), and reconstructs each JPEG as a sequentially numbered output file (`000.jpg`, `001.jpg`, etc.).

---

## ✨ Features

**Volume:**
- Correct use of `int16_t` (aliased as `SAMPLE_AUDIO`) for signed 16-bit WAV sample data
- Header copied as a raw byte array — untouched by the scaling operation
- Simple sample-by-sample read-multiply-write loop

**Filter:**
- `getBlur` helper function accepts a colour channel index to avoid duplicating the neighbourhood averaging logic
- Sobel edge detection uses a temporary image copy so convolution always reads original pixel values
- Reflect handles both odd and even widths with separate loop bounds
- All filters operate in-place on the `RGBTRIPLE` image array

**Recover:**
- JPEG signature detection using byte-level comparison and nibble masking (`buffer[3] & 0xf0 == 0xe0`)
- Sequential file naming with `sprintf` and a block counter
- Previous output file closed before a new one opens — no file handle leaks
- Input file and final output file both explicitly closed after the loop

---

## 🛠 Tech Stack

| Component | Detail |
|-----------|--------|
| Language | C |
| Standard Libraries | `stdio.h`, `stdlib.h`, `stdint.h`, `math.h` |
| CS50 Filter scaffold | `helpers.h`, `filter.c`, `bmp.h` (provided by CS50) |
| Compiler | `make` (CS50 VS Code environment) |

---

## ▶️ How to Run

All programs run in the CS50 development environment using `make`.
```bash
# Volume — scale a WAV file up or down
make volume
./volume input.wav output.wav 2.0

# Filter — apply a filter to a BMP image
make filter
./filter -g image.bmp grayscale.bmp   # grayscale
./filter -r image.bmp reflected.bmp   # reflect
./filter -b image.bmp blurred.bmp     # blur
./filter -e image.bmp edges.bmp       # edges

# Recover — reconstruct JPEGs from a raw memory card image
make recover
./recover card.raw
```

---

## 🧠 How the Sobel Edge Filter Works

The Sobel operator applies two 3×3 convolution kernels to each pixel:
```
Gx = [[-1, 0, 1],   Gy = [[-1, -2, -1],
      [-2, 0, 2],         [ 0,  0,  0],
      [-1, 0, 1]]         [ 1,  2,  1]]
```

For each colour channel (R, G, B) and each pixel:
1. Compute `Gx` and `Gy` by multiplying neighbouring pixel values by the kernel weights and summing
2. Combine: `result = sqrt(Gx² + Gy²)`
3. Cap at 255 to stay within valid RGB range

Results are written to a temporary copy of the image so the convolution always reads from the original, unmodified pixel values.

---

## 🧠 How Recover Works

| Step | Detail |
|------|--------|
| Read in 512-byte blocks | Matches the block size of a FAT filesystem |
| Detect JPEG signature | `0xff 0xd8 0xff` + upper nibble of byte 4 equals `0xe` |
| Open new output file | Named `000.jpg`, `001.jpg`, etc. using `sprintf` |
| Write all blocks | Every block after a signature goes to the current output file |
| Close on next signature | Previous file is closed before the next one opens |
| Final close | Last output file closed after the read loop ends |

---

## 🔗 Blog & Links

The full write-up — covering how the Sobel operator works, why `int16_t` matters for audio samples, and what JPEG recovery teaches you about how filesystems actually handle deleted files — is on the ParsaDev blog:

👉 [CS50 Week 4 C — Volume Scaling, Image Filters and JPEG Recovery](https://www.parsadev.co.uk/post/cs50-week-4-c-volume-scaling-image-filters-and-jpeg-recovery)

Browse the rest of the CS50x series at [parsadev.co.uk/blog/categories/cs50x](https://www.parsadev.co.uk/blog/categories/cs50x).

---

## 📬 Contact

Built by Parsa — find more projects and writing at [parsadev.co.uk](https://www.parsadev.co.uk).

---

## 🎓 Credit

Problem sets designed by [Harvard CS50x 2026](https://cs50.harvard.edu/x/2026/). All code written independently as part of the course.