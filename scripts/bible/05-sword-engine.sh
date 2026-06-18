#!/bin/bash
set -e

echo ">> Instalando ecossistema de estudo bíblico (BibleTime + SWORD)..."

add-apt-repository universe -y
apt update
apt install -y bibletime libsword-utils

# Alimentar o banco de dados offline com Bíblias de Domínio Público
mkdir -p /usr/share/sword/
cd /usr/share/sword/

wget -c "https://www.crosswire.org/ftpmirror/pub/sword/packages/rawzip/KJV.zip"
wget -c "https://www.crosswire.org/ftpmirror/pub/sword/packages/rawzip/PorAlmeida1911.zip"

unzip -o KJV.zip
unzip -o PorAlmeida1911.zip
rm -f *.zip