function ai
    # slim-kitten @ kitten scripts/group_window.py AI

    set -l prev_cwd (pwd)
    set -l session_dir ~/.pi/agent/simple-sessions
    mkdir -p "$session_dir"
    cd "$session_dir"
    command pi --provider openrouter --model openai/gpt-5.4 --system-prompt "" --no-skills --no-extensions --no-prompt-templates --offline --no-themes --no-tools --session-dir "$session_dir" $argv
    cd "$prev_cwd"
end
