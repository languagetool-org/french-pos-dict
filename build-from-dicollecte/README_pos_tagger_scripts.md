# Speller: `pos_tagger_scripts` (legacy)
Before Q1 2024, the entire binary build and release process relied on Grammalecte data and legacy scripts.
Some modifications were implemented in the legacy scripts, and these changes will be detailed.
The Part-of-Speech (PoS) tagging logic is outlined below. 
However, with the discontinuation of the Grammalecte project in December 2022, there will be no new dicollecte releases. 
Consequently, the steps preceding Step 4 are no longer necessary for replication.

### Main Script: `build-lt`
The main script, named `build-lt.sh`, orchestrates the entire process step by step with added debugging functionalities. At each stage, the script echoes the current step, and each step outputs a file with a unique name, facilitating easy tracking and debugging. This was not as readable in the original state of the repo.

#### Step 1: Degreasing (`Degraissage.sh`)
- **Input:** Grammalectv7.0 data
- **Output:** `maigre.txt` (meaning "lean")
    1. `Degraissage.sh` initiates the process, producing `degraissage.01.txt` by removing the first 16 lines (comments).
    2. Using an AWK instead of SED, `degraissage.02.txt` is created by keeping the first 3 columns of the v7.0 file.
    3. Further removals and adjustments are made on these columns before running a Perl script. This involves nine separate SED commands, each generating debug files from `degraissage.03.txt` to `degraissage.11.txt`.
    4. A multistep correction is applied to fix bugs in the lexique dicollecte, and the final output is `degraissage.12.txt`.
    5. Some tags are changed, and apostrophes are replaced. The result is `maigre.txt`.
#### Step 2: Data Formatting (`DicollecteDataFormatting.pl`)
    The Perl script `DicollecteDataFormatting.pl` changes tags to LT-compatible ones and performs additional replacements.
#### Step 3: Simplification (`Simplification.sh`)
    Replacements are applied on the tags again, and additional fixes for some Grammalecte bugs are implemented.
#### Step 4: Integration of Additional Words
- **Input:** `fr.simplif.txt`, `added.txt`, `remove.txt`
  - **Output:** Updated `fr.simplif.txt`
      Words already tagged from LT added/removed are integrated into the dicollecte data. 
  For new releases, this step is the one that should be repeated with the current word lists.
#### Step 5: Sed Replacement
- **Input:** `fr.simplif.txt`
- **Output:** `fr.simplif.txt`
    A Sed script replaces versions of é|ée|és in the file.
#### Step 6: Duplicate Removal
- **Input:** `fr.simplif.txt`
- **Output:** `fr.simplif.txt`
    After sorting, duplicates resulting from the normalization of é|ée pairs are removed.
#### Step 7: Removal of Duplicates (`SuppressionDoublons.sh`)
- **Input:** `fr.simplif.txt`
- **Output:** `fr.simplif.txt`
    A cleanup script (`SuppressionDoublons.sh`) removes duplicates generated in the Step 6. In the future, we should implement a new method, utilizing `sort` and `uniq` for optimization.
 `dict.txt` is ready for use. 

This final file is now directly accessible in `data/dict.txt`, simplifying the addition of new data without the need to modify the Dicollecte file. 
Further investigation is required to understand and potentially optimise certain steps in the process. 
A full rewrite in Python would make the whole process more stable and future-proof.
