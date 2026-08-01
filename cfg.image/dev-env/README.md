# Dev Environment Container

A container to bring up my main AlmaLinux 10 development environment.


## Building

The image can rebuilt with a new `update` build argument to apply package
updates without recreating everything from scratch:

    podman build --build-arg=update=$(date +%s) . -t dev-env


## Running a shell

To run a shell in a transient image, without bringing up systemd:

    podman run --rm -it dev-env /bin/zsh

To reuse the same mutable environment multiple times, create a named
container and enter it with `podman start`:

    podman create -it --name my-dev-env dev-env /bin/sh
    podman start -ai my-dev-env

If the container is already running, you can get a second shell with:

    podman exec -it my-dev-env /bin/zsh

but note that all shells will terminate when the initial shell command exits.


## Running with an SSH server

Create a container configured to launch systemd and with a port mapping:

    podman create \
      --name my-dev-systemd \
      --user 0 \
      --ipc=host \
      --cap-add=SYS_ADMIN \
      --cap-add=NET_ADMIN \
      --stop-signal=SIGRTMIN+3 \
      -p 2222:22 \
      -it \
      dev-env /sbin/init

Then just use `start` to launch it:

    podman start my-dev-env

You can also exec a shell within the running container, but you'll have to
pass `--user` to get the non-root user:

    podman exec --user mshroyer -it my-dev-env /bin/zsh

TODO: `--ipc=host` isn't ideal for isolation, but core systemd targets like
systemd-journald.socket currently fail with `--ipc=private`.
