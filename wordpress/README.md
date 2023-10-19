# Import WordPress

## L'environnement

1. Dupliquez le fichier .env.example et renommez le .env
2. Dans ce fichier .env, intégrez les données :
- l'adresse de l'instance
- le jeton secret
- l'identifiant du site dans lequel vous voulez importer

## Le script

```
bundle update
bundle exec ruby import.rb
```

## Les tests

Un jeu de test couvre des cas problématiques dans WordPress, avec Minitest.

Pour le lancer : 

```
rake
```