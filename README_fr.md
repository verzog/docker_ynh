<!--
N.B.: Ce README est automatiquement généré par https://github.com/YunoHost/apps/tree/main/tools/README-generator
Il ne doit pas être édité à la main.
-->

# Docker Container pour YunoHost

[![Niveau d'intégration](https://dash.yunohost.org/integration/docker_container.svg)](https://ci-apps.yunohost.org/ci/apps/docker_container/)
[![Installer Docker Container avec YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=docker_container)

*[Read this README in english.](./README.md)*

> *Ce package vous permet d'installer Docker Container rapidement et simplement sur un serveur YunoHost.
> Si vous n'avez pas YunoHost, consultez [ce guide](https://yunohost.org/install) pour savoir comment l'installer et en profiter.*

## Vue d'ensemble

Déployez et gérez un conteneur Docker sur votre serveur YunoHost

**Version incluse :** 1.0~ynh1

## Avertissements / informations importantes

- Docker doit être installé sur le serveur avant d'installer cette app (`sudo apt install docker.io`)
- Cette app ne s'intègre **pas** avec le SSO/LDAP de YunoHost — les conteneurs sont des services indépendants
- Cette app ne fonctionnera **pas** si YunoHost lui-même s'exécute dans un conteneur Docker
- Seules les données stockées dans le volume `/data` monté sont incluses dans les sauvegardes YunoHost
- L'action de mise à jour re-télécharge l'image et recrée le conteneur

## Documentations et ressources

- YunoHost Store : <https://apps.yunohost.org/app/docker_container>
- Signaler un bug : <https://github.com/verzog/docker_ynh/issues>

## Informations pour les développeurs

Merci de faire vos pull request sur la [branche testing](https://github.com/verzog/docker_ynh/tree/testing).

Pour essayer la branche testing, procédez comme suit :

```bash
sudo yunohost app install https://github.com/verzog/docker_ynh/tree/testing --debug
ou
sudo yunohost app upgrade docker_container -u https://github.com/verzog/docker_ynh/tree/testing --debug
```

**Plus d'infos sur le packaging d'applications :** <https://yunohost.org/packaging_apps>
