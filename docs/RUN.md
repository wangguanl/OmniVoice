# 运行命令

- 项目：OmniVoice（多语种零样本 TTS，Gradio Demo）
- 生成时间：2026-09-05
- 运行方式：直接运行（纯 Python 库 + 单一 Gradio 服务，无 Docker）
- 硬件评估：**有压力**（结论 + 依据见下，**尚未启动**）

## 硬件评估

| 项 | 项目要求 | 本机 |
|---|---|---|
| GPU | NVIDIA，官方未写死最低显存；0.6B 权重，README 推荐 `torch.float16`；社区/Issue #41 显示 Demo+Whisper 在 8GB 卡上可占约 6.6GB | RTX 4080 16GB |
| 剩余显存 | Demo 峰值大约 3–7GB（含默认 Whisper ASR 时偏高） | 已用 5393 MiB，剩余约 10640 MiB |
| 占卡 | 无官方多卡要求（推理） | **已有计算进程**：`FunClip\.venv\python.exe`、`Bert-VITS2\.venv\python.exe`，另有桌面/Chrome/Cursor |
| 内存 | 未写死 | 31.8GB 总 / 约 12.1GB 空闲 |
| 磁盘 | 权重约 6.5GB 已在缓存 | E: 空闲约 738GB |

结论：**官方推理门槛低于 16GB，剩余显存理论上够本次 Demo；但卡上已有两个其它项目的 Python 计算进程，属于「有压力」。** 未启动、未下载新权重、未写 `start.ps1`。

可选方案（等你决定）：

1. **先关掉 FunClip / Bert-VITS2 再跑完整 Demo**（含 Whisper 自动转写，最稳）。
2. **就用当前剩余约 10.6GB 硬上**（大概率够，但其它进程若突然占卡可能 OOM）。
3. **降显存：`omnivoice-demo --no-asr`**（不预加载 Whisper；克隆时需手填参考文本）。
4. **不跑**。

## 环境准备

本机已具备：PowerShell 7（`C:\Program Files\PowerShell\7\pwsh.exe`）、`uv` 0.12.2、项目 `.venv`（Python 3.12.13）、`torch 2.8.0+cu128`、可 `import omnivoice`、ffmpeg（`E:\Programs\ffmpeg-master-latest-win64-gpl\bin`）。`nvcc` 不在 PATH，推理不需要本机 CUDA Toolkit。

官方源探测（2026-09-05）：`huggingface.co` / `pypi.org` / `github.com` 超时；`https://hf-mirror.com` 200（788ms）；清华 PyPI 200（195ms）。后续拉取走国内镜像。

```powershell
# 在仓库根目录，用 pwsh
$env:HF_ENDPOINT = 'https://hf-mirror.com'
$env:HF_HOME = 'E:\huggingface_cache'
$env:Path = 'E:\Programs\ffmpeg-master-latest-win64-gpl\bin;' + $env:Path

# 依赖（已同步过则跳过）
uv sync --default-index "https://pypi.tuna.tsinghua.edu.cn/simple"
```

权重：`k2-fsa/OmniVoice` 已缓存在 `E:\huggingface_cache\models--k2-fsa--OmniVoice`（约 6.5GB），一般不必再下。默认 ASR `openai/whisper-large-v3-turbo` **尚未**在该缓存中；完整 Demo 首次会再下一份（走 `HF_ENDPOINT`）。

## 启动

- 推荐：`pwsh -NoProfile -File .\start.ps1`（你确认继续后再生成并执行）
- 等价手动命令（建议端口 8001，占用则自行 +1）：

```powershell
$env:HF_ENDPOINT = 'https://hf-mirror.com'
$env:HF_HOME = 'E:\huggingface_cache'
$env:Path = 'E:\Programs\ffmpeg-master-latest-win64-gpl\bin;' + $env:Path
# 低显存可选：去掉 ASR
# uv run omnivoice-demo --ip 127.0.0.1 --port 8001 --no-asr
uv run omnivoice-demo --ip 127.0.0.1 --port 8001
```

访问：`http://127.0.0.1:<实际端口>`（README 写 8001；当前 `demo.py` 默认参数是 7860）。

## 验证

1. 启动日志出现 Gradio 监听地址，无 CUDA OOM。
2. 浏览器打开后，用「声音设计」：文本例如 `你好，这是 OmniVoice 本机测试。`，属性选 `Female / 女`，点生成，应得到 24kHz 音频且状态为 Done。
3. 或 CLI：`uv run omnivoice-infer --model k2-fsa/OmniVoice --text "Hello, this is a test." --instruct "female, low pitch" --output hello.wav`，退出码 0 且生成 wav。

## 备注

- 端口：以 README 建议的 8001 为起点探测，占用则顺延；不要写死。
- 精度：官方推荐 fp16，不量化、不换小模型。
- 镜像：Hugging Face 用 `HF_ENDPOINT=https://hf-mirror.com`；`uv` 用清华 PyPI。
- ffmpeg：会话 PATH 加入 `E:\Programs\ffmpeg-master-latest-win64-gpl\bin`。
- 本机已有未提交改动：`omnivoice/cli/demo.py`、`uv.lock`；未跟踪文件 `fix-global-path.ps1`。本文档不纳入 git。
- 工作区当前终端是 Windows PowerShell 5.1，`pwsh` 已安装但不在该会话 PATH 里，启动时用完整路径或先开 pwsh。
