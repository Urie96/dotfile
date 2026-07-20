# clear both screen and history
# bind -n C-l send-keys C-l \; run 'sleep 0.2' \; clear-history

bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

bind-key f display-popup -E -w 100% -h 100% -b none 'pick-window'
bind-key C-f display-popup -E -w 100% -h 100% -b none '~/.config/tmux/scripts/scrollback-pager'
bind-key a display-popup -E -w 80% -h 80% -b rounded 'coding-agent-status status'
bind-key v new-window nvim -c 'call feedkeys("\<Space>bn")'

# -- navigation ----------------------------------------------------------------

bind C-t new-window -c "#{pane_current_path}"

unbind '"'
unbind %
bind n splitw -h -c '#{pane_current_path}'
bind - splitw -c '#{pane_current_path}'

# pane navigation
bind j select-pane -L  # move left
bind k select-pane -D  # move down
bind i select-pane -U  # move up
bind l select-pane -R  # move right
bind J "select-pane -m; select-pane -L; swap-pane; select-pane -L; select-pane -M"
bind K "select-pane -m; select-pane -D; swap-pane; select-pane -D; select-pane -M"
bind I "select-pane -m; select-pane -U; swap-pane; select-pane -U; select-pane -M"
bind L "select-pane -m; select-pane -R; swap-pane; select-pane -R; select-pane -M"


bind -r C-j previous-window # select previous window
bind -r C-l next-window     # select next window
bind C-S-j swap-window -t -1 \; select-window -t -1  # swap current window with the previous one
bind C-S-l swap-window -t +1 \; select-window -t +1  # swap current window with the next one

# -- copy mode -----------------------------------------------------------------

bind Enter copy-mode # enter copy mode

bind p paste-buffer

bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi C-v send -X rectangle-toggle
bind -T copy-mode-vi y send -X copy-selection-and-cancel
bind -T copy-mode-vi Escape send -X cancel
bind -T copy-mode-vi Home send -X start-of-line
bind -T copy-mode-vi End send -X end-of-line
bind -T copy-mode-vi i send-keys -X previous-prompt # 跳到上一个prompt
bind -T copy-mode-vi k send-keys -X next-prompt # 跳到下一个prompt

# vim:ft=tmux
