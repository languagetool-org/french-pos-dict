#!/bin/bash
# Simplification du jeu de tags

Input=$1
cp "${Input}.txt" "${Input}.simplif.01.txt"

# Simplification
sed -e "s/R pers suj \([12]\) [^ ]*/R pers suj \1/g; s/R pers obj \([12]\) [^ ]*/R pers obj \1/g;" "${Input}.simplif.01.txt"  > "${Input}.simplif.02.txt"
# Correction de bugs dicollecte
sed -e "s/\tlaquelle\t/\tlequel\t/g; s/\tlesquels\t/\tlequel\t/g; s/\tauxquelles\t/\tauquel\t/g; s/\tauxquels\t/\tauquel\t/g;  s/\ttoutes\t/\ttout\t/g; s/\ttoute\t/\ttout\t/g; s/\ttous\t/\ttout\t/g;" ${Input}.simplif.02.txt  > ${Input}.simplif.txt

#rm $Input.simplif*.txt
