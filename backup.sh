#!/bin/sh
# Installation de l'outil AWS (nécessaire car on utilise l'image postgres-alpine)
apk add --no-cache aws-cli > /dev/null

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="/tmp/backup_$TIMESTAMP.sql.gz"

echo "Démarrage du backup de [$POSTGRES_DB] sur [$POSTGRES_HOST]..."

# Exécution du backup avec les variables fournies par le CronJob
PGPASSWORD="$POSTGRES_PASSWORD" pg_dump -h "$POSTGRES_HOST" -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > "$BACKUP_FILE"

# Vérification de sécurité
SIZE=$(stat -c%s "$BACKUP_FILE")
if [ "$SIZE" -lt 100 ]; then
    echo "ERREUR : Le fichier de backup est vide. Vérifiez les identifiants !"
    exit 1
else
    echo "Succès : Backup généré ($SIZE octets)."
    sha256sum "$BACKUP_FILE" > "$BACKUP_FILE.sha256"
    
    echo "Envoi vers S3..."
    aws s3 cp "$BACKUP_FILE" "s3://$S3_BUCKET/backups/"
    aws s3 cp "$BACKUP_FILE.sha256" "s3://$S3_BUCKET/backups/"
    echo "Backup terminé avec succès !"
fi
