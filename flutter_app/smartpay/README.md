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


## Les formulaire dynamique
*Propos*: Aficher et gerer dynamiquement des champs de formulaire.

Dans odoo, des méthode comme default_get ou encore onchange sont charger d'aider
l'application frontend pour rendre dynamiquement les formulaire.
Pour permettre à nôtre application smartpay de suivre le même dessein, nous avons ajouter des fonctionnalités suivante:
>
>    * Créeation de nouvelle méthode dans la session `defaultGet`,
      `searchCount`, `searchRead`, `create`, `write`
>    * Des model repressantant des model odoo (`OdooModel`, `OdooField`, `OdooFieldType`) ont été crée avec quelque
      méthode `defaultGet`, ...
>    * Un Widget Formulaire `AppForm` à été créer par défaut pour toute
      l'application. Il utilise les méthode des model précédant pour
      être dynamique
>    * Une vue callandrier pour test à été ajouté
>    * Deux formulaire ont été ajouté dans l'interface des congés, l'une
      utilise le nouveau type de formulaire (**Demande de congé**) et
      l'autre l'ancien