FROM asia-northeast1-docker.pkg.dev/cloud-workstations-images/predefined/code-oss:latest

# Terraform & Zsh
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
       sudo tee /etc/apt/sources.list.d/hashicorp.list
RUN sudo apt update && sudo apt install -y zsh gnupg software-properties-common terraform
RUN apt-get clean
ENV ZSH=/opt/workstation/oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone https://github.com/zsh-users/zsh-autosuggestions /opt/workstation/oh-my-zsh/plugins/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /opt/workstation/oh-my-zsh/custom/themes/powerlevel10k

# NPM
RUN npm -g install n && n lts && apt purge -y nodejs npm && apt autoremove -y

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && mkdir -p /opt/cargo && mv $HOME/.cargo/bin /opt/cargo/

# VSCode extensions
RUN wget -O vscode-icons.vsix $(curl -s https://open-vsx.org/api/vscode-icons-team/vscode-icons | jq -r '.files.download') \
    && unzip vscode-icons.vsix "extension/*" && mv extension /opt/code-oss/extensions/vscode-icons

RUN wget -O terraform.vsix $(curl -s https://open-vsx.org/api/hashicorp/terraform/linux-x64 | jq -r '.files.download') \
    && unzip terraform.vsix "extension/*" && mv extension /opt/code-oss/extensions/terraform

RUN wget -O prettier.vsix $(curl -s https://open-vsx.org/api/esbenp/prettier-vscode | jq -r '.files.download') \
    && unzip prettier.vsix "extension/*" && mv extension /opt/code-oss/extensions/prettier

RUN wget -O vscode-html-css.vsix $(curl -s https://open-vsx.org/api/ecmel/vscode-html-css | jq -r '.files.download') \
    && unzip vscode-html-css.vsix "extension/*" && mv extension /opt/code-oss/extensions/vscode-html-css

# RUN wget -O go.vsix $(curl -s https://open-vsx.org/api/golang/go | jq -r '.files.download') \
#     && unzip go.vsix "extension/*" && mv extension /opt/code-oss/extensions/go

# RUN wget -O python.vsix $(curl -s https://open-vsx.org/api/ms-python/python | jq -r '.files.download') \
#     && unzip python.vsix "extension/*" && mv extension /opt/code-oss/extensions/python

RUN wget -O isort.vsix $(curl -s https://open-vsx.org/api/ms-python/isort | jq -r '.files.download') \
    && unzip isort.vsix "extension/*" && mv extension /opt/code-oss/extensions/isort

RUN wget -O autopep8.vsix $(curl -s https://open-vsx.org/api/ms-python/autopep8 | jq -r '.files.download') \
    && unzip autopep8.vsix "extension/*" && mv extension /opt/code-oss/extensions/autopep8

RUN wget -O jupyter.vsix $(curl -s https://open-vsx.org/api/ms-toolsai/jupyter | jq -r '.files.download') \
    && unzip jupyter.vsix "extension/*" && mv extension /opt/code-oss/extensions/jupyter

RUN wget -O rust-analyzer.vsix $(curl -s https://open-vsx.org/api/rust-lang/rust-analyzer | jq -r '.files.download') \
    && unzip rust-analyzer.vsix "extension/*" && mv extension /opt/code-oss/extensions/rust-analyzer

RUN wget -O trailing-spaces.vsix $(curl -s https://open-vsx.org/api/shardulm94/trailing-spaces | jq -r '.files.download') \
    && unzip trailing-spaces.vsix "extension/*" && mv extension /opt/code-oss/extensions/trailing-spaces

RUN wget -O code-spell-checker.vsix $(curl -s https://open-vsx.org/api/streetsidesoftware/code-spell-checker | jq -r '.files.download') \
    && unzip code-spell-checker.vsix "extension/*" && mv extension /opt/code-oss/extensions/code-spell-checker

# Customization script
COPY customize.sh /etc/workstation-startup.d/300-workstation-customization.sh
RUN chmod +x /etc/workstation-startup.d/300-workstation-customization.sh
