#!/bin/bash
set -e

echo ">> Instalando Mixing Station a partir de binário local..."

# 1. Verifica se o arquivo foi injetado via Drag & Drop
if [ -f "/mixing-station_3.0.1_amd64.deb" ]; then
    
    # 2. Instala via DPKG (o instalador de pacotes local)
    # O --force-all ajuda caso faltem dependências muito específicas
    dpkg -i /mixing-station_3.0.1_amd64.deb || apt-get install -f -y
    
    # 3. Limpeza do instalador injetado
    rm -f /mixing-station_3.0.1_amd64.deb
    
    echo ">> Mixing Station instalado com sucesso pelo pacote local."
else
    echo "❌ ERRO: O arquivo 'mixing-station_3.0.1_amd64.deb' não foi encontrado na raiz do sistema."
    echo ">> Lembre-se de arrastar o arquivo .deb para dentro do terminal antes de rodar o build!"
    exit 1
fi