#!/bin/sh
# 1. Installation des outils
apk add --no-cache aws-cli postgresql-client > /dev/null

echo "--- DÉBUT DU TEST DE RESTAURATION ---"

# 2. Recherche du backup le plus récent
LATEST_BACKUP=$(aws s3 ls s3://$S3_BUCKET/backups/ --recursive | sort | tail -n 1 | awk '{print $4}')

if [ -z "$LATEST_BACKUP" ]; then
    echo "ERREUR : Aucun backup trouvé sur S3 !"
    exit 1
fi

echo "Fichier trouvé : $LATEST_BACKUP"
aws s3 cp s3://$S3_BUCKET/$LATEST_BACKUP /tmp/restore.sql.gz

# 3. NETTOYAGE ET RESTAURATION (Utilisation de PGPASSWORD pour chaque commande)
export PGPASSWORD="$POSTGRES_PASSWORD"

echo "Nettoyage de la base de test..."
psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

echo "Injection des données du backup..."
# On utilise -w pour dire à psql de ne jamais demander de mot de passe (no-password)
gunzip -c /tmp/restore.sql.gz | psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -w

# 4. VÉRIFICATION
if [ $? -eq 0 ]; then
    echo "--- SUCCÈS : La restauration a été testée et validée ! ---"
else
    echo "--- ÉCHEC : La restauration a rencontré une erreur ! ---"
    exit 1
fi
