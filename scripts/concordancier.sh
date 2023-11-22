#!/usr/bin/env bash

echo 	"""
            <html>
             <html lang=\"$lang\">
			 <head>
							<meta charset=\"utf-8\" />
							<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">
							<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
							<title>Concordance</title>
			</head>
			<body class=\"has-navbar-fixed-top\">
		        <nav class=\"navbar is-light is-fixed-top\"><div class=\"navbar-menu\"><div class=\"navbar-start\"><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#introduction\">Introduction</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#analyse\">Analyse</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../scripts.html\">Scripts</a></div><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\">Tableaux</a><div class=\"navbar-dropdown\"><a class=\"navbar-item\" href=\"tableau_fr.html\">Français</a><a class=\"navbar-item\" href=\"tableau_en.html\">Anglais</a><a class=\"navbar-item\" href=\"tableau_zh.html\">Chinois</a></div></div></div><div class=\"navbar-end\"><div class=\"navbar-item has-dropdown is-hoverable\"><a class=\"navbar-item\" href=\"../index.html#aPropos\">À propos</a></div><div class=\"navbar-item\"><a href=\"https://github.com/PetX33/Desinformation-Projet\"><img src=\"../images/github_logo.png\" alt=\"Github\"></a></div></div></div></nav>
							<h1 class=\"title\">Concordance</h1>
							<table class=\"table is-bordered is-striped is-narrow is-hoverable is-fullwidth\">
									<thead>
									<tr>
									<th class=\"has-text-right\">Contexte gauche</th>
									<th>Cible</th>
									<th class=\"has-text-left\">Contexte droit</th>
									</tr>
									</thead>
									"""

