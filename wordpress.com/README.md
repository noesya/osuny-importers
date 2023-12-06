# Import WordPress

## L'environnement

1. Dupliquez le fichier .env.example et renommez le .env
2. Dans ce fichier .env, intégrez les données :
- l'adresse de l'instance
- le jeton secret
- l'identifiant du site dans lequel vous voulez importer
- l'identifiant d'import
- l'adresse de l'API sur wordpress.com

## Le script

```
bundle update
bundle exec ruby import.rb
```
