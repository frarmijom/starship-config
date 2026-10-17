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

El programa lista los equipos considerados y permite elegir la configuración **del equipo local**, no de uno remoto. Para probar esta versión sin tocar `main`:

```bash
git clone --depth 1 --branch feature/interactive-host-installer \
  https://github.com/frarmijom/starship-config.git /tmp/starship-installer-pr3
cd /tmp/starship-installer-pr3
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

## Comandos cortos Bash (PR independiente)

El [PR #2](https://github.com/frarmijom/starship-config/pull/2) incorpora módulos opcionales y separados de Starship:

| Grupo | Ejemplos | Archivo |
|---|---|---|
| Navegación y sistema | `ll`, `la`, `..`, `ports`, `mem` | `bash/aliases-common.sh` |
| Git | `gs`, `gd`, `gl`, `gf`, `groot` | `bash/aliases-git.sh` |
| Docker | `dps`, `dlog`, `dc`, `dcl` | `bash/aliases-docker.sh` |
| Funciones | `ff`, `ft`, `psg`, `helpme` | `bash/functions.sh` |

**Estos archivos todavía no están presentes en el branch del instalador.** El instalador solamente registra su cargador cuando encuentra `bash/load.sh`; por eso, en la prueba actual **no instala aliases**. `ft` requiere `ripgrep`. Evita ejecutar `dcd` o `gpr` a modo de prueba porque realizan cambios efectivos.

## Estructura actual en el branch del instalador

```text
starship-config/
├── starship.toml            # 👽 INFRA-CORE01
├── starship-thinkpad.toml   # 💀 ThinkPad
├── install.sh               # selector interactivo
├── INSTALL-PROFILES.md
└── README.md
```

## Recuperación

El instalador deja una copia con nombre semejante a:

```text
~/.config/starship.toml.backup-20261017-110338
```

Para recuperar una versión, selecciona un respaldo correcto y cópialo sobre `~/.config/starship.toml`, después ejecuta `exec bash`. La carga de aliases, si se hubiera añadido a `~/.bashrc`, se desactiva retirando su línea de carga.

## Estado del trabajo — 17 de octubre de 2026

| PR | Alcance | Situación |
|---|---|---|
| [#1](https://github.com/frarmijom/starship-config/pull/1) | Perfiles, reloj, identidades y colores | Probados visualmente en ThinkPad e INFRA-CORE01; pendiente de merge |
| [#2](https://github.com/frarmijom/starship-config/pull/2) | Aliases y funciones Bash | Publicado, pendiente de validación en terminal |
| [#3](https://github.com/frarmijom/starship-config/pull/3) | Selector interactivo y backups | Basado en branch del PR #1; pendiente de validación del instalador |

**No se ha fusionado ningún PR a `main`.** Para consolidar todo, primero validar `bash -n`, selección de perfiles y aliases; después integrar los PR en orden, comprobando que los perfiles del instalador sigan actualizados.
