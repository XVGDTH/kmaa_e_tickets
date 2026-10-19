# kmaa_e_tickets

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Tester l'application Web via un tunnel

Lancer le serveur Web Flutter sur une adresse accessible depuis le tunnel :

```powershell
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --dart-define=API_URL=https://<tunnel-backend>/api
```

Remplacer `https://<tunnel-backend>/api` par l'adresse HTTPS publique du backend,
puis transférer le port `8080`. Sans `API_URL`, l'application utilise
`http://localhost:8000/api` : dans le navigateur d'un collègue, `localhost`
désigne son propre ordinateur, pas celui qui héberge le backend. Le backend doit
être joignable depuis Internet et autoriser l'origine du tunnel Web dans sa
configuration CORS. Pour éviter les messages de communication de l'extension
Flutter de débogage lors d'un test partagé, utiliser une compilation de
production (`flutter build web --release`) et héberger le contenu de `build/web`.
