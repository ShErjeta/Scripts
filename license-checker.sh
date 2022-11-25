FILES="/mnt/c/Users/ErjetaShkodra/Desktop/*.json"
dst="/mnt/c/Users/ErjetaShkodra/jsons/$(date +"%d-%m-%Y")_license-report.csv"
 if [ -f "$dst" ]
  then
     rm -rf $dst
  fi
for f in $FILES
do
  basename "$f"
  fn="$(basename -- $f)"
  if grep -iFq "license" $f
  then
    printf -- "\n$fn\n\n" >> $dst
    jq --raw-output '.dependencies[] | [.license, .fileName] | join(", ")' $f >> $dst
  else
    printf -- "\n$fn - No License Found For This File!" >> $dst
  fi
done
