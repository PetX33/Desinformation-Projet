**Journal de Bord**

**15/11**

- Nous avons commencer à mettre des fichiers sur notre git commun, tel que les fichiers urls pour le français et l'anglais, les tableaux d'urls pour ces deux langues et la page de présentation (début de page de présentation) pour notre site. J'espère qu'on pourra mettre les fichiers concernant le chinois dans la semaine.
- Nous avons vu comment écrire une page HTML pour commencer à mettre en forme notre site web, qui permettra de visualiser nos résultats. Nous avons également fait la correction du miniprojet (écrire sous forme de tableau HTML les résultats). Nous n'avons pas rencontrer de difficultés particulière puisqu'à l'Inalco nous avons déjà un cours de langage web.

**22/11**

- Nous avons commencé à travailler sur notre projet de groupe, c'est-à-dire à aspirer les pages HTML, le texte de ces pages, à compter le nombre d'occurrence, extraire le contexte, et créer le concordancier. Pour cela on a modifier le programme du miniprojet en y ajoutant les différentes parties. On a décidé de séparer le programme traitement_url.sh en deux, une partie pour le chinois et l'autre pour l'anglais et le français. On a également fait un script pour le concordancier, car il fallait créer une autre page HTML et on trouvait cela plus simple pour séparer la partie HTML du code. 
- Pour la commande grep, comme nous n'utilisons pas tous le même système, nous n'avons pas la même commande, sur mac nous devons utiliser ggrep lorsque l'on cherche des expressions régulières en utilisant Perl, on a donc mis un vérification au début du programme qui permet de vérifier si ggrep existe ou non et determine qu'elle commande utiliser en fonction, grep ou ggrep.
- On a rencontré un petit problème pour recupérer certaines pages, je pense à cause de l'adblock, ça ne récupérer rien, on a donc du changer ces liens.

**29/11**

- Nous avons travailler sur les scripts permettant d'obtenir les dumps et contextes concaténés. Pour le français et l'anglais nous n'avons rencontrés aucune difficultés, cependant pour le chinois c'est autre chose, au départ lorsque l'on utilisait pas les dumps tokeniser, il n'y avait pas de problème pour obtenir les fichiers concordances.txt, mais après en utilisant les dumps tokenisés, nous avons d'abord du modifier la ligne de code permettant de retrouver le motif recherché dans le corpus car il ne trouvais rien, on a donc cherché et trouvé qu'il fallait utiliser LANG=zh_CN.UTF-8 avant ggrep (ou grep si sous linux) -P et utilisait \p{Han} dans l'expression régulière, pareil pour le sed qui permet de mettre chaque partie dans la bonne colonne, sur linux ça fonctionnait bien, mais pas sur mac, donc après plusieurs heures de recherche nous avons trouvé qu'il fallait rajouter un g devant sed et installer gnu-sed pour que ça fonctionne. 

**06/12**

- Nous avons fait des mises à jour sur le site en y incluant les pages "équipe.html", "scripts.html", "intro.html" et "analyse.html". Nous avons également généré les nuages de mots. Nous avons rencontré quelques difficultés pour l'utilisation de --mask, en effet le fond noir et la forme blanche ne fonctionnait pas, contrairement à ce qui était indiqué, mais il fallait une image avec les couleurs inversés, fond blanc, forme noir.

**18/12**

- Ajout de l'analyses pour l'anglais (coocurrences (itrameur), nuage de mots) ainsi que différentes pages html.

**01/01**

- Ajout des analyses pour le français et le chinois, ainsi que la présentation de l'équipe
- Finalisation du site