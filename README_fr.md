# Docker Container pour YunoHost

> **Avertissement :** Cette application est destinée aux utilisateurs avancés. Les conteneurs Docker ne sont pas intégrés au SSO ou au LDAP de YunoHost — utilisez des applications YunoHost natives quand elles sont disponibles.

## Que fait cette application ?

Ce paquet YunoHost vous permet de télécharger n'importe quelle image Docker depuis [hub.docker.com](https://hub.docker.com) et de l'exécuter comme un service systemd géré sur votre serveur YunoHost. Chaque instance exécute un conteneur et est gérée indépendamment via le panneau d'administration YunoHost ou la CLI.

Fonctionnalités :
- Télécharger n'importe quelle image Docker publique
- Gestion du conteneur comme un service systemd (démarrage/arrêt/redémarrage depuis la page Services de YunoHost)
- Répertoire de données persistant optionnel monté à `/data` dans le conteneur
- Passage d'options Docker personnalisées (ports, variables d'environnement, volumes supplémentaires)
- Multi-instance : déployez autant de conteneurs que nécessaire
- Politique de redémarrage configurable

## Limitations

- Aucune intégration SSO ou LDAP — les conteneurs s'exécutent indépendamment
- Ne fonctionne **pas** si YunoHost lui-même tourne dans un conteneur Docker
- La mise à jour de l'image nécessite d'exécuter l'action de mise à jour YunoHost (qui re-télécharge `latest` ou le tag épinglé)
- La sauvegarde couvre uniquement le volume `/data` monté ; les données stockées exclusivement à l'intérieur du conteneur ne sont pas sauvegardées

## Installation

Depuis le panneau d'administration YunoHost ou la CLI :

```bash
yunohost app install https://github.com/verzog/docker_container_ynh
```

Vous serez invité à saisir :

| Paramètre | Description |
|---|---|
| `container_name` | Étiquette lisible pour ce conteneur |
| `image` | Image Docker (ex : `nginx:latest`) |
| `restart_policy` | `always`, `unless-stopped`, `on-failure` ou `no` |
| `use_data_volume` | Monter `$data_dir` à `/data` dans le conteneur |
| `docker_options` | Options `docker run` supplémentaires (ports, variables, volumes) |

## Gestion du conteneur

```bash
# Démarrer / arrêter / redémarrer
yunohost service start docker_container
yunohost service stop docker_container

# Consulter les journaux
journalctl -u docker_container -f

# Entrer dans le conteneur en cours d'exécution
docker exec -it docker_container bash
```

## Contribuer

Les pull requests sont bienvenues sur <https://github.com/verzog/docker_container_ynh>.
