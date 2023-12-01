# lancer depuis la racine du projet avec: sh ./scripts/concatenation_dumps.sh dossier lang

if [[ $# -ne 2 ]]
then
  echo "Deux arguments attendus : <dossier> <langue>"
  exit
fi

folder=$1     # dumps-text OU contextes
basename=$2   # en, fr, zh

echo "<lang=\"$basename\">" > "./itrameur/$folder-$basename.txt"

for filepath in $(ls $folder/$basename/$basename-*.txt)
do
	# filepath == dumps-texts/fr-1.txt
	# 	==> pagename = fr-1
	pagename=$(basename -s .txt $filepath)

	echo "<page=\"$pagename\">" >> "./itrameur/$folder-$basename.txt"
	echo "<text>" >> "./itrameur/$folder-$basename.txt"

	# on récupère les dumps/contextes
	# et on écrit à l'intérieur de la balise text
	content=$(cat $filepath)
	# ordre important : & en premier
	# sinon : < => &lt; => &amp;lt;
	content=$(echo "$content" | gsed -E "s/&/&amp;/g")
	content=$(echo "$content" | gsed -E "s/</&lt;/g")
	content=$(echo "$content" | gsed -E "s/>/&gt;/g")

	echo "$content" >> "./itrameur/$folder-$basename.txt"

	echo "</text>" >> "./itrameur/$folder-$basename.txt"
	echo "</page> §" >> "./itrameur/$folder-$basename.txt"
done

echo "</lang>" >> "./itrameur/$folder-$basename.txt"