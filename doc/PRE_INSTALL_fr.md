# Avant l'installation : Gestionnaire de conteneurs Docker

Veuillez lire ces prérequis et limitations avant d'installer.

## Prérequis système

### Docker doit être installé
Ce paquet nécessite que Docker soit déjà installé sur votre serveur YunoHost :

```bash
sudo apt update
sudo apt install docker.io
```

### Le démon Docker doit être actif
```bash
sudo systemctl status docker
```

Si Docker n'est pas actif, démarrez-le :
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

## Limitations importantes

### ❌ Pas d'intégration SSO/LDAP
Les conteneurs déployés via ce paquet **ne s'intègrent pas** à l'authentification centralisée de YunoHost (LDAP/OpenID Connect).

### ❌ Incompatible avec YunoHost-dans-Docker
Si YunoHost lui-même s'exécute dans un conteneur Docker, ce paquet ne fonctionnera pas.

### ⚠️ La sauvegarde couvre uniquement les données montées
- **Sauvegardé** : Fichiers stockés dans le répertoire `/data` du conteneur (si vous activez le volume de données)
- **NON sauvegardé** : Données dans d'autres chemins du conteneur

### ⚠️ Les mises à jour d'images réinitialisent le conteneur
Lors d'une mise à jour, la nouvelle image est tirée et le conteneur est recréé. Tout état non stocké dans `/data` est perdu.

## Recommandation : Testez d'abord

Commencez par une image de test comme `hello-world` pour vérifier la configuration, puis déployez des charges de travail en production.
