#!/bin/bash
#
#    This creates the POS tag dictionary 'french.dict'
#    and the synthesizer dictionary 'french_synth.dict'
#    from the dicollecte lexique
#
#   Compile Input format :
#   en trois colonnes : flexion lemme   étiquette
#   séparées par des tabulations
#
#   abandonnique abandonnique J e s
#   abandonniques abandonnique J e p
#   abandonnisme abandonnisme N m s
#   abandonnismes abandonnisme N m p
#   abandonnons abandonner V imp pres 1 p
#   abandonnons abandonner V ind pres 1 p
#   abandonnions abandonner V sub pres 1 p
#   abaque abaque N m s
#   abaques abaque N m p
#
# http://grammalecte.net/download/fr/lexique-grammalecte-fr-v7.0.zip
#

#ToolPath="../../languagetool/languagetool-tools/target/"
ToolPath="../../languagetool/languagetool-standalone/target/LanguageTool-5.7-SNAPSHOT/LanguageTool-5.7-SNAPSHOT/"
#ToolName="languagetool-tools-5.7-SNAPSHOT-jar-with-dependencies"
ToolName="languagetool"
Input="lexique-grammalecte-fr-v7.0"

Output="french"
OldDict="old-french"
#Debug=false
Debug=true
. ./SuppressionDoublons.sh

if [ ! -f "$ToolPath""$ToolName"".jar" ]; then
    echo -e "\nBuilding packages first, they are needed to compile the dictionary .."
    cd "../../languagetool/"
    mvn package -DskipTests
    cd "../french-pos-dict/build-from-dicollecte/"
fi

echo -e "\n${0}"" is running ..."

#rm $Output*

# Téléchargement du Lexique Dicollecte
echo "Donwloading lexique-dicollecte ..."
if [ ! -f $Input.zip ]; then
  wget http://grammalecte.net/download/fr/$Input.zip
fi

mv french.dict $OldDict.dict 

if [ ! -f $Input.txt ]; then
  rm README*
  unzip $Input.zip
fi

# Mise en forme des données du Lexique Dicollecte
echo "Formatting lexique data ..."
echo "step 1 ..."
chmod +x Degraissage.sh
./Degraissage.sh $Input
echo "step 2 ..."
chmod +x DicollecteDataFormatting.pl
./DicollecteDataFormatting.pl $Input
echo "step 3 ..."
chmod +x Simplification.sh
./Simplification.sh $Input.maigre.LT 
echo "step 4 ..."

# add changes from added.txt and removed.txt
grep -Fvxf ../lt-changes/removed.txt $Input.maigre.LT.txt > $Input.removed.LT.txt
grep -v '#' ../lt-changes/added.txt > ../lt-changes/added-clean.txt
cat ../lt-changes/added-clean.txt $Input.removed.LT.txt > $Input.added.LT.txt

# fix lemma in adjectives: infitintive -> adj m s 
sed -i -E 's/^(.*(é|ée|és|ées)\t.*)er\t(J .*)$/\1é\t\3/' $Input.added.LT.txt

cat $Input.added.LT.txt | sort > $Input.sorted.txt 
echo "step 5 ..."
FontionSuppressionDoublons $Input.sorted.txt
mv $Input.sorted.txt $Input.LT.txt

# Compilation des dictionnaires avec LT
echo -e "\tCompiling dictionnaries ..."

#echo "# Dictionary properties." > $Output.info
#echo "fsa.dict.separator=+">> $Output.info
#echo "fsa.dict.encoding=utf-8" >> $Output.info
#echo "fsa.dict.encoder=SUFFIX" >> $Output.info

#cp $Output.info "$Output""_synth.info"


java -cp "$ToolPath""$ToolName"".jar" \
org.languagetool.tools.POSDictionaryBuilder \
    -i $Input.LT.txt \
    -info $Output.info \
    -freq fr_wordlist.xml \
    -o $Output.dict

java -cp "$ToolPath""$ToolName"".jar" \
org.languagetool.tools.DictionaryExporter \
    -i $Output.dict \
    -info $Output.info \
    -o $Output.dump 


java -cp "$ToolPath""$ToolName"".jar" \
org.languagetool.tools.SynthDictionaryBuilder \
     -i $Output.dump \
     -info "$Output""_synth.info" \
     -o "$Output""_synth.dict"

mv -f "$Output""_synth.dict_tags.txt" ./"$Output""_tags.txt"

#comparaison des dictionnaires version 6.1 et 6.4
if [[ ( "$Debug" == true ) && ( -f $OldDict.dict ) ]]
    then
    cp $Output.info "$OldDict"".info"

java -cp "$ToolPath""$ToolName"".jar" \
org.languagetool.tools.DictionaryExporter \
    -i $OldDict.dict \
    -info $OldDict.info \
    -o $OldDict.dump 

    echo -e "\nDictionaries comparison v6.4.1 versus v-6.1:"
    wc -l $Output.dump
    wc -l $OldDict.dump
# output:
# 624133 french.dump
# 617826 old-french-6.1.dump
echo "Differences in dump.diff"
diff $OldDict.dump $Output.dump > dump.diff

fi


if [[ ( "$Debug" == false ) ]]
    then
    rm $Input.maigre*
    rm *.dump
fi
echo -e "\nDone.\n"
