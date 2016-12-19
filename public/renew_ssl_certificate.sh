#!/bin/bash
#created by carson
#renew ssl certificate  automatically (signed to let's encry )


service $1 stop  
certbot renew --quiet
service $1 start 


