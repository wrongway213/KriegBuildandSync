#!/usr/bin/env bash

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
      [[ $(git status) == *"Your branch is up to date"* ]] && git fetch && git pull
      cd ${KRIEG_ROOT}
    else
      echo ""
      EchoRed "$i directory not found. Cloning."
      echo ""
      case "$i" in
        "scripts") git clone$depth https://github.com/Krieg-Kernel/scripts.git "$i";;
        "OP5-OP5T") git clone$depth https://github.com/Krieg-Kernel/OP5-OP5T.git "$i";;
        "AnyKernelBase") git clone$depth https://github.com/Krieg-Kernel/AnyKernelBase.git "$i";;
        "Toolchains/aarch64-linux-android-4.9") git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 "$i";;
        "Toolchains/linux-x86") git clone --depth=1 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 "$i";;
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
Usage () {
  echo " "
  EchoRed "USAGE: Valid arguments are:"
  EchoGreen "-s(ync)"
  EchoGreen "-b(uild) <all/treble/nontreble>"
  EchoGreen "-v(ersion) <version>"
  EchoGreen "-d(epth) <sync depth for kernel repo>"
  EchoRed "Sync, build, or both must be specified"
  echo " "
  unset KRIEG_SCRIPT
  exit 1
}

export KRIEG_SCRIPT="true"
KRIEG_ROOT=`pwd`
TEXTRESET=$(tput sgr0)
TEXTGREEN=$(tput setaf 2)
TEXTRED=$(tput setaf 1)
buildshit=false; syncshit=false

while true; do
  case "$1" in
    -b) buildshit=true; shift; buildtype="$1"; shift;;
    -s) syncshit=true; shift;;
    -v) shift; version="$1"; shift;;
    -d) shift; depth=" --depth=$1"; shift;;
    "") shift; break;;
    *) EchoRed "Unsupported flag $1!"; Usage;;
  esac
done

if $buildshit; then
  [ -z "$version" ] && { EchoRed "NO Version number specified. Naming zips as TEST}"; version="TEST"; }
  [ -z "$depth" ] && { EchoRed "Depth not specified. Pulling everything"; }
fi

if $syncshit && $buildshit; then
  Sync
	scripts/build.sh "$buildtype" "$version"
elif $syncshit && ! $buildshit; then
	Sync
elif $buildshit; then
	scripts/build.sh "$buildtype" "$version"
else
  EchoRed "No action specified!"
  Usage
fi

unset KRIEG_SCRIPT
