#!/bin/bash
#created by carson
#renew ssl certificate  automatically (signed to let's encry )

case $1 in 
	apache)
		certbot renew --quiet
		service apache restart
		;;
	nginx)
		service nginx stop 
		certbot renew --quiet
		service nginx start 
		;;
	*)
		echo "parameter must be apache or nginx"
		;;
esac	



