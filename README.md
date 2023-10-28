# Ada-83-compiler-tools



## Motivation

Au moment de son apparition, le langage Ada, aujourd'hui "Ada 83", fut une vraie innovation et constituait un univers de programmation spécial contraignant son utilisateur à produire du logiciel bien conçu, tout en offrant à ce même utilisateur une palette de structures et de services logiciels inégalés sous une syntaxe remarquablement naturelle.
Les révisions ultérieures du langage aboutissant d'abord à Ada 95 puis 2005 et 2012 constituent-elles des progrès ? A titre personnel je ne le crois pas. L'introduction de la programmation objet et ses pointeurs omniprésents, ses types estampillés, la complication de la structure possible des programmes avec les paquets fils apportent une fausse impression de richesse alors que se multiplient simultanément les opportunités de faire des noeuds dans le système logiciel.
La plupart des programmes n'ont pas de bénéfice à tirer des mécanismes d'héritage et de structures d'enregistrement extensibles. Les idées qui sous-tendent ces fonctionnalités proviennent de systèmes à usage spécifique, et ce n'est qu'avec artifice qu'on les applique à tous les programmes ; souvent au détriment de la compréhensibilité de ceux-ci.
Quant à la syntaxe des révisions modernes du langage, il est clair que nombre de formules d'expression n'ont aucun sens immédiat et exigent une connaissance approfondie de certaines situations créées par la complexification des versions Ada ultérieures. De Ada 95 à Ada 2012, les révisions ont permis à de nombreux ingénieurs de travailler, mais comme de nombreux système logiciels, les développements empâtent et finalement dégradent la netteté du système d'origine et parfois même la philosophie.

Il apparaît dès lors souhaitable que reste accessible un langage Ada conforme à la définition d'origine Ada 83. Comment peut-on conserver un environnement juste réalisant le langage originel ? Gnat, le compilateur libre le plus utilisé possède une option -gnat83 qui compile en principe une version originelle du langage, mais l'ensemble du système de compilation adapté aux révisions alourdit considérablement l'implantation, et s'il s'agit de ne compiler que la version Ada 83, il est préférable de n'avoir que le strict nécessaire.

Ada 83 étant un langage dont l'implantation se montre malgré tout assez complexe, il n'existe que très peu de systèmes de compilation Ada 83 accessibles au niveau du code source. Une spécification SETL interprétable a été conservée par certains passionnés, mais en elle même elle est aujourd'hui de peu d'utilité. Cette spécification a fait l'objet d'une traduction en langage C qui a donné le compilateur NYU intégré au système Ada-Ed. Les sources C sont toujours accessibles et recompilables moyennant quelques interventions. Cependant, la structure du logiciel C traduit du SETL est bien difficile à appréhender.
Il eût été souhaitable que fut produit un compilateur Ada 83 en Ada 83. Malheureusement aucun tel source ne fut rendu accessible.
Le seul système qui s'en approchait, à notre connaissance, fut le prototype de traducteur Ada 83 vers DIANA produit par Peregrine Systems vers 1988. Ce système était fourni dans une suite logicielle composée de deux CD-ROMs.

C'est ce système que nous avons repris ici et modifié pour en mieux faire ressortir la structure en profitant de la disponibilité de Gnat. Notre espoir étant que ce prototype, qui est doté de caractéristiques intéressantes, puisse servir de base à un compilateur Ada 83 comparable à Ada-Ed, mais de maintenance facilitée par l'usage d'Ada 83 pour sa programmation.


