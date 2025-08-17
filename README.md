WeaponBack
===========

WeaponBack est une ressource Lua pour FiveM qui permet d'afficher les armes lourdes sur le dos des joueurs.  
Le script est entièrement configurable via **NativeUILua**, inclus dans la ressource.  
Facile à installer et entièrement personnalisable.

Fonctionnalités
---------------
- Affichage dynamique des armes sur le dos du joueur
- Compatible avec plusieurs groupes d'armes : ASSAULT, SHOTGUN, LAUNCHER
- Possibilité d'exclure certains groupes ou armes spécifiques
- Synchronisation des armes visibles pour tous les joueurs
- Menu NativeUI inclus pour activer/désactiver l’affichage et gérer les groupes d’armes
- Commande `/weaponback` et raccourci clavier (par défaut K) pour ouvrir le menu

Installation
------------
1. Placez le dossier `WeaponBack` dans le répertoire `resources` de votre serveur FiveM.
2. Ajoutez dans votre `server.cfg` :
start WeaponBack

markdown
Copier
Modifier
3. Configurez les offsets et rotations des armes si nécessaire dans `cl_weapons-on-back.lua`.

Configuration
-------------
Dans `cl_weapons-on-back.lua`, vous pouvez ajuster :

- **SETTINGS_BY_GROUP** : os, offset et rotation pour chaque groupe d’armes
- **config.enabled** : activer ou désactiver l’affichage global
- **config.excludedGroups** : exclure certains groupes d’armes
- **config.excludedWeapons** : exclure certaines armes individuellement

Contribution
------------
Les contributions sont les bienvenues. Forkez le dépôt, créez une branche pour vos modifications et envoyez une pull request.

Auteur
------
AzizAnakin – [GitHub](https://github.com/AzizAnakin/Weaponback---Fivem---Standalone)
