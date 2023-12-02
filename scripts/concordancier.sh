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
if [[ $lang != 'fr' && $lang != "en" && $lang != "zh" ]]
then
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
    <html lang=\"$lang\">
        <!-- HTML head section -->
        <head>
            <meta charset=\"UTF-8\" />
            <!-- Link to Bulma CSS framework -->
            <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">
            <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
            <title>Concordance</title>
        </head>
        <!-- HTML body section -->
        <body class=\"has-navbar-fixed-top\">
            <!-- Navigation bar -->
            <nav class=\"navbar is-light is-fixed-top\">...</nav>
            <!-- Title -->
            <h1 class=\"title\" style=\"text-align: center; \">Concordance</h1>
            <!-- Concordance table -->
            <table class=\"table is-bordered is-striped is-narrow is-hoverable is-fullwidth\">
                <thead style=\"background-color: #355b8a;\">
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
    LANG=zh_CN.UTF-8 $GREP_CMD -Po "(?:\p{Han}{1,}\s){1,5}$motif(?:\s\p{Han}{1,}){0,5}" $fichier_text | LANG=C $SED_CMD -E -r "s/(.*)($motif)(.*)/<tr><td class=\"has-text-right\">\1<\/td><td class=\"has-text-danger\">\2<\/td><td class=\"has-text-left\">\3<\/td><\/tr>/"
# Search pattern logic for other languages
else
    grep -E -o -i "(\w+\W+){0,5}$motif(\W+\w+){0,5}" $fichier_text | sed -E -r "s/(.*)$motif(.*)/<tr><td class=\"has-text-right\">\1<\/td><td class=\"has-text-danger\">\2<\/td><td class=\"has-text-left\">\3<\/td><\/tr>/"
fi

# End of HTML output
echo "
                </tbody>
            </table>
        </body>
</html>
"
