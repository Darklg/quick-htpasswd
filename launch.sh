#!/bin/bash

cat <<EOF

###################################
## Quick htpasswd v 0.5.1
###################################

EOF

_PATH=$(pwd);

####################################
## Check if htpasswd is installed
####################################

if ! command -v htpasswd &> /dev/null; then
    echo "htpasswd could not be found, please install it first.";
    exit 1;
fi;

###################################
## Detect an active protection
###################################

if [[ -f "${_PATH}/.htaccess" ]];then
    if grep -q "AuthUserFile" "${_PATH}/.htaccess"; then
        echo 'It looks like this folder is already protected !';
        exit 1;
    fi
fi;

###################################
## Generate password
###################################

_HTPASSWD_USERNAME='';
while [[ "${_HTPASSWD_USERNAME}" = "" ]]; do
    read -p "What’s your username ? " _HTPASSWD_USERNAME;
done
htpasswd -c  "${_PATH}/.htpasswd" "${_HTPASSWD_USERNAME}" || { echo "Error while creating .htpasswd file"; exit 1; }
read -p "Do you need to bypass protection for static assets ? Type yes/[no] : " _HTACCESS_STATIC_BYPASS;
read -p "Do you need to authorize specific IP addresses ? Type yes/[no] : " _HTACCESS_IP_BYPASS;

###################################
## Generate htaccess
###################################

_HTACCESS_CONTENT=$(cat <<EOF

# htpasswd protection
AuthType Basic
AuthName "Admin"
AuthUserFile ${_PATH}/.htpasswd
Require valid-user
ErrorDocument 401 "401"
EOF
);

# Bypass protection for admin-ajax.php
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

# Bypass protection for specific IP addresses
if [[ "${_HTACCESS_IP_BYPASS}" == 'yes' || "${_HTACCESS_IP_BYPASS}" == 'y' ]];then
    _HTACCESS_CONTENT=$(cat <<EOF
${_HTACCESS_CONTENT}
Order deny,allow
Deny from all
Allow from 1.1.1.1
Allow from 8.8.8.8
Satisfy any
EOF
);
fi;

# Bypass protection for static content
if [[ "${_HTACCESS_STATIC_BYPASS}" == 'yes' || "${_HTACCESS_STATIC_BYPASS}" == 'y' ]];then
    _HTACCESS_CONTENT=$(cat <<EOF
${_HTACCESS_CONTENT}
<Files ~ "\.(css|js|jpg|png|svg|jpeg|gif)$">
  Order allow,deny
  Allow from all
  Satisfy any
</Files>
EOF
);
fi;

echo "${_HTACCESS_CONTENT}" >> "${_PATH}/.htaccess";
