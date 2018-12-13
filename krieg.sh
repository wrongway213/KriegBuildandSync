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
      cd ${REPO_ROOT}
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
build () {
    mkdir -p ${REPO_ROOT}/AnyKernelBase/kernels/custom/$1 ${REPO_ROOT}/AnyKernelBase/kernels/oos/$1
    
    LOCAL_VERSION="Krieg-EAS$ZIPNAME-${VERSION}"
    sed -i -r "s/(CONFIG_LOCALVERSION=).*/\1\"-${LOCAL_VERSION}\"/" ${REPO_ROOT}/OP5-OP5T/arch/arm64/configs/krieg_defconfig
    
    if [ "$1" = "nontreble" ]; then
        EchoGreen "Building for NON-TREBLE. Reverting vendor partition mounting in DTSI"
        git am "${REPO_ROOT}/patches/0001-Revert-oneplus5-custom-mount-vendor-partition.patch"
    else
        EchoGreen "Building for TREBLE"
    fi
    
    make O=out ARCH=arm64 krieg_defconfig
    make -j$(nproc --all) O=out \
    ARCH=arm64 \
    CC="${CLANG}" \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    CROSS_COMPILE="${CROSS_COMPILE}" \
    KBUILD_COMPILER_STRING="$(${CLANG}  --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')" \
    
    # Check exit code of make command
    BUILD_SUCCESS=$?
    
    if [ $BUILD_SUCCESS -ne 0 ]; then
        EchoRed "Build for #1 failed! Aborting further processing!"
    else
        # Move image to AK2
        cp -f "${REPO_ROOT}/OP5-OP5T/out/arch/arm64/boot/Image.gz-dtb" "${REPO_ROOT}/AnyKernelBase/kernels/custom/$1/Image.gz-dtb"
        EchoGreen "Build for $1 complete"
    fi
    
    # Cleanup
    rm -rf "${REPO_ROOT}/OP5-OP5T/out"
    [ "$1" == "nontreble" ] && git reset --hard HEAD
}
Usage () {
  echo " "
  EchoRed "USAGE: Valid arguments are:"
  EchoGreen "-s(ync)"
  EchoGreen "-b(uild) <all/treble/nontreble>"
  EchoGreen "-d(epth) <sync depth for kernel repo>"
  EchoRed "Sync, build, or both must be specified"
  echo " "
  exit 1
}

REPO_ROOT=`pwd`
SECONDS=0
TEXTRESET=$(tput sgr0)
TEXTGREEN=$(tput setaf 2)
TEXTRED=$(tput setaf 1)
BUILD_SUCCESS="999"
buildshit=false; syncshit=false

# If not defined gives long compiler name
export COMPILER_NAME="CLANG-8.0.4"

# Clang and GCC paths
CLANG=${REPO_ROOT}/Toolchains/linux-x86/clang-r344140b/bin/clang
if [ ${USE_CCACHE:-"0"} = "1" ]; then
    CLANG="ccache ${CLANG}"
fi
CROSS_COMPILE="${REPO_ROOT}/Toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-"

# Is this test release?
TAG="$(git describe --tags 2>/dev/null)"
if [ -z "${TAG}" ]; then
    VERSION="TEST-$(git rev-parse --short HEAD)"
else
    VERSION="STABLE-${TAG}"
fi

# Clean up if anything is remaining.
rm -rf ${REPO_ROOT}/OP5-OP5T/out
cd ${REPO_ROOT}/OP5-OP5T

while true; do
  case "$1" in
    -b) buildshit=true; shift; buildtype="$1"; shift;;
    -s) syncshit=true; shift;;
    -d) shift; depth=" --depth=$1"; shift;;
    "") shift; break;;
    *) EchoRed "Unsupported flag $1!"; Usage;;
  esac
done

if $syncshit; then
    [ -z "$depth" ] && EchoRed "Depth not specified. Pulling everything"
    sync
elif ! $buildshit; then
    EchoRed "No action specified!"
    Usage
fi

[ -z $buildtype ] || { case "$(echo "$buildtype" | tr '[:upper:]' '[:lower:]')" in
                        "all")
                            ZIPNAME=""
                            build treble
                            [ $BUILD_SUCCESS -ne 0 ] && break
                            build nontreble;;
                        "treble")
                            ZIPNAME="-TREBLE"
                            build treble;;
                        "nontreble")
                            ZIPNAME="-NONTREBLE"
                            build nontreble;;
                        *) echo -e "Please enter an argument\nValid arguments are: all treble nontreble";;
                        esac; }

if [ $BUILD_SUCCESS -eq 0 ]; then
  # Make zip and cleanup
  cd ${REPO_ROOT}/AnyKernelBase
  zip -r9 ${REPO_ROOT}/Krieg-EAS$ZIPNAME-V-$VERSION.zip * -x README Krieg-EAS$ZIPNAME-V-$VERSION.zip
  rm -rf ${REPO_ROOT}/AnyKernelBase/kernels/
  EchoGreen "Builds complete. The zips can be found at: ${REPO_ROOT}"
  EchoGreen "Total time taken: $(($SECONDS / 60)):$(($SECONDS % 60))"
fi
