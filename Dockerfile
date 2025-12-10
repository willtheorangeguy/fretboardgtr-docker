FROM python:3.10-slim

LABEL description="fretboardgtr docker image"
LABEL org.opencontainers.image.source="https://github.com/antscloud/fretboardgtr"
LABEL org.opencontainers.image.description="Package that makes easy creation of highly customizable fretboards and chords diagrams"
LABEL org.opencontainers.image.licenses="AGPL-3.0"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libcairo2-dev \
        pkg-config \
        gcc \
        g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml setup.py MANIFEST.in README.md LICENSE py.typed ./
COPY fretboardgtr ./fretboardgtr/

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir .

CMD ["python"]
