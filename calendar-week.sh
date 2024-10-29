#!/bin/bash


json_calendar="program_778.json"


if [ ! -f "$json_calendar" ]; then
	echo "Le fichier $json_calendar n'existe pas."
	exit 1
fi


affichage_cours_date() {
    local date_recherche="$1"
    echo "$date_recherche"
    if [ -z "$date_recherche" ]; then
        echo "Veuillez fournir une date (ex. AAAA-MM-JJ)."
        return 1
    fi

    echo "Calendrier des événements de la date $date_recherche :"
    jq -r --arg date "$date_recherche" '
        .rows[] | 
        select(.srvTimeCrDateFrom | contains($date)) | 
        "\n- Date: \(.srvTimeCrDateFrom) \n- Nom du Cours: \(.prgoOfferingDesc) \n- Description du Cours: \(.valDescription)"' "$json_calendar" 
}


affichage_cours_date "$1"