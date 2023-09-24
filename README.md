# Server Hardening

## Minimal hardening for proxy server

### How to run

1. clone this repo

   ```bash
   git clone https://github.com/mehrdad-drpc/serverharden.git
   ```

2. change you location inside the project directory

   ```bash
   cd serverharden
   ```

3. run this command and enter the inputs

   ```bash
   sudo bash hardening.sh
   ```

### one-command-run

you can also do the above steps with one command

```bash
git clone https://github.com/mehrdad-drpc/serverharden.git && cd serverharden && sudo bash hardening.sh
```

The script is waiting for you to copy your `public ssh key` to your new user's home directory that was created recently.

**Note:** `UFW` will be enabled after the script is run, and the ssh port will be changed to `8452`, also you can't login into ssh through [password](https://github.com/mehrdad-drpc/serverharden/blob/edc3601d1befeb838a87acca3e3294eac1698990/sshd_config#L9) due to new ssh config.

### move the haproxy [config sample file](haproxy.cfg) via this command

```bash
sudo mv --force --verbose haproxy.cfg /etc/haproxy/haproxy.cfg
```

---

### Follow the below command to copy your `public key`

```bash
$ ssh-copy-id -p <default_port_number> -i /path/to/<your_public_key> <new_user>@<server_address>
```

### Test your connection

```bash
$ ssh <your_server_ip_address> -p 8452 -l <new_user>
```
