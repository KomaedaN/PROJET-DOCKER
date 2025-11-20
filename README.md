Vidéo Docker, on se base sur le compose.yml.

Ordre de compose.yml :
- Build de PHP1 et PHP2
- Création des volumes : db_data, vendor_data, storage_data
- Démarrage de db
- healthcheck de db jusqu'à être ok
- démarrage de PHP1 et PHP2 (attend que db soit healthy)
- démarrage de Nginx1, Nginx2 et Vite (ils attendent que PHP1 ou PHP2 soit démarré)

- PHP1 et PHP2 :
On commence par build l’image PHP depuis notre dockerFile.

DockerFile :
- On utilise l’image Ubuntu.
- On configure les variables d’environnement pour le setup PHP.
- on fait une mise à jour, puis on installe PHP et ses dépendances
- On copie l’image de Composer qui permet d’installer des plugins PHP tels que php mailer.
- On définit le chemin d’accès pour ensuite copier les fichiers de setup de composer.
- puis on l’installe
- on copie l’ensemble du projet dans le var/www/html/
- on donne les permissions fichiers/dossier nécessaires à l’utilisateur www/data
- Puis on donne les permissions pour l'entrypoint.sh.
- Le Entrypoint et le CMD se déclencheront à la création du conteneur.

Entrypoint.sh :
- on se place dans les dossiers
- on vérifie que la clé soit vide, si c’est le cas, on la génère et on initialise la BDD

- DB :
container_name permet d'assigner un nom à notre conteneur
On se base sur la dernière version de l'image officielle de MySQL.
On déclare les variables d'environnement nécessaires, à savoir le mdp root et le nom de la db (on utilise .env pour ne pas rendre les valeurs visibles).
On monte le volume db_data sur /var/lib/MySQL, ce qui va permettre de faire persister les données.
Expose sur le port 3306
Ensuite, on utilise un healthcheck qui va permettre de vérifier que le service db soit bien valide et fonctionnel, ça va nous permettre de faire attendre le bon fonctionnement de "db" avant de démarrer les services Php1 et Php2.

- PHP1

Comme vu précédemment, nous avons déjà build l'image depuis notre fichier Docker File. Context permet de spécifier la localisation, puis dockerfile à pointer sur le bon dockerfile.
On initialise les volumes, comme vu précédemment, la valeur précédente les ":" désigne la location de nos fichiers en local à copier, puis la suite des ":" désigne l'endroit dans lequel ils seront "collés" dans notre conteneur.
depends_on puis condition service healthy force PHP1 à attendre que le service db soit complètement terminé et fonctionnel avant de se démarrer lui même (il dépend du bon fonctionnement du service db)

- PHP2

Exactement comme PHP1, à l'exception du dockerfile qui possède une différence, pas d'entrypoint.sh dans PHP2. 
Nous n'avons pas besoin de l'utiliser 2 fois, donc on le retire du dockerFile PHP2.

-Nginx1

on se base sur l'image officielle et la plus récente de nginx
on l'expose sur le port 8080 qui nous permettra d'y accéder en local
depends_on sans la condition cette fois, permet d'attendre que PHP1 soit démarré avant de se démarrer lui-même, la différence est qu'il n'est pas nécessaire que PHP1 soit prêt pour se lancer.
puis une nouvelle fois on setup les volumes

- Nginx2
  
Exactement comme Nginx1 sauf pour le port exposé qui est différent et lui dépend de PHP2

- Vite 

utilise l'image de node version 20
working_dir va définir le répertoire de travail 
command nous permet de lancer au démarrage npm installe puis npm run dev qui va lancer le serveur dev de vvite 
Expose sur le port 5173
Il dépend de PHP1 pour se lancer, même si je ne suis pas sûr à 100% que ce soit nécessaire, c'est là que je suis dans le doute

