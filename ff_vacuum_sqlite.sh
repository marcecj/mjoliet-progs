# TODO: extend, so it can be run from cron
for i in ~/.mozilla/firefox/*.marcec/*.sqlite; do
    sqlite3 $i "vacuum;"
done