Already a pro? Just edit this README.md and make it your own. Want to make it easy? [Use the template at the bottom](#editing-this-readme)!

## Add your files

- [ ] [Create](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#create-a-file) or [upload](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#upload-a-file) files
- [ ] [Add files using the command line](https://docs.gitlab.com/ee/gitlab-basics/add-file.html#add-a-file-using-the-command-line) or push an existing Git repository with the following command:

```
cd existing_repo
git remote add origin https://framagit.org/VMo/ada-83-compiler-tools.git
git branch -M main
git push -uf origin main
```

## Integrate with your tools

- [ ] [Set up project integrations](https://framagit.org/VMo/ada-83-compiler-tools/-/settings/integrations)

## Collaborate with your team

- [ ] [Invite team members and collaborators](https://docs.gitlab.com/ee/user/project/members/)
- [ ] [Create a new merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html)
- [ ] [Automatically close issues from merge requests](https://docs.gitlab.com/ee/user/project/issues/managing_issues.html#closing-issues-automatically)
- [ ] [Enable merge request approvals](https://docs.gitlab.com/ee/user/project/merge_requests/approvals/)
- [ ] [Set auto-merge](https://docs.gitlab.com/ee/user/project/merge_requests/merge_when_pipeline_succeeds.html)

## Test and Deploy

Use the built-in continuous integration in GitLab.

- [ ] [Get started with GitLab CI/CD](https://docs.gitlab.com/ee/ci/quick_start/index.html)
- [ ] [Analyze your code for known vulnerabilities with Static Application Security Testing(SAST)](https://docs.gitlab.com/ee/user/application_security/sast/)
- [ ] [Deploy to Kubernetes, Amazon EC2, or Amazon ECS using Auto Deploy](https://docs.gitlab.com/ee/topics/autodevops/requirements.html)
- [ ] [Use pull-based deployments for improved Kubernetes management](https://docs.gitlab.com/ee/user/clusters/agent/)
- [ ] [Set up protected environments](https://docs.gitlab.com/ee/ci/environments/protected_environments.html)

***

# Editing this README

When you're ready to make this README your own, just edit this file and use the handy template below (or feel free to structure it however you want - this is just a starting point!). Thank you to [makeareadme.com](https://www.makeareadme.com/) for this template.

## Suggestions for a good README
Every project is different, so consider which of these sections apply to yours. The sections used in the template are suggestions for most open source projects. Also keep in mind that while a README can be too long and detailed, too long is better than too short. If you think your README is too long, consider utilizing another form of documentation rather than cutting out information.

## Name
Choose a self-explaining name for your project.

## Description
Let people know what your project can do specifically. Provide context and add a link to any reference visitors might be unfamiliar with. A list of Features or a Background subsection can also be added here. If there are alternatives to your project, this is a good place to list differentiating factors.

## Badges
On some READMEs, you may see small images that convey metadata, such as whether or not all the tests are passing for the project. You can use Shields to add some to your README. Many services also have instructions for adding a badge.

## Visuals
Depending on what you are making, it can be a good idea to include screenshots or even a video (you'll frequently see GIFs rather than actual videos). Tools like ttygif can help, but check out Asciinema for a more sophisticated method.

## Installation
Within a particular ecosystem, there may be a common way of installing things, such as using Yarn, NuGet, or Homebrew. However, consider the possibility that whoever is reading your README is a novice and would like more guidance. Listing specific steps helps remove ambiguity and gets people to using your project as quickly as possible. If it only runs in a specific context like a particular programming language version or operating system or has dependencies that have to be installed manually, also add a Requirements subsection.

## Usage
Use examples liberally, and show the expected output if you can. It's helpful to have inline the smallest example of usage that you can demonstrate, while providing links to more sophisticated examples if they are too long to reasonably include in the README.

## Support
Tell people where they can go to for help. It can be any combination of an issue tracker, a chat room, an email address, etc.

## Roadmap
If you have ideas for releases in the future, it is a good idea to list them in the README.

## Contributing
State if you are open to contributions and what your requirements are for accepting them.

For people who want to make changes to your project, it's helpful to have some documentation on how to get started. Perhaps there is a script that they should run or some environment variables that they need to set. Make these steps explicit. These instructions could also be useful to your future self.

You can also document commands to lint the code or run tests. These steps help to ensure high code quality and reduce the likelihood that the changes inadvertently break something. Having instructions for running tests is especially helpful if it requires external setup, such as starting a Selenium server for testing in a browser.

## Authors and acknowledgment
Show your appreciation to those who have contributed to the project.

## License
For open source projects, say how it is licensed.

## Project status
If you have run out of energy or time for your project, put a note at the top of the README saying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.
