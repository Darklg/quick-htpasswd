#!/bin/bash

cat <<EOF

###################################
## Quick htpasswd v 0.1.1
###################################

EOF

_PATH=$(pwd);

###################################
## Generate password
###################################

_HTPASSWD_USERNAME='';
while [[ "${_HTPASSWD_USERNAME}" = "" ]]; do
    read -p "What’s your username ? " _HTPASSWD_USERNAME;
done
htpasswd -c  "${_PATH}/.htpasswd" "${_HTPASSWD_USERNAME}";

###################################
## Generate htaccess
###################################

_HTACCESS_CONTENT=$(cat <<EOF
AuthType Basic
AuthName "Admin"
AuthUserFile ${_PATH}/.htpasswd
Require valid-user
EOF
);

if [[ -f "admin-ajax.php" ]];then
    _HTACCESS_CONTENT=$(cat <<EOF
${_HTACCESS_CONTENT}
<Files admin-ajax.php>
  Order allow,deny
  Allow from all
  Satisfy any
</Files>
EOF
);
fi;

echo "${_HTACCESS_CONTENT}" >> "${_PATH}/.htaccess"
