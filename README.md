# Orca OpenCode Server

A Docker container that runs [Orca](https://github.com/stablyai/orca) with [OpenCode](https://opencode.ai/) to create a multi-agent orchestration and code generation platform.

## Overview

This project provides a containerized environment for:
- **Orca**: A multi-agent orchestrator for coordinating AI agents
- **OpenCode**: An AI-powered code generation and testing tool
- **ClaudeCode**: An AI-powered code generation and testing tool
- **OpenSpec**: A spec-driven development tool
- **Python 3.14**: For code execution and testing
- **Node.js 22**: For JavaScript/TypeScript code generation and npm packages

## Prerequisites

- Docker installed ([Docker Installation Guide](https://docs.docker.com/get-docker/))
- Docker Compose (optional, for easier deployment)
- ~2GB of disk space for the image

## Quick Start

### Build the Docker Image

```bash
# Build with default versions
docker build -t orca-opencode:latest .

# Build with custom versions
docker build \
  --build-arg ORCA_VERSION=v1.4.205 \
  --build-arg OPENCODE_VERSION=1.18.31 \
  --build-arg NODE_VERSION=22 \
  -t orca-opencode:latest .
```

### Run the Container

**Basic run:**
```bash
docker run -d \
  --name orca-opencode \
  -p 6768:6768 \
  orca-opencode:latest
```

**With workspace volume (recommended for development):**
```bash
docker run -d \
  --name orca-opencode \
  -p 6768:6768 \
  -v $(pwd)/workspace:/workspace \
  orca-opencode:latest
```

**Interactive mode (for debugging):**
```bash
docker run -it \
  --name orca-opencode \
  -p 6768:6768 \
  orca-opencode:latest
```

### Access the Service

The service runs on port **6768** by default.

**Check if it's running:**
```bash
docker ps | grep orca-opencode
```

**View logs:**
```bash
docker logs -f orca-opencode
```

**Enter the container:**
```bash
docker exec -it orca-opencode bash
```

## Testing the Service

### Health Check

```bash
# Basic connectivity test
curl -v http://localhost:6768/

# Check if opencode CLI is working
docker exec orca-opencode opencode --version
```

### Using OpenCode

Inside the container:

```bash
# Enter the container
docker exec -it orca-opencode bash

# Run opencode commands
opencode --help

# Start the server
opencode serve --port 6768 --pairing-address orca --json
```

## Configuration

### Build Arguments

You can customize the build with these arguments:

| Argument | Default | Description |
|----------|---------|-------------|
| `ORCA_VERSION` | `v1.4.205` | Orca AppImage version |
| `OPENCODE_VERSION` | `1.18.31` | OpenCode npm package version |
| `NODE_VERSION` | `22` | Node.js major version (20, 22, etc.) |

**Example with custom versions:**
```bash
docker build \
  --build-arg ORCA_VERSION=v1.5.0 \
  --build-arg OPENCODE_VERSION=1.19.0 \
  --build-arg NODE_VERSION=20 \
  -t orca-opencode:custom .
```

### Environment Variables

The container sets these environment variables:

```dockerfile
ENV HOME=/home/orca
ENV XDG_DATA_HOME=/home/orca/.local/share
ENV XDG_CONFIG_HOME=/home/orca/.config
ENV LIBGL_ALWAYS_SOFTWARE=1
```

You can override them when running:
```bash
docker run -d \
  -e "HOME=/home/orca" \
  -p 6768:6768 \
  orca-opencode:latest
```

## Docker Compose (Optional)

Create a `docker-compose.override.yml` for local development:

```yaml
version: '3.8'

services:
  orca-opencode:
    build:
      context: .
      args:
        ORCA_VERSION: v1.4.205
        OPENCODE_VERSION: 1.18.31
        NODE_VERSION: 22
    ports:
      - "6768:6768"
    volumes:
      - ./workspace:/workspace
    environment:
      - HOME=/home/orca
    restart: unless-stopped
```

Then run:
```bash
docker-compose up -d
```

## Image Specifications

### Base Image
- **python:3.14-slim** - Lightweight Python 3.14 with essential system libraries

### Installed Components
- **Python 3.14**: For code execution and testing
- **Node.js 22**: Latest LTS version from NodeSource official repository
- **npm**: Node package manager (included with Node.js)
- **Git**: Version control
- **curl**: HTTP client
- **X11 libraries**: For GUI support (xvfb, libgtk-3-0, etc.)
- **jq**: JSON processor

### Image Size
- Approximately **1.2GB** (compressed ~400MB)

## Security Considerations

- Runs as non-root user `orca`
- Uses pinned versions for reproducibility
- Regular security updates via base image
- No hardcoded credentials

## Troubleshooting

### Container won't start

```bash
# Check logs
docker logs orca-opencode

# Rebuild without cache
docker build --no-cache -t orca-opencode:latest .
```

### Permission denied errors

Ensure the workspace directory has proper permissions:
```bash
chmod 755 workspace
```

### Port already in use

```bash
# Use a different port
docker run -d \
  -p 8000:6768 \
  orca-opencode:latest
```

Then access via `http://localhost:8000`

### OpenCode crashes

Check the logs inside the container:
```bash
docker exec orca-opencode cat /home/orca/.local/share/opencode/log/opencode.log
```

## Development

### Building for testing
```bash
# Build and run with verbose output
docker build --progress=plain -t orca-opencode:latest .
```

### Running tests
```bash
docker exec orca-opencode python3 --version
docker exec orca-opencode node --version
docker exec orca-opencode npm --version
docker exec orca-opencode opencode --version
```

## Updating Versions

To update any component:

1. Find the latest version:
   - [Orca Releases](https://github.com/stablyai/orca/releases)
   - [OpenCode npm](https://www.npmjs.com/package/opencode-ai)
   - [Node.js LTS](https://nodejs.org/en/)

2. Update the Dockerfile ARG values or rebuild with `--build-arg`:
   ```bash
   docker build \
     --build-arg ORCA_VERSION=v1.5.0 \
     -t orca-opencode:latest .
   ```

## Resources

- [Orca GitHub](https://github.com/stablyai/orca)
- [OpenCode AI](https://opencode.ai/)
- [Node.js](https://nodejs.org/)
- [Python Docker Documentation](https://pythonspeed.com/articles/base-image-python-docker-images/)

## License

This Docker configuration is provided as-is. See the licenses of the individual components (Orca, OpenCode) for licensing terms.

## Support

For issues with:
- **Orca**: See [Orca Issues](https://github.com/stablyai/orca/issues)
- **OpenCode**: See [OpenCode Support](https://opencode.ai/)
- **This Docker setup**: Open an issue in this repository

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

**Last Updated**: September 17, 2026
