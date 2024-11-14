# AI Image Generation AIO (all-in-one) Podman Container

## Disclaimer

Fork of the amazing work of https://github.com/ashleykleynhans/stable-diffusion-docker but unfortunatley no longer available.

## Features

Welcome! This container will (hopefully) get you started on custom image generation tools!

Contains everything to start your image generation:
* [A1111 Stable Diffusion](https://github.com/AUTOMATIC1111/stable-diffusion-webui): Simplified image generation. Perfect for beginners.
* [ComfyUI](https://github.com/comfyanonymous/ComfyUI): Workflow based /config based and usually uses latest technology. More advanced.
* [InvokeAI](https://github.com/invoke-ai/InvokeAI): ComfyUI alternative.

Additional software:
* [JupyterLab](https://jupyter.org/): Notebook interface to upload / download files / modify.

## IMPORTANT NOTES

* Models / LORAs / etc are synced between all AI generational tools, download on Stable Diffusion, and it will appear under ComfyAI.
* A1111 Stable Diffusion contains a set of plugins to help you get started.
* **LINUX ONLY. Does not run on macOS / Windows through Podman Machine.**
* **NVIDIA GPUs ONLY.**
* **AMD64 ARCHITECTURE ONLY.**
* Does not include ANY SAFETENSORS. Add your models through Stable Diffusion Web UI, or by manually uploading them via Jupyter Lab.
* Made slim as possible, some "default" models such as SDXL are removed. Download them manually.

## Building

Recommended to use Linux as there are issues building this container with Podman Machine on macOS / Windows. The reasoning is that `pip` and other tools used to initially build the image rely being on AMD64 / Linux architecture.

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
  -p 8000:8000 \
  -p 8888:8888 \
  -p 9090:9090 \
  -e JUPYTER_PASSWORD=Jup1t3R! \
  stable-diffusion-podman
```

| Connect Port | Internal Port | Description                   |
|--------------|---------------|-------------------------------|
| 3000         | 3001          | A1111 Stable Diffusion Web UI |
| 3020         | 3021          | ComfyUI                       |
| 8000         | 8000          | Application Manager           |
| 8888         | 8888          | Jupyter Lab                   |
| 9090         | 9090          | InvokeAI                      |