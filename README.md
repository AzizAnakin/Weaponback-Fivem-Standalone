# WeaponBack - FiveM - Standalone

WeaponBack est une ressource standalone pour **FiveM** qui permet d'afficher les armes lourdes sur le dos des joueurs.  
Le script est entièrement **configurable via NativeUILua**, inclus dans la ressource.

---

## Fonctionnalités

- Affichage dynamique des armes sur le dos du joueur.
- Compatible avec plusieurs groupes d'armes :  
  - **ASSAULT** (fusils d’assaut, SMG, MG, sniper)  
  - **SHOTGUN** (fusils à pompe)  
  - **LAUNCHER** (lance-roquettes, RPG, railgun, feu d’artifice)
- Possibilité d'exclure certains groupes ou armes spécifiques.
- Synchronisation des armes visibles pour **tous les joueurs** sur le serveur.
- Menu NativeUI inclus et configurable :  
  - Activer/désactiver l’affichage des armes sur le dos.  
  - Masquer ou afficher chaque groupe d’armes individuellement.
- Commande et raccourci clavier :  
  - `/weaponback` pour ouvrir le menu.  
  - Touches configurables via KeyMapping (par défaut `K`).

---

## Installation

1. Placez le dossier `WeaponBack` dans votre répertoire `resources` FiveM.
2. Ajoutez `start WeaponBack` dans votre `server.cfg`.
3. Configurez les offsets et rotations des armes si nécessaire dans `cl_weapons-on-back.lua` (table `SETTINGS_BY_GROUP`).

---

## Configuration

- **SETTINGS_BY_GROUP** : Ajuste l’os, l’offset et la rotation pour chaque groupe d’armes.
- **config.enabled** : Activer ou désactiver l’affichage global.
- **config.excludedGroups** : Exclure certains groupes d’armes.
- **config.excludedWeapons** : Exclure certaines armes individuellement.

---

## Commandes

| Commande | Description |
|----------|-------------|
| `/weaponback` | Ouvre le menu NativeUI pour gérer l’affichage des armes sur le dos. |

---

## Lien GitHub

[WeaponBack sur GitHub](https://github.com/AzizAnakin/Weaponback---Fivem---Standalone)

---

## Notes

- Les armes équipées ne sont pas visibles sur le dos.  
- Synchronisation automatique toutes les 5 secondes pour les autres joueurs.

---

## Auteur

AzizAnakin
