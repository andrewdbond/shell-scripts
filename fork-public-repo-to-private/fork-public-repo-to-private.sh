#!/usr/bin/env bash

# Set exit immediately if a command exits with a non-zero status.
set -o errexit

# Set print shell lines as they're read, without variable expansion/substitution
set -o verbose

# If you have just downloaded this script you may need to set it to executable
: '
chmod +x fork-public-repo-to-private.sh
'

# First, create a corresponding private repo in your user account:
# https://github.com/new

# Variables to set - example: https://github.com/andrewdbond/shell-scripts
public_user="andrewdbond"
public_repo="shell-scripts"

private_user="andrewdbond"
private_repo="shell-scripts"

keep_public_repo_clone=false
in_public_clone_add_private_remote=false

# Can use SSH:
git_url="git@github.com:"
# Or if HTTPS is needed instead:
# git_url="https://github.com/"

# If will be pushing commits to the public repo, it's recommend to create a
# branch other than main in the public repo that will be the destination for
# commit merges from the private repo. In general, develop works well for this
# purpose.
branch="main"

# Now we’re ready to proceed.
public_repo_full_url="$git_url$public_user/$public_repo.git"
private_repo_full_url="$git_url$private_user/$private_repo.git"

# Clone (mirror) the existing public repo into our newly created private repo.
# This won’t affect anything in the existing public one.
git clone --bare "$public_repo_full_url"
cd "$public_repo.git"
git push --mirror "$private_repo_full_url"

# Remove the bare clone.
cd ..
rm -rf "$public_repo.git"

# Clone a local copy private repo.
git clone "$private_repo_full_url"

# Switch to the desired branch in our new private repo.
cd "$private_repo"
git checkout -b "$branch"
git branch --set-upstream-to="origin/$branch" "$branch"

# In the private repo, add a remote back to the public repo
git remote add "public" "$public_repo_full_url"
cd ..

# Set up remotes to the private repo in the public repo, so we can push.
if [ "$keep_public_repo_clone" = true ] ; then
    git clone "$public_repo_full_url"
    cd "$public_repo"
    if [ "$in_public_clone_add_private_remote" = true ] ; then
        git remote -v
        git remote add "$private_repo" "$private_repo_full_url"
    fi
    git remote -v
    cd ..
fi

# Here’s how to make a pull request from the private repo back to the public
# one. Then simply make a pull request from the branch (e.g. develop) back to
# main.
#
# cd "$public_repo"
# git pull "$private_repo" "$branch"
# git push origin "$branch"
# cd ..

# Inspired by https://steinbaugh.com/posts/git-private-fork.html