#!/bin/sh

function fixFormattingOnPhpSpecFiles ()
{
    echo -ne "Fixing SPEC files... \033[36mcleaning\033[0m"\\r

    IS_VISIBILITY_REQUIRED=`phpcsfixerBinary help fix | grep visibility_required | wc -l`

    if [ $IS_VISIBILITY_REQUIRED -eq 0 ]; then
        VISIBILITY_FIXER='--fixers=-visibility'
    else
        VISIBILITY_FIXER='--rules=-visibility_required'
    fi

    phpcsfixerBinary fix $VISIBILITY_FIXER spec --quiet

    if [ $? -eq 0 ]; then
        echo -e "Fixing SPEC files... \033[32mclean   \033[0m"
        return 0
    else
        echo -e "Fixing SPEC files... \033[33mfixed   \033[0m"
        return 1
    fi
}

function getLastEditedSpecFile ()
{
    environment=`uname -s`
    if [ "${environment}" = "Darwin" ]; then
        echo $(find spec -type f -print0 | xargs -0 stat -f "%m %N" | sort -rn | head -1 | cut -f2- -d" ")
    else
        echo $(find spec -type f -printf '%T@ %p\n' | sort -rn | head -1 | cut -f2- -d" ")
    fi
}

function phpspecBinary ()
{
    if [ -e bin/phpspec ]; then
        bin/phpspec "$@"
    elif [ -e vendor/bin/phpspec ]; then
        vendor/bin/phpspec "$@"
    elif [ -e vendor/phpspec/phpspec/bin/phpspec ]; then
        vendor/phpspec/phpspec/bin/phpspec "$@"
    else
        echo -e "\033[31mPhpSpec binary not found!\033[0m"
    fi
}

FORMATTING_TOOLS+=('fixFormattingOnPhpSpecFiles')

if [ -n "$ENABLE_ALIAS" ] && [ "$ENABLE_ALIAS" = true ]; then
    alias psr="phpspecBinary run"

    function psl ()
    {
        lastEdited=$(getLastEditedSpecFile)
        echo -e "Running phpspec for: \033[36m${lastEdited}\033[0m"
        phpspecBinary run "${lastEdited}"
    }

    function psd ()
    {
        file="$1"
        len=`expr "$file" : 'src/'`
        if [ $len -gt 0 ]; then
            file="${file#src/}"
        else
            len=`expr "$file" : 'spec/'`
            if [ $len -gt 0 ]; then
                file="${file#spec/}"
            fi
        fi

        phpspecBinary desc "$file"
    }
fi
