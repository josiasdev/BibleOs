#!/bin/bash
set -e # Para a execução se qualquer submódulo falhar

echo "==================================================="
echo " INICIANDO COMPILAÇÃO MODULAR DO BIBLEOS"
echo "==================================================="

# Descobre o diretório raiz onde os scripts estão localizados
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Array com a ordem exata de execução dos módulos
MODULES=(
    "core/01-base-setup.sh"
    "apps/02-holyrics.sh"
    "apps/03-mixing-station.sh"
    "apps/04-streaming.sh"
    "bible/05-sword-engine.sh"
    "ui/06-xfce-custom.sh"
)

# Loop de execução de cada módulo isolado
for MODULE in "${MODULES[@]}"; do
    MODULE_PATH="$SCRIPT_DIR/$MODULE"
    
    if [ -f "$MODULE_PATH" ]; then
        echo ">>> Executando módulo: $MODULE"
        chmod +x "$MODULE_PATH"
        source "$MODULE_PATH"
    else
        echo "ERRO: Módulo $MODULE não encontrado!"
        exit 1
    fi
done

echo "==================================================="
echo " COMPILAÇÃO FINALIZADA COM SUCESSO"
echo "==================================================="
