# shader-msl-verify

Throwaway public mirror so GitHub's **free macOS runners** can compile the
Metal (MSL) ports of the gradient-lab / shader-lab shader catalogue. The real
source repo is private; MSL only compiles on Apple's `xcrun metal`.

- `msl/` — the four `.metal` shaders (Mesh, Soft, GradientPass, Noise)
- `glsl/primitives/` — the GLSL parent source (math ground truth)
- `scripts/verify-metal.sh` — compiles every `.metal` with `xcrun metal` and
  links a `.metallib` (fails the job on any error)
- `.github/workflows/verify-msl.yml` — macOS runner, `-Wall -Werror`

Run: `bash scripts/verify-metal.sh` on macOS, or just push and watch Actions.

## Sync

The mirror is regenerated from the private catalogue by:
```
rsync -a ../../msl/ msl/ 2>/dev/null        # (from the source catalogue)
```
(contents are aspirational — edits happen upstream)