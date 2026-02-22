KubeBackup : System de backup Automatisé sur Kubernetes

Automatisation de bout en bout des sauvegardes PostgreSQL vers S3, avec testing continu de la restauration dans un environnement de test, le tout piloté par GitLab CI/CD.

    Contexte et Enjeu Métier (Disaster Recovery)

Dans les environnements de production modernes, la présence d'une politique de sauvegarde ne garantit pas la reprise d'activité.

Une sauvegarde externalisée n'a de valeur que si la capacité à la restaurer a été prouvée.

Ce projet répond à une problématique critique de Continuité buisness : 

implémenter un système qui ne se contente pas de générer des backups, mais qui valide automatiquement leur intégrité et le fait qu'ils soient exploitable.



    Architecture et Flux de Données (Workflow)

L'infrastructure repose sur une isolation des environnements (Namespaces) pour garantir la sécurité des données:

1. Environnement de Production (app-test) 


Sauvegarde continue : Un CronJob Kubernetes extrait la base de données PostgreSQL.

Sécurisation : Compression à la volée et génération d'une empreinte cryptographique (hash SHA256) pour garantir l'intégrité de l'artefact.

Externalisation : Envoi automatisé vers un bucket Amazon S3.


2. Environnement de Validation (app-restore-test) 

Test destructif : Un second CronJob, décalé dans le temps, récupère dynamiquement le dernier artefact sur S3.

Validation par l'échec : Le script détruit intégralement le schéma de la base de test (DROP SCHEMA CASCADE) avant d'y réinjecter le backup.

Résultat : Le succès de cette tâche certifie qu'en cas de crash majeur, le système est techniquement capable de reconstruire la donnée en partant de zéro.

    Stack Technique & GitOps

Orchestration : Kubernetes (K3s) pour une empreinte ressource minimale.

SGBD : PostgreSQL 15 (Image Alpine optimisée).

Cloud Storage : Amazon S3 (AWS CLI).

CI/CD (GitOps) : Pipeline GitLab avec un GitLab Runner (Shell executor) local pour un déploiement continu "as-code".

Sécurité : Injection dynamique des credentials via les Secrets natifs de Kubernetes.


    Approche et Productivité 

Pour faciliter le deploiment de ce projet,  je me suis appuyé sur l'IA Manus.

L'IA a été utilisée pour accélérer l'écriture de la base des manifests YAML et syntaxe des scripts Bash. Cette approche m'a permis de me concentrer sur le véritable travail de l'ingénieur DevOps qui est la conception de l'architecture, la logique d'isolation, la sécurisation des flux réseau, la gestion du stockage persistant et le troubleshooting système.
