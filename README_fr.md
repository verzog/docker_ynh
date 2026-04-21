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

Déployez et gérez des conteneurs Docker sur votre serveur YunoHost, chacun accessible via un domaine YunoHost avec proxy inverse NGINX. Les apps à conteneur unique fonctionnent directement ; les configurations multi-conteneurs (ex. web + base de données) sont prises en charge en installant chaque conteneur comme instance distincte et en les reliant via un réseau Docker partagé.

**Version incluse :** 1.0~ynh1

## Ce que cette app prend en charge

### Apps à conteneur unique

Une seule installation, pointez sur l'image, c'est prêt. Cas typiques :

| Image | Description |
|---|---|
| `vaultwarden/server` | Gestionnaire de mots de passe |
| `gitea/gitea` | Hébergement Git |
| `ghost` | Plateforme de blog |
| `freshrss/freshrss` | Lecteur RSS |
| `uptime-kuma/uptime-kuma` | Surveillance de disponibilité |
| `joplin/server` | Synchronisation de notes |
| `nginx:alpine` | Serveur de fichiers statiques |

### Apps multi-conteneurs

Plusieurs conteneurs peuvent communiquer via un **réseau Docker défini par l'utilisateur**. Installez chaque conteneur comme instance distincte, donnez-leur le même nom de réseau dans le formulaire d'installation, et ils se référencent par nom de conteneur. Voir [`DOCKER_IMAGES.md`](./DOCKER_IMAGES.md) pour des recettes concrètes. Exemples :

| App | Recette |
|---|---|
| **Moodle** + MariaDB | Instance MariaDB + instance Moodle sur un réseau partagé |
| **Nextcloud** + MariaDB | Même principe, `MYSQL_HOST=<nom-instance-mariadb>` |
| **WordPress** + MariaDB | Même principe avec `WORDPRESS_DB_HOST` |

Pour les apps nécessitant une intégration YunoHost plus poussée (LDAP/SSO, provisionnement automatique de BDD, hooks de sauvegarde natifs), un paquet `_ynh` dédié reste recommandé — cette app échange cette intégration contre la flexibilité et la rapidité de mise en place.

## Avertissements / informations importantes

- Docker doit être installé sur le serveur avant d'installer cette app (`sudo apt install docker.io`)
- Cette app ne s'intègre **pas** avec le SSO/LDAP de YunoHost — chaque conteneur fonctionne comme un service indépendant
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
