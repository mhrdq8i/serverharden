# Server Hardening
### Minimal hardening for proxy server

Run `bash harden_proxy_server.sh`

The script is waiting for you to copy your `public ssh key` to your new user's home directory that was created recently. 

**Note:** `UFW` will be enabled after the script run, and the ssh port will be changed to `8452`, also you can't login into ssh through password.

--- 

### Follow the below command to copy your `public key`
```bash
$ ssh-copy-id -p <default_port_number> -i /path/to/<your_public_key> <new_user>@<server_address>
```

### Test your connection
```bash
$ ssh <your_server_ip_address> -p 8452 -l <new_user>
```
