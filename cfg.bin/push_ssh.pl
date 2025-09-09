#!/usr/bin/env perl

# Automates a common task when cloning GitHub repos from an HTTPS URL: I'll
# often want to set the push-specific URL to use SSH authentication.

use warnings;
use strict;

my ($remote) = @ARGV;

if (not defined $remote) {
    $remote = "origin";
}

my $pull_url = `git remote get-url $remote` || die("Failed to get remote's URL");
my $push_url;

if ($pull_url =~ /^https?:\/\/(.*?)\/(.*)/) {
    $push_url = "git\@$1:$2";
    unless ($push_url =~ /.*\.git$/) {
        $push_url .= ".git";
    }
} else {
    die("Remote $remote doesn't have an HTTP-based URL");
}

`git remote set-url --push $remote $push_url`;
