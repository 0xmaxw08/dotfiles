# ~/max-dots/.config/.zshrc

# --------------------------------------------------
# Options
# --------------------------------------------------

setopt INTERACTIVE_COMMENTS   # allow # comments when pasting into the prompt
setopt AUTO_CD                # type a directory name to cd into it
zmodload zsh/terminfo

# --------------------------------------------------
# History
# --------------------------------------------------

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt SHARE_HISTORY          # implies APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# --------------------------------------------------
# Live autocompletion (must come before anything that calls compinit)
# --------------------------------------------------

if [[ -r /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]]; then
  # settings go BEFORE sourcing so the plugin reads them on load
  zstyle ':autocomplete:*' min-input 0              # show suggestions on an empty word too
  zstyle ':autocomplete:*' delay 0.05               # small delay so typing stays smooth
  zstyle ':autocomplete:*' list-lines 12            # max rows in the live menu
  zstyle ':autocomplete:*' insert-unambiguous yes   # Tab first fills the common prefix

  source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

  # Tab / Shift+Tab step through the live menu
  bindkey '^I' menu-complete
  bindkey "$terminfo[kcbt]" reverse-menu-complete
else
  autoload -Uz compinit && compinit
  zstyle ':completion:*' menu select
fi

# Up/Down: normal history navigation
bindkey '^[[A' up-line-or-history
bindkey '^[[B' down-line-or-history
bindkey "$terminfo[kcuu1]" up-line-or-history
bindkey "$terminfo[kcud1]" down-line-or-history

# --------------------------------------------------
# Completion styling
# --------------------------------------------------

# Case-insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Grayscale completion colors
zstyle ':completion:*' list-colors \
  '=(#b)*(=0)=38;5;250' \
  '=(#b)*(=1)=38;5;255' \
  '=(#b)*(=2)=38;5;245' \
  '=(#b)*(=3)=38;5;240'

# Dim group headers
zstyle ':completion:*:descriptions' format '%F{8}-- %d --%f'

# --------------------------------------------------
# Windows-style editing keys
# --------------------------------------------------

WORDCHARS=''                                   # words stop at / . - _ etc.

bindkey '^H'        backward-kill-word         # Ctrl+Backspace (most terminals)
bindkey '^[[127;5u' backward-kill-word         # Ctrl+Backspace (kitty extended keys)
bindkey '^[^?'      backward-kill-word         # Alt+Backspace
bindkey '^[[3;5~'   kill-word                  # Ctrl+Delete
bindkey '^[[1;5D'   backward-word              # Ctrl+Left
bindkey '^[[1;5C'   forward-word               # Ctrl+Right
bindkey '^[[H'      beginning-of-line          # Home
bindkey '^[[F'      end-of-line                # End
bindkey '^[[3~'     delete-char                # Delete
[[ -n "$terminfo[khome]" ]] && bindkey "$terminfo[khome]" beginning-of-line
[[ -n "$terminfo[kend]"  ]] && bindkey "$terminfo[kend]"  end-of-line
[[ -n "$terminfo[kdch1]" ]] && bindkey "$terminfo[kdch1]" delete-char

# --------------------------------------------------
# Prompt
# --------------------------------------------------

command -v starship >/dev/null && eval "$(starship init zsh)"

# --------------------------------------------------
# eza (monochrome)
# --------------------------------------------------

export EZA_COLORS="uu=bright-black:gu=bright-black:da=bright-black:ur=white:uw=bright-black:ux=white:ue=bright-black:gr=bright-black:gw=bright-black:gx=white:tr=bright-black:fi=white:di=bright-white:ln=bright-black:pi=bright-black:so=bright-black:bd=bright-black:cd=bright-black:or=bright-black:mi=bright-black:ex=white"

alias ls='eza --icons=always'
alias ll='eza -lah --icons=always --git'
alias la='eza -a --icons=always'
alias lt='eza --tree --icons=always'
alias ff="fastfetch"

# --------------------------------------------------
# Autosuggestions
# --------------------------------------------------

if [[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# --------------------------------------------------
# Syntax highlighting (keep LAST)
# --------------------------------------------------

if [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

  ZSH_HIGHLIGHT_STYLES[command]='fg=white'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=white'
  ZSH_HIGHLIGHT_STYLES[function]='fg=white'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=white'
  ZSH_HIGHLIGHT_STYLES[path]='fg=245'
  ZSH_HIGHLIGHT_STYLES[comment]='fg=240'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=245'
fi

# --------------------------------------------------
# Max theme controller
# --------------------------------------------------

theme() { python3 "$HOME/.config/maxdots/bin/theme.py" "$@"; }

# --------------------------------------------------
# Startup
# --------------------------------------------------

export PATH=$PATH:/home/max/.spicetify



# fastfetch that adapts to the current terminal size
fastfetch() {
  local rows cols
  read -r rows cols < <(stty size </dev/tty 2>/dev/null)
  : ${rows:=$LINES} ${cols:=$COLUMNS}

  if [[ $# -gt 0 ]]; then
    command fastfetch "$@"                                   # explicit flags win
  elif (( rows < 10 || cols < 62 )); then
    command fastfetch -c "$HOME/.config/fastfetch/tiny.jsonc"
  elif (( rows < 26 || cols < 100 )); then
    command fastfetch -c "$HOME/.config/fastfetch/compact.jsonc"
  else
    command fastfetch
  fi
}
