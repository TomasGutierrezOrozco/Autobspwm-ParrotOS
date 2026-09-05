# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Fix the java problem
export _JAVA_AWT_WM_NONREPARENTING=1

# Powerlevel10k theme loader
if [ -f "$HOME/powerlevel10k/powerlevel10k.zsh-theme" ]; then
    source "$HOME/powerlevel10k/powerlevel10k.zsh-theme"
elif [ -f "/usr/share/powerlevel10k/powerlevel10k.zsh-theme" ]; then
    source "/usr/share/powerlevel10k/powerlevel10k.zsh-theme"
fi

# Zsh plugins
[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f /usr/share/zsh-sudo/sudo.plugin.zsh ] && source /usr/share/zsh-sudo/sudo.plugin.zsh

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt histignorealldups sharehistory

# Modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b 2>/dev/null)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Custom Aliases
# -----------------------------------------------
# bat
alias cat='batcat'
alias catn='batcat --style=plain'
alias catnp='batcat --style=plain --paging=never'

# ls
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'

# nmtui & blueman
alias wifi='nmtui'
alias bluetooth='blueman-manager'

# tailscale
alias vpn-on="sudo tailscale up"
alias vpn-off="sudo tailscale down"
alias vpn-status="tailscale status"

export LS_COLORS="rs=0:di=34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:"

# Environment PATH
export PATH="/opt/kitty/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/sbin:/opt/nvim/nvim-linux-x86_64/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"

# Set target function
function settarget(){
    local ip_address=$1
    local machine_name=$2
    mkdir -p "$HOME/.config/bin"
    echo "$ip_address $machine_name" > "$HOME/.config/bin/target"
}

# Clear target function
function cleartarget(){
    mkdir -p "$HOME/.config/bin"
    echo '' > "$HOME/.config/bin/target"
}

# Custom mkt
function mkt(){
  mkdir -p nmap content exploits
}

# Clear History
function clearhist(){
    echo '' > ~/.zsh_history
}

# ExtractPorts
function extractPorts(){
  ports="$(cat $1 2>/dev/null | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
  ip_address="$(cat $1 2>/dev/null | grep -oP '^Host: .* \(\)' | head -n 1 | awk '{print $2}')"
  echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
  echo -e "\t[*] IP Address: $ip_address" >> extractPorts.tmp
  echo -e "\t[*] Open Ports: $ports\n" >> extractPorts.tmp
  echo "$ports" | tr -d '\n' | xclip -sel clip 2>/dev/null || true
  echo -e "[*] Ports copied to clipboard\n" >> extractPorts.tmp
  cat extractPorts.tmp
  rm extractPorts.tmp
}

# System clean function
ClearCache() {
    echo "[*] Limpieza de caché para Parrot/Debian"
    echo
    echo "[*] Limpiando caché de APT..."
    sudo apt-get clean
    sudo apt-get autoclean
    echo
    echo "[*] Eliminando paquetes no necesarios..."
    sudo apt-get autoremove --purge
    echo
    echo "[*] Purgando configuraciones residuales de paquetes eliminados..."
    local residuals
    residuals=$(dpkg -l 2>/dev/null | awk '/^rc/ {print $2}')
    if [[ -n "$residuals" ]]; then
        echo "$residuals" | xargs -r sudo apt-get purge
    else
        echo "    No hay configuraciones residuales."
    fi
    echo
    echo "[*] Limpiando cachés comunes del usuario..."
    [[ -d "$HOME/.cache/thumbnails" ]] && rm -rf "$HOME/.cache/thumbnails/"*
    [[ -d "$HOME/.cache/pip" ]] && rm -rf "$HOME/.cache/pip/"*
    [[ -d "$HOME/.cache/go-build" ]] && rm -rf "$HOME/.cache/go-build/"*
    echo
    echo "[*] Limpiando caché de npm si existe..."
    if command -v npm >/dev/null 2>&1; then
        npm cache clean --force
    else
        echo "    npm no está instalado."
    fi
    echo
    echo "[*] Limpiando Flatpak si existe..."
    if command -v flatpak >/dev/null 2>&1; then
        flatpak uninstall --unused -y
    else
        echo "    Flatpak no está instalado."
    fi
    echo
    echo "[*] Reduciendo logs antiguos de systemd..."
    if command -v journalctl >/dev/null 2>&1; then
        sudo journalctl --vacuum-time=7d
    else
        echo "    journalctl no está disponible."
    fi
    echo
    echo "[+] Limpieza completada."
}

# Source Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# FZF integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# NVM loader (if installed)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
