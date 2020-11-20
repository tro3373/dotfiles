#!/bin/bash

wbinfo=/usr/local/samba/bin/wbinfo
ldbdel=/usr/local/samba/bin/ldbdel
idmap=/usr/local/samba/private/idmap.ldb

user_id=$1
while [[ $user_id == "" ]]; do
  echo
  $wbinfo -u
  echo
  echo "Input user_id..."
  read user_id
done

sid=$($wbinfo -n $user_id | awk '{print $1}')
xid=$($wbinfo --sids-to-unix-ids=$sid | awk '{print $4}')
uid=$(getent passwd $user_id | awk -F":" '{print $3}')
gid=$(getent passwd $user_id | awk -F":" '{print $4}')

echo "==> User info"
echo "    user_id=$user_id"
echo "    uid=$uid"
echo "    xid=$xid"
echo "    sid=$sid"
echo "    gid=$gid"
echo "---------------------------------"

dowbinfo() {
  option=$1
  option=${option/SID/$sid}
  option=${option/XID/$xid}
  option=${option/UID/$uid}
  option=${option/GID/$gid}
  option=${option/GROUP/$gid}
  option=${option/Sid-List/$sid}
  echo "===>${option/--/}"
  $wbinfo ${option}
}

dowbinfo --uid-info=UID
dowbinfo --uid-info=XID
dowbinfo --user-sids=SID
dowbinfo --user-sidinfo=SID
dowbinfo --lookup-sids=Sid-List
dowbinfo --sid-aliases=SID
dowbinfo --sid-to-fullname=SID
dowbinfo --user-domgroups=SID
dowbinfo --sid-to-uid=SID
dowbinfo --sids-to-unix-ids=Sid-List
echo "---------------------------------"
dowbinfo --gid-info=GID
dowbinfo --gid-to-sid=GID
gsid=$($wbinfo --gid-to-sid=$gid)
group=$($wbinfo -s $gsid | awk '{print $1}' | awk -F"\\" '{print $2}')
dowbinfo --group-info=$group
xsid=$($wbinfo --gid-to-sid=$xid)
group=$($wbinfo -s $xsid | awk '{print $1}' | awk -F"\\" '{print $2}')
dowbinfo --group-info=$group
echo "==>user-sids=$sid dump to-gid result"
for s in $($wbinfo --user-sids=$sid); do
  dowbinfo --sid-to-gid=$s
done

# wbinfo Usage
#
# -u, --domain-users                   Lists all domain users
# -g, --domain-groups                  Lists all domain groups
# -N, --WINS-by-name=NETBIOS-NAME      Converts NetBIOS name to IP
# -I, --WINS-by-ip=IP                  Converts IP address to NetBIOS name
# -n, --name-to-sid=NAME               Converts name to sid
# -s, --sid-to-name=SID                Converts sid to name
# --sid-to-fullname=SID                Converts sid to fullname
# -R, --lookup-rids=RIDs               Converts RIDs to names
# --lookup-sids=Sid-List               Converts SIDs to types and names
# -U, --uid-to-sid=UID                 Converts uid to sid
# -G, --gid-to-sid=GID                 Converts gid to sid
# -S, --sid-to-uid=SID                 Converts sid to uid
# -Y, --sid-to-gid=SID                 Converts sid to gid
# --allocate-uid                       Get a new UID out of idmap
# --allocate-gid                       Get a new GID out of idmap
# --set-uid-mapping=UID,SID            Create or modify uid to sid mapping in
#                                      idmap
# --set-gid-mapping=GID,SID            Create or modify gid to sid mapping in
#                                      idmap
# --remove-uid-mapping=UID,SID         Remove uid to sid mapping in idmap
# --remove-gid-mapping=GID,SID         Remove gid to sid mapping in idmap
# --sids-to-unix-ids=Sid-List          Translate SIDs to Unix IDs
# -t, --check-secret                   Check shared secret
# -c, --change-secret                  Change shared secret
# -P, --ping-dc                        Check the NETLOGON connection
# -m, --trusted-domains                List trusted domains
# --all-domains                        List all domains (trusted and own
#                                      domain)
# --own-domain                         List own domain
# --sequence                           Deprecated command, see --online-status
# --online-status                      Show whether domains are marked as
#                                      online or offline
# -D, --domain-info=文字列          Show most of the info we have about the
#                                      domain
# -i, --user-info=USER                 Get user info
# --uid-info=UID                       Get user info from uid
# --group-info=GROUP                   Get group info
# --user-sidinfo=SID                   Get user info from sid
# --gid-info=GID                       Get group info from gid
# -r, --user-groups=USER               Get user groups
# --user-domgroups=SID                 Get user domain groups
# --sid-aliases=SID                    Get sid aliases
# --user-sids=SID                      Get user group sids for user SID
# -a, --authenticate=user%password     authenticate user
# --pam-logon=user%password            do a pam logon equivalent
# --logoff                             log off user
# --logoff-user=文字列              username to log off
# --logoff-uid=INT                     uid to log off
# --set-auth-user=user%password        Store user and password used by
#                                      winbindd (root only)
# --ccache-save=user%password          Store user and password for ccache
#                                      operation
# --getdcname=domainname               Get a DC name for a foreign domain
# --dsgetdcname=domainname             Find a DC for a domain
# --dc-info=domainname                 Find the currently known DCs
# --get-auth-user                      Retrieve user and password used by
#                                      winbindd (root only)
# -p, --ping                           Ping winbindd to see if it is alive
# --domain=domain                      Define to the domain to restrict
#                                      operation
# -K, --krb5auth=user%password         authenticate user using Kerberos
# --krb5ccname=krb5ccname              authenticate user using Kerberos and
#                                      specific credential cache type
# --separator                          Get the active winbind separator
# --verbose                            Print additional information per command
# --change-user-password=文字列     Change the password for a user
# --ntlmv2                             Use NTLMv2 cryptography for user
#                                      authentication
# --lanman                             Use lanman cryptography for user
#                                      authentication
