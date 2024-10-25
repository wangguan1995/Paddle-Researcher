```
conda create -n ai-researcher python=3.10
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip install -r requirements.txt
cd ai_researcher
bash scripts/end_to_end.sh
```