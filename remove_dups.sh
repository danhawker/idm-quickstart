cp fake-users.csv fake-users.csv.orig
cat fake-users.csv | cut -d , -f 1 | sort | uniq -c | sort -n | sed -e '/^   1 / d' > dups.txt
O_IFS=$IFS
IFS=$'\n'
for LINE in $(cat dups.txt); do

   COUNT=$(echo $LINE | awk '{ print $1 }')
   NAME=$(echo $LINE | awk '{ print $2 }')

  for I in $(seq 1 $COUNT); do
    RND="$(($RANDOM % 10))$(($RANDOM % 10))$(($RANDOM % 10))$(($RANDOM % 10))"
    NEW_NAME="${NAME}${RND}"
    gsed -i "0,/${NAME},/s//${NEW_NAME},/" fake-users.csv
  done

done
IFS=$O_IFS
cat fake-users.csv | cut -d , -f 1 | sort | uniq -c | sort -n | sed -e '/^   1 / d'


