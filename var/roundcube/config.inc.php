<?php

// default DES key
$config['des_key'] = '_ROUNDCUBE_DESKEY_';

// default domain
$config['username_domain'] = '_DOMAIN_';

// Name of this product
$config['product_name'] = 'MailAD Webmail [RoundCube]';

// only accept https traffic
$config['use_https'] = _HTTPS_ONLY_;

// Allow browser-autocompletion on login form.
// 0 - disabled, 1 - username and host only, 2 - username, host, password
$config['login_autocomplete'] = 1;

// max message size
$config['max_message_size'] = '_MESSAGESIZE_M';

// server linking ///

// IMAP server host (for fetching mail).
$config['imap_host'] = "ssl://_HOSTNAME_";
$config['imap_port'] = 993;
$config['imap_auth_type'] = 'IMAP';
$config['imap_vendor'] = 'dovecot';
$config['imap_conn_options'] = array(
    'ssl' => [
         'verify_peer'       => true,
         'allow_self_signed' => true,
         'peer_name'         =>  '_HOSTNAME_',
         'verify_peer_name'  => true,
    ],
);

// SMTP server host (for sending mails).
$config['smtp_host'] = "tls://_HOSTNAME_";
$config['smtp_port'] = 587;
$config['smtp_auth_type'] = 'PLAIN';
$config['smtp_conn_options'] = array(
    'ssl'=> array(
        'verify_peer'      => true,
        'peer_name'        =>  '_HOSTNAME_',
        'allow_self_signed'=> true,
        'verify_peer_name' => true,
    ),
);

// Samba AD DC Address Book
$config['autocomplete_addressbooks'] = array('global_ldap_book');
$config['ldap_public']["global_ldap_book"] = array(
    'name'              => 'Mailboxes',
    'hosts'             => explode(" ", "_LDAP_HOSTS_"),
    'ldap_version'      => '3',
    'network_timeout'   => 10,
    'user_specific'     => false,
    'base_dn'           => "_LDAPSEARCHBASE_",
    'bind_dn'           => "_LDAPBINDUSER_",
    'bind_pass'         => "_LDAPBINDPASSWD_",
    'writable'          => false,
    'search_fields'     => array(
       'mail',
    ),
    'fieldmap' => array(
        'name'          => 'cn',
        'surname'       => 'sn',
        'firstname'     => 'name',
        'title'         => 'title',
        'email'         => 'userPrincipalName:*',
        'phone:work'    => 'telephoneNumber',
        'phone:mobile'  => 'mobile',
        'phone:workfax' => 'facsimileTelephoneNumber',
        'street'        => 'street',
        'zipcode'       => 'postalCode',
        'locality'      => 'l',
        'department'    => 'department',
        'notes'         => 'description',
        'photo'         => 'jpegPhoto',
    ),
    'sort'          => 'cn',
    'scope'         => 'sub',
    'filter'        => '(&(mail=*)(|(objectClass=group)(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)))',
    'fuzzy_search'  => true,
    'vlv'           => false,
    'sizelimit'     => '0',
    'timelimit'     => '0',
    'referrals'     => false,
    // 'group_filters' => array(
    //     'departments' => array(
    //     'name'    => 'Lists',
    //     'scope'   => 'sub',
    //     'base_dn' => "_LDAPSEARCHBASE_",
    //     'filter'  => '(&(objectClass=group)(mail=*))',
    //     ),
    // ),
);
$config['ldap_public']["global_ldap_book"]['conn_options'] = array(
    'ssl' => array(
        'verify_peer'       => false,
        'verify_peer_name'  => true,
        'allow_self_signed' => true,
    ),
);

// local DB [sqlite3]
$dbtype='sqlite3';
$basepath='_SQLITE_STORAGE_';
$dbname='_SQLITE_DB_';
$config['db_dsnw'] = "sqlite:///$basepath/$dbname?mode=0664";

?>
