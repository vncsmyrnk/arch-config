default:
  just --list

dep:
  pacman -S ansible
  ansible-galaxy collection install -r requirements.yaml

config:
  ansible-playbook setup.yaml --tags "core" -K

config-etc:
  ansible-playbook setup.yaml --tags "etc" -K

config-all:
  ansible-playbook setup.yaml -K
