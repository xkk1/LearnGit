#!/usr/bin/bash
# Author: xkk1
# 描述：Git中文语言包安装脚本（需管理员权限）
# 注意：请以Git Bash（管理员权限）运行此脚本
# "C:\Program Files\Git\bin\bash.exe" WinGit_zh-CN.sh

# 参考：https://zhuanlan.zhihu.com/p/681521193

# -------------------------- 权限检查 --------------------------
# 检测目标目录是否可写（通过临时文件测试）
TARGET_BASE="/mingw64/share/locale/zh_CN"
TEST_FILE="${TARGET_BASE}/langpack_test_$(date +%s).tmp"  # 唯一临时文件防冲突

# 尝试创建测试文件检测写入权限
if ! touch "$TEST_FILE" 2>/dev/null; then
    echo "❌ 权限错误：当前用户无权限写入 ${TARGET_BASE} 目录，请以管理员身份运行"
    exit 1
fi
# 清理测试文件
rm -f "$TEST_FILE"

# -------------------------- 语言包下载 --------------------------
LANG_FILE="zh_CN.po"
echo "⬇️ 正在下载 Git 中文语言包"
# Git 官方源地址（GitHub原始文件） https://github.com/git/git/blob/master/po/zh_CN.po
# wget https://raw.githubusercontent.com/git/git/master/po/zh_CN.po -O zh_CN.po
# Git for Windows 官方源地址（GitHub原始文件） https://github.com/git-for-windows/git/blob/main/po/zh_CN.po
# 使用curl下载（更适合Windows环境）
curl -L -o zh_CN.po https://github.com/git-for-windows/git/raw/refs/heads/main/po/zh_CN.po
# 下载结果校验
if [ $? -ne 0 ] || [ ! -s "$LANG_FILE" ]; then  # -s检查文件非空
    echo "❌ 下载失败：网络问题或文件损坏"
    echo "    手动下载地址：https://raw.githubusercontent.com/git/git/master/po/zh_CN.po"
    exit 1
fi
echo "✅ 语言包下载完成（$(du -h "$LANG_FILE" | awk '{print $1}')）"


# -------------------------- 环境检查 --------------------------
# 检查msgfmt工具是否存在（生成mo文件必需）
if ! command -v msgfmt &>/dev/null; then
    echo "❌ 工具缺失：未找到msgfmt命令"
    echo "   请确认已安装Git for Windows（通常自带gettext工具）"
    exit 1
fi

# -------------------------- 生成MO文件 --------------------------
echo "🔄 正在生成二进制语言包（mo文件）..."
if ! msgfmt -o git.mo "$LANG_FILE"; then
    echo "❌ 生成失败：语言包格式错误或msgfmt异常"
    exit 1
fi
echo "✅ MO文件生成成功：$(ls -lh git.mo | awk '{print $5}')"

# -------------------------- 部署到系统目录 --------------------------
DEST_DIR="${TARGET_BASE}/LC_MESSAGES"
DEST_FILE="${DEST_DIR}/git.mo"

echo "📂 正在部署到系统目录：${DEST_DIR}"
# 创建多级目录（-p自动创建缺失父目录）
if ! mkdir -vp "$DEST_DIR"; then
    echo "❌ 目录创建失败：请检查${DEST_DIR}路径是否存在"
    exit 1
fi

# 复制文件并校验
if ! cp -v git.mo "$DEST_FILE"; then
    echo "❌ 复制失败：目标目录无写入权限或路径错误"
    exit 1
fi

# -------------------------- 最终验证 --------------------------
echo -e "\n🎉 安装完成！验证信息："
echo "   语言包路径：$(realpath "$DEST_FILE")"

# -------------------------- 清理文件并退出 --------------------------
rm -f git.mo "$LANG_FILE"
exit 0
