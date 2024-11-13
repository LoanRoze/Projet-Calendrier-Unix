#!/bin/bash

json_calendar="program_778.json"

if [ ! -f "$json_calendar" ]; then
    echo "Le fichier $json_calendar n'existe pas."
    exit 1
fi

obtenir_dates_semaine() {
    local annee="$1"
    local numero_semaine="$2"

    # Vérifier si une année et un numéro de semaine ont été fournis
    if [ -z "$annee" ] || [ -z "$numero_semaine" ]; then
        echo "Veuillez fournir une année et un numéro de semaine (ex. 2024 42)."
        return 1
    fi

    # Calculer la date de début de la semaine (lundi)
    local date_debut
    date_debut=$(date -d "$annee-01-01 +$(((numero_semaine - 1) * 7)) days" +%Y-%m-%d)

    # Mettre toutes les dates de la semaine dans la liste
    for i in {0..6}; do
        date_jour=$(date -d "$date_debut + $i days" +%Y-%m-%d)
        echo "$date_jour"
    done
}

affichage_cours_date() {
    local date_recherche="$1"
    if [ -z "$date_recherche" ]; then
        echo "Veuillez fournir une date (ex. AAAA-MM-JJ)."
        return 1
    fi

    echo "Calendrier des événements de la date $date_recherche :"
    jq -r --arg date "$date_recherche" '
        .rows[] | 
        select(.srvTimeCrDateFrom | contains($date)) | 
        "\n- Date: \(.srvTimeCrDateFrom) \n- Heure Début: \(.timeCrTimeFrom/100)h \n- Heure Fin: \(.timeCrTimeTo/100)h \n- Nom du Cours: \(.prgoOfferingDesc) \n- Description du Cours: \(.valDescription)"' "$json_calendar"
}

affichage_cours_semaine() {
    local list_of_days=$(obtenir_dates_semaine "$1" "$2")
    for day in $list_of_days; do
        echo "|-----------------------------------------------------|"
        affichage_cours_date $day
    done
}

affichage_controles_a_venir() {
    local current_date="$1"

    if [ -z "$current_date" ]; then
        echo "Veuillez fournir une date (ex. AAAA-MM-JJ)."
        return 1
    fi

    echo "Liste des controles/evaluations suivant la date du $current_date :"
    jq -r --arg date "$current_date" '
        .rows[] | 
        select(.srvTimeCrDateFrom>=$date and .soffDeliveryMode=="DEVOIRECRIT") | 
        "\n- Date: \(.srvTimeCrDateFrom) \n- Heure Début: \(.timeCrTimeFrom/100)h \n- Heure Fin: \(.timeCrTimeTo/100)h \n- Nom du Cours: \(.prgoOfferingDesc) \n- Description du Cours: \(.valDescription)"' "$json_calendar"
}

calculer_duree_periode() {
  local heure_debut=$1
  local heure_fin=$2

  # Extraire les heures et minutes
  local heure_debut_h=$((heure_debut / 100))
  local heure_debut_m=$((heure_debut % 100))
  local heure_fin_h=$((heure_fin / 100))
  local heure_fin_m=$((heure_fin % 100))

  # Calculer la durée en minutes
  local duree_minutes=$(( (heure_fin_h * 60 + heure_fin_m) - (heure_debut_h * 60 + heure_debut_m) ))

  # Convertir en heures et minutes
  local duree_heures=$(( duree_minutes / 60 ))
  local duree_reste_minutes=$(( duree_minutes % 60 ))

  # Afficher la durée au format heures:minutes
  echo "${duree_heures}h${duree_reste_minutes}m"
}



calculer_duree_periode 1000 4000