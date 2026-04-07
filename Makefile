ansible-install:
	ansible-galaxy collection install -r ansible/requirements.yml

deploy:
	ansible-playbook -i ansible/inventory.ini ansible/deploy.yml --ask-vault-pass

rollback:
	@if [ -z "$(ROLLBACK_TAG)" ]; then \
		echo "Укажите ROLLBACK_TAG"; \
		exit 1; \
	fi
	ansible-playbook -i ansible/inventory.ini ansible/deploy.yml \
		--extra-vars "docker_tag=$(ROLLBACK_TAG)" \
		--ask-vault-pass
