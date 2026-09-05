# Guia de Soporte y Despliegue en Arch Linux

Este documento describe la arquitectura, consideraciones tecnicas y pasos de validacion para ejecutar **Autobspwm** en **Arch Linux** y sus distribuciones derivadas (EndeavourOS, BlackArch, Manjaro).

---

## 1. Filosofia de Diseno Multi-Distribucion

Autobspwm separa estrictamente dos capas:
1. **Capa de Entorno y Rice (Agnostica):** Las configuraciones en `~/.config/` (`bspwm`, `sxhkd`, `polybar`, `picom`, `dunst`, `rofi`, `kitty`, `nvim`) y los dotfiles de usuario son identicos para cualquier sistema basado en X11.
2. **Capa de Aprovisionamiento (Especifica por Distro):** La deteccion del sistema en `lib/common.sh` bifurca la instalacion de paquetes hacia `pacman` y `AUR` en Arch Linux, o hacia `apt` en Debian/Parrot/Kali.

---

## 2. Requisitos Previos en Arch Linux Puro

En entornos como Parrot Security o Kali Linux, el sistema operativo incluye de serie servidores graficos, controladores de pantalla, utilidades de red y gestores de sonido. En una instalacion minima de Arch Linux (instalada desde `archinstall` o manual), asegurate de contar con:

1. **Controladores de Video (GPU):**
   - Intel: `mesa vulkan-intel`
   - AMD: `mesa vulkan-radeon`
   - Nvidia: `nvidia nvidia-utils` (o controladores open-source `nouveau`)
   - Maquina Virtual (QEMU/KVM/VirtualBox): `xf86-video-vmware` o paquetes de `virtualbox-guest-utils`

2. **Gestor de Inicio de Sesion (Display Manager):**
   - Recomendado: `lightdm` con `lightdm-gtk-greeter`, `sddm` o `gdm`.
   - Autobspwm registra automaticamente la sesion en `/usr/share/xsessions/bspwm.desktop` para que aparezca en el menu de cualquier gestor.
   - Si inicias sesion por consola (TTY) mediante `startx`, asegurate de agregar `exec bspwm` en tu archivo `~/.xinitrc`.

3. **Conexion de Red:**
   - `NetworkManager` activo (`systemctl enable --now NetworkManager`).

---

## 3. Gestion de Paquetes y AUR

Arch Linux divide los paquetes entre los repositorios oficiales (`core`, `extra`) y el repositorio comunitario (`AUR`).

### Paquetes Nativos (`packages/pacman.txt`)
Se instalan automaticamente usando:
```bash
sudo pacman -S --needed --noconfirm [paquetes...]
```

### Paquetes de AUR (`packages/aur.txt`)
Autobspwm gestiona las dependencias comunitarias de forma resiliente:
* Si tienes `yay` o `paru` instalado, se invocan para instalar `i3lock-fancy-git` y temas auxiliares.
* Si no tienes ningun helper de AUR, el instalador te ofrece compilar e instalar `yay-bin` automaticamente.
* Si decides no utilizar AUR, el instalador activa **rutinas autonomas de respaldo**:
  - `i3lock-fancy` se clona e instala directamente desde su codigo fuente en GitHub.
  - El cursor `Bibata-Modern-Ice` se descarga directamente desde sus releases oficiales en GitHub.

---

## 4. Diferencias Clave Resueltas

### A. Binario de Bat
- En Debian/Parrot: `/usr/bin/batcat`.
- En Arch Linux: `/usr/bin/bat`.
- **Solucion en `.zshrc`:** Alias condicionales que detectan dinamicamente si el comando disponible es `batcat` o `bat`.

### B. Rutas de Plugins de Zsh
- En Debian: `/usr/share/zsh-autosuggestions/` y `/usr/share/zsh-syntax-highlighting/`.
- En Arch Linux: `/usr/share/zsh/plugins/zsh-autosuggestions/` y `/usr/share/zsh/plugins/zsh-syntax-highlighting/`.
- **Solucion en `.zshrc`:** Iteracion dinamica sobre las rutas conocidas para cargar los plugins sin importar la distribucion.

### C. Plugin de Sudo (Doble Escape)
- En Debian: Paquete `zsh-sudo`.
- En Arch: No existe como paquete nativo de pacman.
- **Solucion en `.zshrc`:** Si el archivo no existe en el sistema, se define una funcion ZLE nativa que vincula `ESC ESC` para anteponer `sudo` a cualquier comando en pantalla.

### D. Controlador de Touchpad
- En Parrot OS: Controlador `synaptics` (`synclient`).
- En Arch Linux: Controlador moderno `libinput` (`xinput`).
- **Solucion en `bspwmrc` y `toggle-touchpad-synclient`:** Deteccion hibrida en tiempo real que ejecuta `synclient` si esta presente y responde, o `xinput set-prop [id] "Device Enabled"` bajo `libinput`, acompanado de una notificacion OSD con Dunst.

---

## 5. Procedimiento de Prueba en Maquina Virtual

Para verificar el entorno en una maquina virtual limpia de Arch Linux o EndeavourOS:

1. Inicia la maquina virtual y asegurate de tener acceso a internet.
2. Clona la rama `arch-linux`:
   ```bash
   git clone -b arch-linux https://github.com/TomasGutierrezOrozco/Autobspwm-ParrotOS.git
   cd Autobspwm-ParrotOS
   ```
3. Ejecuta la validacion preliminar:
   ```bash
   ./check.sh
   ```
4. Lanza la instalacion:
   ```bash
   ./install.sh
   ```
5. Reinicia el equipo y selecciona **bspwm** en tu gestor de login:
   ```bash
   sudo reboot
   ```
