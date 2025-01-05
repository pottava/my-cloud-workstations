FROM asia-northeast1-docker.pkg.dev/cloud-workstations-images/predefined/code-oss:latest

# Terraform & Zsh
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
       tee /etc/apt/sources.list.d/hashicorp.list
RUN apt update && apt install -y zsh gnupg software-properties-common terraform && apt autoremove -y && apt-get clean
ENV ZSH=/opt/workstation/oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone https://github.com/zsh-users/zsh-autosuggestions /opt/workstation/oh-my-zsh/plugins/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /opt/workstation/oh-my-zsh/custom/themes/powerlevel10k
RUN wget -O terraform.vsix $(curl -s https://open-vsx.org/api/hashicorp/terraform/linux-x64 | jq -r '.files.download') \
    && unzip terraform.vsix "extension/*" && mv extension /opt/code-oss/extensions/terraform

# Node.js
RUN npm -g install n && n lts && apt purge -y nodejs npm && apt autoremove -y && apt clean
RUN wget -O prettier.vsix $(curl -s https://open-vsx.org/api/esbenp/prettier-vscode | jq -r '.files.download') \
    && unzip prettier.vsix "extension/*" && mv extension /opt/code-oss/extensions/prettier

# Python
RUN apt install -y python3.12-venv && apt autoremove -y && apt-get clean
RUN wget -O black.vsix $(curl -s https://open-vsx.org/api/ms-python/black-formatter | jq -r '.files.download') \
    && unzip black.vsix "extension/*" && mv extension /opt/code-oss/extensions/black-formatter
RUN wget -O flake8.vsix $(curl -s https://open-vsx.org/api/ms-python/flake8 | jq -r '.files.download') \
    && unzip flake8.vsix "extension/*" && mv extension /opt/code-oss/extensions/flake8
RUN wget -O ruff.vsix $(curl -s https://open-vsx.org/api/charliermarsh/ruff | jq -r '.files.download') \
    && unzip ruff.vsix "extension/*" && mv extension /opt/code-oss/extensions/ruff
RUN wget -O jupyter.vsix $(curl -s https://open-vsx.org/api/ms-toolsai/jupyter | jq -r '.files.download') \
    && unzip jupyter.vsix "extension/*" && mv extension /opt/code-oss/extensions/jupyter

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && mkdir -p /opt/cargo && mv $HOME/.cargo/bin /opt/cargo/
RUN wget -O rust-analyzer.vsix $(curl -s https://open-vsx.org/api/rust-lang/rust-analyzer | jq -r '.files.download') \
    && unzip rust-analyzer.vsix "extension/*" && mv extension /opt/code-oss/extensions/rust-analyzer

# Go
RUN mkdir -p /opt/workstation/bin
RUN GOBIN="/opt/workstation/bin" go install golang.org/x/tools/gopls@latest
RUN GOBIN="/opt/workstation/bin" go install golang.org/x/tools/cmd/goimports@latest
RUN GOBIN="/opt/workstation/bin" go install honnef.co/go/tools/cmd/staticcheck@latest
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /opt/workstation/bin v1.63.2

# Protobuf
RUN apt install -y clang-format && apt autoremove -y && apt clean
RUN npm -g install @bufbuild/buf
RUN GOBIN="/opt/workstation/bin" go install github.com/bufbuild/buf/cmd/buf@latest
RUN GOBIN="/opt/workstation/bin" go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
RUN GOBIN="/opt/workstation/bin" go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
RUN GOBIN="/opt/workstation/bin" go install connectrpc.com/connect/cmd/protoc-gen-connect-go@latest
RUN wget -O clang-format.vsix $(curl -s https://open-vsx.org/api/xaver/clang-format | jq -r '.files.download') \
    && unzip clang-format.vsix "extension/*" && mv extension /opt/code-oss/extensions/clang-format
RUN wget -O proto3.vsix $(curl -s https://open-vsx.org/api/zxh404/vscode-proto3 | jq -r '.files.download') \
    && unzip proto3.vsix "extension/*" && mv extension /opt/code-oss/extensions/vscode-proto3

# Other VSCode extensions
RUN wget -O vscode-icons.vsix $(curl -s https://open-vsx.org/api/vscode-icons-team/vscode-icons | jq -r '.files.download') \
    && unzip vscode-icons.vsix "extension/*" && mv extension /opt/code-oss/extensions/vscode-icons
RUN wget -O vscode-html-css.vsix $(curl -s https://open-vsx.org/api/ecmel/vscode-html-css | jq -r '.files.download') \
    && unzip vscode-html-css.vsix "extension/*" && mv extension /opt/code-oss/extensions/vscode-html-css
RUN wget -O trailing-spaces.vsix $(curl -s https://open-vsx.org/api/shardulm94/trailing-spaces | jq -r '.files.download') \
    && unzip trailing-spaces.vsix "extension/*" && mv extension /opt/code-oss/extensions/trailing-spaces
RUN wget -O code-spell-checker.vsix $(curl -s https://open-vsx.org/api/streetsidesoftware/code-spell-checker | jq -r '.files.download') \
    && unzip code-spell-checker.vsix "extension/*" && mv extension /opt/code-oss/extensions/code-spell-checker

# Customization script
COPY customize.sh /etc/workstation-startup.d/300-workstation-customization.sh
RUN chmod +x /etc/workstation-startup.d/300-workstation-customization.sh
