# Installing SSL Certificate

To install the SSL certificate, follow these steps:
1. **Backup the older SSL files to `/var/backups/ssl`:**

    ```sh
    sudo mkdir -p /var/backups/ssl
    sudo cp /etc/ssl/certs/star_scg_com.crt /var/backups/ssl/star_scg_com.crt.bak -f
    sudo cp /etc/ssl/private/star_scg_com.key /var/backups/ssl/star_scg_com.key.bak -f
    ```
2. **Copy the private key and certificate files from the client to the server using `scp`:**

    ```sh
    scp /path/to/local/star_scg_com.crt user@server:~/star_scg_com.crt
    scp /path/to/local/star_scg_com.key user@server:~/star_scg_com.key #skip this command if the file already on server
    ```
    Replace `/path/to/local/` with the actual path to your certificate and key files on the client machine. Replace `user@server` with your server's username and hostname or IP address.

3. **Copy the private key and certificate files to destination directory:**
    ```sh
    sudo cp ~/star_scg_com.crt /etc/ssl/certs/star_scg_com.crt -f
    sudo cp ~/star_scg_com.key /etc/ssl/private/star_scg_com.key -f
    ```

4. **Set the correct permissions for the private key file:**

    ```sh
    sudo chmod 600 /etc/ssl/private/star_scg_com.key
    ```

5. **Verify the files are in the correct locations:**

    ```sh
    ls -l /etc/ssl/certs/star_scg_com.crt
    ls -l /etc/ssl/private/star_scg_com.key
    ```

6. **Test and restart web server to apply the changes.**

    Test configuration:
    ```sh
    sudo nginx -t
    ```

    Restart nginx:
    ```sh
    sudo systemctl restart nginx
    ```

Your SSL certificate should now be installed and active.