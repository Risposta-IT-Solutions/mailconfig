<?php

$config = [];
// Do not set db_dsnw here, use dpkg-reconfigure roundcube-core to configure database!
include_once("/etc/roundcube/debian-db-roundcube.php");

$config['smtp_server'] = 'ssl://smtp.{{_domain_}}';
$config['smtp_port'] = 465;
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';
$config['smtp_auth_type'] = 'LOGIN';
$config['product_name'] = 'Pearlstone Energy Webmail';

$config['smtp_conn_options'] = array(
    'ssl' => array(
        'verify_peer'       => false,
        'verify_peer_name'  => false,
        'allow_self_signed' => true,
    ),
);

$config['des_key'] = '3IE5ZSkAjjS7JXxLFyuLhWbE';
$config['username_domain'] = '{{_domain_}}';
$config['plugins'] = [
];
$config['skin'] = 'elastic';
$config['enable_spellcheck'] = false;
