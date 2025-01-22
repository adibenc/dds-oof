cn1=ooffice-ds
docker exec $cn1 sudo supervisorctl start ds:example
# Add it to the autostart:
docker exec $cn1 sudo sed 's,autostart=false,autostart=true,' -i /etc/supervisor/conf.d/ds-example.conf
