#!/usr/bin/env bash
# Configuracion transversal de Starship y perfiles GNOME Terminal.
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${TARGET:-auto}"
MODE="${MODE:-}"
SELECTED_SHELL="${SELECTED_SHELL:-auto}"
THEME="${THEME:-}"
HOST_LABEL="${HOST_LABEL:-}"
APPLY=0

usage() {
  cat <<'HELP'
Uso:
  bash setup.sh                        Menu interactivo
  bash setup.sh --target auto --mode all --dry-run
  bash setup.sh --target infra-core01 --mode starship --apply
  bash setup.sh --target thinkpad --mode all --apply
  bash setup.sh --target new --theme thinkpad --host-label LAB-01 --mode starship --apply
Opciones:
  --target auto|infra-core01|thinkpad|new
  --mode starship|terminal|all
  --shell auto|bash|zsh
  --theme infra-core01|thinkpad        Base visual para un equipo nuevo
  --host-label NOMBRE                  Etiqueta visual para un equipo nuevo
  --dry-run                            Sin cambios (predeterminado)
  --apply                              Aplicar despues de revisar el plan
HELP
}

TARGET=auto
while (($#)); do
  case "$1" in
    --target|--mode|--shell|--theme|--host-label)
      (($# >= 2)) || { echo "Falta argumento para $1" >&2; exit 2; }
      case "$1" in
        --target) TARGET="$2";;
        --mode) MODE="$2";;
        --shell) SELECTED_SHELL="$2";;
        --theme) THEME="$2";;
        --host-label) HOST_LABEL="$2";;
      esac
      shift 2;;
    --apply) APPLY=1; shift;;
    --dry-run) APPLY=0; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Opcion desconocida: $1" >&2; usage >&2; exit 2;;
  esac
done

detected_host="$(hostname -s 2>/dev/null || hostname)"
case "${detected_host,,}" in
  infra-core01) guessed_target=infra-core01;;
  thinkpad) guessed_target=thinkpad;;
  *) guessed_target=new;;
esac

if [[ "$TARGET" == auto ]]; then
  if [[ -t 0 && -z "$MODE" ]]; then
    printf '\nEquipo detectado: %s. Configurar como:\n' "$detected_host"
    printf '  1) INFRA-CORE01\n  2) THINKPAD\n  3) Equipo nuevo\n'
    printf 'Elige [1-3] (Enter = %s): ' "$guessed_target"
    IFS= read -r choice
    case "$choice" in
      1) TARGET=infra-core01;;
      2) TARGET=thinkpad;;
      3) TARGET=new;;
      '') TARGET="$guessed_target";;
      *) echo 'Seleccion invalida' >&2; exit 2;;
    esac
  else
    TARGET="$guessed_target"
  fi
fi
case "$TARGET" in infra-core01|thinkpad|new) ;; *) echo "Target invalido: $TARGET" >&2; exit 2;; esac

if [[ -z "$MODE" ]]; then
  if [[ -t 0 ]]; then
    printf '\nQue deseas configurar?\n  1) Starship del equipo\n  2) Perfiles LOCAL/FJK en GNOME Terminal\n  3) Ambos\n'
    printf 'Elige [1-3] (Enter = 3): '
    IFS= read -r choice
    case "$choice" in
      1) MODE=starship;;
      2) MODE=terminal;;
      3|'') MODE=all;;
      *) echo 'Seleccion invalida' >&2; exit 2;;
    esac
  else
    MODE=all
  fi
fi
case "$MODE" in starship|terminal|all) ;; *) echo "Modo invalido: $MODE" >&2; exit 2;; esac

if [[ "$TARGET" == new ]]; then
  if [[ -z "$THEME" ]]; then
    if [[ -t 0 ]]; then
      printf '\nBase visual del equipo nuevo:\n  1) Coral/turquesa (INFRA)\n  2) Azul/cian (THINKPAD)\nElige [1-2] (Enter = 2): '
      IFS= read -r choice
      case "$choice" in 1) THEME=infra-core01;; 2|'') THEME=thinkpad;; *) echo 'Seleccion invalida' >&2; exit 2;; esac
    else
      THEME=thinkpad
    fi
  fi
  if [[ -z "$HOST_LABEL" ]]; then
    HOST_LABEL="$detected_host"
    if [[ -t 0 ]]; then
      printf 'Etiqueta visual para el hostname [%s]: ' "$HOST_LABEL"
      IFS= read -r input
      [[ -z "$input" ]] || HOST_LABEL="$input"
    fi
  fi
else
  THEME="$TARGET"
  if [[ -n "$HOST_LABEL" ]]; then
    echo '--host-label solo es valido para --target new' >&2; exit 2
  fi
