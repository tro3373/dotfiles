#!/usr/bin/env php

<?php

function wakeup($mac) {
    $body = h2s('FFFFFFFFFFFF');
    for( $i=0; $i<16; $i++ ) {
        $body .= h2s($mac);
    }
    $soc = socket_create( AF_INET, SOCK_DGRAM, SOL_UDP );
    socket_set_option($soc, SOL_SOCKET, SO_BROADCAST, 1);
    socket_connect($soc, '192.168.1.255', 2304);
    socket_write($soc, $body, 126);
    socket_close($soc);
}

function h2s($h) {
    $s = '';
    $p = 0;
    while( $p<strlen($h) ) {
        $s .= chr(intval(substr($h, $p, 2), 16));
        $p += 2;
    }
    return $s;
}

wakeup('specify-macaddress');
?>
