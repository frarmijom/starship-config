# Starship Config — perfiles de terminal Debian

Configuraciones para **INFRA-CORE01** y **ThinkPad**. Bash + Starship, prompt de dos líneas, contexto Git y reloj local alineado a la derecha.

## Perfiles existentes

| Equipo | Archivo | Identidad | Paleta | Hostname mostrado |
|---|---|---|---|---|
| INFRA-CORE01 | `starship.toml` | 👽 | Coral / turquesa | `INFRA-CORE01` |
| ThinkPad | `starship-thinkpad.toml` | 💀 | Azul / cian | `THINKPAD` |

La configuración de cada equipo se mantiene independiente. Ambos perfiles utilizan `$fill` para alinear `$time` a la derecha y conservan `$line_break` para la línea de entrada `❯`. El reloj se calcula cuando se dibuja el prompt (normalmente tras finalizar el comando anterior): **no es el registro preciso del inicio del comando**.

Los nombres en mayúsculas son etiquetas visuales estáticas de cada perfil; no renombran el hostname Linux.

## Instalación interactiva por equipo

El programa lista los equipos considerados y permite elegir la configuración **del equipo local**, no de uno remoto. Para instalar desde `main` en una ubicación permanente:

```bash
git clone https://github.com/frarmijom/starship-config.git "$HOME/Projects/starship-config"
cd "$HOME/Projects/starship-config"
bash -n install.sh
./install.sh --list
./install.sh --profile infra-core01 --dry-run
```

Para aplicar el perfil correcto en el equipo en el que estás conectado:

```bash
./install.sh
exec bash
```

Se requiere Starship previamente instalado. El instalador solicita confirmación, crea un respaldo con timestamp de `~/.config/starship.toml` y conserva el inicializador de Starship en `~/.bashrc` sin añadir la misma línea dos veces. No uses `sudo`. Consulta [INSTALL-PROFILES.md](INSTALL-PROFILES.md).

**Advertencia:** el instalador actúa sobre el usuario y equipo local. Seleccionar otro perfil cambiará los colores/identidad visual de la sesión actual; no configura ese otro equipo a través de SSH.

## Comandos cortos Bash (incluidos)

Los aliases del [PR #2](https://github.com/frarmijom/starship-config/pull/2), ahora integrados en `main`, se mantienen separados de los temas de Starship:

| Grupo | Ejemplos | Archivo |
|---|---|---|
| Navegación y sistema | `ll`, `la`, `..`, `ports`, `mem` | `bash/aliases-common.sh` |
| Git | `gs`, `gd`, `gl`, `gf`, `groot` | `bash/aliases-git.sh` |
| Docker | `dps`, `dlog`, `dc`, `dcl` | `bash/aliases-docker.sh` |
| Funciones | `ff`, `ft`, `psg`, `helpme` | `bash/functions.sh` |

El instalador registra el cargador de aliases cuando encuentra `bash/load.sh`, incluido en `main`. **Instala desde una ruta permanente:** `.bashrc` hace referencia a esa ubicación. `ft` requiere `ripgrep`. Evita ejecutar `dcd` o `gpr` a modo de prueba porque realizan cambios efectivos.

## Estructura del repositorio

```text
starship-config/
├── starship.toml            # 👽 INFRA-CORE01
├── starship-thinkpad.toml   # 💀 ThinkPad
├── install.sh               # selector interactivo
├── INSTALL-PROFILES.md
├── bash/
│   ├── aliases-common.sh
│   ├── aliases-git.sh
│   ├── aliases-docker.sh
│   ├── functions.sh
│   ├── load.sh
│   └── README.md
└── README.md
```

## Recuperación

El instalador deja una copia con nombre semejante a:

```text
~/.config/starship.toml.backup-20261017-110338
```

Para recuperar una versión, selecciona un respaldo correcto y cópialo sobre `~/.config/starship.toml`, después ejecuta `exec bash`. La carga de aliases, si se hubiera añadido a `~/.bashrc`, se desactiva retirando su línea de carga.

## Historial de integración — 17 de octubre de 2026

| PR | Alcance | Situación |
|---|---|---|
| [#1](https://github.com/frarmijom/starship-config/pull/1) | Perfiles, reloj, identidades y colores | Fusionado a `main` |
| [#2](https://github.com/frarmijom/starship-config/pull/2) | Aliases y funciones Bash | Fusionado a `main`; pruebas funcionales en equipos pendientes |
| [#3](https://github.com/frarmijom/starship-config/pull/3) | Selector interactivo y backups | Fusionado a `main`; pruebas interactivas pendientes |

**Los PR #1, #2 y #3 están fusionados en `main`.** La prueba visual de ambos perfiles está realizada; faltan pruebas completas del instalador y de los aliases en los equipos. No ejecutar una instalación desde `/tmp`, porque la carga de aliases dependería de un directorio temporal.
