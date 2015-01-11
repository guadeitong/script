#!/bin/bash
#notice: ubuntu must reconfig bash
#        sudo ln -sf /bin/bash /bin/sh
#bash_profile
unset USERNAME


#use bash_completion
#ubuntu : already exists
#readhat: rpm -ivh http://www.caliban.org/files/redhat/RPMS/noarch/bash-completion-20060301-1.noarch.rpm
#osx : brew install bash-completion
if [ "$PS1" ]
then
    if [ -f /etc/bash_completion ]
    then
        if [ -r /etc/bash_completion ]
        then
            . /etc/bash_completion
        fi
    fi
fi

# Gimme a huge history
#export HISTSIZE=50000
# Don't store duplicate lines in history
export HISTCONTROL=ignoreboth
# Apend to history instead of overwriting
#shopt -s histappend
# Unify histories across screen sessions
PROMPT_COMMAND="$PROMPT_COMMAND;history -a; history -n"



# local variables
export PATH=/bin:/sbin:/usr/sbin:/usr/bin:/usr/local/bin:~/bin
export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib

#设置了Ls的目录颜色
export HOSTSHORT=`hostname`
export OS=`uname`;

#export LC_ALL='zh_CN.UTF-8'
export LC_ALL='en_US.UTF-8'
#export LANG='zh_CN.UTF-8'
export LANG='en_US.UTF-8'

export EDITOR='vim'
export SVN_EDITOR=vim

#shell promaote and title.
PROMPT_COMMAND='echo -ne "\033]0;[${HOSTSHORT}:`basename $PWD`\$]${PWD}\007"'
#PS1='[\u@\h:${YROOT_NAME}\w\$] '
#PS1='[\u@Luna \w\$] '

#.bashrc
#if [ -f /etc/bashrc ]; then
#        . /etc/bashrc
#fi

#.markrc
if [ -f ~/.markrc ]; then
        . ~/.markrc
fi


#all aliases
ALIASES=`\ls ~/.*aliases`
for f in $ALIASES
do
  if [ -f $f ];then
     . $f
  fi
done

#all completion
ALIASES=`\ls ~/.*completion`
for f in $ALIASES
do
  if [ -f $f ];then
     . $f
  fi
done


#need to install linuxlogo, sudo apt-get install linuxlogo
which linuxlogo > /dev/null 2>&1
if [ $? = 0 ]
then
    linuxlogo -L ubuntu -a
fi


export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
