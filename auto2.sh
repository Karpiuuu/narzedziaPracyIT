#!/bin/bash

REPO_URL="https://github.com/Karpiuuu/pythonConversionFileProject.git"
PROJECT_DIR="projekt"

show_help() {
    echo "Użycie: ./auto2.sh [opcje]"
    echo "--init            Konfiguruje Git: autor, edytor i narzędzie do mergowania"
    echo "--install         Klonuje repozytorium, ustawia PATH, tworzy path.bin"
    echo "--update          Aktualizuje gałąź o zmiany z main i wypycha"
    echo "--authorrights    Eksportuje commity autora z ostatniego miesiąca i pakuje do archiwum"
}

git_init_config() {
    git config --global user.name "Karpiuuu"
    git config --global user.email "karpiucorp@gmail.com"
    git config --global core.editor "code"
    echo "Konfiguracja Git zakończona."
}

install_project() {
    git clone "$REPO_URL"
    cd "$PROJECT_DIR" || exit 1
    echo "export PATH=\$PATH:$(pwd)" >> ~/.bashrc
    export PATH=$PATH:$(pwd)

    {
        date
        nproc
        echo "$PATH"
    } > path.bin

    echo "Repozytorium zainstalowane, path.bin utworzony."
}

update_branch() {
    current_branch=$(git branch --show-current)

    if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
        echo "Jesteś na gałęzi main/master. Stwórz własny branch, aby wykonać update."
        exit 1
    fi

    git fetch origin
    git merge origin/main || git merge origin/master
    git push origin "$current_branch"

    echo "Branch '$current_branch' zaktualizowany i wypchnięty."
}

author_rights() {
    AUTHOR_EMAIL=$(git config --global user.email)
    TMP_DIR="author_commits"
    ZIP_FILE="commits_$(date +%Y-%m).zip"

    rm -rf "$TMP_DIR"
    mkdir "$TMP_DIR"

    commits=$(git log --since="1 month ago" --author="$AUTHOR_EMAIL" --format="%H")

    for commit in $commits; do
        files=$(git diff-tree --no-commit-id --name-only -r "$commit")
        for file in $files; do
            mkdir -p "$TMP_DIR/$commit"
            git show "$commit:$file" > "$TMP_DIR/$commit/$(basename "$file")" 2>/dev/null
        done
    done

    tar -czf "$ZIP_FILE" "$TMP_DIR" > /dev/null
    echo "Zmiany z ostatniego miesiąca zapisane i spakowane w $ZIP_FILE"
}

case "$1" in
    --init)
        git_init_config
        ;;
    --install)
        install_project
        ;;
    --update)
        update_branch
        ;;
    --authorrights)
        author_rights
        ;;
    *)
        echo "Nieznana opcja: $1"
        show_help
        ;;
esac