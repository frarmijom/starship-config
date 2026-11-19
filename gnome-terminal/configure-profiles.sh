#!/usr/bin/env bash
# Configura perfiles GNOME Terminal sin modificar otros perfiles.
set -euo pipefail
MODE="${1:---dry-run}"
[[ "$MODE" == --dry-run || "$MODE" == --apply ]] || { echo "Uso: $0 [--dry-run|--apply]" >&2; exit 2; }

if ! command -v gsettings >/dev/null 2>&1; then
  echo 'Sin gsettings: no es posible configurar perfiles graficos.'
  exit 0
fi
if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
  echo 'Sin sesion D-Bus de usuario: se omiten los perfiles graficos.'
  exit 0
fi
SCHEMA_LIST=org.gnome.Terminal.ProfilesList
SCHEMA_PROFILE=org.gnome.Terminal.Legacy.Profile
if ! current="$(gsettings get "$SCHEMA_LIST" list 2>/dev/null)"; then
  echo 'No se puede consultar GNOME Terminal: se omiten perfiles graficos.'
  exit 0
fi
mapfile -t ids < <(printf '%s\n' "$current" | grep -oE '[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}' || true)
schema_for() { printf '%s:/org/gnome/terminal/legacy/profiles:/: %s' "$SCHEMA_PROFILE" "$1"; }
find_named() {
  local candidate schema
  for candidate in "${ids[@]}"; do
    schema="$SCHEMA_PROFILE:/org/gnome/terminal/legacy/profiles:/:$candidate/"
    if [[ "$(gsettings get "$schema" visible-name 2>/dev/null)" == "'$1'" ]]; then
      printf '%s' "$candidate"
      return 0
    fi
  done
  return 1
}
for label in LOCAL FJK; do
  if uuid="$(find_named "$label")"; then
    printf '%s: existente (%s)\n' "$label" "$uuid"
  else
    printf '%s: se creara\n' "$label"
  fi
done
if [[ "$MODE" == --dry-run ]]; then
  echo 'Simulacion: perfiles graficos sin cambios.'
  exit 0
fi
# El respaldo se toma antes de actualizar comandos o colores.
command -v dconf >/dev/null 2>&1 || { echo 'Falta dconf: no se tocaran perfiles graficos.' >&2; exit 1; }
backup_dir="$HOME/.config/gnome-terminal/backups"
mkdir -p "$backup_dir"
backup="$backup_dir/profiles-$(date +%Y%m%d-%H%M%S)-$$.dconf"
dconf dump /org/gnome/terminal/legacy/profiles:/ > "$backup"
printf 'Respaldo perfiles graficos: %s\n' "$backup"

for label in LOCAL FJK; do
  key="${label,,}"
  command_string="/bin/bash --rcfile $HOME/.config/gnome-terminal/profiles/$key.bashrc -i"
  created=0
  if ! uuid="$(find_named "$label")"; then
    if command -v uuidgen >/dev/null 2>&1; then
      uuid="$(uuidgen | tr '[:upper:]' '[:lower:]')"
    else
      uuid="$(cat /proc/sys/kernel/random/uuid)"
    fi
    created=1
  fi
  schema="$SCHEMA_PROFILE:/org/gnome/terminal/legacy/profiles:/:$uuid/"
  gsettings set "$schema" visible-name "$label"
  gsettings set "$schema" use-custom-command true
  gsettings set "$schema" custom-command "$command_string"
  gsettings set "$schema" login-shell false
  if ((created)); then
    gsettings set "$schema" use-theme-colors false
    if [[ "$label" == LOCAL ]]; then
      gsettings set "$schema" background-color 'rgb(30,30,46)'
      gsettings set "$schema" foreground-color 'rgb(205,214,244)'
    else
      gsettings set "$schema" background-color 'rgb(253,246,227)'
      gsettings set "$schema" foreground-color 'rgb(101,123,131)'
    fi
    ids+=("$uuid")
    # Construir la lista GVariant sin alterar orden, perfil default ni IDs existentes.
    variant='['
    for item in "${ids[@]}"; do
      [[ "$variant" == '[' ]] || variant+=', '
      variant+="'$item'"
    done
    variant+=']'
    gsettings set "$SCHEMA_LIST" list "$variant"
    printf '%s: creado (%s)\n' "$label" "$uuid"
  else
    printf '%s: reutilizado y comando actualizado (%s)\n' "$label" "$uuid"
  fi
done
echo 'Perfiles listos. Abre pestañas nuevas para validar WORK_ENV.'
