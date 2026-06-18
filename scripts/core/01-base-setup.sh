#!/bin/bash
set -e

echo ">> Configurando dependências do sistema e atualizando repositórios..."
export DEBIAN_FRONTEND=noninteractive

# Aceitar licença EULA das fontes Microsoft automaticamente
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

apt update && apt upgrade -y

# Instalação de utilitários de sistema e codecs multimídia essenciais para igrejas
apt install -y wget curl git unzip nano htop software-properties-common mint-meta-codecs vlc openjdk-17-jre

# Arquitetura de 32 bits e Wine para softwares legados
dpkg --add-architecture i386
apt update
apt install -y wine64 wine32 wine
