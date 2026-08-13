#!/bin/bash
# ============================================================
# CachyOS 定制层 - 在 chroot 中执行的定制脚本
# 由 mkarchiso 在构建时自动调用 (customize_airootfs.sh 约定)
# ============================================================
set -e

# 构建标记: 验证 customize 是否真的执行 (grep 构建日志 CACHYOS_CN_CUSTOMIZE)
echo "=== CACHYOS_CN_CUSTOMIZE_RUNNING ==="
whoami
ls -la /root/ | head

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

# ---- 2.5 默认启用拼音输入法 ----
# fcitx5-chinese-addons 提供 pinyin 引擎; 首次登录 Ctrl+Space 直接打拼音
# 注意: mkarchiso 在运行本脚本之前就会把 /etc/skel 复制到 liveuser 家目录
# (archiso/mkarchiso 的 _make_customize_airootfs), 所以光写 /etc/skel 只对安装后
# 的新用户生效, live 会话必须同时直接写 /home/liveuser
write_fcitx_profile() {
    local dir="$1"
    mkdir -p "$dir/.config/fcitx5"
    cat > "$dir/.config/fcitx5/profile" <<'EOF'
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
# 防御两种执行顺序: 若 archiso 已先创建 liveuser 并拷贝 skel 则补写 liveuser;
# 若尚未创建 (customize 先跑), 则只写 skel, 由 mkarchiso 后续拷贝到 liveuser。
# 注意: 不要主动 mkdir /home/liveuser, 否则 useradd -m 会跳过 skel 拷贝。
if [ -d /home/liveuser ]; then
    write_fcitx_profile /home/liveuser
    chown -R liveuser:liveuser /home/liveuser/.config 2>/dev/null || true
fi

# ---- 3. 安装 hysteria2 (本地构建的 pkg, 见 build.sh 中 hysteria 构建步骤) ----
if ls /root/hysteria-*.pkg.tar.zst >/dev/null 2>&1; then
    pacman -U --noconfirm /root/hysteria-*.pkg.tar.zst
    rm -f /root/hysteria-*.pkg.tar.zst
fi

# ---- 4. WPS 中文字体兜底 (noto-fonts-cjk 已在 packages 列表, 此处仅校验) ----
fc-cache -f >/dev/null 2>&1 || true

exit 0
