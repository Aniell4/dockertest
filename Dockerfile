FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

# Install system dependencies
RUN apt update && apt install -y \
    git python3 python3-pip wget curl libgl1 libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /ComfyUI
WORKDIR /ComfyUI

# Install Python packages for GPU support
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN pip install -r requirements.txt

# Create model directory & download Image Diffuser model
RUN mkdir -p /ComfyUI/models/checkpoints && \
    curl -L "https://civitai.com/api/download/models/1612720?type=Model&format=SafeTensor&size=pruned&fp=fp16" \
    -o /ComfyUI/models/checkpoints/ImageDiffuser-pruned-fp16.safetensors

# Install custom nodes
RUN mkdir -p /ComfyUI/custom_nodes && \
    cd /ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git && \
    git clone https://github.com/journey-ad/Comfy-Mira.git

# Install dependencies for custom nodes
RUN cd /ComfyUI/custom_nodes/ComfyUI-Impact-Pack && \
    pip install -r requirements.txt && \
    python install.py

RUN cd /ComfyUI/custom_nodes/Comfy-Mira && \
    pip install -r requirements.txt

# Expose ComfyUI port
EXPOSE 8188

# Start the server (listen on all interfaces)
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
