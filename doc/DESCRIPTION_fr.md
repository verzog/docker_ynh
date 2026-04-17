# Gestionnaire de conteneurs Docker

Déployez et gérez n'importe quel conteneur Docker sur votre serveur YunoHost avec une gestion intégrée via systemd.

## Ce que fait cette application

Ce paquet YunoHost vous permet d'exécuter n'importe quelle image Docker depuis [Docker Hub](https://hub.docker.com) en tant que service géré sur votre instance YunoHost. Chaque installation crée un conteneur indépendant qui :

- Démarre automatiquement au démarrage du serveur
- Peut être géré via le panneau d'administration YunoHost (démarrer/arrêter/redémarrer)
- Stocke les données persistantes dans un volume optionnel (`/data` dans le conteneur)
- Journalise vers systemd pour un monitoring facile
- Supporte le déploiement multi-instance (exécuter plusieurs conteneurs en parallèle)

## Fonctionnalités principales

✅ **Tirez n'importe quelle image Docker publique** — nginx, PostgreSQL, votre app personnalisée, etc.
✅ **Géré comme service systemd** — Intégré aux contrôles de service YunoHost
✅ **Stockage persistant optionnel** — Montez un volume `/data` pour les données du conteneur
✅ **Options Docker personnalisées** — Passez des variables d'environnement, mappages de ports, volumes supplémentaires
✅ **Support multi-instance** — Déployez plusieurs conteneurs indépendamment
✅ **Politique de redémarrage configurable** — always, unless-stopped, on-failure ou manual
✅ **Journalisation intégrée** — Consultez les logs du conteneur via `journalctl`

## Limitations importantes

⚠️ **Pas d'intégration SSO/LDAP** — Les conteneurs s'exécutent indépendamment et ne s'intègrent pas aux comptes utilisateurs YunoHost
⚠️ **Pas pour YunoHost dans Docker** — Cette app ne fonctionnera pas si YunoHost lui-même s'exécute dans un conteneur Docker
⚠️ **La sauvegarde couvre uniquement les volumes montés** — Les données stockées exclusivement dans le conteneur (pas dans `/data`) ne sont pas sauvegardées
⚠️ **Les mises à jour d'images réinitialisent le conteneur** — L'upgrade re-tire l'image et recrée le conteneur
