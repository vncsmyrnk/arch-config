.PHONY: help
help:
	@echo "Available targets:"
	@echo "  system       - Install arch linux via Ansible (can be run from Live ISO)"
	@echo "  install-aur  - Install AUR packages interactively"
	@echo "  config       - Run the full configuration playbook as the target user after installation"
	@echo "  config-core  - Run the configuration playbook with 'core' tags as the target user after installation"
	@echo "  config-etc   - Run the configuration playbook with 'etc' tags as the target user after installation"
	@echo "  config-deps  - Install dependencies for config targets"
	@echo "  lint         - Lint the playbooks"

.PHONY: config-deps
config-deps:
	sudo pacman -Sy ansible-core
	ansible-galaxy collection install -r requirements.yml > /dev/null

.PHONY: system
system:
	@if [ -z "$$CI" ]; then \
		read -p "This process will install Arch Linux from scratch using ansible. Continue? (y/N): " choice; \
		if [ "$${choice,,}" != "y" ]; then echo "Aborted."; exit 0; fi; \
	fi
	mount -o remount,size=2G /run/archiso/cowspace
	pacman -Sy --noconfirm archlinux-keyring ansible ansible-core python python-jinja python-markupsafe python-yaml
	ansible-galaxy collection install -r requirements.yml
	ansible-playbook system.yml $(EXTRA_VARS)
	@echo "All Done. Inspect, unmount and reboot"

.PHONY: install-aur
install-aur: # Automating AUR packages installations is a security risk
	yay -S \
	google-chrome gnome-shell-extension-argos-git gnome-shell-extension-window-calls-git gwin-git \
	shell-utils-git antigravity-cli ngrok stripe-cli downgrade python-plotext \
	github-copilot-cli envycontrol google-cloud-sdk redis-cli claude-code

.PHONY: config
config:
	ansible-playbook user.yml $(if $(CI),,-K) $(EXTRA_VARS)

.PHONY: config-core
config-core:
	ansible-playbook user.yml --tags "core" $(if $(CI),,-K) $(EXTRA_VARS)

.PHONY: config-etc
config-etc:
	ansible-playbook user.yml --tags "etc" $(if $(CI),,-K) $(EXTRA_VARS)

.PHONY: lint
lint:
	ansible-lint system.yml user.yml

# systemd-run --user --scope -p CPUQuota=50% make test-system
.PHONY: test-system
test-system:
	cd tests && packer init arch-base.pkr.hcl && packer build arch-base.pkr.hcl

.PHONY: test-user
test-user:
	cd tests && packer init arch-user.pkr.hcl && packer build arch-user.pkr.hcl

.PHONY: test-all
test-all: test-system test-user
