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

Déployez et gérez un conteneur Docker **unique** sur votre serveur YunoHost, accessible via un domaine YunoHost avec proxy inverse NGINX.

**Version incluse :** 1.0~ynh1

## ⚠️ Cette app est uniquement pour les conteneurs autonomes

Cette app fonctionne en exécutant un seul conteneur Docker et en le proxifiant via NGINX. Elle est conçue pour les apps qui se déploient en **une seule image sans dépendances externes** — parce qu'elles embarquent leur propre base de données, ou n'en ont pas besoin.

**Cas d'usage appropriés — conteneurs autonomes :**

| Image | Description |
|---|---|
| `vaultwarden/server` | Gestionnaire de mots de passe |
| `gitea/gitea` | Hébergement Git |
| `ghost` | Plateforme de blog |
| `freshrss/freshrss` | Lecteur RSS |
| `uptime-kuma/uptime-kuma` | Surveillance de disponibilité |
| `joplin/server` | Synchronisation de notes |
| `nginx:alpine` | Serveur de fichiers statiques |

**Non adapté — apps multi-conteneurs :**

Des apps comme **Moodle**, **Gibbon EDU**, **WordPress** (avec MySQL) et **Nextcloud** (complet) nécessitent plusieurs conteneurs coordonnés (web + base de données + cache). Cette app ne peut pas les orchestrer. Pour celles-ci, un paquet `_ynh` dédié est la bonne approche — il offre l'intégration LDAP/SSO, la gestion automatique de la base de données et une sauvegarde/restauration propre.

## Avertissements / informations importantes

- Docker doit être installé sur le serveur avant d'installer cette app (`sudo apt install docker.io`)
- Cette app ne s'intègre **pas** avec le SSO/LDAP de YunoHost — le conteneur fonctionne comme un service indépendant
- Cette app ne fonctionnera **pas** si YunoHost lui-même s'exécute dans un conteneur Docker
- Seules les données dans le volume `/data` monté sont sauvegardées — les données ailleurs dans le conteneur sont perdues lors d'une mise à jour
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
