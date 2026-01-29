#!/bin/bash
# Ajusta permissões da pasta swagger para evitar erros de escrita no Docker

set -e

SWAGGER_DIR="$(dirname "$0")/../swagger"

if [ -d "$SWAGGER_DIR" ]; then
  echo "Ajustando permissões em $SWAGGER_DIR..."
  sudo chown -R $(id -u):$(id -g) "$SWAGGER_DIR"
  sudo chmod -R 777 "$SWAGGER_DIR"
  echo "Permissões ajustadas."
else
  echo "Diretório $SWAGGER_DIR não encontrado."
fi
