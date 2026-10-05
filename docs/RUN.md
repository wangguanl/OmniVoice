# 运行命令

- 项目：OmniVoice（多语种零样本 TTS，Gradio Demo）
$12026-09-09
- 运行方式：直接运行（纯 Python 库 + 单一 Gradio 服务，无 Docker）
- 硬件评估：**满足**（用户关闭其它占卡进程后；启动后约占用 11.7GB / 16GB）
- 当前状态：已启动 `http://127.0.0.1:8001`（`--no-asr`，本地权重）

## 硬件评估

| 项 | 项目要求 | 本机 |
|---|---|---|
| GPU | NVIDIA；官方未写死最低显存；0.6B + fp16；非 24GB 硬门槛 | RTX 4080 16GB |
| 剩余显存 | Demo+Whisper 峰值大约数 GB（远低于 16GB） | 已用约 1.7GB，剩余约 14GB（桌面占用） |
| 占卡 | 推理单卡即可 | 运行前关闭 FunClip / Bert-VITS2 等计算进程 |
| 内存 | 未写死 | 约 32GB |
| 磁盘 | 权重约 6.5GB 已缓存 | E: 充足 |

结论：**满足。** 官方未要求 24GB；16GB 在空闲卡上跑完整 Demo（含 Whisper）足够。

## 环境准备

本机已具备：PowerShell 7、`uv`、项目 `.venv`（Python 3.12 + `torch 2.8.0+cu128` + `omnivoice`）、ffmpeg。

```powershell
$env:HF_ENDPOINT = 'https://hf-mirror.com'
$env:HF_HOME = 'E:\huggingface_cache'
$env:Path = 'E:\Programs\ffmpeg-master-latest-win64-gpl\bin;' + $env:Path
# 依赖已同步过则跳过
# uv sync --default-index "https://pypi.tuna.tsinghua.edu.cn/simple"
```

权重：`k2-fsa/OmniVoice` 已在 `E:\huggingface_cache\models--k2-fsa--OmniVoice`。首次完整 Demo 可能仍会拉 `openai/whisper-large-v3-turbo`（走 `HF_ENDPOINT`）。

## 启动

- 推荐：`pwsh -NoProfile -File .\start.ps1`（菜单；默认 [1] `demo-no-asr`）
- 服务 Id：`demo-no-asr`（推荐）、`demo`（含 Whisper ASR）
- 自动化：`pwsh -NoProfile -File .\start.ps1 -Service demo-no-asr`
- 等价手动命令：

```powershell
$env:HF_ENDPOINT = 'https://hf-mirror.com'
$env:HF_HOME = 'E:\huggingface_cache'
$env:Path = 'E:\Programs\ffmpeg-master-latest-win64-gpl\bin;' + $env:Path
$Model = "$env:HF_HOME\models--k2-fsa--OmniVoice\snapshots\c5fdb5ccb189668d56333f77ba2629f4cd7535f4"
uv run omnivoice-demo --ip 127.0.0.1 --port 8001 --model $Model --no-asr
```

访问：`http://127.0.0.1:<实际端口>`（起点 8001，占用则顺延）。

## 验证

1. 启动日志出现 Gradio 地址，无 CUDA OOM。
2. 「声音设计」：文本 `你好，这是 OmniVoice 本机测试。`，选 `Female / 女`，生成成功。
3. 或：`uv run omnivoice-infer --model k2-fsa/OmniVoice --text "Hello, this is a test." --instruct "female, low pitch" --output hello.wav`

## 备注

- 镜像：`HF_ENDPOINT=https://hf-mirror.com`；PyPI 可用清华源。
- ffmpeg：`E:\Programs\ffmpeg-master-latest-win64-gpl\bin`
- 本机记录（`docs/RUN.md`、`start.ps1`）默认不提交。
