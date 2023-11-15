#!/usr/bin/env bash

if [ $# -ne 2 ];
then
	echo "Deux arguments attendu exactement"
	exit
fi

if [ -f $1 ]
then
	echo "On a bien un fichier"
else
	echo "On attend un fichier qui existe"
	exit
fi

fichier_urls=$1
fichier_tableau=$2

basename=$(basename -s .txt $fichier_urls)
lineno=1

echo "<html>
	<head>
		<meta charset=\"utf-8\"/>
		<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">
		<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
		<title>Tableau des URLS</title>
	</head>
	<body class="has-navbar-fixed-top">
		<nav class=\"navbar is-light is-fixed-top\"><div class=\"navbar-menu\"><div class=\"navbar-start\"><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"./index.html#introduction\">Introduction</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#analyse\">Analyse</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../scripts.html\">Scripts</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\">Tableaux</a><div class=\"navbar-dropdown\"><a class=\"navbar-item\" href=\"tableau_fr.html\">Français</a><a class=\"navbar-item\" href=\"tableau_en.html\">Anglais</a><a class=\"navbar-item\" href=\"tableau_zh.html\">Chinois</a></div></div></div><div class=\"navbar-end\"><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#aPropos\">À propos</a></div><div class=\"navbar-item\"><a href=\"https://github.com/PetX33/Desinformation-Projet\"><img src=\"./images/github_logo.png\" alt=\"Github\"></a></div></div></div></nav>" > "$fichier_tableau"

echo "		<h1 class=\"title\" style=\"text-align: center; \">Tableau des URLs $basename</h1>
		<table class=\"table is-bordered is-bordered is-striped is-narrow is-hoverable\" style=\"margin: auto\">
			<thead style=\"background-color: #355b8a;\"><tr><th style=\" color: #ffffff\">ligne</th><th style=\" color: #ffffff\">code HTTP</th><th style=\" color: #ffffff\">URL</th><th style=\" color: #ffffff\">encodage</th></thead>" >> "$fichier_tableau"


while read -r URL;
do
	echo -e "\tURL : $URL";
	# réponse HTTP
	code=$(curl -s -I -L -w "%{http_code}" -o /dev/null $URL)
	
	# récupération de l'encodage
	charset=$(curl -s -I -L -w "%{content_type}" $URL | ggrep -P -o "charset=\S+" | cut -d"=" -f2 | tail -n 1)

	 # Déterminer le résultat en fonction du code de réponse HTTP
	if [ "$code" -eq 200 ]; then
		result="OK"
	else
		result="Not OK"
	fi

	if [[ -z $charset ]]
	then
		echo -e "\tencodage non détecté.";
		charset="UTF-8";
	else
		echo -e "\tencodage : $charset";
	fi

	# pour transformer les 'utf-8' en 'UTF-8' :
	charset=$(echo $charset | tr "[a-z]" "[A-Z]")

	
	echo "			<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td></tr>" >> "$fichier_tableau"

	((lineno++));
done < "$fichier_urls"

echo "		</table>
	</body>
</html>" >> "$fichier_tableau"