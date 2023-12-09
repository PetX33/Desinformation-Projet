#!/usr/bin/env bash

# Call from the root folder with: sh ./scripts/traitement_url.sh <language> ./urls/<file_urls> ./tableaux/<file_table>


# Check if exactly three arguments are provided
if [ $# -ne 3 ];
then
	echo "Trois arguments attendu exactement"
	exit
fi

# Check if the second argument is a file that exists
if [ -f $2 ]
then
	echo "On a bien un fichier"
else
	echo "On attend un fichier qui existe"
	exit
fi

# Check if ggrep is available, otherwise use grep
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

# Assigning command line arguments to variables
lang=$1 # fr, en, zh
fichier_urls=$2 # URL file
fichier_tableau=$3 ## Table file

# Extracting the base name from fichier_urls
basename=$(basename -s .txt $fichier_urls)
lineno=1

# Setting up the keyword(s) based on the provided language
if [ "$lang" = 'zh' ]
then
	mot="虚假信息|政治宣传"
	export LANG=C
elif [ "$lang" = 'en' ]
then
 	mot="([Dd]isinformation|[Pp]ropaganda)"
elif [ "$lang" = 'fr' ]
then
	mot="([Dd]ésinformation|[Pp]ropagande)"
fi

# Starting HTML output for URL table
echo "<html>
	<head>
		<meta charset=\"UTF-8\"/>
		<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">
		<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
		<title>Tableau des URLS $basename</title>
		<link rel=\"stylesheet\" href=\"../html_css/style.css\">
		<link rel=\"icon\" type=\"image/png\" href=\"../images/logo.png\">
		<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"></script>
		<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.10.2/dist/umd/popper.min.js"></script>
		<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
	</head>
	<body class=\"has-navbar-fixed-top\">
	<nav class=\"navbar is-light\" role=\"navigation\" aria-label=\"main navigation\">
    	<div class=\"collapse navbar-collapse\" id=\"navbarResponsive\"><div class=\"logo\"><a href=\"index.html\"><img src=\"../images/logo.png\" width=\"auto\"></a></div><div class=\"navbar-menu\"><div class=\"navbar-start\"><a class=\"navbar-item\" href=\"../html_css/intro.html\">Introduction</a><a class=\"navbar-item\" href=\"./script.html\">Scripts</a><a class=\"navbar-item\" href=\"./analyse.html\">Analyse</a><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\">Tableaux</a><div class="navbar-dropdown"><a class=\"navbar-item sub\" href=\"../tableaux/tableau_fr.html\">Français</a><a class=\"navbar-item sub\" href=\"../tableaux/tableau_en.html\">Anglais</a><a class=\"navbar-item sub\" href=\"../tableaux/tableau_zh.html\">Chinois</a></div></div></div></div>
		<div class=\"navbar-end\"><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"./equipe.html\">À propos</a></div><div class=\"navbar-item\"><a href=\"https://github.com/PetX33/Desinformation-Projet\"><img src=\"../images/github_blanc.png\" alt=\"Github\"></a></div></div></div></nav>" > "$fichier_tableau" 

echo "		<h1 class=\"title\" style=\"text-align: center; \">Tableau des URLs $basename</h1>
		<table class=\"table is-bordered is-bordered is-striped is-narrow is-hoverable\">
			<thead style=\"background-color: #428cb5;\"><tr><th style=\" color: #ffffff\">ligne</th><th style=\" color: #ffffff\">code HTTP</th><th style=\" color: #ffffff; text-align: center;\">URL</th><th style=\" color: #ffffff\">encodage</th><th style=\" color: #ffffff\">HTML</th><th style=\" color: #ffffff\">dump</th><th style=\" color: #ffffff\">occurrences</th><th style=\" color: #ffffff\">contextes</th><th style=\" color: #ffffff\">concordances</th></thead>" >> "$fichier_tableau"

# If language is Chinese, set the environment language to C for correct character handling
if [ "$lang" = "zh" ]
then

	# Read each URL from fichier_urls and process it
	while read -r URL;
	do
		
		# HTTP response handling
		code=$(curl -ILs $URL | grep -e "^HTTP/" | grep -Eo "[0-9]{3}" | tail -n 1)
		
		# Charset detection and handling
		charset=$(curl -Ls $URL -D -o "./aspirations/$lang/$basename-$lineno.html" | grep -Eo "charset=(\w|-)+" | tail -n 1 | cut -d= -f2)

		# Process the URL's contents and save them in different formats
		if [ "$code" -eq 200 ]; then
			result="OK"
		else
			result="Not OK"
		fi

		# If charset is not detected, set it to UTF-8
		if [ -z $charset ]
		then
			echo -e "\tencodage non détecté.";
			charset="UTF-8";
		else
			echo -e "\tencodage : $charset";
		fi

		if [ "$URL" = "http://world.people.com.cn"* ]
		then
			charset="gb2312|GB2312"
		fi
		
		# Convert lowercase charset to uppercase
		charset=$(echo "$charset" | tr "[a-z]" "[A-Z]")

		if [ $code -eq 200 ]
		then
			if [ "$charset" = 'UTF-8' ]
			then
				dump=$(curl $URL | iconv -f UTF-8 -t UTF-8//IGNORE | lynx -stdin -accept_all_cookies -dump -nolist -assume_charset=utf-8 -display_charset=utf-8)
			else
				dump=$(curl $URL | iconv -f GB2312 -t UTF-8 | lynx -stdin -accept_all_cookies -dump -nolist -assume_charset=utf-8 -display_charset=utf-8)
			fi
		else
			echo -e "\tcode différent de 200 utilisation d'un dump vide"
			dump=""
			charset=""
		fi
		
		# echo "$aspiration" > "./aspirations/$lang/$basename-$lineno.html"
		echo "$dump" > "./dumps-text/$lang/$basename-$lineno.txt"

		# Segment the text dump with the Chinese tokenizer thulac
		dumptok=$(python3 ./scripts/tokenize_chinese.py "./dumps-text/$lang/$basename-$lineno.txt")

		# Remove spaces between 虚假 and 信息 and 政治 and 宣传
		dumptok=$(echo "$dumptok" | sed -e 's/虚假 信息/虚假信息/g' -e 's/政治 宣传/政治宣传/g')

		# Crushed the text dump with the Chinese tokenizer thulac
		echo "$dumptok" > "./dumps-text/$lang/$basename-$lineno.txt"

		# Count occurrences of the keyword in the text dump
		compte=$(grep -E -i -o "$mot" "./dumps-text/$lang/$basename-$lineno.txt" | wc -l)
		echo "$compte"

		# Extract contexts of the keyword in the text dump
		grep -E -i -A 2 -B 2 "$mot" "./dumps-text/$lang/$basename-$lineno.txt" > "./contextes/$lang/$basename-$lineno.txt"

		# Generate concordance HTML file
		concordance=$(sh ./scripts/concordancier.sh $lang "./dumps-text/$lang/$basename-$lineno.txt" $mot)
		echo "$concordance" > "./concordances/$lang/$basename-$lineno.html"
		
		# Add a row to the HTML table for each URL
		echo "			<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td><td><a href=\"../aspirations/$lang/$basename-$lineno.html\">html</a></td><td><a href=\"../dumps-text/$lang/$basename-$lineno.txt\">text</a></td><td>$compte</td><td><a href=\"../contextes/$lang/$basename-$lineno.txt\">contexte</a></td><td><a href=\"../concordances/$lang/$basename-$lineno.html\">concordances</a></td></tr>" >> "$fichier_tableau"

		lineno=$((lineno +1))

	done < "$fichier_urls"

	# Finish the HTML output
	echo "		</table>
				<footer>
					<p>© 2023/2024 - Projet Propagande et Désinformation - MA Zhiya • PENG Yuanlong • QUENNEHEN Perrine</p>
				</footer>
		</body>
	</html>" >> "$fichier_tableau"


elif [ "$lang" = "en" ]
then
	while read -r URL;
	do
		# HTTP response handling
		code=$(curl -s -L -w "%{http_code}" -o ./aspirations/$lang/$basename-$lineno.html $URL)
		
		# Charset detection and handling
		charset=$(curl -s -I -L -w "%{content_type}" -o /dev/null $URL | $GREP_CMD -P -o "charset=\S+" | cut -d"=" -f2 | tail -n 1)

		# Process the URL's contents and save them in different formats
		# 200 OK
		if [ "$code" -eq 200 ]; then
			result="OK"
		else
			result="Not OK"
		fi

		# If charset is not detected, set it to UTF-8
		if [ -z $charset ]
		then
			echo -e "\tencodage non détecté.";
			charset="UTF-8";
		else
			echo -e "\tencodage : $charset";
		fi

		# Convert lowercase charset to uppercase
		charset=$(echo $charset | tr "[a-z]" "[A-Z]")

		
		if [ $code -eq 200 ]
		then
			# If charset is UTF-8, use iconv to convert to UTF-8
			if [ "$charset" = 'UTF-8' ]
			then
				dump=$(curl $URL | iconv -f UTF-8 -t UTF-8//IGNORE | lynx -stdin  -accept_all_cookies -dump -nolist -assume_charset=utf-8 -display_charset=utf-8 | $SED_CMD -E '/(BUTTON)/d' | $SED_CMD -E '/^(\s*)[+([o*_©►]/d' | $SED_CMD -E '/^(\s*)http/d' | $SED_CMD -E "/^(\s*)IFRAME/d" | $SED_CMD -E "/^(\s*)Ad Feedback/d")
			# Otherwise, use the detected charset
			else
				dump=$(curl $URL | iconv -f $charset -t UTF-8//IGNORE | lynx -stdin  -accept_all_cookies -dump -nolist -assume_charset=utf-8 -display_charset=utf-8 | $SED_CMD -E '/(BUTTON)/d' | $SED_CMD -E '/^(\s*)[+([o*_©►]/d' | $SED_CMD -E '/^(\s*)http/d' | $SED_CMD -E "/^(\s*)IFRAME/d" | $SED_CMD -E "/^(\s*)Ad Feedback/d")
			fi
		else
			echo -e "\tcode différent de 200 utilisation d'un dump vide"
			dump=""
			charset=""
		fi


		# Write the dump to a text file
		echo "$dump" > "./dumps-text/$lang/$basename-$lineno.txt"

		# Count occurrences of the keyword in the text dump
		compte=$(grep -E -i -o $mot "./dumps-text/$lang/$basename-$lineno.txt" | wc -l)

		# Extract contexts of the keyword in the text dump
		grep -E -i -C 3 $mot "./dumps-text/$lang/$basename-$lineno.txt" > "./contextes/$lang/$basename-$lineno.txt" 

		# Generate concordance HTML file
		sh ./scripts/concordancier.sh $lang "./dumps-text/$lang/$basename-$lineno.txt" $mot > "./concordances/$lang/$basename-$lineno.html"
		
		# Add a row to the HTML table for each URL
		echo "			<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td><td><a href="../aspirations/$lang/$basename-$lineno.html">html</a></td><td><a href="../dumps-text/$lang/$basename-$lineno.txt">text</a></td><td>$compte</td><td><a href="../contextes/$lang/$basename-$lineno.txt">contexte</a></td><td><a href="../concordances/$lang/$basename-$lineno.html">concordances</a></td></tr>" >> "$fichier_tableau"

    	lineno=$((lineno + 1))
	done < "$fichier_urls"

	# Finish the HTML output
	echo "		</table>
				<footer>
       				<p>© 2023/2024 - Projet Propagande et Désinformation - MA Zhiya • PENG Yuanlong • QUENNEHEN Perrine</p>
    			</footer>
		</body>
	</html>" >> "$fichier_tableau"

else
	while read -r URL;
	do
		# HTTP response handling
		code=$(curl -s -L -w "%{http_code}" -o ./aspirations/$lang/$basename-$lineno.html $URL)
		
		# Charset detection and handling
		charset=$(curl -s -I -L -w "%{content_type}" -o /dev/null $URL | $GREP_CMD -P -o "charset=\S+" | cut -d"=" -f2 | tail -n 1)

		# Process the URL's contents and save them in different formats
		# 200 OK
		if [ "$code" -eq 200 ]; then
			result="OK"
		else
			result="Not OK"
		fi

		# If charset is not detected, set it to UTF-8
		if [ -z $charset ]
		then
			echo -e "\tencodage non détecté.";
			charset="UTF-8";
		else
			echo -e "\tencodage : $charset";
		fi

		# Convert lowercase charset to uppercase
		charset=$(echo $charset | tr "[a-z]" "[A-Z]")

		
		if [ $code -eq 200 ]
		then
			# If charset is UTF-8, use iconv to convert to UTF-8
			if [ "$charset" = 'UTF-8' ]
			then
				dump=$(curl $URL | iconv -f UTF-8 -t UTF-8 | lynx -stdin  -accept_all_cookies -dump -nolist -assume_charset=utf-8 -display_charset=utf-8 | $SED_CMD -E '/(BUTTON)/d' | $SED_CMD -E '/^(\s*)[+([o*_©►]/d' | $SED_CMD -E '/^(\s*)http/d' | $SED_CMD -E "/^(\s*)IFRAME/d" | $SED_CMD -E "/^(\s*)Ad Feedback/d")
			# Otherwise, use the detected charset
			else
				dump=$(curl $URL | iconv -f $charset -t UTF-8 | lynx -stdin  -accept_all_cookies -dump -nolist -assume_charset=utf-8 -display_charset=utf-8 | $SED_CMD -E '/(BUTTON)/d' | $SED_CMD -E '/^(\s*)[+([o*_©►]/d' | $SED_CMD -E '/^(\s*)http/d' | $SED_CMD -E "/^(\s*)IFRAME/d" | $SED_CMD -E "/^(\s*)Ad Feedback/d")
			fi
		else
			echo -e "\tcode différent de 200 utilisation d'un dump vide"
			dump=""
			charset=""
		fi


		# Write the dump to a text file
		echo "$dump" > "./dumps-text/$lang/$basename-$lineno.txt"

		# Count occurrences of the keyword in the text dump
		compte=$(grep -E -i -o $mot "./dumps-text/$lang/$basename-$lineno.txt" | wc -l)

		# Extract contexts of the keyword in the text dump
		grep -E -i -C 3 $mot "./dumps-text/$lang/$basename-$lineno.txt" > "./contextes/$lang/$basename-$lineno.txt" 

		# Generate concordance HTML file
		sh ./scripts/concordancier.sh $lang "./dumps-text/$lang/$basename-$lineno.txt" $mot > "./concordances/$lang/$basename-$lineno.html"
		
		# Add a row to the HTML table for each URL
		echo "			<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td><td><a href="../aspirations/$lang/$basename-$lineno.html">html</a></td><td><a href="../dumps-text/$lang/$basename-$lineno.txt">text</a></td><td>$compte</td><td><a href="../contextes/$lang/$basename-$lineno.txt">contexte</a></td><td><a href="../concordances/$lang/$basename-$lineno.html">concordances</a></td></tr>" >> "$fichier_tableau"

    	lineno=$((lineno + 1))
	done < "$fichier_urls"

	# Finish the HTML output
	echo "		</table>

			<footer>
				<p>© 2023/2024 - Projet Propagande et Désinformation - MA Zhiya • PENG Yuanlong • QUENNEHEN Perrine</p>
			</footer>
		</body>
	</html>" >> "$fichier_tableau"
fi

