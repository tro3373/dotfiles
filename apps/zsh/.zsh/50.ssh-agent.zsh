#
# ssh-agent start settings
#
_grep=`bash -c 'which grep'`
_ls=`bash -c 'which ls'`

ssh_env="${HOME}/.ssh/environment"
priv_key_path=${HOME}/.ssh

function dlog() {
    true && return
    echo $*
}

function should_continue() {
    if [ ! -e $priv_key_path/id_rsa ]; then
        dlog "No such file exist($priv_key_path/id_rsa). do nothing."
        return 1
    fi
    return 0
}

function load_ssh_env {
    if [ -f "$ssh_env" ]; then
        dlog "$ssh_env is exists. load!"
        . "$ssh_env" > /dev/null
    fi
}

# add private keys
function add_keys {
    dlog "add_keys!"
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
    dlog "start_agent!"
    # spawn ssh-agent
    ssh-agent | sed 's/^echo/#echo/' > "$ssh_env"
    echo "ssh-agent started."
    chmod 600 "$ssh_env"
    load_ssh_env
    add_keys
}

# test for identities
function test_identities {
    dlog "test_identities!"
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
        dlog " ==> agent is running"
        return 0
    fi
    dlog " ==> agent is not running"
    return 1
}

function my_ssh_agent {
    dlog "my_ssh_agent!"
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

function my_ssh_agent2 {
    dlog "my_ssh_agent2!"
    ! should_continue && return

    if [ -z $SSH_AGENT_PID ]; then
        dlog "SSH_AGENT_PID variable is not setted."
        load_ssh_env
    fi
    if [ -n $SSH_AGENT_PID ]; then
        dlog "SSH_AGENT_PID variable is setted."
        if is_agent_running; then
            dlog "do nothing becose agent is running."
            return
        fi
    fi
    start_agent
}
my_ssh_agent2

# --------------------------------------------------------
# zshが終了するときに自動的にssh-agentを終了させる
# --------------------------------------------------------
# TRAPEXIT() {
#    ssh-agent -k
# }

