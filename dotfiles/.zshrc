if [ -d "$HOME/.bin" ] ;
	then PATH="$HOME/.bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ;
	then PATH="$HOME/.local/bin:$PATH"
fi


if [ -d "$HOME/.cargo/bin" ] ;
	then PATH="$HOME/.cargo/bin:$PATH"
fi

export EDITOR=/usr/bin/nvim
export PAGER=less
#export WINEPREFIX=~/.wine-appimage-stable

#[ "$TERM" = "xterm-kitty" ] && alias ssh = "kitty +kitten ssh"
source ~/.local/share/zinit/zinit.git/zinit.zsh

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit ice pick"async.zsh" src"pure.zsh"; zinit light sindresorhus/pure
#zinit light-mode for \
#    zdharma-continuum/zinit-annex-as-monitor \
#    zdharma-continuum/zinit-annex-bin-gem-node \
#    zdharma-continuum/zinit-annex-patch-dl \
#    zdharma-continuum/zinit-annex-rust
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
alias update='sudo pacman -Syu'
alias udpate='update'
alias remove='pacman -Rscn'
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
alias ctl="sudo systemctl"
alias dd='sudo dd status=progress'
alias umount='sudo umount -l'
alias free="free -mt"
alias rsync='rsync -ahuxv --progress'
alias unlock="sudo rm /var/lib/pacman/db.lck"
alias wget="wget -c"
alias ps="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias sftp="sftp -R 1288 -B 65536"
alias sshfs="sudo sshfs -F /home/luz/.ssh/config -o allow_other"
alias make='make -j 16'
alias makepkg='makepkg -sriCfc'
alias update-fc='sudo fc-cache -fv'
alias cat='bat -pp' 

alias microcode='grep . /sys/devices/system/cpu/vulnerabilities/*'
alias userlist="cut -d: -f1 /etc/passwd"
alias mirror="sudo reflector -f 30 -l 30 --protocol https --sort rate --country Japan --verbose --save /etc/pacman.d/mirrorlist"

#alias youtube-dl='youtube-dl --fragment-retries "infinite"'
#alias yta-best="youtube-dl --extract-audio --audio-format best "
alias yta-best="yt-dlp -f 'ba' -x --audio-format mp3"
alias yt-best="yt-dlp -f 'bv&+ba'"
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -100"
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'
alias jctl="journalctl -p 3 -xb"

alias gitdiff="nvim +DiffviewOpen"

#nvim ()
#{
#  if [ -z $1 ]; then
#	  /usr/bin/nvim 
#  elif [ -f $1 ]; then
#    case $1 in
#      *.sh|*.c|*.cc|*.cpp|*.h)   
#        lvim $1	;;
#      *.exe)
#        echo "Binary File"	;;
#      *)		  
#        /usr/bin/nvim $1	;;
#	esac
#  elif [ -d $1 ]; then 
#    echo "Diretory"
#  else
#	/usr/bin/nvim $1
#	fi
#}

help_ex(){
	echo "Usage: ex [<option>] <file/directory>"
	echo "options: "
	echo "r 	Remove archive after extract"
}

extract_archive() {
    case $1 in
		*.tar.bz2|*.tbz2|*.tar.gz|*.tgz|*.tar.xz|*.txz|*.tar)    
			tar xf $1  ;;
		*.rar|*.zip|*.7z|*.Z)
			7z x $1 -o'*' ;;
		*.bz2)       
			bunzip2 $1 ;;
		*.gz)        
			gunzip $1  ;;
		*.deb)       
			ar x $1    ;;
		*)           
			echo "'$1' cannot be extracted via ex()" ;;
	esac
}
ex() {
	local option=""
	local args=()

	if [ $# -eq 0 ]; then
		help_ex
		return 1
	fi

	for arg in "$@" 
	do 
		if [ "$arg" = "-r" ]; then 
			option="$1"
			shift
		elif [ "$arg" = '.' ]; then 
			for file in *; do 
				args+=("$file")
			done
			shift
		elif [ -f "$arg" ] || [ -d "$arg" ]; then
			args+=("$arg")
			shift
		fi 
	done

	for target in "${args[@]}"; 
	do 
		if [ -f ]; then
			extract_archive "$target"
				if [ $? -eq 0 ] && [ "$option" = "-r" ]; then
					rm "$target"
				fi
		elif [ -d ]; then 
			for archive in "$target"/* 
			do 
				extract_archive "$archive"
				if [ $? -eq 0 ] && [ "$option" = "-r" ]; then
					rm "$archive"
				fi
			done
		fi
	done
}
sr() { 
	if [ -s "/usr/lib/modules/$(uname -r)/pkgbase" ]; then
		sudo systemctl soft-reboot 
	else 
		sudo reboot 
	fi
}
