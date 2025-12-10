# Docker Usage Guide

This guide explains how to use fretboardgtr with Docker.

## Prerequisites

- Docker and Docker Compose installed on your server
- Access to GitHub Container Registry (public images)

## Quick Start

### Using Docker Compose (Recommended)

1. Create a `docker-compose.yml` file or use the provided one:

```bash
docker-compose up -d
```

2. Execute Python scripts inside the container:

```bash
docker-compose exec fretboardgtr python -c "from fretboardgtr import FretBoard; print('FretBoardGtr is ready!')"
```

3. Run your own scripts by mounting them:

```bash
# Place your scripts in ./scripts/ directory
docker-compose exec fretboardgtr python /app/scripts/your_script.py
```

### Using Docker directly

Pull the image from GitHub Container Registry:

```bash
docker pull ghcr.io/antscloud/fretboardgtr:latest
```

Run a container:

```bash
docker run -it --rm \
  -v $(pwd)/output:/app/output \
  ghcr.io/antscloud/fretboardgtr:latest \
  python
```

## Creating Fretboards in Docker

### Example 1: Interactive Python Shell

```bash
docker-compose exec fretboardgtr python
```

Then in the Python shell:

```python
from fretboardgtr.fretboard import FretBoard
from fretboardgtr.notes_creators import ScaleFromName

fretboard = FretBoard()
c_major = ScaleFromName(root="C", mode="Ionian").build()
fretboard.add_notes(scale=c_major)
fretboard.export("/app/output/my_fretboard.svg", format="svg")
```

### Example 2: Run a Script

Create a file `scripts/generate_fretboard.py`:

```python
from fretboardgtr import FretBoard
from fretboardgtr.notes_creators import ScaleFromName

TUNING = ["E", "A", "D", "G", "B", "E"]
config = {
    "general": {
        "first_fret": 0,
        "last_fret": 16,
        "fret_width": 50,
        "show_note_name": True,
        "show_degree_name": False,
    }
}
fretboard = FretBoard(config=config)
c_scale = ScaleFromName(root="C", mode="Ionian").build().get_scale(TUNING)
fretboard.add_scale(c_scale, root="C")
fretboard.export("/app/output/c_scale.svg", format="svg")
```

Then run:

```bash
docker-compose exec fretboardgtr python /app/scripts/generate_fretboard.py
```

The output will be saved in your `./output/` directory.

## GitHub Actions Workflow

The repository includes a GitHub Actions workflow (`.github/workflows/docker-build.yml`) that automatically:

- Builds the Docker image on every push to `master`/`main` branch
- Pushes the image to GitHub Container Registry
- Tags images with version numbers when you create git tags
- Creates a `latest` tag for the default branch

### Triggering a Build

Simply push to your main branch:

```bash
git add .
git commit -m "Update fretboardgtr"
git push origin main
```

For versioned releases:

```bash
git tag v1.0.0
git push origin v1.0.0
```

This will create tagged images like:
- `ghcr.io/antscloud/fretboardgtr:latest`
- `ghcr.io/antscloud/fretboardgtr:v1.0.0`
- `ghcr.io/antscloud/fretboardgtr:1.0`
- `ghcr.io/antscloud/fretboardgtr:1`

## Using on Your Server

1. SSH into your server
2. Clone the repository or just copy `docker-compose.yml`
3. Run:

```bash
docker-compose pull  # Pull the latest image from GitHub
docker-compose up -d  # Start the container
```

4. Update the image when needed:

```bash
docker-compose pull
docker-compose up -d --force-recreate
```

## Volumes

The docker-compose setup mounts two directories:

- `./output`: For generated fretboard files
- `./scripts`: For your Python scripts

Create these directories:

```bash
mkdir -p output scripts
```

## Troubleshooting

### Container exits immediately

The default command keeps the container running. If it exits, check logs:

```bash
docker-compose logs
```

### Permission issues

If you encounter permission issues with output files:

```bash
sudo chown -R $USER:$USER output/
```

### Image not found

Make sure the GitHub Actions workflow has run successfully and the image is public. Check:
- GitHub Actions tab in your repository
- GitHub Packages section

## Advanced Usage

### Custom Dockerfile modifications

If you need to modify the Dockerfile, rebuild locally:

```bash
docker build -t fretboardgtr-custom .
```

Then update `docker-compose.yml` to use `fretboardgtr-custom` instead of the GitHub image.

### Environment Variables

Add environment variables to `docker-compose.yml`:

```yaml
services:
  fretboardgtr:
    environment:
      - CUSTOM_VAR=value
```
