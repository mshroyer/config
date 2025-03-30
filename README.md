# Unix Config and Dotfiles

This repository contains my portable Unix home directory configuration
dotfiles.  It should be cloned as a bare git repository into `$HOME/.cfg`,
then checked out with a working directory of `$HOME`.

This is based on the approach described in [this blog
post](https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/),
based on a [Hacker News comment by
StreakyCobra](https://news.ycombinator.com/item?id=11071754).

To setup the configuration repository on a new host:

    % alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
    % git clone --bare git@github.com:mshroyer/config.git $HOME/.cfg
    % config checkout

You may need to manually remove files that would be overwritten in order
for the checkout to succeed.  Finally, to prevent `config status` from
showing untracked files:

    % config config --local status.showUntrackedFiles no
