#!/usr/bin/env bash

export KRIEG_SCRIPT="true"

KRIEG_ROOT=`pwd`

TEXTRESET=$(tput sgr0)
TEXTGREEN=$(tput setaf 2)
TEXTRED=$(tput setaf 1)

SYNCUNSAFE=false

EchoRed () {
	echo "${TEXTRED}$1${TEXTRESET}"
}
EchoGreen () {
	echo "${TEXTGREEN}$1${TEXTRESET}"
}

Sync () {
	Status
	if [ "$SYNCUNSAFE" = true ]; then
		EchoRed "You have unsaved changes, exiting sync."
	else
		git fetch && git pull
		if [ -d scripts ]; then
				echo ""
				EchoGreen "Scripts directory found. Syncing."
				echo ""
				cd scripts
				git fetch && git pull
				cd ..
			else
				echo ""
				EchoRed "Scripts directory not found. Cloning."
				echo ""
				git clone https://github.com/Krieg-Kernel/scripts.git
		fi

		if [ -d OP5-OP5T ]; then
				echo ""
				EchoGreen "Kernel Source directory found. Syncing."
				echo ""
				cd OP5-OP5T
				git fetch && git pull
				cd ..
			else
				echo ""
				EchoRed "Kernel Source directory not found. Cloning."
				echo ""
				git clone https://github.com/Krieg-Kernel/OP5-OP5T.git
		fi

		if [ -d AnyKernelBase ]; then
				echo ""
				EchoGreen "AnyKernelBase directory found. Syncing."
				echo ""
				cd AnyKernelBase
				git fetch && git pull
				cd ..
			else
				echo ""
				EchoRed "AnyKernelBase directory not found. Cloning."
				echo ""
				git clone https://github.com/Krieg-Kernel/AnyKernelBase.git
		fi

		mkdir -p Toolchains

		if [ -d Toolchains/aarch64-linux-android-4.9 ]; then
				echo ""
				EchoGreen "4.9 ToolChain found. Syncing."
				echo ""
				cd Toolchains/aarch64-linux-android-4.9
				git fetch && git pull
				cd ../..
			else
				cd Toolchains
				echo ""
				EchoRed "4.9 ToolChain not found. Cloning."
				echo ""
				git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9
				cd ..
		fi

		if [ -d Toolchains/linux-x86 ]; then
				echo ""
				EchoGreen "Clang ToolChain found. Syncing."
				echo ""
				cd Toolchains/linux-x86
				git fetch && git pull
				cd ../..
			else
				cd Toolchains
				echo ""
				EchoRed "Clang ToolChain not found. Cloning."
				echo ""
				git clone --depth=1 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86
				cd ..
		fi 
		Spam
	fi
}

Status () {
		EchoGreen "Checking Status of sub repos..."
    for i in "scripts" "OP5-OP5T" "AnyKernelBase" "Toolchains/aarch64-linux-android-4.9" "Toolchains/linux-x86"; do
      if [ -d "$i" ]; then
        cd $i
        TEMP=`git status`
        if [[ ${TEMP} == *"Your branch is up to date"* ]] && [[ ${TEMP} != *"Untracked files"* ]]; then
          EchoGreen "$i repo is Up to Date"
        else
          EchoRed "$i repo is out of sync with remote!!!"
          SYNCUNSAFE=true
        fi
        cd ${KRIEG_ROOT}
      else
        EchoRed "$i repo doesn't exist!!!"
      fi
    done
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
elif [ "$1" = "status" ]; then
	Status
else
	Sync
	Build "$2" "$3"
fi

unset KRIEG_SCRIPT
