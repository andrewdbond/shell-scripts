#!/usr/bin/env bash
set -o errexit # Set the shell option to exit immediately if a command exits with a non-zero status.
set -o verbose # Set the shell option to print shell input lines as they are read (but without variable expansion/substitution)

# If you have just downloaded this script you may need to set it to executable
: '
chmod +x fork-public-repo-to-private.sh
'

# Variables to set - https://github.com/${public_user}/${public_repo}"
public_user="andrewdbond"
public_repo="shell-scripts"

private_user="andrewdbond"
private_repo="shell-scripts"

keep_public_repo_clone=false
add_private_remote_to_public_repo=false

# Can use git@github.com
git_url="git@github.com:"
# Or if HTTPS is needed instead:
# git_url="https://github.com/"

# If we'll be pushing commits to the public repo, we recommend creating a branch other than master
# in the public repo that will be the destination for commit merges from the private repo. In general,
# develop works well for this purpose.
branch="master"

# Now we’re ready to define and clone the repos from GitHub. First, create a corresponding
# private repo in your user account using the new repo UI: https://github.com/new
# In our example here, the name should be basejump-private.
public_repo_full_url="$git_url$public_user/$public_repo.git"
private_repo_full_url="$git_url$private_user/$private_repo.git"

# Clone (mirror) the existing public repo into our newly created private repo on GitHub. Note
# that this won’t affect anything in the existing public one.
git clone --bare "$public_repo_full_url"
cd "$public_repo.git"
git push --mirror "$private_repo_full_url"

# Safe to remove the bare clone.
cd ..
rm -rf "$public_repo.git"

# Clone a local copy private repo.
git clone "$private_repo_full_url"

# Ensure we switch away from the master branch in our new private repo.
cd "$private_repo"

# Switch away from master branch.
git checkout -b "$branch"
git branch --set-upstream-to="origin/$branch" "$branch"
git remote add "public" "$public_repo_full_url"
cd ..


# Set up remotes to the private repo in the public repo, so we can push. We’re switching to the
# corresponding branch (e.g. “develop” here).
if [ "$keep_public_repo_clone" = true ] ; then
    git clone "$public_repo_full_url"
    cd "$public_repo"
    if [ "$keep_public_repo_clone" = true ] ; then
        git remote -v
        git remote add "$private_repo" "$private_repo_full_url"
    fi
    git remote -v
    cd ..
fi

# Here’s how to make a pull request from the private repo back to the public one. Then simply
# make a pull request from the branch (e.g. develop) back to master.
#
# cd "$public_repo"
# git pull "$private_repo" "$branch"
# git push origin "$branch"
# cd ..

# Based off of https://steinbaugh.com/posts/git-private-fork.html