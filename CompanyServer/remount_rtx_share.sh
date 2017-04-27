#!/bin/bash
#create by carson
# this script use to remount /rtx_share(connect to rtx.pcw365.com server)  

#umount
umount -f /rtx_share 

#mount /rtx_share again
mount -t cifs -o username='administrator',password='admin-1610' //rtx.pcw365.com/rtx_share  /rtx_share 
