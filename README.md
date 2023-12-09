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
