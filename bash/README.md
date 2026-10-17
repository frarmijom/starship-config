# Atajos Bash (ThinkPad e INFRA-CORE01)

Independientes del tema Starship. No se ejecutan acciones Git, Docker o del sistema al cargar los archivos; solo se registran aliases y funciones.

## Prueba en una sesión sin modificar ~/.bashrc

Desde el directorio raíz del repositorio:

```bash
for f in bash/*.sh; do bash -n "$f" || exit 1; done
source bash/load.sh
helpme
type ll gs dps ff groot
```

No ejecutes `dcd` ni `gpr` solo para probarlos: tienen efectos reales.

## Instalación persistente

Tras aprobar la prueba, agrega **una única vez** a `~/.bashrc` (ajusta la ruta a tu clon local):

```bash
[ -r "$HOME/Projects/starship-config/bash/load.sh" ] && source "$HOME/Projects/starship-config/bash/load.sh"
```

Reabre Bash con `exec bash`. No es necesario ejecutar `install.sh`, que instala el tema INFRA de Starship.

## Reversión

Quita la línea de carga de `~/.bashrc` y abre una nueva sesión Bash. Ninguno de los atajos cambia configuraciones globales por sí mismo.

## Consideraciones

- `ft` necesita `ripgrep` (`sudo apt install ripgrep`).
- `gpr` ejecuta `git pull --rebase`: utilízalo solo tras revisar el estado Git.
- `dcd` ejecuta `docker compose down`: puede detener servicios y retirar redes/contendores del stack, pero no elimina volúmenes por defecto.
- `ll`, `la`, `..`, etc. pueden sobreescribir aliases definidos previamente en una sesión que cargue este paquete.
- Los scripts están destinados a Bash.
