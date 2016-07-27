#!/bin/bash
SHELLFILENAME=`basename $0`
LOGFILE=$SHELLFILENAME.log
DEF_BACKUP_DIR=/tmp
DEF_XML_DIR=/etc/libvirt/qemu
DEF_IMG_DIR=/var/lib/libvirt/images

fncLog()
{
    if [ -e $LOGFILE ]; then
        echo "$*" >> $LOGFILE
    fi
}

fncEchoLog()
{
    logdate=`date '+%Y/%m/%d:%H:%M:%S'`
    outMsg="[$SHELLFILENAME] $logdate :$*"
    echo $outMsg
    fncLog $outMsg
}
fncStartProc()
{
    fncEchoLog "Start process."
}
fncEndProc()
{
    if [ $1 -ne 0 ]
    then
        fncEchoLog "AbNormal End."
    else
        fncEchoLog "Normal End."
    fi
    exit
}
funcShutdown()
{
    fncEchoLog "Shutdown process start."
    target=$1
    for domain in $DEF_XML_DIR/*xml; do
        domain=$(basename $domain .xml)
        state=$(virsh domstate $domain)
        doshutdown=0
        if [ "$target" = "$domain" ]; then
            doshutdown=1
        fi
        if [ "$doshutdown" = "1" -a "$state" = "running" ]; then
            fncEchoLog "  target=${target}, domain=${domain} is running. shutdown..."
            virsh shutdown ${domain}
        else
            fncEchoLog "  target=${target}, domain=${domain}. skip."
        fi
    done
    fncEchoLog "Shutdown process done."
}
funcWaitAndDestroy()
{
    fncEchoLog "Wait and Destroy process start."
    target=$1
    count=0
    for domain in $DEF_XML_DIR/*xml; do
        domain=$(basename $domain .xml)
        state=$(virsh domstate $domain)
        if [ ! "$target" = "$domain" ]; then
            fncEchoLog "  target=${target}, domain=${domain}. skip."
            continue
        fi
        if [ "$state" = "running" ]; then
            while [ "$state" = "running" ]
            do
                count=`expr $count + 1`
                if [ $count -gt 15 ]; then
                    if [ 0 -eq 0 ]; then
                        fncEchoLog "   Could not Safe Shutdown for ${domain}. Failed."
                        fncEndProc 1
                    else
                        fncEchoLog "   !!WARNING!! destroy ${domain}..."
                        virsh destroy ${domain}
                        RC=$?
                        if [ $RC -ne 0 ]; then
                            fncEchoLog "    exit=$RC Faild."
                            fncEndProc $RC
                        fi
                        fncEchoLog "   exit=$RC break"
                        break
                    fi
                fi
                fncEchoLog "  $domain shutdown waiting..."
                sleep 2
                state=$(virsh domstate $domain)
                fncEchoLog "   trycount=$count state=$state"
            done
            fncEchoLog "  state=$state ok. done."
        fi
    done
    fncEchoLog "Wait and Destroy process done."
}
funcCopy()
{
    src=$1
    dst=$2
    fncEchoLog " copy $src to $dst"
    cp $src $dst
    RC=$?
    if [ $RC -ne 0 ]; then
        fncEchoLog "   exit=$RC Faild."
        fncEndProc $RC
    fi
}
funcMove()
{
    src=$1
    dst=$2
    fncEchoLog " move $src to $dst"
    mv $src $dst
    RC=$?
    if [ $RC -ne 0 ]; then
        fncEchoLog "   exit=$RC Faild."
        fncEndProc $RC
    fi
}
funcBackup()
{
    fncEchoLog "Backup process start."
    target=$1
    output=$2
    fncEchoLog "  backup to ${output}, target is ${target}."
    if [ ! -d ${output} ]; then
        mkdir -p ${output}
    fi
    for domain in $DEF_XML_DIR/*xml; do
        filename=$domain
        domain=$(basename $domain .xml)
        state=$(virsh domstate $domain)

        if [ ! "$target" = "$domain" ]; then
            # 対象外のドメインは処理なし
            continue
        fi
        fncEchoLog "  domain=$domain, state=$state backup start."
        if [ ! "$state" = "shut off" ]; then
            fncEchoLog "   Status $state is invalid. Failed."
            fncEndProc 1
        fi
        fncEchoLog "   image copy start."
        funcCopy $DEF_IMG_DIR/$domain.img $output/
        fncEchoLog "   xml copy start."
        funcCopy $filename $output/
    done
    fncEchoLog "Backup process done."
}
funcBackupMain()
{
    targetdomain=$1
    output=$2
    LOGFILE=$output/$LOGFILE
    mkdir -p ${output}
    touch $LOGFILE
    xmlfile=$DEF_XML_DIR/$targetdomain.xml
    if [ ! -e $xmlfile ]; then
        # xmlファイルが存在しない
        fncEchoLog "unknown domain $targetdomain."
        fncEndProc 1
    fi
    state=$(virsh domstate $targetdomain)
    fncEchoLog "----------------------------------------------"
    fncEchoLog "Backup Detail"
    fncEchoLog "domain:${targetdomain} state:$state"
    fncEchoLog "backup to:${output}"
    fncEchoLog "----------------------------------------------"
    if [ "$state" = "running" ]; then
        fncEchoLog "----------------------------------------------"
        fncEchoLog "   !!WARNING!! Domain will be shutdown or destroy."
        fncEchoLog "----------------------------------------------"
    fi
    fncEchoLog " Press Any Key to Continue.  (Ctrl + c to cansel.)"
    read input
    fncStartProc
    fncEchoLog "Backup Main process start."
    # Shutdown process.
    funcShutdown $targetdomain
    # Wait and Destroy process.
    funcWaitAndDestroy $targetdomain
    # Backup process.
    funcBackup $targetdomain $output
    fncEchoLog "Backup Main process done."
}

funcRestoreMain()
{
    targetdir=$1
    output=$2
    LOGFILE=$output/$LOGFILE
    mkdir -p ${output}
    touch $LOGFILE
    targetdomain=""
    for domain in $targetdir/*xml; do
        targetdomain=$(basename $domain .xml)
        break
    done
    xmlfile=$targetdir/$targetdomain.xml
    if [ ! -e $xmlfile ]; then
        # xmlファイルが存在しない
        fncEchoLog "xml File Not Found in $targetdir."
        fncEndProc 1
    fi

    imagefile=$targetdir/$targetdomain.img
    if [ ! -e $imagefile ]; then
        # imgファイルが存在しない
        fncEchoLog "img File Not Found. $target."
        fncEndProc 1
    fi

    waring=0
    if [ -e $DEF_IMG_DIR/$targetdomain.img -o -e $DEF_XML_DIR/$targetdomain.xml ]; then
        # 現在のxml,imgファイルが存在する
        waring=1
    fi

    state=$(virsh domstate $targetdomain)
    fncEchoLog "----------------------------------------------"
    fncEchoLog "Restore Detail"
    fncEchoLog "domain:${targetdomain} state:$state"
    fncEchoLog "restore from:${targetdir}"
    fncEchoLog " xmlfile:${xmlfile}"
    fncEchoLog " imagefile:${imagefile}"
    fncEchoLog "restore log:${output}"
    fncEchoLog "----------------------------------------------"
    if [ "$state" = "running" ]; then
        fncEchoLog "----------------------------------------------"
        fncEchoLog "   !!WARNING!! Domain will be shutdown or destroy."
        fncEchoLog "----------------------------------------------"
    fi
    if [ "$waring" = "1" ]; then
        fncEchoLog "----------------------------------------------"
        fncEchoLog "   !!WARNING!! Current img/xml is Exist."
        fncEchoLog "   !!WARNING!! These files will be move to .bk file."
        fncEchoLog "----------------------------------------------"
    fi
    fncEchoLog " Press Any Key to Continue.  (Ctrl + c to cansel.)"
    read input
    fncStartProc
    fncEchoLog "Restore Main process start."

    # Shutdown process.
    funcShutdown $targetdomain
    # Wait and Destroy process.
    funcWaitAndDestroy $targetdomain

    state=$(virsh domstate $targetdomain)
    if [ ! "$state" = "shut off" ]; then
        fncEchoLog "   Status $state is invalid. Failed."
        fncEndProc 1
    fi
    funcMove $DEF_IMG_DIR/$targetdomain.img $DEF_IMG_DIR/$targetdomain.img.bk
    funcMove $DEF_XML_DIR/$targetdomain.xml $DEF_XML_DIR/$targetdomain.xml.bk
    funcCopy $imagefile $DEF_IMG_DIR/$targetdomain.img
    funcCopy $xmlfile $DEF_XML_DIR/$targetdomain.xml

    fncEchoLog "Restore Main process done."
}
fncMain()
{
    LANG=C
    backup_restore=$1
    target=$2
    output=$3
    if [ "${backup_restore}" = "" ]; then
        fncEchoLog "Invalid argument. must be specified 'backup' or 'restore' to first parameter."
        fncEndProc 1
    fi
    if [ "$backup_restore" = "restore" -a "$target" = "" ]; then
        fncEchoLog "Invalid argument. 'restore' must be specified Directory has restore files(xml and img) to second parameter."
        fncEndProc 1
    fi
    if [ "$backup_restore" = "backup" -a "$target" = "" ]; then
        target=testappserver
    fi
    if [ "$output" = "" ]; then
        output=$DEF_BACKUP_DIR
    fi
    DATESTR=`date '+%Y%m%d_%H%M%S'`
    output=${output}/${DATESTR}_$backup_restore

    if [ "$backup_restore" = "backup" ]; then
        funcBackupMain ${target} ${output}
    elif [ "$backup_restore" = "restore" ]; then
        funcRestoreMain ${target} ${output}
    else
        fncEchoLog "Invalid argument. 'backup' or 'restore' can specified."
        fncEndProc 1
    fi
    fncEndProc 0
}

fncMain $*
