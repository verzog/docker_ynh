# Gestionnaire de conteneurs Docker

Déployez et gérez un conteneur Docker **de logiciel libre vérifié** sur votre serveur YunoHost avec une gestion intégrée via systemd.

## Ce que fait cette application

Ce paquet YunoHost vous permet d'exécuter l'une des **images de logiciels libres vérifiées d'une liste blanche** en tant que service géré sur votre instance YunoHost. Plutôt que de tirer une image arbitraire depuis Docker Hub, vous choisissez une application dans une courte liste ; le paquet gère la référence exacte de l'image, sa version et son port interne. Chaque installation crée un conteneur indépendant qui :

- Démarre automatiquement au démarrage du serveur
- Peut être géré via le panneau d'administration YunoHost (démarrer/arrêter/redémarrer)
- Stocke les données persistantes dans un volume optionnel (`/data` dans le conteneur)
- Journalise vers systemd pour un monitoring facile
- Supporte le déploiement multi-instance (exécuter plusieurs conteneurs en parallèle)

## Images de logiciels libres vérifiées

Seules les images suivantes peuvent être installées. Chacune est une application de logiciel libre connue, épinglée à une version explicite (jamais `:latest`) pour des installations reproductibles et un logiciel exécuté vérifiable.

| Choix | Image | Licence | Port interne |
|---|---|---|---|
| `vaultwarden` | `vaultwarden/server` | AGPL-3.0-only | 80 |
| `gitea` | `gitea/gitea` | MIT | 3000 |
| `freshrss` | `freshrss/freshrss` | AGPL-3.0-only | 80 |
| `uptime-kuma` | `louislam/uptime-kuma` | MIT | 3001 |
| `ghost` | `ghost` | MIT | 2368 |
| `nginx` | `nginx` (alpine) | BSD-2-Clause | 80 |
| `mariadb` | `mariadb` | GPL-2.0-only | 3306 |
| `postgres` | `postgres` (alpine) | PostgreSQL | 5432 |

Les versions épinglées exactes se trouvent dans `scripts/_common.sh` (table `CURATED_IMAGES`). Pour proposer l'ajout d'une image, ouvrez une pull request — elle doit être un logiciel libre avec une licence claire.

## Fonctionnalités principales

✅ **Uniquement des images de logiciels libres vérifiées** — reproductibles, licence enregistrée, versions épinglées
✅ **Géré comme service systemd** — Intégré aux contrôles de service YunoHost
✅ **Stockage persistant optionnel** — Montez un volume `/data` pour les données du conteneur
✅ **Options Docker personnalisées** — Passez des variables d'environnement et volumes supplémentaires
✅ **Support multi-instance** — Déployez plusieurs conteneurs indépendamment
✅ **Politique de redémarrage configurable** — always, unless-stopped, on-failure ou manual
✅ **Renforcement par défaut** — `--security-opt no-new-privileges`, pas de montage du socket Docker, bac à sable systemd

## Limitations importantes

⚠️ **Images vérifiées uniquement** — Les images Docker Hub arbitraires ne sont volontairement pas installables ici. Pour exécuter une image non listée, utilisez un catalogue personnalisé ou `yunohost app install <url_git>`.
⚠️ **Pas d'intégration SSO/LDAP** — Les conteneurs s'exécutent indépendamment et ne s'intègrent pas aux comptes utilisateurs YunoHost
⚠️ **Pas pour YunoHost dans Docker** — Cette app ne fonctionnera pas si YunoHost lui-même s'exécute dans un conteneur Docker
⚠️ **La sauvegarde couvre uniquement les volumes montés** — Les données stockées exclusivement dans le conteneur (pas dans `/data`) ne sont pas sauvegardées
⚠️ **Les mises à jour recréent le conteneur** — L'upgrade re-tire l'image épinglée et recrée le conteneur
