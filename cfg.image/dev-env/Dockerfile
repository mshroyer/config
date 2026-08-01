FROM almalinux/10-base:latest

ARG USERNAME=mshroyer
ARG USER_UID=1083
ARG USER_GID=1083


########################################################################
# System configuration
########################################################################

# EPEL
RUN dnf install -y 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled crb && \
    dnf install -y epel-release

# System packages
RUN dnf groupinstall -y "Development Tools"
RUN dnf install -y emacs iproute openssh-server openssl sudo tmux zsh

RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd \
        --uid "${USER_UID}" \
        --gid "${USER_GID}" \
        --create-home \
        --shell /bin/zsh \
        "${USERNAME}"

# Unlock the user by setting a random password, so that OpenSSH will let us
# log in
RUN openssl rand -base64 24 | passwd --stdin "${USERNAME}"

# Give user sudo access
RUN usermod -a -G wheel "${USERNAME}"
COPY files/sudoers /etc/sudoers
RUN chmod 440 /etc/sudoers

# Remote access
COPY files/sshd_config /etc/ssh/sshd_config
RUN chmod 600 /etc/ssh/sshd_config
RUN mv /etc/ssh/sshd_config.d/50-redhat.conf \
    /etc/ssh/sshd_config.d/50-redhat.conf.disabled
RUN systemctl enable sshd


########################################################################
# User environment
########################################################################

USER ${USERNAME}
WORKDIR /home/${USERNAME}
ENV LOGNAME="${USERNAME}"

# Make .ssh directory
RUN mkdir /home/${USERNAME}/.ssh
RUN chmod 700 /home/${USERNAME}/.ssh

# Setup my personal Unix dotfiles config
RUN git clone --bare https://github.com/mshroyer/config.git /home/${USERNAME}/.cfg
RUN rm /home/${USERNAME}/.zshrc
RUN git --git-dir=/home/${USERNAME}/.cfg --work-tree=/home/${USERNAME} checkout
RUN git --git-dir=/home/${USERNAME}/.cfg config --local status.showUntrackedFiles no
RUN git --git-dir=/home/${USERNAME}/.cfg remote set-url --push \
    origin git@github.com:mshroyer/config.git

# Emacs configuration
RUN rm -f /home/${USERNAME}/.emacs
RUN git clone https://github.com/mshroyer/emacs-dotfiles.git /home/${USERNAME}/.emacs.d
RUN git -C /home/${USERNAME}/.emacs.d remote set-url --push \
    origin git@github.com:mshroyer/emacs-dotfiles.git
# Run our Emacs init one initial time so that packages will be ready on first use.
RUN emacs --batch -l /home/${USERNAME}/.emacs.d/batch-init.el

# # Rust
# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup.sh && \
#     sh /tmp/rustup.sh --profile minimal -y && \
#     rm /tmp/rustup.sh
# ENV PATH="${PATH}:/home/${USERNAME}/.cargo/bin"
# RUN cargo install cargo-binstall
# RUN cargo binstall jj-cli


########################################################################
# Updates
########################################################################

# A cache-busting gate for update actions, so that we can create an updated
# version of the image without rebuilding everything, such as with:
#
# podman build --build-arg=update=$(date +%s)
ARG update=1

# Update system packages
RUN sudo dnf update -y

# Update Unix dotfiles and Emacs config
RUN git --git-dir=/home/${USERNAME}/.cfg --work-tree=/home/${USERNAME} pull
RUN git -C /home/${USERNAME}/.emacs.d pull
RUN emacs --batch -l /home/${USERNAME}/.emacs.d/batch-upgrade.el


########################################################################
# Shell
########################################################################

# When running as a regular user, just launch zsh.
CMD ["/bin/zsh"]
