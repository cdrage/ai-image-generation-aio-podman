
# Stage 1: Base Image
ARG BASE_IMAGE
FROM ${BASE_IMAGE} AS base

# Install system dependencies for stable diffusion models to work...

ARG TORCH
ARG PYTHON_VERSION
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash

WORKDIR /

# Create workspace directory
RUN mkdir /workspace

# Install python versioning / torch
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt install --yes --no-install-recommends git wget curl bash libgl1 software-properties-common nginx && \
    if [ -n "${PYTHON_VERSION}" ]; then \
        add-apt-repository ppa:deadsnakes/ppa && \
        apt install "python${PYTHON_VERSION}-dev" "python${PYTHON_VERSION}-venv" -y --no-install-recommends; \
    fi && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# If python installed, make sure we are using that verison.
RUN if [ -n "${PYTHON_VERSION}" ]; then \
        ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python && \
        rm /usr/bin/python3 && \
        ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python3 && \
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
        python get-pip.py; \
    fi


RUN pip install --upgrade --no-cache-dir pip

# Install PyTorch only if TORCH is specified
RUN if [ -n "${TORCH}" ]; then pip install --upgrade --no-cache-dir ${TORCH}; fi 
RUN pip install --upgrade --no-cache-dir jupyterlab ipywidgets jupyter-archive jupyter_contrib_nbextensions

# Install jlab
RUN pip install jupyterlab

# Install filebrowser for jlab
RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash;

# Remove ANY possible existing SSH host keys for security
RUN rm -f /etc/ssh/ssh_host_*

# Make sure TQDM is installed
RUN pip install tqdm

# Below is stable diffusion stuff

RUN mkdir -p /sd-models


# You can uncomment the below lines add "package" a model / lora etc. baked into the image, this is just an example. 
#
# These need to already have been downloaded:
#   wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
#   wget https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors
#   wget https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors
#COPY sd_xl_base_1.0.safetensors /sd-models/sd_xl_base_1.0.safetensors
#COPY sd_xl_refiner_1.0.safetensors /sd-models/sd_xl_refiner_1.0.safetensors
#COPY sdxl_vae.safetensors /sd-models/sdxl_vae.safetensors


# Stage 2: A1111 Installation
FROM base AS a1111-install
ARG WEBUI_VERSION
ARG TORCH_VERSION
ARG XFORMERS_VERSION
ARG INDEX_URL
ARG CIVITAI_BROWSER_PLUS_VERSION
COPY --chmod=755 build/install_a1111.sh ./
RUN /install_a1111.sh && rm /install_a1111.sh

# Cache the Stable Diffusion Models
# SDXL models result in OOM kills with 8GB system memory, need 30GB+ to cache these
WORKDIR /stable-diffusion-webui
COPY a1111/cache-sd-model.py ./

# Cache Base Model
#RUN source /venv/bin/activate && \
#    python3 cache-sd-model.py --skip-torch-cuda-test --use-cpu=all --ckpt /sd-models/sd_xl_base_1.0.safetensors && \
#    deactivate

# Cache Refiner Model
#RUN source /venv/bin/activate && \
#    python3 cache-sd-model.py --skip-torch-cuda-test --use-cpu=all --ckpt /sd-models/sd_xl_refiner_1.0.safetensors && \
#    deactivate

# RUN cd /stable-diffusion-webui && python cache.py --use-cpu=all --ckpt /model.safetensors


# Copy Stable Diffusion Web UI config files
COPY a1111/relauncher.py a1111/webui-user.sh a1111/config.json a1111/ui-config.json /stable-diffusion-webui/

# ADD SDXL styles.csv
ADD https://raw.githubusercontent.com/Douleb/SDXL-750-Styles-GPT4-/main/styles.csv /stable-diffusion-webui/styles.csv

# Stage 3: ComfyUI Installation
FROM a1111-install AS comfyui-install
ARG COMFYUI_COMMIT
ARG INDEX_URL
ARG TORCH_VERSION
ARG XFORMERS_VERSION
WORKDIR /
COPY --chmod=755 build/install_comfyui.sh ./
RUN /install_comfyui.sh && rm /install_comfyui.sh

# Copy ComfyUI Extra Model Paths (to share models with A1111)
COPY comfyui/extra_model_paths.yaml /ComfyUI/

# Stage 4: InvokeAI Installation
FROM comfyui-install AS invokeai-install
ARG INVOKEAI_VERSION
ARG INDEX_URL
ARG TORCH_VERSION
ARG XFORMERS_VERSION
WORKDIR /
COPY --chmod=755 build/install_invokeai.sh ./
RUN /install_invokeai.sh && rm /install_invokeai.sh

# Copy InvokeAI config file
COPY invokeai/invokeai.yaml /InvokeAI/

# Stage 6: Application Manager Installation
FROM invokeai-install AS appmanager-install
ARG INDEX_URL
WORKDIR /
COPY --chmod=755 build/install_app_manager.sh ./
RUN /install_app_manager.sh && rm /install_app_manager.sh
COPY app-manager/config.json /app-manager/public/config.json

# Stage 7: Finalise Image
FROM appmanager-install AS final

# Remove any existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

# NGINX Proxy
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Set template version
ARG RELEASE
ENV TEMPLATE_VERSION=${RELEASE}

# Set the main venv path
ARG VENV_PATH
ENV VENV_PATH=${VENV_PATH}

# Copy the scripts
WORKDIR /
COPY --chmod=755 scripts/* ./

# Start the container
CMD ["/bin/bash", "--login", "-c", "/start.sh"]
