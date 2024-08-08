
# Stable diffusion all-in-one Podman container

Fork of https://github.com/ashleykleynhans/stable-diffusion-docker but instead we are using podman


## Important notes

* This custom stable diffusion container contains NO SAFETENSORS. Download your own through the webgui / pass it in using jupyter notebook. This is because it REDUCES the image size. Remember this!
* Kohya removed due to instability / issues. Use OneTrainer / something else instead.
* Only works with NVIDIA
* There are packaged models which are COMMENTED OUT. This reduces the size (it is already a 30GB+ image)
* UI will load with the **DEFAULT** stable diffusion model, look online for others to download

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
  -p 2999:2999 \
  -p 3000:3001 \
  -p 3020:3021 \
  -p 6006:6066 \
  -p 7777:7777 \
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
| 9090         | 9090          | InvokeAI                      |
| 6006         | 6066          | Tensorboard                   |
| 7777         | 7777          | Code Server                   |
| 8000         | 8000          | Application Manager           |
| 8888         | 8888          | Jupyter Lab                   |
| 2999         | 2999          | RunPod File Uploader          |
