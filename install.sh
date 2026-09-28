#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STARSHIP_CONFIG="$HOME/.config/starship.toml"
BASHRC="$HOME/.bashrc"

echo
echo "👽 INFRA Starship Installer"
echo "──────────────────────────"

# ─────────────────────────────────────────────
# 1. Starship
# ─────────────────────────────────────────────

if command -v starship >/dev/null 2>&1; then
    echo "✓ Starship instalado: $(starship --version | head -1)"
else
    echo "→ Starship no encontrado. Instalando..."
    curl -sS https://starship.rs/install.sh | sh
fi

# ─────────────────────────────────────────────
# 2. Directorio de configuración
# ─────────────────────────────────────────────

mkdir -p "$HOME/.config"

# ─────────────────────────────────────────────
# 3. Backup
# ─────────────────────────────────────────────

if [[ -f "$STARSHIP_CONFIG" ]]; then
    BACKUP="${STARSHIP_CONFIG}.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$STARSHIP_CONFIG" "$BACKUP"
    echo "✓ Backup: $BACKUP"
fi

# ─────────────────────────────────────────────
# 4. Instalar configuración
# ─────────────────────────────────────────────

cp "$PROJECT_DIR/starship.toml" "$STARSHIP_CONFIG"

echo "✓ Configuración instalada en:"
echo "  $STARSHIP_CONFIG"

# ─────────────────────────────────────────────
# 5. Integración Bash
# ─────────────────────────────────────────────

INIT_LINE='eval "$(starship init bash)"'

if ! grep -Fqx "$INIT_LINE" "$BASHRC" 2>/dev/null; then
    {
        echo
        echo "# Starship prompt"
        echo "$INIT_LINE"
    } >> "$BASHRC"

    echo "✓ Starship agregado a ~/.bashrc"
else
    echo "✓ ~/.bashrc ya tiene Starship configurado"
fi

echo
echo "──────────────────────────"
echo "✓ Instalación completada"
echo
echo "Ejecuta:"
echo
echo "    source ~/.bashrc"
echo
