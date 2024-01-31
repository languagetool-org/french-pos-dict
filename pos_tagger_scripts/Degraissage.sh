#!/bin/bash
# Dégraissage du Fichier d'entrée

#Input=lexique-dicollecte-fr-v6.4
Input=$1

# Simplification

# Remove first 16 lines (comments, headers)
sed -e "1,16 d" $Input.txt  > $Input.01.txt

# Extract relevant columns
#sed -e "s/\([^\t]*\)[\t]\([^\t]*\)[\t]\([^\t]*\)[\t]\([^\t]*\)[\t]\([^\t]*\)[\t]\([^\t]*\)[\t]\([^\t]*\)[\t]\(.*\)\([^\t]*\)[\t]\(.*\)/\3\t\4\t\5\t/g" $Input.01.txt  > $Input.02.txt
awk -F'\t' '{print $3"\t"$4"\t"$5}' $Input.01.txt > $Input.02.txt

# Replace a bunch of tags??
sed -e "s/[\t]mg /\t/g" $Input.02.txt  > $Input.03.txt
sed -e "s/prep prepv/prep/g" $Input.03.txt  > $Input.04.txt
sed -e "s/ preverb//g" $Input.04.txt  > $Input.05.txt
sed -e "s/adv negadv/adv/g" $Input.05.txt  > $Input.06.txt
sed -e "s/negadv/adv/g" $Input.06.txt  > $Input.07.txt
sed -e "s/ detex//g" $Input.07.txt  > $Input.08.txt
sed -e "s/ proadv//g" $Input.08.txt  > $Input.09.txt
sed -e "s/\(.*\)\(prep\)\(.*\)\( loc\.prep\)\(.*\)/\1\2\3\5/g" $Input.09.txt  > $Input.10.txt
sed -e "s/loc\.nom/nom/g;" $Input.10.txt  > $Input.11.txt

#corrections de bugs du lexique dicollecte
sed -e "s/adj adj/adj epi/g; s/sg pl/inv/g; s/\tmieux\tadv nom/\tmieux\tadv nom mas inv/; s/au\tau\tprep det mas sg/au\tau\tdet mas sg/; s/aux\taux\tprep det mas pl/aux\taux\tdet epi pl/;" $Input.11.txt  > $Input.12.txt

#suppression des entrées actuellement incompatibes
#cat  | grep -v $'\t'l’ > $Input.maigre.txt

#compatibilisation des apostrophes
sed -e "s/^\([^\t]*\)’[\t]/\1\t/g;" $Input.12.txt > $Input.maigre.txt

#rm $Input.01.txt
#rm $Input.02.txt

