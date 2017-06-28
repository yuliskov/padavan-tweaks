#!/bin/sh

# To see remaining time: https://www.ho.ua/cgi-bin/hosting.cgi

logger `basename "$0"` has been started

# replace to /tmp on router
BASE=/tmp
LOGIN_HOST="https://www.ho.ua/cp/"
LOGIN_DATA="login=nik-art&password=nik-art&action=prolong&enter=%C2%F5%EE%E4"
LOGIN_COOKIE="phpbb3_aq128_u=1; phpbb3_aq128_k=; phpbb3_aq128_sid=e848be1819555ccb96f77a1b68c5ffe0; style_cookie=null"
LOGIN_HEADER1="Referer:https://www.ho.ua/cp/?login=nik-art&action=prolong"

echo "$LOGIN_DATA"

# login
curl --silent --dump-header $BASE/houa_header --insecure --header "$LOGIN_HEADER1" --data "$LOGIN_DATA" -L "$LOGIN_HOST" >/dev/null

echo "cookies: $(cat $BASE/houa_header | grep Set-Cookie)"

# find new cookie. match word between hosting= and ;
SESSION=$(cat $BASE/houa_header | grep Set-Cookie | grep -oE "=.*;" | grep -oE "[^=;]*")

echo "session: $SESSION"

LOGIN_HOST="https://www.ho.ua/cp/"
LOGIN_DATA="page_prolong_set=%CF%F0%EE%E4%EB%E8%F2%FC&session=$SESSION"
LOGIN_COOKIE="hosting=$SESSION"
LOGIN_HEADER1="Referer:https://www.ho.ua/cp/"

# prolong
curl --silent --insecure --header "$LOGIN_HEADER1" --cookie "$LOGIN_COOKIE" --data "$LOGIN_DATA" -L "$LOGIN_HOST" >/dev/null
