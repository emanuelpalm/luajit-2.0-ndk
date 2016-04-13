# Checks availability of all required command line tools.

# Checks whether provided command line tool exists in PATH or not. Returns 0 if
# available, 1 if not.
exists() {
    echo >&2 -n "Finding $1 ..."
    type $1 >/dev/null 2>&1
    if [ "$?" == "0" ];
    then
        echo >&2 ' in $PATH.'
        echo "0"
    else
        echo >&2 ' not in $PATH!'
        echo "1"
    fi
}

MISSING=0

let "MISSING += $(exists find)"
let "MISSING += $(exists gcc)"
let "MISSING += $(exists git)"
let "MISSING += $(exists make)"
let "MISSING += $(exists mkdir)"
let "MISSING += $(exists rm)"

if [ "$MISSING" != "0" ];
then
    echo >&2
    echo >&2 '[!] Please install the unavailable tools and try again. If'
    echo >&2 '    installed already, make sure they are present in your $PATH.'
    echo >&2
    exit 1
fi
