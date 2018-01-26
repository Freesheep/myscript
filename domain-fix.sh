#/bin/bash

ALL_DDNS_DOMAIN=("ziguang-rjy1.7766.org")
TMP_FILE="/tmp/ziguang-rjy4.tmp"
TPL_FILE="/root/rinetd.conf.tpl"
CONF_FILE="/etc/rinetd.conf"
TMP_CONF_FILE="/root/rinetd.conf"
export LANG=zh_CN.UTF-8
LIANTONG="联通"

if [ ! -f $TPL_FILE ];then
  
echo "0.0.0.0 443  replace_ip 443" > $TPL_FILE

fi

for IP in ${ALL_DDNS_DOMAIN[@]}
do
REMOTE_HOST=`nslookup $IP ns1.3322.net | tail -2 | head -1 |awk -F" " '{print $2}'`
OLD_REMOTE_HOST=`head -n 1 $TMP_FILE`
echo $OLD_REMOTE_HOST
echo $REMOTE_HOST
date
if [ "$REMOTE_HOST" != "$OLD_REMOTE_HOST" ];then
  echo "changed."
  echo $REMOTE_HOST > $TMP_FILE
  REMOTE_TXT=`curl http://freeapi.ipip.net/$REMOTE_HOST` 
  IPPAN1=${REMOTE_TXT%%]*}
  IPPAN=${IPPAN1##*,}
  if [[ "$IPPAN" =~ "$LIANTONG" ]];then
    \cp $TPL_FILE $TMP_CONF_FILE
    sed -i 's/replace_ip/'`echo $REMOTE_HOST`'/g' $TMP_CONF_FILE
    \cp $TMP_CONF_FILE $CONF_FILE
    service rinetd restart
  fi
fi
done
