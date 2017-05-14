GREP=`bash -c 'which grep'`
LS=`bash -c 'which ls'`

SSH_ENV="${HOME}/.ssh/environment"
PRIV_KEY_PATH=${HOME}/.ssh
[ ! -e $PRIV_KEY_PATH/id_rsa ] && return 0
PRIV_KEY_LIST=(`$LS ${PRIV_KEY_PATH} | $GREP .priv`)

# add private keys
function add_keys {
    /usr/bin/ssh-add
    #echo "Private priv Keys List is... $PRIV_KEY_LIST"
    for key in ${PRIV_KEY_LIST}; do
        /usr/bin/ssh-add ${PRIV_KEY_PATH}/${key}
    done
}

# start the ssh-agent
function start_agent {
    # spawn ssh-agent
    ssh-agent | sed 's/^echo/#echo/' > "$SSH_ENV"
    echo "ssh-agent started."
    chmod 600 "$SSH_ENV"
    . "$SSH_ENV" > /dev/null
    add_keys
}

# test for identities
function test_identities {
    # test whether standard identities have been added to the agent already
    if /usr/bin/ssh-add -l | grep "The agent has no identities" > /dev/null 2>&1; then
        add_keys
        # $SSH_AUTH_SOCK broken so we start a new proper agent
        if [ $? -eq 2 ];then
            start_agent
        fi
    fi
}

function my_ssh_agent {
    # check for running ssh-agent with proper $SSH_AGENT_PID
    # -n: true if string length greater than 0
    if [ -n "$SSH_AGENT_PID" ]; then
        # ps -ef | grep "$SSH_AGENT_PID" | grep ssh-agent > /dev/null
        # if [ $? -eq 0 ]; then
        if ps -ef | grep "$SSH_AGENT_PID" | grep ssh-agent > /dev/null 2>&1; then
            test_identities
        fi
    # if $SSH_AGENT_PID is not properly set, we might be able to load one from $SSH_ENV
    else
        # ps -ef | grep "$SSH_AGENT_PID" | grep ssh-agent > /dev/null
        if [ -f "$SSH_ENV" ]; then
            . "$SSH_ENV" > /dev/null
        fi
        if ps -ef | grep "$SSH_AGENT_PID" | grep ssh-agent > /dev/null 2>&1; then
            . "$SSH_ENV" > /dev/null
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

