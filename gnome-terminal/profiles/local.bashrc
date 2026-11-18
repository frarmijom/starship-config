# Bash interactivo del perfil LOCAL de GNOME Terminal.
if [[ -r "$HOME/.bashrc" ]]; then
    source "$HOME/.bashrc"
fi

unset FJK_DOMAIN GIT_CONFIG_GLOBAL
export WORK_ENV="local"
export PROJECTS_HOME="$HOME/Projects"
