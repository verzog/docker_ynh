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

Déployez et gérez un conteneur Docker **de logiciel libre vérifié** sur votre serveur YunoHost, accessible via un domaine YunoHost avec proxy inverse NGINX. Vous choisissez une application dans une liste blanche vérifiée ; le paquet gère la référence exacte de l'image, sa version épinglée, sa licence et son port interne. Les configurations multi-conteneurs (ex. app + base de données) sont prises en charge en installant chaque conteneur comme instance distincte et en les reliant via un réseau Docker partagé.

**Version incluse :** 1.1~ynh1

## Ce que cette app prend en charge

### Uniquement des images de logiciels libres vérifiées

Vous choisissez l'une de ces images vérifiées, à licence enregistrée et version épinglée (pas d'images Docker Hub arbitraires) :

| Choix | Image | Licence |
|---|---|---|
| `vaultwarden` | `vaultwarden/server` | AGPL-3.0-only |
| `gitea` | `gitea/gitea` | MIT |
| `freshrss` | `freshrss/freshrss` | AGPL-3.0-only |
| `uptime-kuma` | `louislam/uptime-kuma` | MIT |
| `ghost` | `ghost` | MIT |
| `nginx` | `nginx` (alpine) | BSD-2-Clause |
| `mariadb` | `mariadb` | GPL-2.0-only |
| `postgres` | `postgres` (alpine) | PostgreSQL |

Les versions épinglées sont définies dans [`scripts/_common.sh`](./scripts/_common.sh). Pour proposer une nouvelle image, ouvrez une pull request — elle doit être un logiciel libre avec une licence claire.

### Apps multi-conteneurs

Plusieurs conteneurs peuvent communiquer via un **réseau Docker défini par l'utilisateur**. Installez chaque conteneur comme instance distincte, donnez-leur le même nom de réseau dans le formulaire d'installation, et ils se référencent par nom de conteneur. Voir [`DOCKER_IMAGES.md`](./DOCKER_IMAGES.md) pour des recettes concrètes (ex. `ghost` + `mariadb`).

Pour les apps nécessitant une intégration YunoHost plus poussée (LDAP/SSO, provisionnement automatique de BDD, hooks de sauvegarde natifs), un paquet `_ynh` dédié reste recommandé — cette app échange cette intégration contre la flexibilité et la rapidité de mise en place.

## Avertissements / informations importantes

- Seules les images de la liste blanche de logiciels libres peuvent être installées. Pour une image non listée, utilisez un catalogue personnalisé ou `yunohost app install <url_git>`.
- Docker doit être installé sur le serveur avant d'installer cette app (`sudo apt install docker.io`)
- Les conteneurs s'exécutent avec `--security-opt no-new-privileges` et le socket Docker n'est jamais monté à l'intérieur
- Cette app ne s'intègre **pas** avec le SSO/LDAP de YunoHost — chaque conteneur fonctionne comme un service indépendant
- Cette app ne fonctionnera **pas** si YunoHost lui-même s'exécute dans un conteneur Docker
- Seules les données dans le volume `/data` monté sont sauvegardées — les données ailleurs dans le conteneur sont perdues lors d'une mise à jour
- L'action de mise à jour re-télécharge l'image épinglée et recrée le conteneur

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
