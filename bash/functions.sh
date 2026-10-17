# Funciones para argumentos, con comprobaciones básicas.
ff() {
    if [[ $# -ne 1 || -z $1 ]]; then
        printf 'Uso: ff <parte-del-nombre>\n' >&2
        return 2
    fi
    find . -type f -iname "*$1*"
}

ft() {
    if [[ $# -ne 1 || -z $1 ]]; then
        printf 'Uso: ft <texto> (requiere rg/ripgrep)\n' >&2
        return 2
    fi
    if ! command -v rg >/dev/null 2>&1; then
        printf 'ft requiere ripgrep: sudo apt install ripgrep\n' >&2
        return 127
    fi
    rg -n -- "$1" .
}

psg() {
    if [[ $# -ne 1 || -z $1 ]]; then
        printf 'Uso: psg <texto>\n' >&2
        return 2
    fi
    ps aux | grep -iF -- "$1" | grep -v 'grep -iF'
}

groot() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null) || {
        printf 'No estás dentro de un repositorio Git\n' >&2
        return 1
    }
    cd -- "$root" || return
}

jlog() {
    if [[ $# -ne 1 || -z $1 ]]; then
        printf 'Uso: jlog <servicio-systemd>\n' >&2
        return 2
    fi
    journalctl -u "$1" -n 100 -f
}

helpme() {
    cat <<'HELP'
Comunes: ll la l .. ... c h ports listen myip dfh duh mem
Git:     gs gb ga gd gds gl gf gpr gsh groot
Docker:  dps dpa di dst dlog dex dc dcu dcd dcl
Buscar:  ff <nombre> | ft <texto> | psg <texto>
Logs:    jlog <servicio>
Inspección: alias <nombre> | type <nombre>
Aviso: dcd detiene y elimina contenedores/redes del proyecto Compose;
       gpr puede reescribir commits locales. Revisa antes de ejecutarlos.
HELP
}
