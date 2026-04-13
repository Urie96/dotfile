# use `fish_key_reader` to echo keycode
# https://fishshell.com/docs/current/cmds/bind.html
# fish_vi_key_bindings

status is-interactive; or return

fish_default_key_bindings

# bind -M insert \cA beginning-of-line # ctrl-a
# bind -M insert \cE end-of-line # ctrl-e
bind \e\[107\;9u clear-screen # cmd-k
bind \v clear-screen # ctrl-k
bind \e\x7F backward-kill-path-component # alt-backspace to delete word
bind \e\[122\;9u undo # cmd + z
bind \e\[122\;10u redo # cmd + shift + z

function _resume_background_jobs
    set -l jobs_output (jobs | string collect)
    if [ -z "$jobs_output" ]
        printf "No background jobs\n\n"
    else
        set -l selected (echo "$jobs_output" | fzf --prompt 'Background Jobs> ' --bind one:accept --bind ctrl-z:abort | awk '{print $1;exit;}')
        if [ -n "$selected" ]
            fg "%$selected" 2>/dev/null
        end
    end
    commandline -f repaint
end

bind \cZ _resume_background_jobs
bind \cg edit_command_buffer

function _command_line_ls
    if [ -z (commandline -b) ]
        commandline -r r
        commandline -f execute
    else
        set -x CWD_FILE (mktemp -t "yazi-cwd.XXXXX")
        yazi --chooser-file="$CWD_FILE"
        set -l selected (cat -- "$CWD_FILE")
        for i in $selected
            commandline -i (realpath -s --relative-to=. "$i")' '
        end

        commandline -f repaint
    end
end

bind \e\[114\;9u _command_line_ls # cmd + r
bind \cr _command_line_ls

function fzf-file-widget -d "List files and folders"
    set -l FZF_DEFAULT_COMMAND "fd --strip-cwd-prefix --follow --exclude node_modules"
    set -l FZF_CTRL_D_COMMAND "$FZF_DEFAULT_COMMAND --type d"
    set -l FZF_CTRL_F_COMMAND "$FZF_DEFAULT_COMMAND --type f"

    set -l file (fzf --prompt 'All> ' \
            --bind "ctrl-d:change-prompt(Directories> )+reload($FZF_CTRL_D_COMMAND)" \
            --bind "ctrl-f:change-prompt(Files> )+reload($FZF_CTRL_F_COMMAND)" \
            --bind "ctrl-a:change-prompt(All> )+reload($FZF_DEFAULT_COMMAND)")

    if [ -n file ]
        commandline -i "$file"
        commandline -f repaint
    end
end

bind \ct _command_line_ls
bind \e\[116\;6u fzf-file-widget # ctrl-shift-t
