
if [ -d "$HOME/.bin" ] ;
	then PATH="$HOME/.bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ;
	then PATH="$HOME/.local/bin:$PATH"
fi

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$home/.gem/ruby/2.7.0/bin:$PATH"
export PATH="$home/.local/bin:$PATH"

export EDITOR=/usr/bin/nvim
export PAGER=nvim
source ~/.cargo/env
source /home/luz/.zinit/bin/zinit.zsh
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin

zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit ice pick"async.zsh" src"pure.zsh"; zplugin light sindresorhus/pure
autoload -U compinit
compinit
#eval "$(starship init zsh)"

alias ls='exa'
alias la='ls -a'
alias ll='exa -hal --git --time-style=iso --group-directories-first'
alias l='ls -lhmga --git'
alias l.="ls -A | egrep '^\.'"

alias cd..='cd ..'
alias pdw="pwd"
alias udpate='sudo pacman -Syu'
alias update='sudo pacman -Syu'
alias cls=clear
alias cp='cp -vr'
alias xd=cd

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias cal='cal -m --color=auto'
alias pacman='sudo pacman --color auto'

alias df='df -h'
alias fdisk='sudo fdisk -l'
alias ssn="sudo shutdown now"
alias sr="sudo reboot"
alias ctl="sudo systemctl"
alias dd='sudo dd status=progress'
alias umount='sudo umount -l'
alias free="free -mt"
alias rsync='rsync -ahuxv --progress'
alias unlock="sudo rm /var/lib/pacman/db.lck"


alias wget="wget -c"

alias userlist="cut -d: -f1 /etc/passwd"


alias ps="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"

alias update-fc='sudo fc-cache -fv'

alias microcode='grep . /sys/devices/system/cpu/vulnerabilities/*'

alias mirror="sudo reflector -f 30 -l 30 --protocol https --sort rate --country Japan --verbose --save /etc/pacman.d/mirrorlist"

alias youtube-dl='youtube-dl --fragment-retries "infinite"'
alias yta-best="youtube-dl --extract-audio --audio-format best "

alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -100"

alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'

alias jctl="journalctl -p 3 -xb"

alias npacman="sudo nvim /etc/pacman.conf"
alias nmkinitcpio="sudo nvim /etc/mkinitcpio.conf"

ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       7z x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       7z x $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
	  *.deb)       ar x $1      ;;
	  *.tar.xz)    tar xf $1   ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

