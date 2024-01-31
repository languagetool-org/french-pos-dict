#! /bin/bash
# le fichier doit être dans le directory de travail et passé en argument
###################################################### 
# fonction
######################################################
FontionSuppressionDoublons() {
  # Fichier à trier passé en argument
  InputFilename="${1}.sorted.txt"
  DedupedFilename="${1}.deduped.txt"
  DupesFileName="${1}.dupes.txt"
  MyLine1=""
  MyLine2=""
#  rm "$DupesFileName"
#  sed -e "s/[\t]/\\\\t/g;" "$InputFilename" > "$LiteralTabsFilename"
#  rm "$InputFilename"

  while read -r MyLine; do
    MyLine2=$MyLine1
    MyLine1=$MyLine
    if [ "$MyLine1" != "$MyLine2" ] ; then
        echo -e "$MyLine1" >> "$DedupedFilename"
    else
        echo "$MyLine1" >> "$DupesFileName"
    fi

  done < "$InputFilename"
}

