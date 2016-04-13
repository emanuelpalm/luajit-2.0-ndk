#!/usr/bin/env bash

# Generates makefiles for all platforms supported at NDK ABI level specified in
# the build environment configuration (conf/env.conf).

if [ "$#" -lt 1 ];
then
    echo >&2 "[!] Environment configuration not referenced."
    echo >&2 "    Usage: $0 <path/to/env.conf>"
    exit 1
fi

# Path to file containing required environment variables. Required.
ENV=$1
if [ -f "$ENV" ];
then
    . "$ENV"
else
    echo >&2 "[!] Invalid environment file referenced: $ENV."
    exit 2
fi

LUA_PATH="$PROJECT_ROOT/luajit-2.0"
MAKEFILE_ALL="$PROJECT_MAKE/_all.mk"

# Generates Makefile for NDK platform at given platform sysroot path $1.
generate() {
    local filename=$(basename "$1")
    local name=${filename:5}
    echo >&2 -n "Generating makefile for ndk-$name ..."

    # If name contains 64, we assume it names a 64-bit architecture.
    if [[ $name == *64* ]];
    then
        local cpu="64"
    else
        local cpu="32"
    fi

    local toolchains=$(find $NDK_PATH/toolchains -maxdepth 1 -ipath *$name*)
    for i in $toolchains;
    do
        # 64-bit architectures must have 64 in their toolchain names, and
        # 32-bit architectures must not have 64 in their names.
        if [ "$cpu" == "32" ];
        then
            [[ $i == *64* ]] && { continue; }
        else
            [[ $i != *64* ]] && { continue; }
        fi
        local toolchain=$i
        break
    done
    if [ "$toolchain" == "" ];
    then
        echo >&2 " failed!"
        echo >&2 "[!] No suitable NDK toolchain available for arch ($name)."
    else
        local makefile="$PROJECT_MAKE/ndk-$name.mk"
        local gcc=$(find $toolchain -ipath */bin/*-gcc)
        local cross=${gcc%???}
        local out="$PROJECT_OUT/ndk-$name"
        local uname=`uname`

        mkdir -p "$(dirname "$makefile")"

        echo -e 'MKDIR = mkdir -p' > "$makefile"

        echo -e '' >> "$makefile"

        echo -e 'default: install-local' >> "$makefile"

        echo -e '' >> "$makefile"

        echo -e 'install-local:' >> "$makefile"
        echo -e "\t@\${MKDIR} $out && \\" >> "$makefile"
        echo -e "\t\tcd $LUA_PATH && \\" >> "$makefile"
        echo -e "\t\t\${MAKE} clean && \\" >> "$makefile"
        echo -e "\t\t\${MAKE} CC=\"gcc\" \\" >> "$makefile"
        echo -e "\t\t\tHOST_CC=\"gcc -m$cpu\" \\" >> "$makefile"
        echo -e "\t\t\tHOST_SYS=\"$uname\" \\" >> "$makefile"
        echo -e "\t\t\tCROSS=\"$cross\" \\" >> "$makefile"
        echo -e "\t\t\tTARGET_FLAGS=\"--sysroot=$1\" \\" >> "$makefile"
        echo -e "\t\t\tTARGET_SYS=\"Linux\" && \\" >> "$makefile"
        echo -e "\t\t\${MAKE} install PREFIX=\"$out\" && \\" >> "$makefile"
        echo -e "\t\t\${MAKE} clean" >> "$makefile"

        echo -e '' >> "$makefile"

        echo -e 'clean:' >> "$makefile"
        echo -e "\t\${RM} -R $out" >> "$makefile"

        echo -e '' >> "$makefile"

        echo -e '.PHONY: default install-local clean' >> "$makefile"

        echo -e "ndk-$name:" >> "$MAKEFILE_ALL"
        echo -e "\t\${MAKE} -f $makefile" >> "$MAKEFILE_ALL"
        echo -e '' >> "$MAKEFILE_ALL"

        echo >&2 " done."
    fi
}

echo -n '' > "$MAKEFILE_ALL"

ARCHS=${NDK_TARGET_ARCHS//:/ }
for arch in $ARCHS;
do
    generate $arch
done
