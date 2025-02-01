#!/bin/bash
set -e  # 에러 발생 시 종료

REPO_DIR="$(pwd)"
CHARTS_DIR="${REPO_DIR}/helm/charts"
SOURCES_FILE="${REPO_DIR}/helm/sources.txt"

git pull origin main
git pull origin master

mkdir -p "$CHARTS_DIR"

while read -r repo; do
    [[ -z "$repo" || "$repo" == \#* ]] && continue
    repo_name=$(basename "$repo" .git)
    repo_path="${CHARTS_DIR}/${repo_name}"

    if [ -d "$repo_path" ]; then
        echo "Updating $repo_name..."
        cd "$repo_path" && git pull origin main && cd "$REPO_DIR"
    else
        echo "Cloning $repo_name..."
        git clone --depth=1 "$repo" "$repo_path"
    fi
done < "$SOURCES_FILE"

if [[ -n $(git status --porcelain) ]]; then
    git add helm/charts/
    git commit -m "Daily sync: $(date +'%Y-%m-%d')"
    git push origin main
else
    echo "No changes to commit."
fi
