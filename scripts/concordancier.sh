#!/usr/bin/env bash

# Assigning command line arguments to variables
lang=$1 # Language code (fr, en, zh)
fichier_text=$2 # File path
motif=$3 # Pattern to search for

# Check if exactly three arguments are provided
if [ $# -ne 3 ]
then
	echo "Ce programme demande exactement trois arguments."
	echo "Usage : $0 <langue> <fichier> <motif>"
	exit
fi

# Check if the file exists
if [ ! -f $fichier_text ]
then
  echo "le fichier $fichier_text n'existe pas"
  exit
fi

# Check if the pattern is not empty
if [ -z $motif ]
then
  echo "le motif est vide"
  exit
fi

# Check if the language is one of the specified options
if [ "$lang" != "fr" ] && [ "$lang" != "en" ] && [ "$lang" != "zh" ]; then
    echo "La langue doit être fr, en ou zh"
    exit
fi


# Determine the grep command to use based on system availability
if command -v ggrep > /dev/null; then
    GREP_CMD="ggrep"
else
    GREP_CMD="grep"
fi

if command -v gsed > /dev/null; then
    SED_CMD="gsed"
else
    SED_CMD="sed"
fi

# Start of HTML output
echo """
<html>
	<head>
		<meta charset=\"UTF-8\"/>
		<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">
		<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
		<title>Tableau des concordances $basename</title>
		<link rel=\"stylesheet\" href=\"../../html_css/style.css\">
		<link rel=\"icon\" type=\"image/png\" href=\"../../images/logo.png\">
		<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"></script>
		<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.10.2/dist/umd/popper.min.js"></script>
		<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
	</head>
	<body class=\"has-navbar-fixed-top\">
	<nav class=\"navbar is-light\" role=\"navigation\" aria-label=\"main navigation\">
    	<div class=\"collapse navbar-collapse\" id=\"navbarResponsive\"><div class=\"logo\"><a href=\"../../index.html\"><img src=\"../../images/logo.png\" width=\"auto\"></a></div><div class=\"navbar-menu\"><div class=\"navbar-start\"><a class=\"navbar-item\" href=\"../../html_css/intro.html\">Introduction</a><a class=\"navbar-item\" href=\"./script.html\">Scripts</a><a class=\"navbar-item\" href=\"./analyse.html\">Analyse</a><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\">Tableaux</a><div class="navbar-dropdown"><a class=\"navbar-item sub\" href=\"../../tableaux/tableau_fr.html\">Français</a><a class=\"navbar-item sub\" href=\"../../tableaux/tableau_en.html\">Anglais</a><a class=\"navbar-item sub\" href=\"../../tableaux/tableau_zh.html\">Chinois</a></div></div></div></div>
		<div class=\"navbar-end\"><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"./equipe.html\">À propos</a></div><div class=\"navbar-item\"><a href=\"https://github.com/PetX33/Desinformation-Projet\"><img src=\"../../images/github_blanc.png\" alt=\"Github\"></a></div></div></div></nav>
        <!-- Title -->
            <h1 class=\"title\" style=\"text-align: center; \">Concordance</h1>
            <!-- Concordance table -->
            <table class=\"table is-bordered is-striped is-narrow is-hoverable is-fullwidth\">
                <thead style=\"background-color: #428cb5;\">
                    <tr>
                        <th class=\"has-text-right\" style=\" color: #ffffff\">Contexte gauche</th>
                        <th style=\" color: #ffffff\">Cible</th>
                        <th class=\"has-text-left\" style=\" color: #ffffff\">Contexte droit</th>
                    </tr>
                </thead>
                <tbody>
"""

# Search pattern logic for Chinese language
if [ "$lang" = 'zh' ]
then
    # Export the LANG variable for Chinese
    export LANG=zh_CN.UTF-8
    $GREP_CMD -Po "(?:\p{Han}{1,}\s){0,5}(虚假信息|政治宣传)(\s\p{Han}{1,}){0,5}" "$fichier_text" | LANG=C $SED_CMD -E -r "s/(.*)(虚假信息|政治宣传)(.*)/<tr><td class=\"has-text-right\">\1<\/td><td class=\"has-text-danger\">\2<\/td><td class=\"has-text-left\">\3<\/td><\/tr>/"

# Search pattern logic for other languages
else
    grep -E -o -i "(\w+\W+){0,5}$motif(\W+\w+){0,5}" $fichier_text | sed -E -r "s/(.*)$motif(.*)/<tr><td class=\"has-text-right\">\1<\/td><td class=\"has-text-danger\">\2<\/td><td class=\"has-text-left\">\3<\/td><\/tr>/"
fi

# End of HTML output
echo "
                </tbody>
            </table>

            <footer>
                <p>© 2021 - Projet Propagande et Désinformation - MA Zhiya • PENG Yuanlong • QUENNEHEN Perrine</p>
            </footer>
        </body>
</html>
"
