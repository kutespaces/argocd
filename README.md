# Notes

Problem: this is already a git repository but we may need another remote to push it to a local server thats connected to argocd. Maybe change remote during devcontainer creation.

Problem: it's a little weird that the user just has to commit but not to push.

Check out this repo: https://github.com/rockstorm101/gitweb-docker. Maybe we can just use this lightweight container to visualize all repositories in `workspaces`. It also allows unauthenticated access to http to pull the repos.

Upsides:
- user doesn't need to push at all
Downsides:
- we need to adjust pull frequency of argocd

Alternative:

- use other git server with ui.



Message an Felix:

Next steps bevor man es rausschicken kann:

- finde die ux weird mit commiten aber nicht pushen. Würde das gerne 1:1 haben wie bei in echt. Passt dir das?
- muss noch k9s installieren (gab errors mit dem feature)
- ggf. schauen dass man sowas wie lens connecten kann.
- würde gerne noch ein real-world setup mit mehreren stages präsentieren. Da kannst du mir nochmal die Struktur von charles mit kustomize schicken bzw. deinen aktuellen Favorite.
- geile Readme schreiben mit so ner Art Missionen / Guidance aber halt einfach als Markdown runterschreiben.
- ggf. DNS von devcontainer und pods verbinden dann kann man direkt auf alles zugreifen

Fehlt da noch was?

Dannach kann man

1. es ggf. schon rausballern mit LinkedIn Posts und schauen obs Leuten gefällt.
2. wenns Leuten gefällt bei ArgoCD nachhaken was man tun müsste damit die es publishen.
3. anderen Repos schicken und fragen ob die sowas für sich haben möchten.



# WALKTHROUGH

1. checkout dashboard
2. checkout app of apps
4. checkout podinfo
3. checkout game-2048
5. deploy own app in new folder
6. repo structure for real world projects
