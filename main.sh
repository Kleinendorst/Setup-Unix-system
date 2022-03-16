#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ------------------------------------------------------------
# -- Insert some optionally multiline text (third arg, 		--
# -- watch the quoting) into file (first arg) after			--
# -- a specific line (second arg).							--
# ------------------------------------------------------------
insert_in_file_after_line() {
	printf "Insert after line $2 in file $1 the following content:\n$3\n\n"

	filename=$1
	after_which_line=$2
	content="$3" # Quotes important to preserve newlines

	tmp_file=/tmp/content
	echo "$content" > $tmp_file # Quotes important to preserve newlines

	sed -i "/$after_which_line/r $tmp_file" $filename
	rm $tmp_file
}

target_git_clone_path=~/.repos
mkdir -p $target_git_clone_path

bash_prompt_home=$target_git_clone_path/bash-git-prompt
if [[ ! -d $bash_prompt_home ]]; then
	echo 'Installing Git bash...'
	# "--depth 1" specified in the official installation instructions
	git clone https://github.com/magicmonty/bash-git-prompt.git $bash_prompt_home --depth=1
	echo
fi

echo 'Including bash prompt in ~/.bashrc...'
git_bash_rc_snippet=`cat <<- EOF
	if [ -d "$bash_prompt_home" ]; then
	    GIT_PROMPT_ONLY_IN_REPO=0
	    source $bash_prompt_home/gitprompt.sh
	fi
.
EOF`
insert_in_file_after_line ~/.bashrc '# User specific aliases and functions' "${git_bash_rc_snippet%.}"
echo

# Check whether this is a Red Hat system
if [[ `id -u` -eq 0 && -f /etc/redhat-release ]]; then
	echo 'Installing tmux...'
	yum install -y tmux
else
	echo "Couldn\'t detect distribution, tmux might not be installed and this might be the cause"
	echo "for failures in the script..."
fi

tmux_powerline_theme_home=$target_git_clone_path/tmux_powerline
if [[ ! -d $tmux_powerline_theme_home ]]; then
	echo 'Installing Tmux powerline theme...'
	git clone https://github.com/wfxr/tmux-power.git $tmux_powerline_theme_home
	echo
fi

touch ~/.tmux.conf
cat > ~/.tmux.conf << EOF
set -g @tmux_power_theme 'redwine'
run-shell "$tmux_powerline_theme_home/tmux-power.tmux"
EOF

# Add code to ~/.bashrc for starting tmux automatically after ssh startup
tmux_ssh_start_snippet=`cat <<- 'EOF'
if [[ -n "$PS1" ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
  tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
fi
.
EOF`

insert_in_file_after_line ~/.bashrc '# User specific aliases and functions' "${tmux_ssh_start_snippet%.}"

echo 'Script finished and installation is ready, run the following command to activate:'
echo 'source ~/.bashrc'
