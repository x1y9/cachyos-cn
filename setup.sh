#!/bin/bash
# ============================================================
# CachyOS 中文工作环境一键配置
#   fcitx5 中文输入法 (拼音 + Rime) + WPS Office + Hysteria2
# 适用: 已装好的 CachyOS (KDE Plasma)
# 用法: sudo bash setup.sh
# ============================================================
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "请用 sudo 运行: sudo bash setup.sh"
    exit 1
fi

echo "==> [1/4] 安装 fcitx5 中文输入法 + 中文字体"
pacman -S --noconfirm --needed \
    fcitx5 \
    fcitx5-chinese-addons \
    fcitx5-configtool \
    fcitx5-rime \
    noto-fonts-cjk

echo "==> [2/4] 配置输入法环境变量 + 自启动 + 默认拼音"
cat > /etc/environment <<'EOF'
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=fcitx
EOF
mkdir -p /etc/xdg/autostart
cat > /etc/xdg/autostart/fcitx5.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Fcitx5
Comment=Start Fcitx5 input method
Exec=/usr/bin/fcitx5 -d
X-GNOME-Autostart-Phase=Applications
Terminal=false
EOF

# 默认启用拼音 (新用户继承 /etc/skel, 当前用户即时生效)
write_fcitx_profile() {
    mkdir -p "$1/.config/fcitx5"
    cat > "$1/.config/fcitx5/profile" <<'EOF'
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=pinyin

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=pinyin
Layout=

[GroupOrder]
0=Default
EOF
}
write_fcitx_profile /etc/skel
if [[ -n "${SUDO_USER:-}" ]] && [[ -d "/home/$SUDO_USER" ]]; then
    chown -R "$SUDO_USER":"$SUDO_USER" "/home/$SUDO_USER/.config"
    write_fcitx_profile "/home/$SUDO_USER"
fi

echo "==> [3/4] 安装 WPS Office (CachyOS 官方仓库, 国际版)"
pacman -S --noconfirm --needed wps-office wps-office-mime

echo "==> [4/4] 安装 Hysteria2 (AUR)"
if ! command -v yay >/dev/null 2>&1; then
    echo "---- 安装 yay (AUR helper) ----"
    pacman -S --noconfirm --needed base-devel git
    tmpdir=$(mktemp -d)
    git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
    (cd "$tmpdir/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
fi
yay -S --noconfirm hysteria

echo ""
echo "============================================================"
echo " ✅ 全部完成"
echo ""
echo " 输入法: 重启后生效 (fcitx5 已自动启动)"
echo "   - 切换: Ctrl+Space"
echo "   - 拼音: fcitx5 自带, 配置: fcitx5-configtool"
echo "   - Rime: 需在 fcitx5 设置里手动添加『中州韵』"
echo ""
echo " WPS: 开始菜单搜索 wps / 首次启动注册组件"
echo ""
echo " Hysteria2:"
echo "   - 服务端:   sudo systemctl enable --now hysteria-server@config"
echo "   - 客户端:   sudo systemctl enable --now hysteria-client@config"
echo "   - 配置模板: /etc/hysteria/config.yaml"
echo "   - 证书:     hysteria server 会自动签发自签证书, 客户端 insecure 连接"
echo "============================================================"