fi
case "$THEME" in infra-core01|thinkpad) ;; *) echo "Tema invalido: $THEME" >&2; exit 2;; esac
if [[ -n "$HOST_LABEL" && ! "$HOST_LABEL" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo 'Etiqueta de hostname invalida: admite letras, numeros, punto, guion y guion bajo' >&2; exit 2
fi

if [[ "$SELECTED_SHELL" == auto ]]; then
  login_shell="$(getent passwd "$(id -un)" | awk -F: '{print $7}')"
  login_shell="${login_shell:-${SHELL:-}}"
  case "${login_shell##*/}" in
    bash) SELECTED_SHELL=bash;;
    zsh) SELECTED_SHELL=zsh;;
    *)
      echo "Shell de login no reconocida: $login_shell. Usa --shell bash|zsh" >&2
      exit 2;;
  esac
fi
case "$SELECTED_SHELL" in bash|zsh) ;; *) echo "Shell no soportada: $SELECTED_SHELL" >&2; exit 2;; esac

do_starship=0
do_terminal=0
case "$MODE" in starship) do_starship=1;; terminal) do_terminal=1;; all) do_starship=1; do_terminal=1;; esac

if ((do_starship)); then
  if [[ "$THEME" == thinkpad ]]; then source_theme="$ROOT/starship-thinkpad.toml"; else source_theme="$ROOT/starship.toml"; fi
  [[ -s "$source_theme" ]] || { echo "Falta tema: $source_theme" >&2; exit 1; }
  command -v starship >/dev/null 2>&1 || { echo 'Starship no esta instalado. Instalarlo primero.' >&2; exit 1; }
fi
if ((do_terminal)) && ! command -v gnome-terminal >/dev/null 2>&1; then
  if [[ "$MODE" == terminal ]]; then
    echo 'GNOME Terminal no esta instalado. No se modificara el equipo.' >&2
    exit 1
  fi
  echo 'GNOME Terminal no esta instalado: se omitiran sus perfiles (no se instala automaticamente).'
  do_terminal=0
fi

printf '\n=== PLAN DE INSTALACION ===\n'
printf 'Host real: %s | destino: %s | shell de login: %s\n' "$detected_host" "$TARGET" "$SELECTED_SHELL"
printf 'Modo: %s | aplicacion: %s\n' "$MODE" "$([[ $APPLY == 1 ]] && echo SI || echo NO)"
if ((do_starship)); then
  printf 'Starship: %s -> %s/.config/starship.toml\n' "$source_theme" "$HOME"
  if [[ "$SELECTED_SHELL" == zsh ]]; then rc="$HOME/.zshrc"; else rc="$HOME/.bashrc"; fi
  printf 'Inicializacion: %s\n' "$rc"
fi
if ((do_terminal)); then
  printf 'Perfiles: %s/gnome-terminal/profiles/{local,fjk}.bashrc -> ~/.config/gnome-terminal/profiles/\n' "$ROOT"
  echo 'Perfiles graficos de GNOME Terminal: se conservan; configuracion manual indicada al terminar.'
fi
if (( !APPLY )); then
  echo 'Simulacion completa; ningun archivo modificado. Usa --apply para aplicar.'
  exit 0
fi

if [[ -t 0 ]]; then
  printf 'Confirmar instalacion en ESTE equipo? [s/N]: '
  IFS= read -r confirm
  case "$confirm" in s|S|si|SI|sí|SÍ) ;; *) echo 'Cancelado.'; exit 0;; esac
fi

backup_copy() {
  local path="$1" backup
  if [[ -f "$path" ]]; then
    backup="$path.backup-$(date +%Y%m%d-%H%M%S)-$$"
    cp -p -- "$path" "$backup"
    printf 'Respaldo: %s\n' "$backup"
  fi
}

if ((do_starship)); then
  mkdir -p "$HOME/.config"
  target_file="$HOME/.config/starship.toml"
  backup_copy "$target_file"
  if [[ "$TARGET" == new ]]; then
    # Reemplazo controlado del texto estatico del tema base sin alterar modulos.
    if [[ "$THEME" == thinkpad ]]; then base_label=THINKPAD; else base_label=INFRA-CORE01; fi
    sed "s/\[$base_label\]/[$HOST_LABEL]/g" "$source_theme" > "$target_file"
  else
    cp -- "$source_theme" "$target_file"
  fi
  if [[ "$SELECTED_SHELL" == zsh ]]; then
    init_line='eval "$(starship init zsh)"'
  else
    init_line='eval "$(starship init bash)"'
  fi
  if ! grep -Fqx "$init_line" "$rc" 2>/dev/null; then
    backup_copy "$rc"
    printf '\n# Starship — setup.sh\n%s\n' "$init_line" >> "$rc"
    printf 'Inicializador agregado a %s\n' "$rc"
  else
    printf 'Inicializador ya presente en %s\n' "$rc"
  fi
  printf 'Tema instalado: %s\n' "$THEME"
fi

if ((do_terminal)); then
  bash "$ROOT/gnome-terminal/install.sh" --apply
fi
echo 'Instalacion completada. Abre una terminal nueva para validar.'
