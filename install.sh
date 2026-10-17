#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
TARGET="$CONFIG_DIR/starship.toml"
BASHRC="$HOME/.bashrc"

usage() {
  cat <<'HELP'
Uso: ./install.sh [--list] [--profile infra-core01|thinkpad] [--dry-run]
      ./install.sh --help
--list       Lista equipos y perfiles disponibles
--profile    Selecciona un equipo sin menú
--dry-run    Muestra el plan sin realizar cambios
HELP
}
profile=""; dry_run=0; list_only=0
while (($#)); do
  case "$1" in
    --list) list_only=1; shift ;;
    --dry-run) dry_run=1; shift ;;
    --profile) (($# >= 2)) || { usage >&2; exit 2; }; profile="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) printf 'Argumento desconocido: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

profiles() {
  printf 'Equipos disponibles:\n'
  printf '  1) INFRA-CORE01  — 👽 perfil coral/turquesa\n'
  printf '  2) THINKPAD      — 💀 perfil azul/cian\n'
}
if ((list_only)); then profiles; exit 0; fi

if [[ -z "$profile" ]]; then
  if [[ ! -t 0 ]]; then
    printf 'Sin TTY: utiliza --profile infra-core01|thinkpad\n' >&2
    exit 2
  fi
  profiles
  printf 'Selecciona equipo [1-2] (Enter cancela): '
  IFS= read -r choice
  case "$choice" in
    1) profile="infra-core01" ;;
    2) profile="thinkpad" ;;
    '') echo 'Cancelado.'; exit 0 ;;
    *) echo 'Selección inválida.' >&2; exit 2 ;;
  esac
fi

case "$profile" in
  infra-core01) src="$ROOT/starship.toml" ;;
  thinkpad) src="$ROOT/starship-thinkpad.toml" ;;
  *) printf 'Perfil no válido: %s\n' "$profile" >&2; exit 2 ;;
esac
[[ -s "$src" ]] || { printf 'No existe el perfil: %s\n' "$src" >&2; exit 1; }
if ! command -v starship >/dev/null 2>&1; then
  printf 'Instala Starship antes de continuar: https://starship.rs/\n' >&2
  exit 127
fi

printf '\nEquipo elegido: %s\nArchivo: %s\nDestino: %s\n' "$profile" "$src" "$TARGET"
if [[ -d "$ROOT/bash" && -f "$ROOT/bash/load.sh" ]]; then
  printf 'Aliases compartidos disponibles: sí\n'
  use_aliases=1
else
  printf 'Aliases compartidos disponibles: no (PR #2 separado)\n'
  use_aliases=0
fi
if ((dry_run)); then echo 'Simulación: ningún archivo modificado.'; exit 0; fi

if [[ -t 0 ]]; then
  printf '¿Aplicar cambios en ESTE equipo? [s/N]: '
  IFS= read -r confirm
  case "$confirm" in s|S|si|SI|sí|SÍ) ;; *) echo 'Cancelado.'; exit 0;; esac
fi

mkdir -p "$CONFIG_DIR"
if [[ -f "$TARGET" ]]; then
  backup="$TARGET.backup-$(date +%Y%m%d-%H%M%S)"
  cp -p "$TARGET" "$backup"
  printf 'Respaldo: %s\n' "$backup"
fi
cp "$src" "$TARGET"
printf 'Perfil instalado: %s\n' "$profile"

init_line='eval "$(starship init bash)"'
if ! grep -Fqx "$init_line" "$BASHRC" 2>/dev/null; then
  printf '\n# Starship\n%s\n' "$init_line" >> "$BASHRC"
fi
if ((use_aliases)); then
  aliases_line="[ -r \"$ROOT/bash/load.sh\" ] && source \"$ROOT/bash/load.sh\""
  if ! grep -Fqx "$aliases_line" "$BASHRC" 2>/dev/null; then
    printf '\n# Atajos de terminal compartidos\n%s\n' "$aliases_line" >> "$BASHRC"
  fi
  echo 'Aliases configurados para futuras sesiones.'
fi
printf 'Listo. Ejecuta: exec bash\n'
