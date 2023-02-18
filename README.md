# Quick htpasswd
Quickly add a password protection to a folder via htpasswd on Apache 2.

## How to run

```bash
bash <(wget -qO- https://raw.githubusercontent.com/Darklg/quick-htpasswd/main/launch.sh)
```
## Roadmap

- [x] Detect if a protection is active to avoid duplicate in htaccess.
- [x] Ask to bypass protection for assets (JS, CSS, Images, etc).
- [ ] Ask to protect extra files.


### Protect an extra file

```bash
<Files wp-login.php>
AuthType Basic
AuthName "Admin" # Same name as the other protected directories & files
AuthUserFile [HTPASSWDPATH]/.htpasswd
Require valid-user
</Files>
```
