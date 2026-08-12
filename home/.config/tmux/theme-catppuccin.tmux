set -g @catppuccin_flavor 'mocha'
set -g @catppuccin_window_status_style "rounded"
set -g @catppuccin_window_flags "icon"
set -g @catppuccin_status_connect_separator "no"

run ~/.config/tmux/plugins/catppuccin/tmux/catppuccin.tmux

# Make the status line pretty and add some modules
set -g status-right-length 100
set -g status-left-length 100
set -g status-left ""
# 宽屏时才展示host
set -g status-right "#{?#{e|>=:#{client_width},120},#{E:@catppuccin_status_host},}#{E:@catppuccin_status_session}"

# vim:ft=tmux
