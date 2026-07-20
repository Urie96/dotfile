if status is-interactive
    if command -q zoxide
        zoxide init fish | source
    end
    if command -q atuin
        atuin init fish --disable-ctrl-r | source
    end

    if command -q devenv
        devenv hook fish | sed 's/and devenv shell/and devenv shell --no-tui --no-reload/g' | source
    end
    # if command -q direnv
    #     direnv hook fish | source
    # end
end

fish_config theme choose catppuccin-mocha --color-theme=dark
