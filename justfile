default:
  just --list

dep:
  ansible-galaxy collection install -r requirements.yml

config:
  ansible-playbook playbook.yml --tags "core" -K

config-etc:
  ansible-playbook playbook.yml --tags "etc" -K

config-all:
  ansible-playbook playbook.yml -K

lint:
  ansible-lint playbook.yml
