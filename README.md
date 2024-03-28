This repo contains:
1. the build tools to generate the docker files used to build the images in [zyasserd/agda](https://hub.docker.com/r/zyasserd/agda).
2. `devcontainer.json` that creates a VSCode workspace to use the image, and adds a link to cubical directory in the workspace.

Build time ~35 min on an M1 MacBook Pro.

Run `./build.sh --help` to see the build options.
