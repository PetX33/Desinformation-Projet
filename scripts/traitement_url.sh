#!/usr/bin/env bash

if [ $# -ne 3 ];
then
	echo "Trois arguments attendu exactement"
	exit
fi

if [ -f $2 ]
then
	echo "On a bien un fichier"
else
	echo "On attend un fichier qui existe"
	exit
fi

# Vérifier si ggrep est disponible, sinon utiliser grep
if command -v ggrep > /dev/null; then
    GREP_CMD="ggrep"
else
    GREP_CMD="grep"
fi

lang=$1 # fr, en, zh
fichier_urls=$2
fichier_tableau=$3

basename=$(basename -s .txt $fichier_urls)
lineno=1

if [[ $lang == 'zh' ]]
then
	mot="虚假信息"
	export LANG=C
elif [[ $lang == 'en' ]]
then
 	mot="([Dd]isinformation)"
elif [[ $lang == 'fr' ]]
then
	mot="([Dd]ésinformation)"
fi


echo "<html>
	<head>
		<meta charset=\"UTF-8\"/>
		<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">
		<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
		<title>Tableau des URLS</title>
	</head>
	<body class="has-navbar-fixed-top">
		<nav class=\"navbar is-light is-fixed-top\"><div class=\"navbar-menu\"><div class=\"navbar-start\"><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#introduction\">Introduction</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#analyse\">Analyse</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../scripts.html\">Scripts</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\">Tableaux</a><div class=\"navbar-dropdown\"><a class=\"navbar-item\" href=\"tableau_fr.html\">Français</a><a class=\"navbar-item\" href=\"tableau_en.html\">Anglais</a><a class=\"navbar-item\" href=\"tableau_zh.html\">Chinois</a></div></div></div><div class=\"navbar-end\"><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#aPropos\">À propos</a></div><div class=\"navbar-item\"><a href=\"https://github.com/PetX33/Desinformation-Projet\"><img src=\"../images/github_logo.png\" alt=\"Github\"></a></div></div></div></nav>" > "$fichier_tableau"

echo "		<h1 class=\"title\" style=\"text-align: center; \">Tableau des URLs $basename</h1>
		<table class=\"table is-bordered is-bordered is-striped is-narrow is-hoverable\" style=\"margin: auto\">
			<thead style=\"background-color: #355b8a;\"><tr><th style=\" color: #ffffff\">ligne</th><th style=\" color: #ffffff\">code HTTP</th><th style=\" color: #ffffff\">URL</th><th style=\" color: #ffffff\">encodage</th><th style=\" color: #ffffff\">HTML</th><th style=\" color: #ffffff\">dump</th><th style=\" color: #ffffff\">compte</th><th style=\" color: #ffffff\">contextes</th><th style=\" color: #ffffff\">concordances</th></thead>" >> "$fichier_tableau"

if [[ $lang == "zh" ]]
then
	lang_base=$LANG
	export LANG=C

	while read -r URL;
	do
		echo -e "\tURL : $URL";
		# réponse HTTP
		code=$(curl -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" -ILs $URL | grep -e "^HTTP/" | grep -Eo "[0-9]{3}" | tail -n 1)
		
		# récupération de l'encodage
		charset=$(curl -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" -Ls $URL -D - -o "../aspirations/fich-$lineno.html" | grep -Eo "charset=(\w|-)+" | tail -n 1 | cut -d= -f2)

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

		if [[ $URL == "http://world.people.com.cn"* ]]
		then
			charset="gb2312"
		fi
		
		# pour transformer les 'utf-8' en 'UTF-8' :
		charset=$(echo $charset | tr "[a-z]" "[A-Z]")

		if [[ $code -eq 200 ]]
		then
			aspiration=$(curl $URL)

			echo $aspiration

			if [[ $charset == 'UTF-8' ]]
			then
				dump=$(curl $URL | iconv -f UTF-8 -t UTF-8//IGNORE | lynx -stdin -dump -nolist -assume_charset=utf-8 -display_charset=utf-8 | sed -E "/(BUTTON)/d" | sed -E "/   [*+#_©×•]/d" | sed -E "/   \[/d")
			else
				# charset=$(curl $URL | urchardet)
				dump=$(curl $URL | iconv -f $charset -t UTF-8//IGNORE | lynx -stdin -dump -nolist -assume_charset=utf-8 -display_charset=utf-8 | sed -E "/(BUTTON)/d" | sed -E "/   [*+#_©×•]/d" | sed -E "/   \[/d")
			fi
		else
			echo -e "\tcode différent de 200 utilisation d'un dump vide"
			dump=""
			charset=""
		fi

		echo "$aspiration" > "../aspirations/$basename-$lineno.html"

		echo "$dump" > "../dumps-text/$basename-$lineno.txt"

		compte=$(grep -E -i -o $mot "../dumps-text/$basename-$lineno.txt" | wc -l)

		grep -E -i -A 2 -B 2 $mot "../dumps-text/$basename-$lineno.txt" > "../contextes/$basename-$lineno.txt" 

		sh ./concordancier.sh $lang "../dumps-text/$basename-$lineno.txt" $mot > "../concordances/$basename-$lineno.html"
		
		echo "			<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td><td><a href="../aspirations/$basename-$lineno.html">html</a></td><td><a href="../dumps-text/$basename-$lineno.txt">text</a></td><td>$compte</td><td><a href="../contextes/$basename-$lineno.txt">contexte</a></td><td><a href="../concordances/$basename-$lineno.html">concordances</a></td></tr>" >> "$fichier_tableau"

		((lineno++));
	done < "$fichier_urls"

echo "		</table>
	</body>
</html>" >> "$fichier_tableau"

echo "motif : $mot"


else
	while read -r URL;
	do
		echo -e "\tURL : $URL";
		# réponse HTTP
		code=$(curl -s -I -L -w "%{http_code}" -o /dev/null $URL)
		
		# récupération de l'encodage
		charset=$(curl -s -I -L -w "%{content_type}" $URL | $GREP_CMD -P -o "charset=\S+" | cut -d"=" -f2 | tail -n 1)

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

		if [[ $code -eq 200 ]]
		then
			aspiration=$(curl $URL)

			echo $aspiration

			if [[ $charset == 'UTF-8' ]]
			then
				dump=$(curl $URL | iconv -f UTF-8 -t UTF-8//IGNORE | lynx -stdin -dump -nolist -assume_charset=utf-8 -display_charset=utf-8 | sed -E "/(BUTTON)/d" | sed -E "/   [*+#_©×•]/d" | sed -E "/   \[/d")
			else
				# charset=$(curl $URL | urchardet)
				dump=$(curl $URL | iconv -f $charset -t UTF-8//IGNORE | lynx -stdin -dump -nolist -assume_charset=utf-8 -display_charset=utf-8 | sed -E "/(BUTTON)/d" | sed -E "/   [*+#_©×•]/d" | sed -E "/   \[/d")
			fi
		else
			echo -e "\tcode différent de 200 utilisation d'un dump vide"
			dump=""
			charset=""
		fi

		echo "$aspiration" > "../aspirations/$basename-$lineno.html"

		echo "$dump" > "../dumps-text/$basename-$lineno.txt"

		compte=$(grep -E -i -o $mot "../dumps-text/$basename-$lineno.txt" | wc -l)

		grep -E -i -A 2 -B 2 $mot "../dumps-text/$basename-$lineno.txt" > "../contextes/$basename-$lineno.txt" 

		sh ./concordancier.sh $lang "../dumps-text/$basename-$lineno.txt" $mot > "../concordances/$basename-$lineno.html"
		
		echo "			<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td><td><a href="../aspirations/$basename-$lineno.html">html</a></td><td><a href="../dumps-text/$basename-$lineno.txt">text</a></td><td>$compte</td><td><a href="../contextes/$basename-$lineno.txt">contexte</a></td><td><a href="../concordances/$basename-$lineno.html">concordances</a></td></tr>" >> "$fichier_tableau"

		((lineno++));
	done < "$fichier_urls"

	echo "		</table>
		</body>
	</html>" >> "$fichier_tableau"

	echo "motif : $mot"
fi