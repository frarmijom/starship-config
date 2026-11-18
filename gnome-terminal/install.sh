#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.config/gnome-terminal/profiles"
MODE="${1:---dry-run}"

case "$MODE" in
    --dry-run|--apply) ;;
    *) printf 'Uso: %s [--dry-run|--apply]\n' "$0" >&2; exit 2 ;;
esac

for name in fjk local; do
    test -r "$ROOT/profiles/$name.bashrc" || { echo "Falta $name.bashrc" >&2; exit 1; }
done

printf 'Destino: %s\n' "$DEST"
for name in fjk local; do
    printf '  %s.bashrc <- %s\n' "$name" "$ROOT/profiles/$name.bashrc"
done

if [[ "$MODE" == "--dry-run" ]]; then
    echo 'Simulacion: sin cambios. Para instalar usa --apply.'
    exit 0
fi

mkdir -p "$DEST"
for name in fjk local; do
    target="$DEST/$name.bashrc"
    if [[ -f "$target" ]]; then
        backup="$target.backup-$(date +%Y%m%d-%H%M%S)-$$"
        cp -p -- "$target" "$backup"
        printf 'Respaldo: %s\n' "$backup"
    fi
    install -m 0644 "$ROOT/profiles/$name.bashrc" "$target"
done

echo 'Archivos instalados. Conservamos los perfiles gráficos existentes.'
echo 'En GNOME Terminal > Preferencias > perfil > Comando:'
printf '  FJK:   /bin/bash --rcfile %s/fjk.bashrc -i\n' "$DEST"
printf '  LOCAL: /bin/bash --rcfile %s/local.bashrc -i\n' "$DEST"
echo 'Activa «Ejecutar un comando personalizado», desactiva «shell de inicio de sesión»'
echo 'y abre una nueva pestaña con cada perfil para comprobar las variables.'
