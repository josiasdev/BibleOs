#!/bin/bash

# ==============================================================================
# BibleOS 1.0 - Script de Construção do Ambiente Chroot
# Foco: Ambiente Cristão Completo (Estudo, Produtividade, Projeção e Áudio)
# Base: Linux Mint XFCE (Downstream Ubuntu 24.04 LTS "Noble")
# ==============================================================================
# Este script foi desenhado para ser executado como ROOT dentro do ambiente
# terminal do Cubic (Custom Ubuntu ISO Creator).
# Ele automatiza a instalação das dependências, codecs, motor de estudo bíblico,
# Holyrics (Projeção) e Mixing Station (Áudio).
# ==============================================================================

# Encerrar o script se houver erros (Segurança)
set -e

echo "=============================================================================="
echo ">> INICIANDO A CONSTRUÇÃO DO AMBIENTE BIBLEOS (BUILD CHROOT) <<"
echo "=============================================================================="

# ------------------------------------------------------------------------------
# 1. Configurações Iniciais e Pré-requisitos de Instalação
# ------------------------------------------------------------------------------
echo ">> Configurando ambiente para instalação silenciosa e atualizando apt..."
export DEBIAN_FRONTEND=noninteractive

# Aceitar automaticamente os termos da Microsoft para fontes TTF (necessário para codecs)
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

# Atualizar a base de pacotes do sistema base
apt update && apt upgrade -y

# Instalar utilitários essenciais para o fluxo de build
echo ">> Instalar utilitários essenciais (wget, curl, unzip, git, nano)..."
apt install -y wget curl git unzip nano htop software-properties-common

# ------------------------------------------------------------------------------
# 2. Instalação de Codecs e Suporte Multimídia (Nativo Linux Mint)
# ------------------------------------------------------------------------------
echo ">> Instalar Codecs Multimídia Nativos e reprodutor VLC..."
# mint-meta-codecs garante suporte out-of-the-box para MP4, MP3, AAC, etc.
apt install -y mint-meta-codecs vlc

# ------------------------------------------------------------------------------
# 3. Suporte a Aplicações (Java e Wine)
# ------------------------------------------------------------------------------
echo ">> Instalar OpenJDK 17 LTS (necessário para Holyrics)..."
apt install -y openjdk-17-jre

echo ">> Configurando e instalando camada de compatibilidade Wine..."
dpkg --add-architecture i386
apt update
apt install -y wine64 wine32 wine

# ------------------------------------------------------------------------------
# 4. Instalação da Suíte de Estudo Bíblico (Motor SWORD e BibleTime)
# ------------------------------------------------------------------------------
# Devido a mudanças na base Ubuntu 24.04 (Noble), o BibleTime foi escolhido
# em substituição ao Xiphos por ser compatível com Qt/C++ moderno.
echo ">> Instalar BibleTime e motor libsword-utils..."
add-apt-repository universe -y
apt update
apt install -y bibletime libsword-utils

# Baixar e Injetar módulos de domínio público offline (ARC e KJV)
echo ">> Populando motor SWORD com Bíblias de Domínio Público offline..."
mkdir -p /usr/share/sword/
cd /usr/share/sword/

# Módulo KJV (Inglês)
wget -c "https://www.crosswire.org/ftpmirror/pub/sword/packages/rawzip/KJV.zip"
# Módulo PorAlmeida (Almeida Corrigida Fiel original - Português)
wget -c "https://www.crosswire.org/ftpmirror/pub/sword/packages/rawzip/PorAlmeida.zip"

echo ">> Descompactando e limpando módulos..."
unzip -o KJV.zip
unzip -o PorAlmeida.zip
rm -f *.zip

# ------------------------------------------------------------------------------
# 5. Instalação do Holyrics (Software de Projeção)
# ------------------------------------------------------------------------------
# O Holyrics é empacotado como um AppImage. Devido a restrições do Cubic/FUSE,
# extraímos o AppImage manualmente e executamos em modo silencioso.
echo ">> Preparando instalação do Holyrics (via extração de AppImage)..."
cd /tmp
wget -O Holyrics-linux-setup.zip "https://www.holyrics.com.br/download/app/download-setup-linux.php"
unzip -o Holyrics-linux-setup.zip

echo ">> Extraindo o AppImage..."
./Holyrics-linux-setup-*.run --appimage-extract

# Mover a pasta extraída (squashfs-root) para /opt
echo ">> Movendo Holyrics para /opt e ajustando permissões..."
rm -rf /opt/holyrics || true # Garantir pasta limpa
mv squashfs-root /opt/holyrics
chmod -R 755 /opt/holyrics

# Limpar arquivos temporários
echo ">> Limpando instaladores temporários do Holyrics..."
rm -f Holyrics-linux-setup.zip Holyrics-linux-setup-*.run

# Criar o arquivo .desktop (Atalho para o Menu XFCE)
echo ">> Criando atalho .desktop do Holyrics..."
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

