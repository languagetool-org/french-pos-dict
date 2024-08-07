#!/bin/bash -e

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SOURCE_DIR}/SuppressionDoublons.sh"

DICOLLECTE_FILENAME="lexique-grammalecte-fr-v7.0"
SRC_DICOLLECTE_FILEPATH="${DATA_SRC_DIR}/${DICOLLECTE_FILENAME}"
LT_DICOLLECTE_FILEPATH="${RESULTS_DIR}/fr"
LT_READY_FILEPATH="${DATA_SRC_DIR}/dict.txt"

# Remove all "fr." prefixed files from results dir before starting
rm "${RESULTS_DIR}/fr."*

# If the prepared file already exists, just copy that to the LT dir, and then move on with added/removed steps
if [ -f "${LT_READY_FILEPATH}" ]; then
    echo "File ready for compilation found; skipping steps 1-3..."
    cp "${LT_READY_FILEPATH}" "${LT_DICOLLECTE_FILEPATH}.lt.simplif.txt"
else
  cp "${SRC_DICOLLECTE_FILEPATH}.txt" "${LT_DICOLLECTE_FILEPATH}.txt"

  echo "Formatting lexical data..."
  echo "Step 1: dégraissage..."
  bash "${SOURCE_DIR}/Degraissage.sh" "${LT_DICOLLECTE_FILEPATH}"
  # Main output: fr.maigre.txt

  echo "Step 2: dicollecte formatting with Perl..."
  perl "${SOURCE_DIR}/DicollecteDataFormatting.pl" "${LT_DICOLLECTE_FILEPATH}"
  # Main output: fr.lt.txt

  echo "Step 3: simplification..."
  bash "${SOURCE_DIR}/Simplification.sh" "${LT_DICOLLECTE_FILEPATH}.lt"
  # Main output: fr.lt.simplif.txt
fi

echo "Step 4: making changes from added/removed.txt..."
grep -Fvxf "${LT_CHANGES_DIR}/removed.txt" "${LT_DICOLLECTE_FILEPATH}.lt.simplif.txt" > "${LT_DICOLLECTE_FILEPATH}.removed.lt.txt"
grep -v '#' "${LT_CHANGES_DIR}/added.txt" > "${LT_CHANGES_DIR}/added-clean.txt"
cat "${LT_CHANGES_DIR}/added-clean.txt" "${LT_DICOLLECTE_FILEPATH}.removed.lt.txt" > "${LT_DICOLLECTE_FILEPATH}.added.lt.txt"
# Main output: fr.added.lt.txt

echo "Step 5: fixing adjective lemmata: infinitive -> adj m s..."
sed -E "s/^(.*(é|ée|és|ées)\t.*)er\t(J .*)$/\1é\t\3/" "${LT_DICOLLECTE_FILEPATH}.added.lt.txt" > "${LT_DICOLLECTE_FILEPATH}.fixed.lt.txt"

echo "Step 6: sorting..."
sort "${LT_DICOLLECTE_FILEPATH}.fixed.lt.txt" > "${LT_DICOLLECTE_FILEPATH}.sorted.txt"

echo "Step 7: deduping..."
FontionSuppressionDoublons "$LT_DICOLLECTE_FILEPATH"

cp "${LT_DICOLLECTE_FILEPATH}.deduped.txt" "${RESULTS_DIR}/dict.txt"
