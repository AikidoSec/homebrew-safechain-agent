# Homebrew Packaging for Aikido SafeChain Agent

## Installation

```bash
brew tap AikidoSec/safechain-agent
brew install safechain-agent
brew services start safechain-agent
sudo /opt/homebrew/bin/safechain-setup
```

## Upgrade

```bash
brew upgrade safechain-agent
brew services restart safechain-agent
```

## Uninstall

```bash
sudo /opt/homebrew/bin/safechain-setup --uninstall
brew services stop safechain-agent
brew uninstall safechain-agent
```