if status is-interactive
    if command -q zoxide
        zoxide init fish | source
    end
    if command -q atuin
        atuin init fish | source
    end
    if command -q direnv
        direnv hook fish | source
    end
end
