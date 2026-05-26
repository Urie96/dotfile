# clear both screen and history
bind -n C-l send-keys C-l \; run 'sleep 0.2' \; clear-history

# -- navigation ----------------------------------------------------------------

# create session
bind C-c new-session
# find session
bind C-f command-prompt -p find-session 'switch-client -t %%'
bind t new-window -c "#{pane_current_path}"

unbind '"'
unbind %
bind n splitw -h -c '#{pane_current_path}' # 水平方向新增面板，默认进入当前目录

# pane navigation
bind -r j select-pane -L  # move left
bind -r k select-pane -D  # move down
bind -r i select-pane -U  # move up
bind -r l select-pane -R  # move right
bind K swap-pane -D       # swap current pane with the next one
bind U swap-pane -U       # swap current pane with the previous one

bind -r C-j previous-window # select previous window
bind -r C-l next-window     # select next window
bind -r C-S-j swap-window -t -1 \; select-window -t -1  # swap current window with the previous one
bind -r C-S-l swap-window -t +1 \; select-window -t +1  # swap current window with the next one

# -- copy mode -----------------------------------------------------------------

bind Enter copy-mode # enter copy mode

bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi C-v send -X rectangle-toggle
bind -T copy-mode-vi y send -X copy-selection-and-cancel
bind -T copy-mode-vi Escape send -X cancel
bind -T copy-mode-vi Home send -X start-of-line
bind -T copy-mode-vi End send -X end-of-line

# vim:ft=tmux
