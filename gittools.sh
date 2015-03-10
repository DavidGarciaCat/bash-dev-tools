#!/bin/sh

function getGitBranch ()
{
    GIT_SYM=`git symbolic-ref HEAD`
    echo "${GIT_SYM##refs/heads/}"
}

function gitCreateCommit ()
{
    git add --all
    git commit -m "$1" --quiet
}

function gitPushChanges ()
{
    git push origin $(getGitBranch) --quiet
}

function gitExportInit ()
{
    if [ ! -f "${GIT_EXPORT_COMMITS_FILE}" ]; then
        commits=$1
        if [ "$commits" = "" ]; then
            commits=0
        fi

        if [ $commits -ge 1 ]; then
            echo -e "\033[32mYou are about to export the following commits:\033[0m"
            git log -${commits} --oneline
            echo

            if [ "`askQuestion 'Are you sure you want to export them' 'Y'`" = true ]; then
                git log -${commits} --oneline | cut -d' ' -f2- > "${GIT_EXPORT_COMMITS_FILE}"

                for i in `seq 1 ${commits}`; do
                    echo -ne "Saving commit (${i}/${commits})        "\\r
                    git reset HEAD~1 --quiet && git stash -u --quiet
                done

                echo -e "\033[32mCommits exported successfully!\033[0m"
            fi
        else
            echo -e "\033[33mPlease, supply the number of commits you want to export.\033[0m"
        fi
    else
        echo -e "\033[31mYou are already exporting some commits.\033[0m"
    fi
}

GIT_EXPORT_FOLDER="${BASE_PATH}/cache/gexport/"
GIT_EXPORT_COMMITS_FILE="${GIT_EXPORT_FOLDER}/commits"

if [ -n "$ENABLE_ALIAS" ] && [ "$ENABLE_ALIAS" = true ]; then
    alias gclone="git clone"
    alias gstatus="git status"
    alias gpush="git push origin \$(getGitBranch)"
    alias gpull="git pull origin \$(getGitBranch)"
    alias gadd="git add"
    alias gcommit="git commit"
    alias gco="git checkout"
    alias gfetch="git fetch"
    alias gtree="git log --graph --pretty=oneline --abbrev-commit"
    alias gdiff="git diff"
    alias gmerge="git merge"
    alias gbranch="git branch"
    alias gstash="git stash"
    alias grebase="git rebase"
    alias greset="git reset"
    alias grm="git rm"
    alias gmv="git mv"

    function gclean ()
    {
        if [ "`askQuestion 'Are you sure you want to clean your environment' 'Y'`" = true ]; then
            git reset HEAD --quiet
            git clean -dfq
            git checkout -- .

            echo -e "\033[32mEnvironment clean\033[0m"
        else
            echo -e "\033[31mAborted...\033[0m"
        fi
    }

    function gtag ()
    {
        name=`askMessage 'Tag name:'`
        message=`askMessage 'Tag message:'`

        git tag -a "$name" -m "$message"
        echo -e "\033[32mTag successfully created\033[0m"

        if [ "`askQuestion 'Do you want to push it to the server' 'Y'`" = true ]; then
            git push origin "$name" --no-verify --quiet
            echo -e "\033[32mTag pushed to server\033[0m"
        fi
    }

    function gexport ()
    {
        if [ ! -d "${GIT_EXPORT_FOLDER}" ]; then
            mkdir -p "${GIT_EXPORT_FOLDER}"
        fi

        gitExportInit "$1"
    }
fi
