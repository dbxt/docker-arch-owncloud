docker-owncloud
===============

Arch Linux based Docker container including owncloud running on apache with sqlite, mariadb and php-xcache.

Any issues you encounter withthis image can be reported here:  
https://github.com/l3iggs/docker-owncloud/issues

Say thanks by adding a comment or a star here:  
https://registry.hub.docker.com/u/l3iggs/owncloud/

## Usage

1. [**Install docker**](https://docs.docker.com/installation/)
1. **Download and start the owncloud server instance**  
`docker run --name oc -p 80:80 -p 443:443 -d l3iggs/owncloud`
1. **Access the owncloud setup page**  
Point your browser to:  
http://localhost/owncloud  
or  
https://localhost/owncloud  
and follow the on-onscreen instructions to finish the owncloud server setup.
1. **[Optional] Change your owncloud data storage location**  
On the Owncloud initial setup page, after setting up your admin account, instead of clicking the "Finish Setup" button, you can click "Storage & database" instead. You can change the data folder location here (note that this is a path inside the docker container, not on your host machine).  
It's likely desirable for owncloud's data storage to be placed in a persistant storage location outside the docker container, on the host's file system for example. Let's imagine you wish to store your docker files in a folder `~/ocfiles` on the host's file system. Then insert the following into the docker startup command (from step 2. above) between `run` and `--name`:  
`-v ~/ocfiles:/usr/share/webapps/owncloud/data`  
UID 33 or GID 33 (http in the container image) must have r/w permissions for `~/ocfiles` on the host system. Generally, it's enough to do:  
`chmod -R 770  ~/ocfiles; sudo chgrp -R 33  ~/ocfiles`  
[Read this if you run into permissions issues in the container.](http://stackoverflow.com/questions/24288616/permission-denied-on-accessing-host-directory-in-docker)
1. **[Optional] Change your owncloud config storage location**  
Similar to the above change, this allows the owncloud config directory to be stored outside of the docker container.  
`-v ~/occonfig:/etc/webapps/owncloud/config`  
`chmod -R g+rw  ~/occonfig; sudo chgrp -R 33  ~/occonfig`
1. **[Optional] Setup owncloud to use mariadb instead of the default sqlite database**  
On the Owncloud initial setup page, after setting up your admin account, instead of clicking the "Finish Setup" button, you can click "Storage & database" instead. Then click the "MySQL/MariaDB" enter 'root' in the Database user field and leave the password field blank. Choose any name you like for the Database name field. The Database host filed should be left as 'localhost' if you'd like to use the mariadb server provided in this docker image. You can get even fancier and direct owncloud to use a MySQL server outside of the docker image.
1. **[Optional] Harden security**  
This image comes complete with a self-signed ssl certificate already built in, so https access is ready to go out of the box. This pre-generated certificate is provided for convienence. I've provided it for testing purposes only, it affords greatly reduced security since the "private" key is not actually private; anyone can download this image and inspect the keys and then decrypt your ownCloud traffic. To make the ssl connection to this ownCloud server secure, you can (A) provide your own (secret) ssl certificate files or (B) use the script provided here to generate new, self-signed certificate files. Both will provide equal security but (B) will result in browser warnings whenever somone visits your site since the web browser will likely not trust your self-signed keys.  
_For option (A) (providing your own SSL cert files):_  
Assuming you have your own `server.crt` and `server.key` files in a directory `~/sslCert` on the host machine:   
`sudo chown -R root ~/sslCert; sudo chgrp -R root ~/sslCert`  
`sudo chmod 400 ~/sslCert/server.key`   
Then add `-v ~/sslCert:/https` to the docker run command line.  
_For option (B) (using the built-in script to re-generate your own self-sigend ssl certificate):_  
Any time after starting the docker image as described above, run the following two commands:  
`docker exec -it oc SUBJECT="/C=US/ST=CA/L=CITY/O=ORGANIZATION/OU=UNIT/CN=localhost" /etc/httpd/conf/genSSLKey.sh`  
`docker exec -it oc apachectl restart`  
These certificates are stored inside the docker container, so if you upgrade it or otherwise reset it, you'll need to re-generate these. You could edit the `SUBJECT` of the certificate to your liking, especially if you don't want your certificate to be for `localhost`
For either (A) or (B), remember to turn on the option to force https connections in the ownCloud admin settings page to take advantage of your hardened security.
1. **[Optional] Stop the docker-owncloud server instance**  
`docker stop oc`
1. **[Optional] Delete the docker-owncloud server instance (after stopping it)**  
`docker rm oc`
1. **Profit.**
