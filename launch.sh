#!/bin/bash

cat <<EOF

###################################
## Quick htpasswd v 0.7.0
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

        _EXISTING_HTPASSWD=$(grep -m1 "AuthUserFile" "${_PATH}/.htaccess" | awk '{print $2}');
        read -p "Do you want to add a user to ${_EXISTING_HTPASSWD} ? Type yes/[no] : " _ADD_USER;
        if [[ "${_ADD_USER}" != 'yes' && "${_ADD_USER}" != 'y' ]];then
            exit 1;
        fi;

        _NEW_USERNAME='';
        while [[ "${_NEW_USERNAME}" = "" ]]; do
            read -p "What’s the new username ? " _NEW_USERNAME;
        done
        htpasswd "${_EXISTING_HTPASSWD}" "${_NEW_USERNAME}" || { echo "Error while updating .htpasswd file"; exit 1; }
        exit 0;
    fi
fi;

###################################
## Generate password
###################################

_HTPASSWD_CREATE='1';
if [[ -f "${_PATH}/.htpasswd" ]];then
    echo 'A .htpasswd file exists but is not used by .htaccess.';
    read -p "Reuse existing .htpasswd? \"no\" will overwrite it. Type [yes]/no : " _HTPASSWD_REUSE;
    if [[ "${_HTPASSWD_REUSE}" != 'no' && "${_HTPASSWD_REUSE}" != 'n' ]];then
        _HTPASSWD_CREATE='0';
        read -p "Add a user to .htpasswd ? Type yes/[no] : " _ADD_USER;
        if [[ "${_ADD_USER}" == 'yes' || "${_ADD_USER}" == 'y' ]];then
            _NEW_USERNAME='';
            while [[ "${_NEW_USERNAME}" = "" ]]; do
                read -p "What’s the new username ? " _NEW_USERNAME;
            done
            htpasswd "${_PATH}/.htpasswd" "${_NEW_USERNAME}" || { echo "Error while updating .htpasswd file"; exit 1; }
        fi;
    fi;
fi;

if [[ "${_HTPASSWD_CREATE}" == '1' ]];then
    _HTPASSWD_USERNAME='';
    while [[ "${_HTPASSWD_USERNAME}" = "" ]]; do
        read -p "What’s your username ? " _HTPASSWD_USERNAME;
    done
    htpasswd -c  "${_PATH}/.htpasswd" "${_HTPASSWD_USERNAME}" || { echo "Error while creating .htpasswd file"; exit 1; }
fi;
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
