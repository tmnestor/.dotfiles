# change directory just by keying in the path 
setopt autocd
# enables zsh’s ability to suggest correct commands when you mis-key one
setopt CORRECT
# zmv — Z Shell’s super-smart file renamer
autoload -U zmv
# Enable Auto Completion of Commands
autoload -Uz compinit && compinit
# see: https://thevaluable.dev/zsh-completion-guide-examples/
# zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

setopt EXTENDED_GLOB

#authenticate to git using keychain
# ssh-add --apple-use-keychain ~/.ssh/id_rsa


export JULIA_NUM_THREADS=4
# export SPARK_HOME=~/spark/spark-3.1.2-bin-hadoop3.2
# export PYSPARK_PYTHON=~/miniconda3/envs/pyspark/bin/python

# Set JAVA_HOME for Spark 
# added 29/11/2021
export JAVA_HOME=`/usr/libexec/java_home`

# a vertical layout for docker information
export FORMAT="\nID\t{{.ID}}\nIMAGE\t{{.Image}}\nCOMMAND\t{{.Command}}\nCREATED\t{{.RunningFor}}\nSTATUS\t{{.Status}}\nPORTS\t{{.Ports}}\nNAMES\t{{.Names}}\n"

export BP=$(brew --prefix) #is /usr/local
# replace BSD coreutils with GNU coreutils
export PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
# replace BSD grep with GNU grep
export PATH="$(brew --prefix)/opt/grep/libexec/gnubin:$PATH"
# replace BSD sed with GNU sed
export PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"
# replace BSD make with GNU make
export PATH="$(brew --prefix)/opt/make/libexec/gnubin:$PATH"
# dsutils
export PATH="$HOME/Documents/Unix/dsutils:$PATH"


# export PATH="$(brew --prefix)/bin:$BP/sbin:$HOME/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# vscode
alias c="code .";
alias zshconfig='code ~/.zshrc'

# alias ppath="echo -e ${PATH//:/\\n}"
# alias ppath="echo ${PATH//':'/'\n'}"
alias ppath="tr ':' '\n' <<< $PATH"
# get parent directory
alias pd="echo $(dirname -- "$(realpath -- "$PWD")")"
# get base directory
alias bd="echo ${PWD##*/}"


# export PATH="$PATH:/Library/Apple/usr/bin"
export PATH="$PATH:$BP/opt/openjdk@11/bin"
export PATH="$PATH:$BP/bin/gfortran"

# run conda init zsh
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/tod/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/tod/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/tod/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/tod/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# PROMPT='
# NestorDataScience
# %1~ %# '
