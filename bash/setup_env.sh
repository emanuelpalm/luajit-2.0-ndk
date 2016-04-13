# Resolves and writes required environment variables to configuration file.

# Local file containing shell definitions.
PROJECT_CONF_ENV="$PROJECT_CONF/env.conf"

# Attempts to find named directory, returning its path if successful.
findpath() {
    echo >&2 -n "Finding $1 ..."
    local result=""
    for path in ~ /opt;
    do
        for i in "$(find $path -ipath $1 2>/dev/null)";
        do
            [[ "$i" == "" ]] && { break; }
            echo >&2 " FOUND AT $i"
            result="$i"
            break 2
        done
    done
    [[ "$result" == "" ]] && {
        echo >&2 " NOT FOUND"
    }
    echo "$result"
}

MISSING=0

[[ -f "$PROJECT_CONF_ENV" ]] && {
    . "$PROJECT_CONF_ENV"
}

# Resolve Android NDK path.
[[ -z "$NDK_PATH" ]] && {
    NDK_PATH=$(findpath "*/ndk-bundle/ndk-build")
    if [ "$NDK_PATH" != "" ];
    then
        NDK_PATH=$(dirname "$NDK_PATH")
    else
        let "MISSING += 1"
        echo >&2 "! Android NDK not found. Cannot set NDK_PATH."
    fi
}

# Resolve Android NDK ABI level and platform.
([[ -z "$NDK_PLATFORM" ]] || [[ -z "$NDK_ABI" ]]) \
    && [[ "$NDK_PATH" != "" ]] && {
    for level in $NDK_ABI 24 23 21 16 9 8 5 4 3;
    do
        NDK_PLATFORM=$(findpath "$NDK_PATH/platform*-$level")
        [[ "$NDK_PLATFORM" != "" ]] && {
            NDK_ABI="$level"
            break
        }
    done
    [[ "$NDK_PLATFORM" == "" ]] && {
        let "MISSING += 1"
        echo >&2 "! No NDK platform found. Cannot set NDK_PLATFORM."
        echo >&2 "! No NDK platform found. Cannot set NDK_ABI."
    }
}

# Resolve target Android NDK CPU architectures.
[[ -z "$NDK_TARGET_ARCHS" ]] && [[ "$NDK_PLATFORM" != "" ]] && {
    echo >&2 -n "Finding supported platform architecutes ..."
    platforms="$(find $NDK_PLATFORM -iname arch-* -type d 2>/dev/null)"
    for i in $platforms;
    do
        name=$(basename "$i")
        echo >&2 -n " ${name:5}"
        NDK_TARGET_ARCHS="$i:$NDK_TARGET_ARCHS"
    done
    echo >&2

    unset name
    unset platforms

    [[ "$NDK_TARGET_ARCHS" == "" ]] && {
        let "MISSING += 1"
        echo >&2 "! No NDK target archs found. Cannot set NDK_TARGET_ARCHS."
    }

    NDK_TARGET_ARCHS="${NDK_TARGET_ARCHS%?}"
}

# Set makefile generation output folder.
[[ -z "$PROJECT_MAKE" ]] && {
    PROJECT_MAKE="$PROJECT_ROOT/make"
}

# Set build output folder.
[[ -z "$PROJECT_OUT" ]] && {
    PROJECT_OUT="$PROJECT_ROOT/out"
}

# Sets current platform name.
[[ -z "$UNAME" ]] && {
    UNAME=`uname`
}

if [ "$MISSING" == "0" ];
then
    mkdir -p $PROJECT_CONF
    echo "NDK_ABI=$NDK_ABI" > "$PROJECT_CONF_ENV"
    echo "NDK_PATH=$NDK_PATH" >> "$PROJECT_CONF_ENV"
    echo "NDK_PLATFORM=$NDK_PLATFORM" >> "$PROJECT_CONF_ENV"
    echo "NDK_TARGET_ARCHS=$NDK_TARGET_ARCHS" >> "$PROJECT_CONF_ENV"
    echo "PROJECT_MAKE=$PROJECT_MAKE" >> "$PROJECT_CONF_ENV"
    echo "PROJECT_OUT=$PROJECT_OUT" >> "$PROJECT_CONF_ENV"
    echo "PROJECT_ROOT=$PROJECT_ROOT" >> "$PROJECT_CONF_ENV"
    echo "UNAME=$UNAME" >> "$PROJECT_CONF_ENV"
else
    echo >&2
    echo >&2 "[!] Some significant paths could not be resolved. Please review"
    echo >&2 "    the above list and make sure all desired utilities are"
    echo >&2 "    installed and available via your home folder. If you"
    echo >&2 "    intalled the listed utilities outside your home folder, you"
    echo >&2 "    have the option of specifying those paths manually in the"
    echo >&2 "    following file:"
    echo >&2
    echo >&2 "    $PROJECT_CONF_ENV"
    echo >&2
fi
