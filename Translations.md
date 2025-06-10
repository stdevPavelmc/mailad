<!-- Original translation by: @stdevPavelmc "Pavel Milanes" <pavelmc@gmail.com> -->
# Translations

This page is also available in the following language(s): [ [Español](i18n/Translations.es.md) 🇪🇸 🇨🇺] [ [Deutsch](i18n/Translations.de.md) 🇩🇪] *Warning: translations may be outdated.*

This document contains the guidelines for MailAD translations.

## Goal

The main goal is to establish guidelines for contributing translations to languages other than English. This should avoid duplication of work and loss of time.

At the beginning, the focus will be on the documentation.

## Guidelines

These are the main guidelines, which may change over time:

1. Translations must be done in a new file derived from the original by adding the [two-letter language code](https://es.wikipedia.org/wiki/ISO_639-1) to the name. For example, for Spanish, `README.md` will become `README.es.md`. The new files must be placed under the `i18n` directory.

2. You must start with the original file and only translate the explanatory text. Don't translate the text inside code blocks as they are software-generated and must remain in the original language.

3. All documentation translation PRs must be made against the `development` branch. I will be responsible for review and merging.

4. Please only make a PR when you have a complete translation of a document. Avoid sending partial translations, as this will waste both your time and mine.

5. You can claim authorship of a translation by inserting a hidden line like the one at the top of this document with your information. I will respect this attribution when you submit it *(this line will not be shown via web but will be visible locally)*.

6. When you intend to start a translation, please go to [issue #10](https://github.com/stdevPavelmc/mailad/issues/10) and check if anyone else is already working on that document and language.
