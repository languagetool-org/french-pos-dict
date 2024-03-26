french-pos-dict
===============

A French part-of-speech dictionary that can be used from Java. This repo contains no Java code,
but it contains [Morfologik](https://github.com/morfologik/) binary files to look up part-of-speech data.

As a developer, consider using [LanguageTool](https://github.com/languagetool-org) instead  of this. If you really want to
use this directly, though, do it at your own peril.

Also use LanguageTool to export the data in these dictionaries, [as documented here](https://dev.languagetool.org/developing-a-tagger-dictionary#exporting-the-data).

# Workflow

If you simply intend on making changes to the dictionary data (i.e. adding/removing words,
changing part-of-speech tags, etc.), you can follow this workflow:

1. clone this repo and make changes to the dictionary files in `./data`, or update the LT files in `lt-changes`;
2. push to this repo;
3. the GitHub Actions workflows will trigger, and build the dictionary files, as well as test them against current LT;
4. if all tests pass, push a new tag — this will release the new dictionary binaries to SonaType;
5. update the `french-pos-dict` version in LT's `pom.xml` to the new one.

# Development

If you want to build the dictionaries locally, you will need to set up your environment as per
the instructions of the [dict_tools](dict_tools/README.md) submodule. Once you do, simply running
`./dict_tools/scripts/build_tagger_dicts.py` (with the appropriate arguments) will build the dictionaries.

The [French-specific scripts](pos_tagger_scripts/README.md) are legacy, and we do not recommend modifying them extensively.
If you intend on working on them, please consider instead rewriting them in a more future-proof language, like Python.
