#!/bin/bash
set -e

REPO_DIR="$(pwd)"
CHARTS_DIR="helm/charts"
SOURCES_FILE="helm/sources.txt"

while read -r repo; do
    echo Sync $repo...

    [[ -z "$repo" || "$repo" == \#* ]] && continue
    repo_name=$(basename "$repo" .git)
    repo_path="${CHARTS_DIR}/${repo_name}"

    if [ -d "$repo_path" ]; then
        echo "Updating $repo_name..."
        cd "$repo_path"

        default_branch=$(git remote show origin | awk '/HEAD branch/ {print $NF}')
        git pull origin "$default_branch" || true

        cd "$REPO_DIR"
    else
        echo "Cloning $repo_name..."
        git clone "$repo" "$repo_path"
        rm -rf "./$repo_path/.git"
        rm -rf "./$repo_path/.github"


        cd "$repo_path"
        default_branch=$(git remote show origin | awk '/HEAD branch/ {print $NF}')
        git checkout "$default_branch" || true

        cd "$REPO_DIR"
    fi

done < "$SOURCES_FILE"

cd "$REPO_DIR"
if [[ -n $(git status --porcelain) ]]; then
    git add helm/charts/
    git commit -m "Daily sync: $(date +'%Y-%m-%d')"
    git push origin main
else
    echo "No changes to commit."
fi