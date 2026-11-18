# Bash interactivo del perfil FJK de GNOME Terminal.
# GNOME Terminal: ejecutar /bin/bash --rcfile /home/farmijo/.config/gnome-terminal/profiles/fjk.bashrc -i
if [[ -r "$HOME/.bashrc" ]]; then
    source "$HOME/.bashrc"
fi

export WORK_ENV="fjk"
export PROJECTS_HOME="/almacenamiento/Projects"
export FJK_DOMAIN="fjk.internal"
export GIT_CONFIG_GLOBAL="$HOME/.config/git/fjk.gitconfig"
