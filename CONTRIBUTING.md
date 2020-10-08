# Contributing to MailAD

This page is also available in the following languages: [ [Español](i18n/CONTRIBUTING.es.md) 🇪🇸 🇨🇺]

## Developer process & workflows

This document stablish the process and workflows as per github and gitflow good practices (in some cases simplified and relaxed), if in doubt please take a peek [here](https://medium.com/@devmrin/learn-complete-gitflow-workflow-basics-how-to-from-start-to-finish-8756ad5b7394) or [here](https://nvie.com/posts/a-successful-git-branching-model/)

This practices must appear so "elite" or "cathedral style" at first, but believe me you will thanks me for teaching you this if you pretend to work for a bigger or professional soft company. At the end and with the time you will see how easy is to pin-point any info from the entangle of branches, issues, travis, etc.

At first we will be easy with this but people, please catch the (git)flow ASAP.

## Issues!

Its all about issues, every change must have a reference issue in which the dev team can debate about, and branches that name the user and issue it's working on.

So if you need to do a change, fix something or add a new feature, please open an issue or feature for it. Once you have a issue number to work with, create a branch from latest develop in YOUR own fork and name it user_t#_short_description_of_issue, see here where I created a branch named stdevPavelmc_t8_travis_integration where the number is the issue number

## Commits

All commits comments must start with "Refs #8, ...." where in this case the #8 refers to the issue you are working on, why? see it [here in action](https://github.com/swl-x/MystiQ/issues/8)

Hover the mouse over the name, number and comments of the commit d4a19cd github does a great job by linking all together, this is possible because we mentiones the issue in the branch name and also in the commit comment.

## Pull request

Pull request are intentions to merge some code into the main tree, you can open a pull request of your local work at any time, the only condition is that you have pushed at least a commit for an issue.

In fact is a recommended practice, open an issue, analyze, make your first commit and open the pull request ride away; in this way changes will be picked by travis and CI/CD will fire to tell you if your changes are good o broke something.

As a general rule a pulll request must end with a comment on which you mentions @stdevPavelmc and estate that the pull request is ready to merge

The merge action by the repo owner (@stdevPavelmc) will automatically close the corresponding pull request and the issue just by adding a comment like this to the comment of the merge "Closing issue #8..." github will do the magic and will (if travis build is a success) close the PR and the matching issue, all in just one place.

## Monetary contributions

This is free software and you can use it without charges, but if you want to express your gratitude in monetary form here is how:

Este es un software libre y puedes usarlo sin cargos, pero si quieres expresar tu gratitud en forma monetaria estamos agradecidos por ello:

### Top my cell phone up!

That will allow me to stay online to develop & improve MailAD, my cell number is: **`(+53) 53 847 819`**, You can donate the amount you want.

Tip: my service provider has promotions almost every other week that will duplicate any amount over USD $20.00!

- The official top-up sites are this (you can also check www.etecsa.cu to verify them):
    - [Ding](https://www.ding.com)
    - [Recargas a Cuba](https://www.recargasacuba.com)
    - [CSQWorl](https://www.csqworld.com)
    - [Compra dtodo](https://moviles.compra-dtodo.com)
    - [Global DSD](https://www.globaldsd.com)
    - [Boss Revolution](https://www.bossrevolution.com)
    - [E-Topup Online](https://cubacel.etopuponline.com)
- By using **Crypto currencies**, use [BilRefill](https://www.bitrefill.com/buy/cubacel-cuba/?hl=en) for that.

### Direct money transfers (Only in Cuba)

- You can donate any amount in CUP (national currency) via Transfermovil:

<p align="center"><img src="imgs/donation_transfermovil_cup.png" alt="Transfermovil"></img></p>

**Thank you very much in advance!**
