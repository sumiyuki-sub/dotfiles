#!/bin/bash
set -euo pipefail

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

echo "🔐 zsh補完ディレクトリ権限確認..."
if [ -d "$HOMEBREW_PREFIX/share" ]; then
    chmod g-w "$HOMEBREW_PREFIX/share"
fi

"$DOTFILES/link.sh"

if command -v code &>/dev/null && [ -f "$DOTFILES/vscode/extensions.txt" ]; then
    echo "🧩 VS Code拡張機能確認..."
    while IFS= read -r extension; do
        [ -z "$extension" ] && continue
        code --install-extension "$extension" --force
    done < "$DOTFILES/vscode/extensions.txt"
fi

echo "✅ セットアップ完了！"
echo "👉 ターミナル再起動して！"
