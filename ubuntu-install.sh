#!/usr/bin/env bash

set -e

echo "🚀 Starting environment setup..."

USER_HOME="$HOME"
ZSHRC="$USER_HOME/.zshrc"

# -----------------------------
# System Update
# -----------------------------
echo "📦 Updating system..."
sudo apt update -y
sudo apt upgrade -y

# -----------------------------
# Install base packages
# -----------------------------
echo "🔧 Installing base packages..."
sudo apt install -y zsh git curl wget unzip gnome-tweaks gnome-extensions-app

# Dev tools
sudo apt install -y build-essential automake gcc g++ make

# -----------------------------
# Set Zsh as default shell
# -----------------------------
echo "🐚 Setting Zsh as default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
  if chsh -s $(which zsh); then
    echo "✅ Zsh set as default shell!"
  else
    echo "⚠️  Could not auto-change shell."
    echo "👉 Run this manually:"
    echo "   chsh -s $(which zsh)"
  fi
else
  echo "✅ Zsh is already the default shell"
fi

# -----------------------------
# Install Oh My Zsh
# -----------------------------
echo "✨ Installing Oh My Zsh..."
if [ ! -d "$USER_HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# -----------------------------
# Install NVS (Node Version Switcher)
# -----------------------------
echo "🟢 Installing NVS..."

export NVS_HOME="$HOME/.nvs"

if [ ! -d "$NVS_HOME" ]; then
  git clone https://github.com/jasongin/nvs "$NVS_HOME"
fi

# Load NVS
[ -s "$NVS_HOME/nvs.sh" ] && . "$NVS_HOME/nvs.sh"

# Install and use Node LTS
nvs add lts
nvs use lts

# -----------------------------
# Install Homebrew (Linux)
# -----------------------------
echo "🍺 Installing Homebrew..."
if [ ! -d "/home/linuxbrew/.linuxbrew" ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# -----------------------------
# Install packages via brew
# -----------------------------
echo "📦 Installing brew packages..."
brew install gcc
brew install jandedobbeleer/oh-my-posh/oh-my-posh

# -----------------------------
# Install Oh My Posh font
# -----------------------------
echo "🔤 Installing fonts..."
oh-my-posh font install meslo || true

# -----------------------------
# Download Oh My Posh themes from GitHub repository
# -----------------------------
echo "🎨 Downloading Oh My Posh themes from repository..."

TEMP_DIR=$(mktemp -d)

git clone --depth 1 https://github.com/mowaisnizami/fresh-environment-setup "$TEMP_DIR"

# Copy only .poshthemes folder
if [ -d "$TEMP_DIR/.poshthemes" ]; then
  mkdir -p "$HOME/.poshthemes"
  cp -r "$TEMP_DIR/.poshthemes/"* "$HOME/.poshthemes/"
else
  echo "⚠️  .poshthemes folder not found in repo"
fi

rm -rf "$TEMP_DIR"

# -----------------------------
# Install Zsh plugins
# -----------------------------
echo "🔌 Installing Zsh plugins..."

ZSH_CUSTOM=${ZSH_CUSTOM:-$USER_HOME/.oh-my-zsh/custom}

git clone https://github.com/zsh-users/zsh-autosuggestions \
  $ZSH_CUSTOM/plugins/zsh-autosuggestions || true

git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  $ZSH_CUSTOM/plugins/zsh-syntax-highlighting || true

git clone https://github.com/zsh-users/zsh-history-substring-search \
  $ZSH_CUSTOM/plugins/zsh-history-substring-search || true

# -----------------------------
# Install additional tools
# -----------------------------
echo "📱 Installing extra tools..."
sudo apt install -y uxplay

npm install -g @nestjs/cli
npm install -g @angular/cli
npm install -g @ionic/cli

# -----------------------------
# Generate .zshrc (CLEAN WRITE)
# -----------------------------
echo "📝 Generating .zshrc..."

cat > "$ZSHRC" << 'EOF'
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh

# -----------------------------
# NVS (Node)
# -----------------------------
export NVS_HOME="$HOME/.nvs"
[ -s "$NVS_HOME/nvs.sh" ] && . "$NVS_HOME/nvs.sh"
eval "nvs use lts"

# -----------------------------
# Homebrew
# -----------------------------
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# -----------------------------
# Oh My Posh
# -----------------------------
eval "$(oh-my-posh init zsh --config $HOME/.poshthemes/quick-term.omp.json)"

# -----------------------------
# Typewriter Effect
# -----------------------------
function typewrite() {
  for arg in "$@"; do
    for ((i = 0; i < ${#arg}; i++)); do
      echo -n "${arg:$i:1}"
      sleep 0.01
    done
  done
  echo ""
}

function zsh_greeting() {
  typewrite ""
  typewrite " Hello, $(whoami)!"
  typewrite " Welcome back! Today is $(date '+%A, %B %d, %Y')."
  typewrite " Remember, every day is a new opportunity to shine! 🚀"
  typewrite ""
}

zsh_greeting
EOF

# -----------------------------
# Install VS Code
# -----------------------------
echo "🧠 Installing VS Code..."

sudo apt-get install wget gpg &&
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg &&
sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg &&
rm -f microsoft.gpg

sudo sh -c 'cat > /etc/apt/sources.list.d/vscode.sources <<EOF
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF'

sudo apt install apt-transport-https &&
sudo apt update &&
sudo apt install code

echo "✅ VS Code installed!"

# -----------------------------
# Install pgAdmin 4
# -----------------------------
echo "🐘 Installing pgAdmin..."

# Add pgAdmin repository
echo "📥 Adding pgAdmin repository..."
if sudo curl -fsSL https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/pgadmin-archive-keyring.gpg 2>/dev/null; then
  sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/pgadmin-archive-keyring.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'
  sudo apt update
  echo "✅ pgAdmin repository added!"
else
  echo "⚠️  Failed to add pgAdmin repository"
fi

# Install pgAdmin desktop
if sudo apt install -y pgadmin4-desktop 2>/dev/null; then
  echo "✅ pgAdmin installed!"
else
  echo "⚠️  pgAdmin installation skipped (may not be available)"
fi


# -----------------------------
# Install DBeaver
# -----------------------------
echo "🐘 Installing DBeaver..."

# Check if DBeaver is already installed
if ! command -v dbeaver &>/dev/null && ! dpkg -l | grep -q dbeaver-ce; then
  echo "📥 Installing DBeaver via Snap..."
  if sudo snap install dbeaver-ce; then
    echo "✅ DBeaver installed!"
  else
    echo "⚠️  DBeaver installation failed (snap may not be available)"
  fi
else
  echo "✅ DBeaver is already installed"
fi

# -----------------------------
# Done
# -----------------------------
echo "✅ Installation complete!"
echo "👉 Restart terminal or run: exec zsh"

