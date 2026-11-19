#!/usr/bin/env bash
# Prepara Git FJK sin guardar credenciales ni alterar la configuracion LOCAL.
set -euo pipefail
MODE="${1:---dry-run}"
[[ "$MODE" == --dry-run || "$MODE" == --apply ]] || { echo "Uso: $0 [--dry-run|--apply]" >&2; exit 2; }
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
dest="$HOME/.config/git/fjk.gitconfig"
template="$ROOT/git/fjk.gitconfig.example"
[[ -f "$template" ]] || { echo "Falta plantilla FJK." >&2; exit 1; }
helper=''
for candidate in "$HOME/.local/libexec/git-credential-libsecret" /usr/lib/git-core/git-credential-libsecret /usr/libexec/git-core/git-credential-libsecret; do
  if [[ -x "$candidate" ]]; then helper="$candidate"; break; fi
done
if [[ -z "$helper" ]] && command -v git-credential-libsecret >/dev/null 2>&1; then
  helper="$(command -v git-credential-libsecret)"
fi
if [[ -z "$helper" ]]; then
  src=/usr/share/doc/git/contrib/credential/libsecret
  if [[ -f "$src/Makefile" && -f "$src/git-credential-libsecret.c" ]] &&
     command -v make >/dev/null && command -v pkg-config >/dev/null &&
     pkg-config --exists libsecret-1 && command -v cc >/dev/null; then
    helper="$HOME/.local/libexec/git-credential-libsecret"
    if [[ "$MODE" == --apply ]]; then
      tmp="$(mktemp -d)"
      trap 'rm -rf -- "$tmp"' EXIT
      cp "$src/Makefile" "$src/git-credential-libsecret.c" "$tmp/"
      make -C "$tmp"
      mkdir -p "$HOME/.local/libexec"
      install -m 755 "$tmp/git-credential-libsecret" "$helper"
      echo "Helper libsecret compilado e instalado."
    else
      echo "Helper libsecret: compilacion local disponible."
    fi
  fi
fi
if [[ "$MODE" == --dry-run ]]; then
  [[ -f "$dest" ]] && echo "Git FJK: se preservara $dest" || echo "Git FJK: se creara $dest"
  [[ -n "$helper" ]] && echo "Helper disponible/preparable: $helper" || echo 'Helper libsecret no disponible; no se instalara automaticamente ningun paquete.'
  exit 0
fi
mkdir -p "$(dirname -- "$dest")"
if [[ ! -e "$dest" ]]; then
  install -m 600 "$template" "$dest"
  echo "Creado: $dest"
else
  echo "Conservado: $dest"
fi
if [[ -n "$helper" && -x "$helper" ]]; then
  current="$(git config --file "$dest" --get 'credential.https://git.fjk.internal.helper' || true)"
  if [[ -z "$current" ]]; then
    git config --file "$dest" 'credential.https://git.fjk.internal.helper' "$helper"
    echo 'Helper Forgejo configurado solo en FJK.'
  else
    echo 'Helper Forgejo existente conservado.'
  fi
else
  echo 'AVISO: falta helper libsecret. Si no hay compilador/dependencias, instalar build-essential libsecret-1-dev pkg-config y repetir.'
fi
email="$(GIT_CONFIG_GLOBAL="$dest" git config --global --get user.email || true)"
if [[ -z "$email" || "$email" == *example.com* ]]; then
  echo 'AVISO: la identidad user.email de FJK falta o contiene un valor de ejemplo; configúrala antes de hacer commits.'
fi
echo 'Git FJK preparado. Las credenciales se introducen solo al autenticar con Forgejo.'
