french-pos-dict
===============

A French part-of-speech dictionary that can be used from Java. This repo contains no code
but [Morfologik](https://github.com/morfologik/) binary files to look up part-of-speech data.
As a developer, consider using [LanguageTool](https://github.com/languagetool-org) instead
of this. If you really want to use this directly, please check out the unit tests for examples.

Also use LanguageTool to export the data in these dictionaries, [as documented here](https://dev.languagetool.org/developing-a-tagger-dictionary#exporting-the-data).

## Internal

To make a release:

* set the version in `pom.xml` to not include `SNAPSHOT`
* `mvn clean test`
* `mvn clean deploy -P release`
* go to https://oss.sonatype.org/#stagingRepositories
* scroll to the bottom, select latest version, and click `Release`
* `git tag vx.y`
* `git push origin vx.y`
