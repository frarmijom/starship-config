# Perfiles LOCAL y FJK — GNOME Terminal (transversal)

Esta configuración reproduce los perfiles que se validaron el **18-11-2026** en Debian 13 con GNOME Terminal 3.56.2, Bash y Starship. No cambia la shell del equipo, no configura otros hosts por SSH y no guarda claves ni tokens.

| Perfil | `WORK_ENV` | `PROJECTS_HOME` | Configuración Git | Apariencia sugerida |
|---|---|---|---|---|
| LOCAL | `local` | `$HOME/Projects` | Git global normal `~/.gitconfig` | Fondo oscuro |
| FJK | `fjk` | `/almacenamiento/Projects` | `~/.config/git/fjk.gitconfig` | **FJK Deep Teal (Custom)** |

## Instalacion completa desde el menu

```bash
bash setup.sh --mode terminal --dry-run
bash setup.sh --mode terminal --apply
```

El instalador copia los archivos Bash, crea `~/.config/git/fjk.gitconfig` si falta, prepara el helper libsecret si esta disponible o compilable sin instalar paquetes, y configura perfiles graficos `LOCAL` y `FJK` por nombre. Conserva los demas perfiles, su perfil predeterminado y sus colores. Hace un respaldo `dconf` antes de escribir los ajustes graficos. Los perfiles FJK nuevos reciben el esquema Custom **FJK Deep Teal** con fondo `rgb(7,59,76)`, texto `rgb(220,239,239)` y paleta ANSI de 16 colores. Los perfiles FJK existentes conservan su paleta personalizada; LOCAL mantiene sus propios colores. Si no hay sesion D-Bus, omite la configuracion grafica y permite terminar la parte de archivos.

La identidad Git del usuario no se inventa: si falta o es un correo de ejemplo, se advierte para configurarla. Los secretos solo se introducen al autenticar con Forgejo, nunca se guardan en el repositorio.

## Instalar solamente archivos Bash (opcion anterior)

Desde la raíz del repositorio, sin `sudo`:

```bash
bash gnome-terminal/install.sh --dry-run
bash gnome-terminal/install.sh --apply
```

Este instalador auxiliar solo respalda y copia archivos; el punto de entrada recomendado para realizar todo el proceso es `setup.sh`. No toca `~/.bashrc`, `~/.gitconfig` ni el llavero.

## Configurar perfiles gráficos existentes

En **GNOME Terminal → Preferencias**, editar o crear `LOCAL` y `FJK`. En cada uno activar **Run a custom command instead of my shell** y dejar desactivado **Run command as a login shell**.

FJK, comando personalizado:

```text
/bin/bash --rcfile /home/farmijo/.config/gnome-terminal/profiles/fjk.bashrc -i
```

LOCAL, comando personalizado:

```text
/bin/bash --rcfile /home/farmijo/.config/gnome-terminal/profiles/local.bashrc -i
```

**Ajustar `/home/farmijo` si se instala con otro usuario.** Se pueden seleccionar los colores en la configuración visual de cada perfil. Abrir sesiones nuevas explícitamente con `gnome-terminal --profile=FJK` y `gnome-terminal --profile=LOCAL`, o desde el menú de perfiles. Cambiar el perfil visual de un Bash ya iniciado **no** actualiza sus variables.

## Configuración Git y autenticación Forgejo

La variable `GIT_CONFIG_GLOBAL` de FJK selecciona otro archivo; no obliga a usar Forgejo si el remoto de un repositorio apunta a otro servidor. Crea `~/.config/git/fjk.gitconfig` a partir de `git/fjk.gitconfig.example` **solo si aún no existe**:

```bash
mkdir -p ~/.config/git
[ -e ~/.config/git/fjk.gitconfig ] || cp git/fjk.gitconfig.example ~/.config/git/fjk.gitconfig
```

El helper `git-credential-libsecret` debe existir en este equipo y GNOME Keyring debe estar disponible. En el perfil FJK, configurar la ruta real del helper sin guardar secretos en el repositorio:

```bash
git config --file "$GIT_CONFIG_GLOBAL" \
  'credential.https://git.fjk.internal.helper' \
  "$HOME/.local/libexec/git-credential-libsecret"
```

Validación de solo lectura:

```bash
printf 'Entorno=%s\nGit=%s\n' "$WORK_ENV" "$GIT_CONFIG_GLOBAL"
GIT_TERMINAL_PROMPT=0 git ls-remote \
  https://git.fjk.internal/hrw/fjk-platform-jenkins.git HEAD
```

La autenticación HTTPS se almacenó y validó mediante libsecret/GNOME Keyring. No incluir contraseña, token, `~/.ssh`, bases de datos del llavero ni `~/.config/git/fjk.gitconfig` real en el repositorio. GitHub LOCAL sigue con su configuración habitual.

## Starship

El archivo `starship-thinkpad.toml` incluye `${custom.work_env}`, que dibuja `[LOCAL]` o `[FJK]` después del hostname y conserva fecha, hora, rama Git y los otros módulos. Si `WORK_ENV` no existe (p. ej., sesión SSH sin perfil), no se muestra indicador.

## Directorios de proyectos

`PROJECTS_HOME` es una **variable**, no cambia automáticamente el directorio de inicio. En FJK, `/almacenamiento` corresponde a la unidad central SMB mediante systemd automount; verificar que esté disponible antes de escribir. No se crean directorios ni se migran repositorios existentes automáticamente.
