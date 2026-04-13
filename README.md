## Доска объявлений (Hexlet DevOps)

Учебный проект: развёртывание Spring Boot-приложения «доска объявлений» на виртуальной машине в облаке с помощью Ansible, Docker и Nginx.

**Демо:** https://hesss.sytes.net/

### Hexlet tests and linter status

[![Actions Status](https://github.com/kimdeun/devops-engineer-from-scratch-project-315/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/kimdeun/devops-engineer-from-scratch-project-315/actions/workflows/hexlet-check.yml)

### Что делает проект

- **Первичная настройка сервера** (`playbook.yml`): Docker, UFW, Nginx, TLS (Let’s Encrypt через Certbot), каталоги данных и логов, корневой сертификат для подключения к БД в Yandex Cloud.
- **Выкат приложения** (`deploy.yml`): скачивание образа из Docker Hub, запуск контейнера с пробросом портов и переменными окружения (БД, S3 и т.д.).
- **Объектное хранилище** (`setup-s3.yml`): создание бакета в S3-совместимом хранилище (роль `amazon.aws`, переменные из vault).

Стек на стороне приложения: PostgreSQL (Managed), файлы в Yandex Object Storage, образ `docker.io/123c/hexlet` (тег задаётся переменной `docker_tag`).

### Структура репозитория

| Путь | Назначение |
|------|------------|
| `playbook.yml` | Полная настройка production-хоста |
| `deploy.yml` | Только обновление контейнера приложения |
| `setup-s3.yml` | Создание S3-бакета (localhost) |
| `inventory.ini` | Хосты Ansible |
| `group_vars/all/main.yml` | Общие переменные (образ, порты, S3, имя сервера) |
| `group_vars/all/rollout.yml` | **Параметры выката** (`serial`, `max_fail_percentage`) |
| `group_vars/all/secrets.yml` | Секреты (шифрование Ansible Vault) |
| `roles/deploy` | Задачи выката Docker-контейнера |
| `roles/nginx` | Базовая конфигурация Nginx |
| `Makefile` | Цели `deploy`, `rollback`, установка ролей/collections |

### Требования

- Ansible, `ansible-galaxy`, доступ по SSH к серверу из `inventory.ini`
- Файл с секретами и пароль/ключ Vault для `group_vars/all/secrets.yml`
- Для `setup-s3.yml` — ключи доступа к облаку в `roles/deploy/vars/secrets.yml` (как в проекте)

### Команды

Установка зависимостей Ansible (collections и roles из `requirements.yml`):

```bash
make ansible-install
```

Первичная настройка сервера (полный `playbook.yml`):

```bash
make deploy
```

Выкат **новой версии** образа (только приложение, без полного прогона `playbook.yml`):

```bash
ansible-playbook -i inventory.ini deploy.yml \
  --extra-vars "docker_tag=<тег_образа>" \
  --ask-vault-pass
```

Откат на предыдущий тег образа:

```bash
make rollback ROLLBACK_TAG=<тег_образа>
```

### Конфигурация выката (rollout)

Отдельного Kubernetes Deployment или Argo Rollouts в репозитории нет: используется **один Docker-контейнер на сервере**, выкат — через Ansible.

Параметры поэтапного выката по хостам (если в `inventory.ini` будет несколько серверов) задаются в **`group_vars/all/rollout.yml`**: `ansible_rollout_serial` и `ansible_rollout_max_fail_percentage`. Они подключены в `deploy.yml` через директивы `serial` и `max_fail_percentage`.

При одном хосте смена версии — это обновление одного контейнера; для отката используйте `make rollback` с нужным `ROLLBACK_TAG`.
