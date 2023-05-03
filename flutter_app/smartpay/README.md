# smartpay

Smart Pay project.

## Comment Démarer

Pour commencer créer dans la racine un fichier `.env`.
Il doit contenir les informations suivantes:
* **ODOO_INSTANCE_HOST**: Represente url vers l'instance odoo. En development sa valeur est `http://10.0.2.2:8069`


## Menu Latéral

La configuration du menu latéral (nom et icon) se fait à partir du fichier `assets/data/side_menus.json`.
C'est un ficier json qui contient les informations suivantes:
* **display_name**: Nom qui doit s'afficher dans la liste de menu
* **icon**: Iconne vien de [Material Icon](https://fonts.google.com/icons?selected=Material+Icons:summarize:&icon.query=report&icon.platform=flutter) ou [Flutter material icon librery](https://api.flutter.dev/flutter/material/Icons-class.html)
#### TODO: 
* sousmenu
* actions