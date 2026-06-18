#!/bin/bash
set -e

# Trava de segurança: Garante que o script está sendo executado como root (sudo)
if [ "$EUID" -ne 0 ]; then
  echo ">> Erro: Por favor, execute este script como root (ex: sudo ./seu_script.sh)"
  exit 1
fi

echo ">> Instalando ferramentas auxiliares..."
# Garantir que temos os utilitários de rede e repositório necessários
apt-get update
apt-get install -y curl wget jq software-properties-common arandr

echo ">> Adicionando OBS Studio..."
# Adicionar PPA oficial do OBS Project
add-apt-repository ppa:obsproject/obs-studio -y
apt-get update
apt-get install -y obs-studio

echo ">> Preparando o ambiente para o NDI (DistroAV)..."
cd /tmp

# Limpar possíveis resíduos de execuções anteriores
rm -f distroav.deb libndi-get.sh

echo ">> Instalando a Runtime oficial do NDI 6..."
wget -qO libndi-get.sh https://raw.githubusercontent.com/DistroAV/DistroAV/master/CI/libndi-get.sh
bash libndi-get.sh

echo ">> Buscando a versão mais recente do plugin DistroAV via GitHub API..."
# Puxa o link da versão "latest" dinamicamente, evitando hardcodes que expiram
API_URL="https://api.github.com/repos/DistroAV/DistroAV/releases/latest"
DISTROAV_URL=$(curl -s $API_URL | grep -oP '"browser_download_url": "\K(.*x86_64-linux-gnu\.deb)(?=")' | head -n 1)

if [ -z "$DISTROAV_URL" ]; then
    echo ">> Erro: Não foi possível obter o link dinâmico do DistroAV. Verifique sua conexão ou limite de taxa do GitHub."
    exit 1
fi

echo ">> Baixando DistroAV de: $DISTROAV_URL"
wget -qO distroav.deb "$DISTROAV_URL"

echo ">> Injetando plugin no sistema..."
# Instala e resolve possíveis dependências pendentes no Mint 22.3
dpkg -i distroav.deb || apt-get install -f -y

echo ">> Limpando a casa..."
rm -f distroav.deb libndi-get.sh

echo ">> Instalação concluída com sucesso! OBS Studio e NDI (DistroAV) prontos."