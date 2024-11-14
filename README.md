
# Stable diffusion all-in-one Podman container

## Disclaimer

Fork of the amazing work of https://github.com/ashleykleynhans/stable-diffusion-docker but unfortunatley no longer available.

## Important notes

* **NVIDIA GPUs ONLY.**
* Does not include ANY SAFETENSORS. Add your models through Stable Diffusion Web UI, or by manually uploading them via Jupyter Lab.
* Made slim as possible, some "default" models such as SDXL are removed. Download them manually.

## Building:

```sh

# Clone
git clone git clone https://github.com/cdrage/stable-diffusion-podman.git
cd stable-diffusion-podman

# See build-args.env for all environment variables regarding versions / you can customise your own version
podman build -t stable-diffusion-podman --build-arg-file build-args.env .
```

## Running:

```sh
podman run -d \
  --gpus all \
  -v /workspace \
  -p 3000:3001 \
  -p 3020:3021 \
  -p 6006:6066 \
  -p 8000:8000 \
  -p 8888:8888 \
  -p 9090:9090 \
  -e JUPYTER_PASSWORD=Jup1t3R! \
  -e ENABLE_TENSORBOARD=1 \
  stable-diffusion-podman
```

| Connect Port | Internal Port | Description                   |
|--------------|---------------|-------------------------------|
| 3000         | 3001          | A1111 Stable Diffusion Web UI |
| 3020         | 3021          | ComfyUI                       |
| 6006         | 6066          | Tensorboard                   |
| 8000         | 8000          | Application Manager           |
| 8888         | 8888          | Jupyter Lab                   |
| 9090         | 9090          | InvokeAI                      |