
# pwd
if [ -f ./shell.fragments.d/third-party/bash-git-prompt/gitprompt.sh ]; then
    # echo found git prompt
    GIT_PROMPT_ONLY_IN_REPO=1
    GIT_PROMPT_THEME=Default_Mint

    source ./shell.fragments.d/third-party/bash-git-prompt/gitprompt.sh

fi

