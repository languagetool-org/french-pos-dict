#!/bin/bash

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SOURCE_DIR}/SuppressionDoublons.sh"

# Detect the operating system so we pick the right sed.
OS="$(uname)"
export OS

function sed_cmd {
  _expr="$1"
  _filepath=$2
  if [[ "$OS" == "Darwin" ]]; then
    sed -i '' -E "$_expr" "$_filepath"
  else
    sed -i -E "$_expr" "$_filepath"
  fi
}

DICOLLECTE_FILENAME="lexique-grammalecte-fr-v7.0"
SRC_DICOLLECTE_FILEPATH="${DATA_SRC_DIR}/${DICOLLECTE_FILENAME}"
LT_DICOLLECTE_FILEPATH="${RESULTS_DIR}/${DICOLLECTE_FILENAME}"

cp "${SRC_DICOLLECTE_FILEPATH}.txt" "${LT_DICOLLECTE_FILEPATH}.txt"

echo "Formatting lexical data..."
echo "step 1 ..."
bash "${SOURCE_DIR}/Degraissage.sh" "${LT_DICOLLECTE_FILEPATH}"
echo "step 2 ..."
perl "${SOURCE_DIR}/DicollecteDataFormatting.pl" "${LT_DICOLLECTE_FILEPATH}"
echo "step 3 ..."
bash "${SOURCE_DIR}/Simplification.sh" "${LT_DICOLLECTE_FILEPATH}.maigre.LT"
echo "step 4 ..."

# Add changes from added.txt and removed.txt
grep -Fvxf "${LT_CHANGES_DIR}/removed.txt" "${LT_DICOLLECTE_FILEPATH}.maigre.LT.txt" > "${LT_DICOLLECTE_FILEPATH}.removed.LT.txt"
grep -v '#' "${LT_CHANGES_DIR}/added.txt" > "${LT_CHANGES_DIR}/added-clean.txt"
cat "${LT_CHANGES_DIR}added-clean.txt" "${LT_DICOLLECTE_FILEPATH}.removed.LT.txt" > "${LT_DICOLLECTE_FILEPATH}.added.LT.txt"

# Fix lemma in adjectives: infinitive -> adj m s
sed_cmd 's/^(.*(é|ée|és|ées)\t.*)er\t(J .*)$/\1é\t\3/' "${LT_DICOLLECTE_FILEPATH}.added.LT.txt"

sort "${LT_DICOLLECTE_FILEPATH}.added.LT.txt" > "${LT_DICOLLECTE_FILEPATH}.sorted.txt"
echo "step 5 ..."
FontionSuppressionDoublons "${LT_DICOLLECTE_FILEPATH}.sorted.txt"
cp "${LT_DICOLLECTE_FILEPATH}.sorted.txt" "${RESULTS_DIR}/dict.txt"
