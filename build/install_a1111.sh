#!/usr/bin/env bash
set -e

# Clone the git repo of the Stable Diffusion Web UI by Automatic1111
# and set version
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd /stable-diffusion-webui
git checkout tags/${WEBUI_VERSION}

# Create and activate venv
python3 -m venv --system-site-packages /venv
source /venv/bin/activate

# Install torch and xformers
pip3 install --no-cache-dir torch==${TORCH_VERSION} torchvision torchaudio --index-url ${INDEX_URL}
pip3 install --no-cache-dir xformers==${XFORMERS_VERSION} --index-url ${INDEX_URL}
pip3 install tensorflow[and-cuda]

# Install A1111
pip3 install -r requirements_versions.txt
python3 -c "from launch import prepare_environment; prepare_environment()" --skip-torch-cuda-test

# Clone the Automatic1111 Extensions
git clone https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet
git clone --depth=1 https://github.com/deforum-art/sd-webui-deforum.git extensions/deforum
git clone --depth=1 https://github.com/zanllp/sd-webui-infinite-image-browsing.git extensions/infinite-image-browsing
git clone --depth=1 https://github.com/Uminosachi/sd-webui-inpaint-anything.git extensions/inpaint-anything
git clone --depth=1 https://github.com/Bing-su/adetailer.git extensions/adetailer
git clone --depth=1 https://github.com/civitai/sd_civitai_extension.git extensions/sd_civitai_extension
git clone https://github.com/BlafKing/sd-civitai-browser-plus.git extensions/sd-civitai-browser-plus

# Install dependencies for the various extensions
cd /stable-diffusion-webui/extensions/sd-webui-controlnet
pip3 install -r requirements.txt
cd /stable-diffusion-webui/extensions/deforum
pip3 install -r requirements.txt
cd /stable-diffusion-webui/extensions/infinite-image-browsing
pip3 install -r requirements.txt
cd /stable-diffusion-webui/extensions/adetailer
python3 -m install
cd /stable-diffusion-webui/extensions/sd_civitai_extension
pip3 install -r requirements.txt

# Install dependencies for inpaint anything extension
pip3 install segment_anything lama_cleaner

# Install dependencies for Civitai Browser+ extension
cd /stable-diffusion-webui/extensions/sd-civitai-browser-plus
pip3 install send2trash beautifulsoup4 ZipUnicode fake-useragent packaging pysocks