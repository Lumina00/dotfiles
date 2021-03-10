
if [ -d "$HOME/.bin" ] ;
	then PATH="$HOME/.bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ;
	then PATH="$HOME/.local/bin:$PATH"
fi

export PATH="/home/luz/.cargo/bin:$PATH"
export PATH="/home/luz/.gem/ruby/2.7.0/bin:$PATH"
source ~/.cargo/env
source /home/luz/.zinit/bin/zplugin.zsh
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin

#zplugin light zsh-users/zsh-autosuggestions
zplugin light zdharma/fast-syntax-highlighting
#zplugin ice pick"async.zsh" src"pure.zsh"; zplugin light sindresorhus/pure
autoload -U compinit
compinit
eval "$(starship init zsh)"

#list
alias ls='exa'
alias la='ls -a'
alias ll='exa -hal --git --time-style=iso --group-directories-first'
alias l='ls -lhmga --git'
alias l.="ls -A | egrep '^\.'"

#fix obvious typo's
alias cd..='cd ..'
alias pdw="pwd"
alias udpate='sudo pacman -Syyu'
alias upate='sudo pacman -Syyu'
alias cls=clear
alias cp='cp -vr'
alias xd=cd
alias rm-'rm -rf'
# Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

#readable output
alias df='df -h'
alias fdisk='sudo fdisk -l'
#pacman unlock
alias unlock="sudo rm /var/lib/pacman/db.lck"

#free
alias free="free -mt"

#use all cores
alias uac="sh ~/.bin/main/000*"

#continue download
alias wget="wget -c"

#userlist
alias userlist="cut -d: -f1 /etc/passwd"


# Aliases for software managment
# pacman or pm
alias pacman='sudo pacman --color auto'

#ps
alias ps="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"

#add new fonts
alias update-fc='sudo fc-cache -fv'

#check vulnerabilities microcode
alias microcode='grep . /sys/devices/system/cpu/vulnerabilities/*'

#get fastest mirrors in your neighborhood
alias mirror="sudo reflector -f 30 -l 30 --protocol https --protocol http --sort rate --country Japan --verbose --save /etc/pacman.d/mirrorlist"

#youtube-dl
alias yta-aac="youtube-dl --extract-audio --audio-format aac "
alias yta-best="youtube-dl --extract-audio --audio-format best "
alias yta-flac="youtube-dl --extract-audio --audio-format flac "
alias yta-m4a="youtube-dl --extract-audio --audio-format m4a "
alias yta-mp3="youtube-dl --extract-audio --audio-format mp3 "
alias yta-opus="youtube-dl --extract-audio --audio-format opus "
alias yta-vorbis="youtube-dl --extract-audio --audio-format vorbis "
alias yta-wav="youtube-dl --extract-audio --audio-format wav "

alias ytv-best="youtube-dl -f bestvideo+bestaudio "

#Recent Installed Packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -100"

#Cleanup orphaned packages
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'

#get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

#nvim
alias npacman="sudo nvim /etc/pacman.conf"
alias nmkinitcpio="sudo nvim /etc/mkinitcpio.conf"
alias nslim="sudo nvim /etc/slim.conf"
alias noblogout="sudo nvim /etc/oblogout.conf"
alias nmirrorlist="sudo nvim /etc/pacman.d/mirrorlist"

#shutdown or reboot
alias ssn="sudo shutdown now"
alias sr="sudo reboot"
#systemctl 
alias ctl="sudo systemctl"

alias sensors="sensors dell_smm-virtual-0"

alias dd='sudo dd status=progress'
alias umount='sudo umount -l'
# # ex = EXtractor for all kinds of archives
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
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

#create a file called .bashrc-personal and put all your personal aliases
#in there. They will not be overwritten by skel.