# ------------------------------------------------------------------------------
# 6. Instalação do Mixing Station (Controle Universal de Áudio)
# ------------------------------------------------------------------------------
# O Mixing Station fornece controle nativo para mesas Behringer, Soundcraft, etc.
echo ">> Instalando Mixing Station nativo (Universal Audio Control)..."
mkdir -p /opt/mixing-station
cd /opt/mixing-station
# Baixar binário oficial usando API dinâmica de release estável
wget -O mixing-station "https://mixingstation.app/backend/api/web/download/attachment/mixing-station-pc/release/linux"
chmod +x mixing-station

# Criar o arquivo .desktop (Atalho para o Menu XFCE)
echo ">> Criando atalho .desktop do Mixing Station..."
cat << 'EOF' > /usr/share/applications/mixing-station.desktop
[Desktop Entry]
Name=Mixing Station
Comment=Controle universal para Mesas de Som Digitais
Exec=/opt/mixing-station/mixing-station
Icon=audio-card
Terminal=false
Type=Application
Categories=AudioVideo;Audio;
EOF

# ------------------------------------------------------------------------------
# 7. Aparência e Customização (etc/skel) - Ícones e Papel de Parede
# ------------------------------------------------------------------------------
echo ">> Configurando customizações visuais padrão (/etc/skel)..."

# Criar diretórios de Área de Trabalho (PT-BR e EN)
mkdir -p /etc/skel/Desktop
mkdir -p "/etc/skel/Área de Trabalho"

# Copiar os atalhos criados para o esqueleto do sistema
echo ">> Copiando atalhos padrão para o Desktop de novos usuários..."
cp /usr/share/applications/holyrics.desktop /etc/skel/Desktop/ 2>/dev/null
cp /usr/share/applications/holyrics.desktop "/etc/skel/Área de Trabalho/" 2>/dev/null

cp /usr/share/applications/mixing-station.desktop /etc/skel/Desktop/ 2>/dev/null
cp /usr/share/applications/mixing-station.desktop "/etc/skel/Área de Trabalho/" 2>/dev/null

# Tenta copiar o atalho do BibleTime (lidando com variações de nome do instalador)
cp /usr/share/applications/ubuntu-bibletime.desktop /etc/skel/Desktop/ 2>/dev/null || cp /usr/share/applications/bibletime.desktop /etc/skel/Desktop/ 2>/dev/null
cp /usr/share/applications/ubuntu-bibletime.desktop "/etc/skel/Área de Trabalho/" 2>/dev/null || cp /usr/share/applications/bibletime.desktop "/etc/skel/Área de Trabalho/" 2>/dev/null

# Dar permissão de execução nos atalhos para evitar alertas de segurança do XFCE
chmod +x /etc/skel/Desktop/*.desktop 2>/dev/null
chmod +x "/etc/skel/Área de Trabalho/"*.desktop 2>/dev/null

# Configuração do Papel de Parede (Background)
echo ">> Configurando Papel de Parede padrão do BibleOS..."
mkdir -p /usr/share/backgrounds/bibleos

# Verificação do Wallpaper customizado.
# NOTA: O desenvolvedor DEVE garantir que 'biblia-padrao.jpg'
# esteja presente na raiz (/) do terminal chroot do Cubic ANTES de rodar este script.
# (Recurso: Drag and Drop do Cubic)
if [ -f "/biblia-padrao.jpg" ]; then
    echo ">> Papel de Parede 'biblia-padrao.jpg' encontrado na raiz. Configurando..."
    mv /biblia-padrao.jpg /usr/share/backgrounds/bibleos/
else
    echo ">> ATENÇÃO: A imagem 'biblia-padrao.jpg' não foi encontrada na raiz (/) do chroot."
    echo ">> Por favor, copie o arquivo de imagem para a raiz do terminal Cubic antes de rodar este script."
    echo ">> Tentando usar um papel de parede padrão do sistema para evitar erros visual..."
fi

# Injetar a configuração XML do XFCE (xfconf) para carregar o papel de parede correto
echo ">> Injetando XML de configuração do XFCE (xfconf)..."
mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml

cat << 'EOF' > /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="image-path" type="string" value="/usr/share/backgrounds/bibleos/biblia-padrao.jpg"/>
        <property name="image-style" type="int" value="5"/>
      </property>
      <property name="monitor1" type="empty">
        <property name="image-path" type="string" value="/usr/share/backgrounds/bibleos/biblia-padrao.jpg"/>
        <property name="image-style" type="int" value="5"/>
      </property>
      <property name="monitorDEFAULT" type="empty">
        <property name="image-path" type="string" value="/usr/share/backgrounds/bibleos/biblia-padrao.jpg"/>
        <property name="image-style" type="int" value="5"/>
      </property>
    </property>
  </property>
</channel>
EOF

# ------------------------------------------------------------------------------
# 8. Finalização e Limpeza
# ------------------------------------------------------------------------------
echo ">> Finalizando o ambiente Chroot e limpando caches do apt..."
# Remover pacotes orfãos, cache do apt e limpar pasta /tmp/ para reduzir o tamanho da ISO final
apt autoremove -y && apt clean && rm -rf /tmp/*

echo "=============================================================================="
echo ">> CONSTRUÇÃO DO AMBIENTE BIBLEOS CONCLUÍDA COM SUCESSO << "
echo ">> Você pode sair do terminal (exit) e gerar a ISO no Cubic. << "
echo "=============================================================================="
