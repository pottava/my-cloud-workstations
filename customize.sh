#!/bin/bash

CODEOSS_PATH="/home/user/.codeoss-cloudworkstations"
SETTINGS_PATH="$CODEOSS_PATH/data/Machine"

mkdir -p $SETTINGS_PATH
cat << EOF > $SETTINGS_PATH/settings.json
{
  "workbench.colorTheme": "Default Dark+",
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true,
  "editor.minimap.enabled": false,
  "go.formatTool": "goimports",
  "[go]": {
    "editor.defaultFormatter": "golang.go",
    "editor.codeActionsOnSave": {
      "source.organizeImports": "explicit"
    }
  },
  "black-formatter.args": ["--line-length=120"],
  "flake8.args": ["--max-line-length=120", "--config=.flake8"],
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter",
    "editor.codeActionsOnSave": {
      "source.organizeImports.ruff": "explicit"
    }
  },
  "notebook.defaultFormatter": "ms-python.black-formatter",
  "files.trimTrailingWhitespace": true,
  "[markdown]": {
    "files.trimTrailingWhitespace": false,
    "editor.renderWhitespace": "boundary"
  },
  "workbench.startupEditor": "none",
  "files.exclude": {
    "**/.git": true,
    ".b*": true,
    ".c*": true,
    ".docker": true,
    ".gitconfig": true,
    ".kube": true,
    ".npm": true,
    ".rustup": true,
    "go/pkg": true,
    ".profile": true,
    ".python_history": true,
    ".sudo_*": true,
    ".viminfo": true,
    ".z*": true
  },
  "terminal.integrated.defaultProfile.linux": "zsh"
}
EOF

chown -R user:user $CODEOSS_PATH
chmod -R 755 $CODEOSS_PATH

export ZSH=/opt/workstation/oh-my-zsh

if [ -f "/home/user/.zshrc" ]; then
    echo "ZSH already configured"
else

    cat << 'EOF' > /home/user/.zshrc
export PATH="$PATH:/opt/workstation/bin:/opt/cargo/bin:/home/user/go/bin"

export ZSH=/opt/workstation/oh-my-zsh
export ZSH_THEME="powerlevel10k/powerlevel10k"
export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=True

plugins=(
    git
    zsh-autosuggestions
    kubectl
)

alias tf='terraform'
alias k='kubectl'
alias d='docker'
alias code='code-oss-cloud-workstations'

git config --global init.defaultBranch main
git config --global core.editor vim

source "$ZSH/oh-my-zsh.sh"
EOF
chsh -s $(which zsh) user
fi

mkdir -p /home/user/.ssh
cat << EOF > /home/user/.ssh/config
Host github github.com
  HostName github.com
  IdentityFile ~/.ssh/id_ed25519
  User git

Host gitlab gitlab.com
  HostName gitlab.com
  IdentityFile ~/.ssh/id_ed25519
  User git
EOF

zsh -c "source $ZSH/oh-my-zsh.sh"

chown -R user:user /home/user
chown -R user:user /opt/workstation
chmod -R 755 /opt/workstation
