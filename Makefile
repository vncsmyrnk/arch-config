.PHONY: help
help:
	@echo "Available targets:"
	@echo "  system       - Install arch linux via Ansible (can be run from Live ISO)"
	@echo "  config       - Run the full configuration playbook as the target user after installation"
	@echo "  config-core  - Run the configuration playbook with 'core' tags as the target user after installation"
	@echo "  config-etc   - Run the configuration playbook with 'etc' tags as the target user after installation"
	@echo "  deps         - Install ansible-galaxy dependencies"
	@echo "  lint         - Lint the playbooks"

.PHONY: deps
deps:
	ansible-galaxy collection install -r requirements.yml > /dev/null

.PHONY: system
system:
	@read -p "This process will install Arch Linux from scratch using ansible. Continue? (y/N): " choice; \
	if [ "$${choice,,}" != "y" ]; then echo "Aborted."; exit 0; fi
	pacman -Sy archlinux-keyring ansible ansible-core python python-jinja python-markupsafe python-yaml > /dev/null
	ansible-galaxy collection install -r requirements.yml > /dev/null
	ansible-playbook system.yml
	@echo "All Done. Inspect, unmount and reboot"

.PHONY: config
config:
	ansible-playbook user.yml -K

.PHONY: config-core
config-core:
	ansible-playbook user.yml --tags "core" -K

.PHONY: config-etc
config-etc:
	ansible-playbook user.yml --tags "etc" -K

.PHONY: lint
lint:
	ansible-lint system.yml user.yml

.PHONY: expand-archiso
expand-archiso:
	mount -o remount,size=1G /run/archiso/cowspace
