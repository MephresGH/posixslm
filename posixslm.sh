#!/bin/sh

### POSIX Shell Login Manager
### Licensed under GNU General Public License v3.0
### Published & Written by Mephres

## Create static variables and aliases for simple repeating of code

user=$(whoami)
date=$(date)
log=$(last | head -n 6)
environment=$(readlink /proc/$$/exe)
alias findsx="find /usr/bin/sx"
alias startxfix="exec startx ~/.config/posixslm/xinitrc"
alias startw="exec ~/.config/posixslm/waylandrc"

## Start a Wayland login prompt

wayland()
{
while true; do
	printf "What Wayland desktop environment do you want to enter? (K/G/S/X/N) "
		read -r kgsxn
		case $kgsxn in
		[Kk]* ) printf "\nStarting KDE Plasma (Wayland)...\n" && WM=kde startw;;
		[Gg]* ) printf "\nStarting GNOME (Wayland)...\n" && WM=gnome startw;;
		[Ss]* ) printf "\nStarting Sway...\n" && WM=sway startw;;
		[Xx]* ) printf "\nAborting, going to login menu...\n" && break;;
		[Nn]* ) printf "\nExiting to TTY...\n" && exit;;
		* ) printf "\nIncorrect input detected, repeating prompt...\n";;
	esac
done
}

## Start an X.Org login prompt
# If "sx" not found, run "startx" instead

xorg()
{
while true; do
	printf "What X.Org desktop environment do you want to enter? (K/G/I/A/O/F/X/N) "
		read -r kgiaofxn
		case $kgiaofxn in
		[Kk]* ) printf "\nStarting KDE Plasma...\n" && findsx && exec sx startplasma-x11 || WM=kde startxfix;;
		[Gg]* ) printf "\nStarting GNOME...\n" && findsx && exec sx gnome-shell || WM=gnome startxfix;;
		[Ii]* ) printf "\nStarting i3wm...\n" && findsx && exec sx i3 || WM=i3wm startxfix;;
		[Aa]* ) printf "\nStarting awesomewm...\n" && findsx && exec sx awesome || WM=awesome startxfix;;
		[Oo]* ) printf "\nStarting Openbox...\n" && findsx && exec sx openbox || WM=openbox startxfix;;
		[Ff]* ) printf "\nStarting Fluxbox...\n" && findsx && exec sx fluxbox || WM=fluxbox startxfix;;
		[Xx]* ) printf "\nAborting, going to login menu...\n" && break;;
		[Nn]* ) printf "\nExiting to TTY...\n" && exit;;
		* ) printf "\nIncorrect input detected, repeating prompt...\n";;
	esac
done
}

## Run a function that creates a TTY-based "display manager"

login()
{
clear
printf "\nPOSIX Shell Login Manager\n\n"
printf "You have logged into the user %s \n\n" "$user"
printf "Recent logins:\n%s\n\n" "$log"
printf "The time and date is %s \n\n" "$date"
printf "The current shell in usage is %s \n\n" "$environment"
printf "The following X11 desktop environments are installed:\n\n"
ls -l /usr/share/xsessions/
printf "\nThe following Wayland desktop environments are installed:\n\n"
ls -l /usr/share/wayland-sessions/
printf "\nNOTE: .desktop files from environments that cannot be found cannot be run.\n\n"

while true; do
printf "Do you want to run an X.Org or Wayland graphical server? (X/W/N) "
read -r xwn
	case $xwn in
		[Xx]* ) printf "\nStarting X.Org prompt...\n\n" && xorg
		;;
		[Ww]* ) printf "Starting Wayland prompt...\n\n" && wayland
		;;
		[Nn]* ) printf "\nExiting to TTY...\n\n" && return && exit;;
		* ) printf "\nIncorrect input detected, repeating prompt...\n";;
	esac
done
}

## Create warning screen

warning()
{
printf "TTY1 was not detected.\nIt is not recommended to run a desktop environment outside of TTY1.\n"
while true; do
printf "Do you want to continue? (Y/N) "
read -r yn
	case $yn in
		[Yy]* ) printf "\nContinuing...\n" && login;;
		[Nn]* ) printf "\nExiting...\n" && return && exit;;
		* ) printf "\nIncorrect input detected, repeating prompt...\n";;
	esac
done
}

## Check for TTY window; if not TTY1, warn user from starting WM/DE

if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
  login
else
  warning
fi
