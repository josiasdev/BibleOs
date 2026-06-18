#!/bin/bash
set -e

echo ">> Instalando software de projeção Holyrics..."
cd /tmp

wget -O Holyrics-linux-setup.zip "https://www.holyrics.com.br/download/app/download-setup-linux.php"
unzip -o Holyrics-linux-setup.zip

# CORREÇÃO: Conceder permissão de execução ao instalador recém-extraído
chmod +x Holyrics-linux-setup-*.run

# Engenharia Reversa: Extrair AppImage devido ao isolamento do Cubic/FUSE
./Holyrics-linux-setup-*.run --appimage-extract
rm -rf /opt/holyrics || true
mv squashfs-root /opt/holyrics
chmod -R 755 /opt/holyrics

# Limpeza de binários temporários
rm -f Holyrics-linux-setup.zip Holyrics-linux-setup-*.run

# Geração do atalho no sistema global
cat << 'EOF' > /usr/share/applications/holyrics.desktop
[Desktop Entry]
Name=Holyrics
Comment=Software de projeção para Igrejas
Exec=/opt/holyrics/AppRun
Icon=multimedia-player
Terminal=false
Type=Application
Categories=AudioVideo;Presentation;Religion;
EOF