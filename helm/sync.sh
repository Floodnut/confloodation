#!/bin/bash
set -e  # 에러 발생 시 종료

REPO_DIR="$(pwd)"
CHARTS_DIR="${REPO_DIR}/helm/charts"
SOURCES_FILE="${REPO_DIR}/helm/sources.txt"

mkdir -p "$CHARTS_DIR"

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
        git clone --depth=1 "$repo" "$repo_path"

        # 기본 브랜치 확인 후 Checkout
        cd "$repo_path"
        default_branch=$(git remote show origin | awk '/HEAD branch/ {print $NF}')
        git checkout "$default_branch" || true

        cd "$REPO_DIR"
    fi
done < "$SOURCES_FILE"

git add helm/charts/
git commit -m "Daily sync: $(date +'%Y-%m-%d')"
git push origin main
