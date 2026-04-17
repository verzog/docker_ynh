# Guide administrateur : Gestionnaire de conteneurs Docker

Guide pour les admins YunoHost gérant des conteneurs Docker via cette app.

## Gestion de votre conteneur

### Voir le statut
```bash
yunohost service status docker_container
```

### Voir les logs
```bash
journalctl -u docker_container -f
```

### Démarrer / Arrêter / Redémarrer
```bash
yunohost service start docker_container
yunohost service stop docker_container
yunohost service restart docker_container
```

### Exécuter des commandes dans le conteneur
```bash
docker exec -it docker_container bash
```

## Gestion de la configuration

### Mettre à jour les options Docker
```bash
yunohost app setting docker_container --key=docker_options --value="-e VAR=valeur -p 8080:80"
systemctl restart docker_container
```

### Changer la politique de redémarrage
```bash
yunohost app setting docker_container --key=restart_policy --value="unless-stopped"
systemctl restart docker_container
```

## Sauvegarde et restauration

### Ce qui est sauvegardé
- Le volume `/data` monté (si activé)
- La configuration du service systemd
- Les paramètres et métadonnées d'installation

### Sauvegarde manuelle des bases de données

**PostgreSQL** :
```bash
docker exec docker_container pg_dump -U postgres mabase > backup.sql
```

**MySQL** :
```bash
docker exec docker_container mysqldump -u root -p mabase > backup.sql
```

## Dépannage

### Le conteneur s'arrête immédiatement
Vérifiez les logs :
```bash
journalctl -u docker_container -n 100
```

### Port déjà utilisé
```bash
sudo netstat -tulpn | grep 8080
```

### Espace disque insuffisant
```bash
docker image prune -a
docker container prune
```

## Support

Pour les problèmes, vérifiez les logs : `journalctl -u docker_container -f`
Signalez les problèmes sur : https://github.com/verzog/docker_container_ynh/issues
