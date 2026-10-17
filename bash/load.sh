# Cargar explícitamente desde ~/.bashrc:
# [ -r "$HOME/Projects/starship-config/bash/load.sh" ] && source "$HOME/Projects/starship-config/bash/load.sh"
# No altera archivos del sistema ni la configuración de Starship.
if [[ -n ${BASH_VERSION:-} ]]; then
    _terminal_alias_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    for _terminal_alias_file in aliases-common.sh aliases-git.sh aliases-docker.sh functions.sh; do
        source "$_terminal_alias_dir/$_terminal_alias_file"
    done
    unset _terminal_alias_dir _terminal_alias_file
fi
