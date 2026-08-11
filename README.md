# CachyOS 中文定制版 ISO 🇨🇳

基于官方 [CachyOS-Live-ISO](https://github.com/CachyOS/CachyOS-Live-ISO) (KDE Plasma) 的定制版，GitHub Actions 自动构建，产物发布在 **Releases** 页面。

## 预装内容

| 组件 | 来源 | 说明 |
|---|---|---|
| **fcitx5** + 拼音 + Rime | Arch 官方仓库 | 中文输入法，**拼音默认启用**（Ctrl+Space 切换），Rime 可选 |
| **WPS Office** 11.1.0 | CachyOS 官方仓库 | 国际版，含文件关联 |
| **Hysteria2** 2.9.x | AUR (hysteria-bin) | 高性能代理，含 systemd 服务 |
| noto-fonts-cjk | Arch 官方仓库 | 中文字体 |

## 下载

👉 [Releases 页面](https://github.com/born729/cachyos-custom-iso/releases) — 下载最新 `.iso`（附 sha256 校验）

## 构建

构建由 GitHub Actions 自动完成（push / 手动触发 `workflow_dispatch`），无需本地 Arch 环境：

```bash
git clone https://github.com/born729/cachyos-custom-iso.git
# 修改 archiso/packages_desktop.x86_64 或 archiso/customize_airootfs.sh 后 push 即可
```

构建产物：
- ISO: `out/desktop/cachyos-desktop-linux-YYMMDD.iso`
- 包清单: `.pkgs.txt`、sha256 校验文件

## 定制内容

- `archiso/packages_desktop.x86_64` — 追加 fcitx5 系 + WPS 包
- `archiso/customize_airootfs.sh` — 输入法环境变量、fcitx5 自启动、默认拼音 profile、hysteria 安装
- `setup.sh` — 已装好的 CachyOS 一键配置脚本（不装 ISO 也能用）
- `configs/` — hysteria 服务端/客户端配置模板

## 手动构建（需要 Arch 环境）

```bash
# Arch Linux 环境
pacman -S --needed archiso mkinitcpio-archiso git squashfs-tools grub base-devel
pacman-key --recv-keys F3B607488DB35A47 && pacman-key --lsign-key F3B607488DB35A47

# 构建 hysteria (不能 root 跑 makepkg)
useradd -m builder
git clone https://aur.archlinux.org/hysteria-bin.git /tmp/hysteria-bin
cd /tmp/hysteria-bin && makepkg -s --noconfirm
cp hysteria-*.pkg.tar.zst /path/to/repo/archiso/airootfs/root/

# 构建 ISO
cd /path/to/repo && ./buildiso.sh -p desktop -v -w
```

## 已知事项

- WPS 为**国际版**（CachyOS 仓库）；中国版 wps-office-cn 需走 AUR
- 官方 `generate_environment` 会覆盖 `/etc/environment`，输入法变量在 customize 脚本中追加（已处理）
- CachyOS 镜像域名 2026 年起为 `mirror.cachyos.org`（已适配）
