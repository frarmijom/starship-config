# Starship — INFRA-CORE01 y ThinkPad

Configuraciones personalizadas de Starship para Bash, diseñada para proporcionar contexto útil de sistema y Git sin consumir espacio innecesario en la línea de comandos.

## Perfiles

- `starship.toml`: INFRA-CORE01, identidad 👽 y paleta original.
- `starship-thinkpad.toml`: ThinkPad, identidad 💀, hostname `THINKPAD` y paleta azul/cian original.

Ambos perfiles muestran fecha y hora local alineadas a la derecha usando `$fill` y `$time`. La hora corresponde a la presentación del prompt, no al inicio exacto del comando.

**Importante:** `install.sh` instala por defecto el perfil INFRA; no lo uses para aplicar el perfil ThinkPad.

Para probar el perfil ThinkPad sin modificar `main`:

```bash
curl -fLsS https://raw.githubusercontent.com/frarmijom/starship-config/feature/starship-prompt-date-time/starship-thinkpad.toml -o /tmp/starship-thinkpad-pr1.toml
STARSHIP_CONFIG=/tmp/starship-thinkpad-pr1.toml starship explain
cp ~/.config/starship.toml ~/.config/starship.toml.backup-$(date +%Y%m%d-%H%M%S)
cp /tmp/starship-thinkpad-pr1.toml ~/.config/starship.toml
exec bash
```

## Vista del prompt

```text
👽 [farmijo:infra-core01] heater-repair-workshop-frontend  feature/hito-03-ui-design !?                      🕒 2026-10-17 10:44:35
❯
```

La primera línea entrega el contexto de la sesión y del repositorio.  
La fecha y hora se alinean al borde derecho de la primera línea mediante el módulo `fill`, independientemente de la longitud del directorio. En terminales muy estrechas el resultado puede ajustarse según el espacio disponible.  
La segunda línea queda libre para escribir comandos.

## Estructura

```text
👽 [farmijo:infra-core01] heater-repair-workshop-frontend  feature/hito-03-ui-design !?
    └── user : host ──┘    └──── repository ─────────┘   └──── branch ──────────┘
```

El prompt muestra:

- usuario actual;
- hostname;
- directorio o repositorio actual;
- branch Git activa;
- estado del repositorio;
- resultado del último comando;
- fecha y hora local al mostrarse el prompt (normalmente al finalizar el comando anterior).

El usuario y el hostname son obtenidos dinámicamente por Starship, por lo que la configuración puede reutilizarse en distintos equipos.

Por ejemplo:

```text
👽 [farmijo:infra-core01] ...
```

En otro host:

```text
💀 [farmijo:THINKPAD] ...
```

## Paleta

| Elemento | Color | Hex |
|---|---|---|
| Usuario | Coral eléctrico | `#FF6B6B` |
| Host | Lavanda digital | `#C792EA` |
| Repositorio | Turquesa neón | `#2DE2E6` |
| Branch Git | Ámbar solar | `#FFD166` |
| Estado Git | Naranja | `#FF9F43` |
| Prompt OK | Verde | `#7DFF8A` |
| Prompt error | Rojo | `#FF5370` |
| Estructura | Gris frío | `#7F849C` |

Verde y rojo se reservan para indicar el resultado del último comando.

## Instalación

### Requisitos

- Linux
- Bash
- Git
- curl

Clonar el repositorio:

```bash
git clone <URL-DEL-REPOSITORIO>
cd infra-starship
```

Ejecutar:

```bash
./install.sh
```

Recargar Bash:

```bash
source ~/.bashrc
```

## Instalación automática

`install.sh` realiza las siguientes tareas:

1. Comprueba si Starship está instalado.
2. Instala Starship si es necesario.
3. Crea `~/.config` si no existe.
4. Respalda cualquier configuración existente de Starship.
5. Instala `starship.toml`.
6. Configura Starship en `.bashrc` si todavía no está configurado.

## Estructura del proyecto

```text
infra-starship/
├── .gitignore
├── README.md
├── install.sh
├── starship-thinkpad.toml
└── starship.toml
```

`starship.toml` contiene la configuración visual del prompt.

`install.sh` permite desplegarla de forma consistente en otros equipos.

## Archivo instalado

La configuración se instala en:

```text
~/.config/starship.toml
```

Si ya existe una configuración, el instalador crea primero un backup con timestamp.

## Actualización

Para obtener una versión nueva de la configuración:

```bash
cd infra-starship
git pull
./install.sh
source ~/.bashrc
```

## Diseño

El prompt está pensado alrededor de cuatro contextos visuales:

**Identidad**

```text
👽 [farmijo:infra-core01]
```

**Proyecto**

```text
heater-repair-workshop-frontend
```

**Git**

```text
 feature/hito-03-ui-design !?
```

**Entrada**

```text
❯
```

El objetivo es mantener visible la información operacional relevante sin sacrificar espacio horizontal para los comandos.
