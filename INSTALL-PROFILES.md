# Instalador interactivo por equipo

Ejecuta el instalador **en el equipo que deseas personalizar**. El menú elige un perfil visual, **no** establece una conexión SSH ni instala remotamente en otras máquinas.

## Perfiles

- `infra-core01`: 👽, paleta INFRA, fecha y hora a la derecha.
- `thinkpad`: 💀, paleta azul/cian, hostname THINKPAD, fecha y hora a la derecha.

## Uso

```bash
./install.sh --list
./install.sh --profile infra-core01 --dry-run
./install.sh
```

El menú pide elegir uno de los equipos y confirmar antes de aplicar el perfil. También acepta `--profile infra-core01` o `--profile thinkpad`.

Se requiere Starship instalado. Si existe configuración previa, se respalda en `~/.config/starship.toml.backup-YYYYMMDD-HHMMSS`. Escribe el perfil elegido a `~/.config/starship.toml`, añade inicialización Starship a `~/.bashrc` si no estaba y, **solo si existe** `bash/load.sh` en el checkout, registra el cargador de aliases. No realiza cambios remotos.

## Revertir

```bash
cp ~/.config/starship.toml.backup-AAAAMMDD-HHMMSS ~/.config/starship.toml
exec bash
```

Si se añadió una línea de carga a `~/.bashrc`, puedes retirarla manualmente. **No ejecutes la instalación con sudo**, porque personaliza la sesión del usuario actual.

## Dependencias entre PR

Este desarrollo parte del branch de perfiles del PR #1. Los aliases del PR #2 están en otro branch y, por tanto, no se instalan en esta versión hasta que se integren al branch final.
