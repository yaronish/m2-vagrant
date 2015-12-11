# Magento vagrant
Vagrant Configuration for M2

Requires 
```vagrant plugin install vagrant-triggers```
Run ```vagrant up``` and enjoy


To use puppet for provisioning existing machine:

```bash get-libs.sh```
```bash puppet.sh```
```sudo puppet apply --modulepath=puppet/modules ./puppet/manifests/site.pp```


Run ```vagrant ssh``` to logging in and ```magento``` to see available commands

# Knowing issues
run  ```sudo chown -R ${MAGENTO_ENV_USER}.${MAGENTO_ENV_USER} /var/www/html``` just after installation
