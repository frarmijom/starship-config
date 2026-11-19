#!/usr/bin/env bash
# Pruebas locales sin modificar la configuracion del usuario.
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
on_error() {
  local status="$?" line="${BASH_LINENO[0]:-unknown}"
  printf '\nERROR: setup-smoke.sh fallo en linea %s (exit %s).\n' "$line" "$status" >&2
  for log in "$TMP"/*.log; do
    [[ -f "$log" ]] || continue
    printf '\n=== %s ===\n' "${log##*/}" >&2
    cat "$log" >&2
  done
  exit "$status"
}
trap on_error ERR
trap 'rm -rf -- "$TMP"' EXIT

mkdir -p "$TMP/bin" "$TMP/home-infra" "$TMP/home-new" "$TMP/home-thinkpad"
printf '#!/bin/sh\nexit 0\n' > "$TMP/bin/starship"
printf '#!/bin/sh\nexit 0\n' > "$TMP/bin/gnome-terminal"
chmod +x "$TMP/bin/starship" "$TMP/bin/gnome-terminal"
export PATH="$TMP/bin:$PATH"
# Nunca usar el D-Bus real durante tests: evita cambios en perfiles del usuario.
export DBUS_SESSION_BUS_ADDRESS=""
mkdir -p "$TMP/home-infra/.local/libexec"
printf '#!/bin/sh\nexit 0\n' > "$TMP/home-infra/.local/libexec/git-credential-libsecret"
chmod +x "$TMP/home-infra/.local/libexec/git-credential-libsecret"

bash -n "$ROOT/setup.sh"
bash -n "$ROOT/gnome-terminal/install.sh"
bash -n "$ROOT/gnome-terminal/configure-profiles.sh"
bash -n "$ROOT/git/bootstrap-fjk.sh"
bash -n "$ROOT/gnome-terminal/profiles/local.bashrc"
bash -n "$ROOT/gnome-terminal/profiles/fjk.bashrc"

# Sin --apply, la simulacion no debe escribir en HOME.
HOME="$TMP/home-thinkpad" bash "$ROOT/setup.sh" --target thinkpad --shell bash --mode all --dry-run > "$TMP/dry-run.log"
test ! -e "$TMP/home-thinkpad/.config"
test ! -e "$TMP/home-thinkpad/.bashrc"

# INFRA-CORE01: Zsh y configuracion completa sin tocar el usuario real.
HOME="$TMP/home-infra" bash "$ROOT/setup.sh" --target infra-core01 --shell zsh --mode all --apply > "$TMP/infra.log"
test -f "$TMP/home-infra/.config/starship.toml"
test -f "$TMP/home-infra/.config/gnome-terminal/profiles/fjk.bashrc"
test -f "$TMP/home-infra/.config/git/fjk.gitconfig"
grep -Fq "git-credential-libsecret" "$TMP/home-infra/.config/git/fjk.gitconfig"
grep -Fqx 'eval "$(starship init zsh)"' "$TMP/home-infra/.zshrc"
grep -Fq '${custom.work_env}' "$TMP/home-infra/.config/starship.toml"
test ! -f "$TMP/home-infra/.bashrc"

# Re-ejecutar no duplica el inicializador Starship.
HOME="$TMP/home-infra" bash "$ROOT/setup.sh" --target infra-core01 --shell zsh --mode all --apply > "$TMP/infra-second.log"
test "$(grep -Fxc 'eval "$(starship init zsh)"' "$TMP/home-infra/.zshrc")" -eq 1

# Equipo nuevo: la etiqueta visual reemplaza el nombre del equipo base.
HOME="$TMP/home-new" bash "$ROOT/setup.sh" --target new --theme thinkpad --host-label LAB-01 --shell bash --mode starship --apply > "$TMP/new.log"
grep -Fq '[LAB-01]' "$TMP/home-new/.config/starship.toml"
grep -Fqx 'eval "$(starship init bash)"' "$TMP/home-new/.bashrc"

echo 'OK: sintaxis, dry-run, INFRA Zsh, Git FJK, idempotencia y equipo nuevo Bash (sin D-Bus real).'
