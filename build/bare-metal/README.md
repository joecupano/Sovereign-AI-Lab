# Bare-Metal

- Installer script: `build_bare-metal.sh`

## Usage

From the `build/bare-metal` directory:

```bash
chmod +x build_bare-metal.sh
./build_bare-metal.sh
```

## What the script does

- Updates Ubuntu packages.
- Detects GPU vendor (`NVIDIA`, `AMD`, `Intel`, or none).
- Installs GPU drivers only if they appear to be missing.
- Installs GPU utilities (`nvtop`, `btop`, plus dynamic `nvidia-utils-*` on NVIDIA hosts).
- Installs build and Python dependencies.
- Installs Ollama and pulls `granite3.3:8b`.
