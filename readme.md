# Druchan.com

Repo to host source and compiled files of the website.

- Requirements
- Setup/installation
- Dev workflow
- Deploy workflow

## Requirements

- Node (any latest)
- Elm (> v0.19)
- Firebase CLI (for deployments)

## Setup/installation

- Clone the repo.
- Run `yarn setup`. Will install dependencies.

## Dev workflow

- Start the watcher
- Start the local server
- Modify files

### Start the watcher

In one terminal window:

```bash
~ yarn watch
```

### Start the local server

In _another_ terminal window:

```bash
~ yarn serve
```

### Modify files

Whenever you modify these files, the app will be recompiled. **Hard-refresh** the browser to see the changes.

```
- src/* # all files in src folder
- public/index.html
```

## Deploy workflow

- Build the app
- Deploy using `firebase` CLI

### Build the app

```bash
~ yarn build
```

### Deploy using `firebase` CLI

This steps assumes:
- you have `firebase` CLI installed. (`npm i -g firebase-tools` should do the trick)
- you are logged in to firebase CLI (`firebase login` should do the trick)
- you have set `firebase` to use the project (`firebase use druchan-website` should do the trick)

```bash
~ firebase deploy
```

Configurations in `firebase.json` and `.firebaserc` will take care of pushing the right folder/files to the right destination.
