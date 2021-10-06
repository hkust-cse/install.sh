#!/usr/bin/env bash

echo "[CSE Lab Helper] Welcome to HKUST CSE Lab Helper install script!"

if type xcode-select >&- && xpath=$( xcode-select --print-path ) &&
   test -d "${xpath}" && test -x "${xpath}" ; then
   echo "[CSE Lab Helper] Xcode Command Line Tools detected...skipping installation"
else
   echo "[CSE Lab Helper] Cannot find existing Xcode Command Line Tools"
   echo "[CSE Lab Helper] Installing Xcode Command Line Tools..."
   xcode-select --install
   # read -p "[CSE Lab Helper] Please enter (Y) when the Xcode Command Line Tools has finished its installation: [Y/n]" -n 1 -r
   # echo    # (optional) move to a new line
   # if [[ $REPLY =~ ^[Yy]$ ]]
   # then
   #    # do dangerous stuff
   # fi
fi

if test ! $(which brew); then
    echo "[CSE Lab Helper] Cannot find existing Xcode Command Line Tools"
    echo "[CSE Lab Helper] Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if test $(which brew); then

   PROFILE_PATH="$HOME/.bash_profile"
   if [[ $SHELL == *"zsh"* ]]; then
      PROFILE_PATH="$HOME/.zshrc"
   fi

   if test -n "$(gcc --version 2 > /dev/null | grep clang)"; then
      brew update
      brew tap homebrew/homebrew-core
      PACKAGES=(
         gcc@10
	 jq
      )
      echo "[CSE Lab Helper] Installing necessary packages..."
      brew install ${PACKAGES[@]} 
   fi

   if ! [ -x "$(command -v gcc-10)" ]; then
     brew update
     brew tap homebrew/homebrew-core
     brew install gcc@10
   fi

   if grep -q "alias gcc='gcc-10'" $PROFILE_PATH; then
      echo "[CSE Lab Helper] Alias for gcc detected, skipping..."
   else
      echo -e "alias gcc='gcc-10'\nalias cc='gcc-10'\nalias g++='g++-10'\nalias c++='c++-10'\n" >> $PROFILE_PATH
      echo "[CSE Lab Helper] Writing out command aliases for gcc tools..."
   fi

   if test ! $(which code); then
      echo "[CSE Lab Helper] Cannot find existing cask for Visual Studio Code"
      echo "[CSE Lab Helper] Installing Visual Studio Code..."
      brew install --cask visual-studio-code
   fi
   if test $(which code); then
      brew install jq
      if test ! -n "$(code --list-extensions | grep ms-vscode.cpptools)"; then
         echo "[CSE Lab Helper] Installing C/C++ for Visual Studio Code extension from Microsoft..."
         code --install-extension ms-vscode.cpptools
      fi
      if test ! -n "$(code --list-extensions | grep formulahendry.code-runner)"; then
         VSCODE_SETTINGS_PATH="$HOME/Library/Application Support/Code/User/settings.json"
         echo "[CSE Lab Helper] Installing Code Runner extension from Jun Han..."
         code --install-extension formulahendry.code-runner
	      jq '."update.mode" = "none" | ."code-runner.customCommand" = "make" | ."code-runner.runInTerminal" = true | ."code-runner.saveFileBeforeRun" = true | ."code-runner.saveAllFilesBeforeRun" = true | ."code-runner.ignoreSelection" = true | ."code-runner.clearPreviousOutput" = true | ."terminal.integrated.scrollback" = 10240 | ."files.eol" = "\n" | ."code-runner.executorMap" = { "cpp" : "cd $dir && /usr/local/bin/g++-10 -std=c++11 $fileName -o $fileNameWithoutExt && $dir$fileNameWithoutExt" }' "$VSCODE_SETTINGS_PATH" > /tmp/settings.json
         cp "$VSCODE_SETTINGS_PATH" "$VSCODE_SETTINGS_PATH.bak"
         mv /tmp/settings.json "$VSCODE_SETTINGS_PATH"
      fi
   fi

   echo "[CSE Lab Helper] Congraduation! Setup process is now complete."
   echo "[CSE Lab Helper] Please close this terminal window and reopen for changes to take effect"
   exit 0
fi
