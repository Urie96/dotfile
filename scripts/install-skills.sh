#!/usr/bin/env bash

skills-add() {
  skills add "$@" -g -a zed -y # 选zed是为了安装到~/.agents/skills，这样pi也能读取
}

skills-add mattpocock/skills --skill grill-with-docs --skill domain-modeling --skill grilling --skill handoff --skill teach

# skills-add openclaw/openclaw --skill summarize --skill tmux

skills-add tavily-ai/skills --skill tavily-search
uv tool install tavily-cli
# tvly login --api-key "$(rbw get tavily-api-key)"
