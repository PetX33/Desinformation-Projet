#!/usr/bin/env bash

lang=$1 # fr, en, zh
fichier_text=$2
motif=$3

if [ $# -ne 3 ]
then
	echo "Ce programme demande exactement trois arguments."
	echo "Usage : $0 <langue> <fichier> <motif>"
	exit
fi

if [ ! -f $fichier_text ]
then
  echo "le fichier $fichier_text n'existe pas"
  exit
fi

if [ -z $motif ]
then
  echo "le motif est vide"
  exit
fi

if [[ $lang != 'fr' && $lang != "en" && $lang != "zh" ]]
then
    echo "La langue doit être fr, en ou zh"
    exit
fi

if command -v ggrep > /dev/null; then
    GREP_CMD="ggrep"
else
    GREP_CMD="grep"
fi

echo 	"""
<html>
    <html lang=\"$lang\">
		<head>
			<meta charset=\"UTF-8\" />
			<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">
			<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
			<title>Concordance</title>
		</head>
		<body class=\"has-navbar-fixed-top\">
			<nav class=\"navbar is-light is-fixed-top\"><div class=\"navbar-menu\"><div class=\"navbar-start\"><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#introduction\">Introduction</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#analyse\">Analyse</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../scripts.html\">Scripts</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\">Tableaux</a><div class=\"navbar-dropdown\"><a class=\"navbar-item\" href=\"tableau_fr.html\">Français</a><a class=\"navbar-item\" href=\"tableau_en.html\">Anglais</a><a class=\"navbar-item\" href=\"tableau_zh.html\">Chinois</a></div></div></div><div class=\"navbar-end\"><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#aPropos\">À propos</a></div><div class=\"navbar-item\"><a href=\"https://github.com/PetX33/Desinformation-Projet\"><img src=\"../images/github_logo.png\" alt=\"Github\"></a></div></div></div></nav>
						<h1 class=\"title\" style=\"text-align: center; \">Concordance</h1>
						<table class=\"table is-bordered is-striped is-narrow is-hoverable is-fullwidth\">
								<thead style=\"background-color: #355b8a;\">
								<tr>
								<th class=\"has-text-right\" style=\" color: #ffffff\">Contexte gauche</th>
								<th style=\" color: #ffffff\">Cible</th>
								<th class=\"has-text-left\" style=\" color: #ffffff\">Contexte droit</th>
								</tr>
								</thead>
									"""

if [ "$lang" = 'zh' ]
then
	grep -E -o "(\w+|\W+){0,10}$motif(\W+|\w+){0,10}" $fichier_text | sed -E "s/(.*)($motif)(.*)/<tr><td class=\"has-text-right\">\1<\/td><td class=\"has-text-danger\">\2<\/td><td class=\"has-text-left\">\3<\/td><\/tr>/"
else
	grep -E -o -i "(\w+\W+){0,5}$motif(\W+\w+){0,5}" $fichier_text | sed -E -r "s/(.*)$motif(.*)/<tr><td class=\"has-text-right\">\1<\/td><td class=\"has-text-danger\">\2<\/td><td class=\"has-text-left\">\3<\/td><\/tr>/"
fi

echo "
								</tbody>
						</table>
		</body>
</html>
"
