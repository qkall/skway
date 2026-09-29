#!/bin/bash
# title="$icon_trm Github Update"
# Inspired by magdesign sxmop6 userscripts


# Prompt the user to enter the commit message for the updated changes[cite: 2]
COMMIT_MSG=$(printf "" | sxmo_dmenu.sh -p "Commit message:")

# Exit if the user closes the menu or provides an empty message[cite: 2]
if [ -z "$COMMIT_MSG" ]; then
    exit 0
fi

# Execute the git update sequence[cite: 3]
git stash
git pull origin main --rebase
git push origin main
git stash pop
git add .
git commit -m "$COMMIT_MSG"
git push origin main
