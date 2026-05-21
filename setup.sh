#!/bin/bash
set -e

DOTFILES="$HOME/.dotfiles"

echo "🚀 セットアップ開始..."

echo "📦 Xcode CLT確認..."
xcode-select --install 2>/dev/null || true

echo "🍺 Homebrew確認..."
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew bundle --file="$DOTFILES/Brewfile"

echo "🐚 oh-my-zsh確認..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "🔌 oh-my-zshプラグイン確認..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions \
    $ZSH_CUSTOM/plugins/zsh-autosuggestions

[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ] && \
    git clone https://github.com/zsh-users/zsh-completions \
    $ZSH_CUSTOM/plugins/zsh-completions

echo "🦀 Rust確認..."
if ! command -v rustup &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi  

echo "🤖 Claude Code確認..."
if ! command -v claude &>/dev/null; then
    curl -fsSL https://claude.ai/install.sh | bash
fi

echo "🔧 mise言語インストール..."
mise install

echo "🔗 シンボリックリンク作成..."
cd "$DOTFILES"
stow zsh git mise ghostty

echo "✅ セットアップ完了！"
echo "👉 ターミナル再起動してな！"