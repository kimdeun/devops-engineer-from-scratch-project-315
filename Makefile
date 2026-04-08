ansible-install:
	ansible-galaxy collection install -r requirements.yml -p collections
	ansible-galaxy role install -r requirements.yml -p roles

deploy:
	ansible-playbook playbook.yml --ask-vault-pass

rollback:
	@if [ -z "$(ROLLBACK_TAG)" ]; then \
		echo "Укажите ROLLBACK_TAG"; \
		exit 1; \
	fi
	ansible-playbook -i inventory.ini deploy.yml \
		--extra-vars "docker_tag=$(ROLLBACK_TAG)" \
		--ask-vault-pass
