---
name: apple-remove-bg
description: Use Apple Vision framework to remove backgrounds from images. Works offline, no API cost. Best for images with clear foreground subjects (objects, people, animals). Less effective on landscapes or top-down scenes without a distinct subject.
---

# Apple Background Removal

Removes backgrounds from images using macOS built-in Vision framework (VNGenerateForegroundInstanceMaskRequest).

**Requirements:** macOS 14+ (uses Apple Silicon or Intel with Neural Engine)

## Usage

```bash
# Single image
/Users/haoyuli/AI/hermes agent/.claude/skills/apple-remove-bg/remove-bg <input> <output>

# Batch: loop over files
for f in image1.png image2.png; do
  /Users/haoyuli/AI/hermes agent/.claude/skills/apple-remove-bg/remove-bg "$f" "${f%.png}_nobg.png"
done
```

## How it works

1. Loads image via AppKit
2. Runs `VNGenerateForegroundInstanceMaskRequest` to detect foreground subject
3. Applies mask via `CIBlendWithMask` with transparent background
4. Exports as PNG with alpha channel

## Limitations

- Works best on images with a clear foreground subject (buildings, objects, characters)
- Landscape/scene images may fail (no distinct foreground detected)
- Large images (>2048px) may be slow
- Mask quality depends on subject clarity
