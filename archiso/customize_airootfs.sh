#!/bin/bash
# ============================================================
# CachyOS 定制层 - 在 chroot 中执行的定制脚本
# 由 mkarchiso 在构建时自动调用 (customize_airootfs.sh 约定)
# ============================================================
set -e

# ---- 1. 输入法环境变量 (追加到 /etc/environment, 保留原有 ZPOOL_VDEV_NAME_PATH) ----
cat >> /etc/environment <<'EOF'
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=fcitx
EOF

# ---- 2. fcitx5 自动启动 (KDE 自动检测的兜底) ----
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

# ---- 2.5 默认启用拼音输入法 (新用户继承 /etc/skel) ----
# fcitx5-chinese-addons 提供 pinyin 引擎; 首次登录 Ctrl+Space 直接打拼音
mkdir -p /etc/skel/.config/fcitx5
cat > /etc/skel/.config/fcitx5/profile <<'EOF'
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

# ---- 3. 安装 hysteria2 (本地构建的 pkg, 见 build.sh 中 hysteria 构建步骤) ----
if ls /root/hysteria-*.pkg.tar.zst >/dev/null 2>&1; then
    pacman -U --noconfirm /root/hysteria-*.pkg.tar.zst
    rm -f /root/hysteria-*.pkg.tar.zst
fi

# ---- 4. WPS 中文字体兜底 (noto-fonts-cjk 已在 packages 列表, 此处仅校验) ----
fc-cache -f >/dev/null 2>&1 || true

exit 0
