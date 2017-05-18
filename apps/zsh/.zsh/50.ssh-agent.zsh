#
# ssh-agent start settings
#
_grep=`bash -c 'which grep'`
_ls=`bash -c 'which ls'`

ssh_env="${HOME}/.ssh/environment"
priv_key_path=${HOME}/.ssh
[ ! -e $priv_key_path/id_rsa ] && return 0

function load_ssh_env {
    if [ -f "$ssh_env" ]; then
        . "$ssh_env" > /dev/null
    fi
}

# add private keys
function add_keys {
    /usr/bin/ssh-add
    priv_key_list=(`$_ls ${priv_key_path} | $_grep .priv`)
    if [[ ! -n $priv_key_list ]]; then
        return;
    fi
    for key in $priv_key_list; do
        /usr/bin/ssh-add ${priv_key_path}/${key}
    done
}

# start the ssh-agent
function start_agent {
    # spawn ssh-agent
    ssh-agent | sed 's/^echo/#echo/' > "$ssh_env"
    echo "ssh-agent started."
    chmod 600 "$ssh_env"
    load_ssh_env
    add_keys
}

# test for identities
function test_identities {
    # test whether standard identities have been added to the agent already
    if /usr/bin/ssh-add -l | $_grep "The agent has no identities" > /dev/null 2>&1; then
        add_keys
        if [ $? -eq 2 ];then
            # $SSH_AUTH_SOCK broken so we start a new proper agent
            start_agent
        fi
    fi
}

function is_agent_running {
    if ps -ef | $_grep "$SSH_AGENT_PID" | $_grep ssh-agent > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

function my_ssh_agent {
    # check for running ssh-agent with proper $SSH_AGENT_PID
    if [ -n "$SSH_AGENT_PID" ]; then
        # -n: true if string length greater than 0
        if is_agent_running; then
            test_identities
        fi
    else
        # if $SSH_AGENT_PID is not properly set, we might be able to load one from $ssh_env
        load_ssh_env
        if is_agent_running; then
            test_identities
        else
            start_agent
        fi
    fi
}
my_ssh_agent

# --------------------------------------------------------
# zshが終了するときに自動的にssh-agentを終了させる
# --------------------------------------------------------
# TRAPEXIT() {
#    ssh-agent -k
# }

