# Mapeo y Arquitectura de Paquetes

Este directorio gestiona la lista oficial de paquetes requeridos por **Autobspwm** para distribuciones basadas en **Debian (Parrot Security OS / Kali Linux)** y **Arch Linux** (EndeavourOS, BlackArch, Manjaro).

---

## Estructura de Archivos

- `apt.txt`: Lista oficial de dependencias para el gestor de paquetes APT (Debian, Parrot, Kali).
- `pacman.txt`: Lista oficial de dependencias nativas para el gestor de paquetes Pacman (Arch Linux).
- `aur.txt`: Paquetes alojados en el repositorio de usuarios de Arch (AUR), instalables mediante `yay` o `paru`.
- `manual.txt`: Registro de componentes con mecanismos de despliegue autónomos o reglas de exclusión.
- `optional.txt`: Paquetes y perfiles secundarios que no son obligatorios para el entorno base.

---

## Tabla de Equivalencias de Paquetes

| Componente / Función | Debian / Parrot / Kali (APT) | Arch Linux (Pacman) | Arch User Repository (AUR) |
| :--- | :--- | :--- | :--- |
| **Window Manager** | `bspwm` | `bspwm` | - |
| **Gestor de atajos** | `sxhkd` | `sxhkd` | - |
| **Barra de estado** | `polybar` | `polybar` | - |
| **Compositor X11** | `picom` | `picom` | - |
| **Lanzador de apps** | `rofi` | `rofi` | - |
| **Terminal principal** | `kitty` | `kitty` | - |
| **Fondo de pantalla** | `feh` | `feh` | - |
| **Shell** | `zsh` | `zsh` | - |
| **Ajustes X11/GTK** | `xsettingsd` | `xsettingsd` | - |
| **Selector de temas** | `lxappearance` | `lxappearance` | - |
| **Explorador archivos** | `caja` | `caja` | - |
| **Notificaciones** | `dunst`, `libnotify-bin` | `dunst`, `libnotify` | - |
| **Control de volumen** | `pamixer` | `pamixer` | - |
| **Control de brillo** | `brightnessctl` | `brightnessctl` | - |
| **Control de audio GUI**| `pavucontrol` | `pavucontrol` | - |
| **Servidor de sonido** | `pipewire` | `pipewire`, `pipewire-pulse` | - |
| **Captura de pantalla** | `flameshot` | `flameshot` | - |
| **Bloqueador pantalla** | `i3lock-fancy` | `i3lock`, `imagemagick` | `i3lock-fancy-git` *(o fallback directo)* |
| **Gestor de energía** | `mate-power-manager` | `mate-power-manager` | - |
| **Cat moderno (syntax)**| `bat` *(binario `batcat`)* | `bat` *(binario `bat`)* | - |
| **Listado moderno** | `lsd` | `lsd` | - |
| **Portapapeles X11** | `xclip` | `xclip` | - |
| **Fuzzy Finder** | `fzf` | `fzf` | - |
| **Sugerencias Zsh** | `zsh-autosuggestions` | `zsh-autosuggestions` | - |
| **Resaltado Zsh** | `zsh-syntax-highlighting`| `zsh-syntax-highlighting`| - |
| **Servidor y utilidades X11** | `x11-xserver-utils`, `x11-utils` | `xorg-server`, `xorg-xinit`, `xorg-xrandr`, `xorg-xrdb`, `xorg-xsetroot`, `xorg-xev`, `xorg-xprop` | - |
| **Control de ventanas**| `suckless-tools` | `xdotool`, `xdo`, `wmname` | - |
| **Touchpad driver** | `xserver-xorg-input-synaptics` | `xf86-input-synaptics` *(y `libinput` nativo)* | - |
| **Configuración fuentes**| `fontconfig` | `fontconfig` | - |
| **Fuentes del sistema**| `fonts-cantarell`, `fonts-font-awesome`, `fonts-noto-color-emoji` | `cantarell-fonts`, `ttf-font-awesome`, `noto-fonts-emoji` | - |
| **Tema de cursores** | `bibata-cursor-theme`, `breeze-cursor-theme` | `xcursor-breeze` | `bibata-cursor-theme-bin` *(o descarga automática)* |
| **Compilación / Git** | `git`, `curl`, `unzip`, `build-essential` | `git`, `curl`, `unzip`, `base-devel` | - |

---

## Resiliencia y Mecanismos de Fallback

Para garantizar que la instalación nunca falle en un sistema Arch Linux limpio:

1. **Auto-instalación de AUR (`yay-bin`):** Si se detecta Arch Linux y no se encuentra instalado ni `yay` ni `paru`, el instalador consulta al usuario si desea compilar e instalar `yay-bin` automáticamente desde AUR.
2. **Despliegue directo de `i3lock-fancy`:** Si el usuario no utiliza un helper de AUR, `install.sh` clona el repositorio oficial de GitHub de `i3lock-fancy` y lo instala en `/usr/local/bin/i3lock-fancy`. Las dependencias (`i3lock` e `imagemagick`) se obtienen directamente de los repositorios oficiales de Pacman.
3. **Despliegue directo de cursores Bibata:** Si el tema `Bibata-Modern-Ice` no está disponible mediante APT o AUR, el instalador descarga el tarball oficial desde los releases de GitHub y lo extrae en `~/.local/share/icons/` y `/usr/share/icons/`.
