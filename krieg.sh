#!/usr/bin/env bash

export KRIEG_SCRIPT="true"

KRIEG_ROOT=`pwd`

TEXTRESET=$(tput sgr0)
TEXTGREEN=$(tput setaf 2)
TEXTRED=$(tput setaf 1)

EchoRed () {
	echo "${TEXTRED}$1${TEXTRESET}"
}
EchoGreen () {
	echo "${TEXTGREEN}$1${TEXTRESET}"
}

Sync () {
  git fetch && git pull
  for i in "scripts" "OP5-OP5T" "AnyKernelBase" "Toolchains/aarch64-linux-android-4.9" "Toolchains/linux-x86"; do
    if [ -d "$i" ]; then
      echo ""
		  EchoGreen "$i directory found. Syncing."
			echo ""
      cd "$i"
      git fetch && git pull
      cd ${KRIEG_ROOT}
    else
      echo ""
      EchoRed "$i directory not found. Cloning."
      echo ""
      case "$i" in
        "scripts") git clone --depth=1 https://github.com/Krieg-Kernel/scripts.git "scripts";;
        "OP5-OP5T") git clone --depth=1 https://github.com/Krieg-Kernel/OP5-OP5T.git "OP5-OP5T";;
        "AnyKernelBase") git clone --depth=1 https://github.com/Krieg-Kernel/AnyKernelBase.git "AnyKernelBase";;
        "Toolchains/aarch64-linux-android-4.9") git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 "Toolchains/aarch64-linux-android-4.9";;
        "Toolchains/linux-x86") git clone --depth=1 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 "Toolchains/linux-x86";;
      esac
    fi
  done
  Spam
}

Spam () {
	echo ""
	echo ""
	EchoGreen " _       _______________________ _______    _       _______ _______ _       _______ _       "
	EchoGreen "| \    /(  ____ )__   __(  ____ (  ____ \  | \    /(  ____ (  ____ | (    /(  ____ ( \      "
	EchoGreen "|  \  / / (    )|  ) (  | (    \/ (    \/  |  \  / / (    \/ (    )|  \  ( | (    \/ (      "
	EchoGreen "|  (_/ /| (____)|  | |  | (__   | |        |  (_/ /| (__   | (____)|   \ | | (__   | |      "
	EchoGreen "|   _ ( |     __)  | |  |  __)  | | ____   |   _ ( |  __)  |     __) (\ \) |  __)  | |      "
	EchoGreen "|  ( \ \| (\ (     | |  | (     | | \_  )  |  ( \ \| (     | (\ (  | | \   | (     | |      "
	EchoGreen "|  /  \ \ ) \ \____) (__| (____/\ (___) |  |  /  \ \ (____/\ ) \ \_| )  \  | (____/\ (____/\\"
	EchoGreen "|_/    \//   \__|_______(_______(_______)  |_/    \(_______//   \__//    )_|_______(_______/"
	echo ""                                                                                            
	EchoRed " _______ ________________   ______  _      ________________________________ ______          "
	EchoRed "(  ____ (  ____ \__   __/  (  ___ \( \     \__   __/ ___   )__   __(  ____ (  __  \         "
	EchoRed "| (    \/ (    \/  ) (     | (   ) ) (        ) (  \/   )  |  ) (  | (    \/ (  \  )        "
	EchoRed "| |     | (__      | |     | (__/ /| |        | |      /   )  | |  | (__   | |   ) |        "
	EchoRed "| | ____|  __)     | |     |  __ ( | |        | |     /   /   | |  |  __)  | |   | |        "
	EchoRed "| | \_  ) (        | |     | (  \ \| |        | |    /   /    | |  | (     | |   ) |        "
	EchoRed "| (___) | (____/\  | |     | )___) ) (____/\__) (___/   (_/\  | |  | (____/\ (__/  )        "
	EchoRed "(_______|_______/  )_(     |/ \___/(_______|_______(_______/  )_(  (_______(______(_)      "
}

Build () {
	scripts/build.sh "$1" "$2"
}

if [ "$1" = "sync" ]; then
	Sync
elif [ "$1" = "build" ]; then
	Build "$2" "$3"
else
	Sync
	Build "$1" "$2"
fi

unset KRIEG_SCRIPT
