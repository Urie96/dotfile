function gh-create
    # Get the git root directory name as repo name
    set -l repo_name (git rev-parse --show-toplevel | xargs basename)

    # Get the current directory path
    set -l current_dir (pwd)

    # Confirm with user
    read -p "echo 'run `gh repo create "$repo_name" --public --source=. --remote=origin --push`? [y/N]: '" -l confirm

    if test "$confirm" = y -o "$confirm" = Y
        gh repo create "$repo_name" --public --source=. --remote=origin --push
    else
        echo "Cancelled."
    end
end
