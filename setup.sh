#!/bin/bash
set -e

DOTFILES="$HOME/.dotfiles"

echo "🚀 セットアップ開始..."
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "📦 Xcode CLT確認..."
if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
fi

echo "🍺 Homebrew確認..."
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
brew bundle --file="$DOTFILES/Brewfile" --no-upgrade || true

echo "🐚 oh-my-zsh確認..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "🔌 oh-my-zshプラグイン確認..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions \
    $ZSH_CUSTOM/plugins/zsh-autosuggestions || true

[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    $ZSH_CUSTOM/plugins/zsh-syntax-highlighting || true

[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ] && \
    git clone https://github.com/zsh-users/zsh-completions \
    $ZSH_CUSTOM/plugins/zsh-completions || true

echo "🦀 Rust確認..."
if ! command -v rustup &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
source "$HOME/.cargo/env"

echo "🦀 Cargoツールインストール..."
if ! command -v cargo-binstall &>/dev/null; then
  curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
fi
cargo binstall -y cargo-nextest flamegraph cargo-criterion bacon cargo-expand || true

echo "🤖 Claude Code確認..."
if ! command -v claude &>/dev/null; then
    curl -fsSL https://claude.ai/install.sh | bash
fi

echo "🔗 シンボリックリンク作成..."
backup_if_real_file() {
    local target="$1"
    if [ -f "$target" ] && [ ! -L "$target" ]; then
        mv "$target" "${target}.bak"
    fi
}

backup_if_real_file ~/.ssh/config
backup_if_real_file ~/.zshrc
backup_if_real_file ~/.zprofile

cd "$DOTFILES"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

stow -R zsh git mise ghostty tmux ssh

chmod 600 "$HOME/.ssh/config" 2>/dev/null || true

echo "🔧 mise言語インストール..."
eval "$(/opt/homebrew/bin/mise activate bash)"
mise install

echo "💻 VSCode設定..."
mkdir -p "$HOME/Library/Application Support/Code/User"
ln -sf "$DOTFILES/vscode/settings.json" \
    "$HOME/Library/Application Support/Code/User/settings.json"

echo "🔌 VSCode拡張機能インストール..."
if command -v code &>/dev/null; then
    xargs -I {} code --install-extension {} < "$DOTFILES/vscode/extensions.txt"
fi

echo "✅ セットアップ完了！"
echo "👉 ターミナル再起動してな！"
