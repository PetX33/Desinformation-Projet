#!/usr/bin/env bash

# Execute this script from the root of the project using: sh ./scripts/make_itrameur_corpus.sh <folder> <language>
# To concatenate files juste use the cat command in terminal : cat dumps-text-*.txt > dumps.txt or cat contextes-*.txt > contextes.txt
# Check if exactly two arguments are provided
if [ $# -ne 2 ]
then
  echo "Deux arguments attendus : <dossier> <langue>"
  exit
fi

# Assigning first argument to 'folder' (expected to be 'dumps-text' or 'contextes')
folder=$1
# Assigning second argument to 'basename' (language code like 'en', 'fr', 'zh')
basename=$2

# Create or overwrite a file in the 'itrameur' folder with the structured data
echo "<lang=\"$basename\">" > "./itrameur/$folder-$basename.txt"

# Loop through each text file in the specified folder and language
for filepath in $(ls $folder/$basename/$basename-*.txt)
do
	# Extract the base name of the file (page name) without the '.txt' extension
	pagename=$(basename -s .txt $filepath)

	# Write the page start tag to the output file
	echo "<page=\"$pagename\">" >> "./itrameur/$folder-$basename.txt"
	# Start of the text tag
	echo "<text>" >> "./itrameur/$folder-$basename.txt"

	# Read the contents of the current file
	content=$(cat $filepath)

	# Replace special characters to prevent XML/HTML formatting issues
	content=$(echo "$content" | sed -E "s/&/&amp;/g")
	content=$(echo "$content" | sed -E "s/</&lt;/g")
	content=$(echo "$content" | sed -E "s/>/&gt;/g")

	# Replace various forms of "Disinformation" with "disinformation", and "Propaganda" with "propaganda"
	if [ "$basename" = "en" ]
	then
		content=$(echo "$content" | sed -E "s/\"?[Dd]isinformation\"?/disinformation/gI")
		content=$(echo "$content" | sed -E "s/\"?[Pp]ropaganda\"?/propaganda/gI")

	# Replace various forms of "Désinformation" with "désinformation", and "Propagande" with "propagande"
	elif [ "$basename" = "fr" ]
	then
		content=$(echo "$content" | sed -E "s/\"?[Dd]ésinformation\"?/désinformation/gI")
		content=$(echo "$content" | sed -E "s/\"?[Pp]ropagande\"?/propagande/gI")
	fi

	# Write the processed content to the output file
	echo "$content" >> "./itrameur/$folder-$basename.txt"

	# Close the text and page tags
	echo "</text>" >> "./itrameur/$folder-$basename.txt"
	echo "</page> §" >> "./itrameur/$folder-$basename.txt"
done

# Write the closing language tag to the output file
echo "</lang>" >> "./itrameur/$folder-$basename.txt"
