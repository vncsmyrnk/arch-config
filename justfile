default:
  just --list

sync-packages:
  yay -S --needed - < packages/pacman/*

config:
  mkdir -p "{{home_dir()}}/.config/yay"
  stow -t "{{home_dir()}}/.config/yay" yay
  sudo stow -t /etc etc

unset-config:
  stow -D -t "{{home_dir()}}/.config/yay" yay
  sudo stow -D -t /etc etc
