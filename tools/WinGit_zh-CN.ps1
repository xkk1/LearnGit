<#
.SYNOPSIS
    下载并执行 WinGit_zh-CN.sh 脚本
.DESCRIPTION
    1. 检查 Git 是否在环境变量 PATH 中
    2. 从 GitHub 下载 WinGit_zh-CN.sh 到当前目录
    3. 以管理员身份使用 Git Bash 执行该脚本
#>

Write-Host "🔧 小喾苦 Git for Windows 语言包自动安装 PowerShell 脚本" -ForegroundColor Green

# 0. 检测是否以管理员身份运行
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ 错误：此脚本需要以管理员权限运行！" -ForegroundColor Red
    Write-Host "🖱️ 请右键点击 PowerShell 图标，选择 '以管理员身份运行' 后重试。" -ForegroundColor Yellow
    exit 1
}

# 1. 检查 Git 是否在环境变量 PATH 中
try {
    $gitExePath = (Get-Command git.exe -ErrorAction Stop).Source
    $gitExeDir = Split-Path -Path $gitExePath -Parent
    # 从 git.exe 路径推导 Git for Windows 路径
    $gitDir = Split-Path -Path $gitExeDir -Parent
    Write-Host "📁 检测到 Git for Windows 安装路径: $gitDir" -ForegroundColor Green
} catch {
    Write-Host "❌ 错误: 未检测到 Git for Windows 安装或 git.exe 不在环境变量 PATH 中" -ForegroundColor Red
    Write-Host "📦 请先安装 Git for Windows 并确保 git.exe 在系统 PATH 环境变量中" -ForegroundColor Yellow
    exit 1
}

try {
    $gitBashPath = Join-Path -Path $gitDir -ChildPath "bin\bash.exe"
    
    if (-not (Test-Path $gitBashPath)) {
        throw "❌ 在 Git 目录中未找到 bash.exe"
    }
    
    Write-Host "📄 Git Bash 路径: $gitBashPath" -ForegroundColor Cyan
} catch {
    Write-Host "❌ 错误：无法找到 Git Bash 路径 $gitBashPath" -ForegroundColor Red
    Write-Host "📦 请确保 Git for Windows 已正确安装，并且 bash.exe 在 Git 安装目录中" -ForegroundColor Yellow
    exit 1
}

# 2. 设置环境变量
$lang = "zh_CN"  # 定义基础语言代码变量（可修改为其他值，如 "zh_TW"）
# 2. 构造完整环境变量值
$langEnvValue = "$lang.UTF-8"
Write-Host "🌐 当前语言设置: $lang" -ForegroundColor Cyan
# 设置环境变量 LANG
$env:LANG = "$langEnvValue.UTF-8"
[Environment]::SetEnvironmentVariable("LANG", $langEnvValue, [EnvironmentVariableTarget]::User)

# 3. 下载 WinGit_zh-CN.sh 到临时文件夹
$scriptUrl = "https://github.com/xkk1/LearnGit/raw/refs/heads/gitee/tools/WinGit_zh-CN.sh"
$downloadedFileName = "WinGit_zh-CN.sh"

# 获取系统临时文件夹路径
$tempDir = $env:TEMP
$downloadedFilePath = Join-Path -Path $tempDir -ChildPath $downloadedFileName

Write-Host "⬇️ 正在从 URL🔗 下载脚本: $scriptUrl" -ForegroundColor Cyan
Write-Host "📂 保存到临时路径: $downloadedFilePath“ -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $scriptUrl -OutFile $downloadedFilePath -UseBasicParsing
    
    if (Test-Path $downloadedFilePath) {
        Write-Host "📄 脚本已成功下载到: $downloadedFilePath" -ForegroundColor Green
    } else {
        throw "⛓️‍💥 下载失败：文件未找到"
    }
} catch {
    Write-Host "❌ 下载过程中出错: $_" -ForegroundColor Red
    exit 1
}

# 4. 执行脚本
Write-Host "🪜 正在执行 Git Bash 安装 Git 中文语言包 bash 脚本..." -ForegroundColor Cyan
# 启动 bash.exe 进程，指定要运行的脚本文件，并设置工作目录
Start-Process -FilePath $gitBashPath -ArgumentList "`"$downloadedFileName`"" -WorkingDirectory $tempDir -NoNewWindow -Wait
# 清理文件
Remove-Item $downloadedFilePath
