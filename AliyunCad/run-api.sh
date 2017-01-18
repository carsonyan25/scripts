#!/bin/bash
# this script use to run api files automatically
# created by carson

# everyday money  count
curl -G -d key=268pcw -i http://app.aec188.com/admin/insdata

#everyday download count
curl -i http://app.aec188.com/admin/get_orders_datas/key/268pcw


# collect the download , payment info
#curl -i http://cad.pcw365.com/disk/cron/total.php


