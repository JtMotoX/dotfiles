clear

# MANUALLY INSTALL PLUGINS AND THEMES
# git -C ~/.oh-my-zsh/custom/plugins clone https://github.com/zsh-users/zsh-autosuggestions
# git -C ~/.oh-my-zsh/custom/plugins clone https://github.com/zsh-users/zsh-completions
# git -C ~/.oh-my-zsh/custom/plugins clone https://github.com/zsh-users/zsh-syntax-highlighting.git
# git -C ~/.oh-my-zsh/custom/themes clone https://github.com/romkatv/powerlevel10k.git
# git -C ~/.oh-my-zsh/custom/themes clone https://github.com/JtMotoX/zsh-jt-themes.git

# LOAD TERMINAL MULTIPLEXER CONFIGURATIONS
test -f ~/.tmux_profile && source ~/.tmux_profile
# test -f ~/.screen_profile && source ~/.screen_profile

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$(brew --prefix 2>/dev/null)/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# RUN THIS COMMAND TO VIEW THEMES
#	ls ~/.oh-my-zsh/themes/*.zsh-theme ~/.oh-my-zsh/custom/themefs/*.zsh-theme 2>/dev/null | xargs -I % echo "clear && LPS1="" RPS1="" LSCOLORS="" PROMPT="" PS1="" PS2="" && source % && ls -lG" | less
# ZSH_THEME="jt1"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# FIX BRACKET ERROR FOR zsh-autosuggestions WHEN PASTING
DISABLE_MAGIC_FUNCTIONS=true

# WHEN PERMISSIONS CANNOT BE SET CORRECTLY DUE TO SYMBOLIC LINK TO WINDOWS ONEDRIVE FOLDER
# ZSH_DISABLE_COMPFIX=true

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git docker docker-compose zsh-syntax-highlighting zsh-autosuggestions zsh-completions)
# plugins=(git colored-man colorize pip python brew osx zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# THEME FOR zsh-syntax-highlighting
source ~/.oh-my-zsh/custom/themes/zsh-jt-themes/jt-highlighting-custom.zsh

# User configuration

# export MANPATH="$(brew --prefix 2>/dev/null)/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# FORMAT TIME COMMAND OUTPUT TO MATCH BASH
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S'

# DISABLE 'no matches found' WHEN RUNNING 'rm' COMMAND
unsetopt nomatch

# CREATE th FOR ZSH TMUX HELP
th() { cat ~/.oh-my-zsh/plugins/tmux/README.md | grep --color=never -E '^\|\s*`[a-z]+`\s*\|'; }

# LOAD CUSTOM NON-ZSH-SPECIFIC PROFILE
test -f ~/.sh_profile_custom && source ~/.sh_profile_custom

# DISABLE RM VERIFICATION
setopt rm_star_silent

# KUBE-PS1
# KUBE_PS1_NS_COLOR=yellow
# KUBE_PS1_SYMBOL_ENABLE=false
# KUBE_PS1_SEPARATOR=''
# source "$(brew --prefix 2>/dev/null)/opt/kube-ps1/share/kube-ps1.sh"
# kube_ps1_autohide() { kube_ps1 | sed -r 's/^(.*}N\/A%.*:.*}(N\/A|default)%.*)$//' }
# PS1='$(kube_ps1_autohide)'$PS1

# INSTALL KUBENS ON UBUNTU
# sudo sh -c "curl -sSL https://github.com/ahmetb/kubectx/releases/download/v0.9.3/kubectx_v0.9.3_linux_x86_64.tar.gz | tar -xz -C /usr/bin/ kubectx"
# sudo sh -c "curl -sSL https://github.com/ahmetb/kubectx/releases/download/v0.9.3/kubens_v0.9.3_linux_x86_64.tar.gz | tar -xz -C /usr/bin/ kubens"

# SET THE TERMINAL TITLE TO LAST COMMAND
DISABLE_AUTO_TITLE="true"
preexec () { print -Pn "\033]0;%m : $1\007"; }
print -Pn "\033]0;%n@%m\007"

# FIX ZSH-COMPLETIONS FOR APPLE SILICON
if [[ $(uname -m) == 'arm64' ]] && type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  autoload -Uz compinit
  compinit
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
