# Merge notes
Merging upstream/main in one go is difficult and error-prone. Instead, do the following:

```bash
# start with a clean, up-to-date repo on the main branch
git stash -u
git fetch upstream
git checkout main
git pull

# merge the changes one commit at a time by rebasing a temporary upstream branch onto main
git branch upstream-main upstream/main
git checkout upstream-main
git rebase main

# fix merge conflicts one commit at a time, porting changes to VHDL.
# test and add additional merge fix commits

# create an empty merge commit marking the point at which upstream is merged in
# (give it a nice message before committing)
git checkout main
git merge upstream/main --allow-unrelated-histories -s ours --no-commit

# squash the merged changes into the empty merge commit we created
git checkout upstream-main -- .
git commit --amend

# clean up
git branch -D upstream-main
git stash pop
```