#!/bin/bash

fichier_json="program_778.json"

if [ ! -f "$fichier_json" ]; then
    echo "Le fichier $fichier_json n'existe pas."
    exit 1
fi

#Prend en parametre 1 : année
#Prend en parametre 2 : numéro de semaine
#Renvoie tous les jours présents dans la semaine
obtenir_dates_semaine() {
    local annee="$1"
    local numero_semaine="$2"

    # Guard Clause
    if [ -z "$annee" ] || [ -z "$numero_semaine" ]; then
        echo "Veuillez fournir une année et un numéro de semaine (ex. 2024 42)."
        return 1
    fi

    # Calculer la date de début de la semaine (lundi)
    local date_debut
    date_debut=$(date -d "$annee-01-01 +$(((numero_semaine - 1) * 7)) days" +%Y-%m-%d)

    # Afficher toutes les dates de la semaine
    for i in {0..6}; do
        date_jour=$(date -d "$date_debut + $i days" +%Y-%m-%d)
        echo "$date_jour"
    done
}

#Prend en parametre 1 : date 
#Renvoie les infos sur les cours de la date mise en paramètre
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
        "\n- Date: \(.srvTimeCrDateFrom) \n- Heure Début: \(.timeCrTimeFrom/100)h \n- Heure Fin: \(.timeCrTimeTo/100)h \n- Nom du Cours: \(.prgoOfferingDesc) \n- Description du Cours: \(.valDescription)"' "$fichier_json"
}

#Prend en parametre 1 : année
#Prend en parametre 2 : numéro de semaine
#Renvoie un affichage des cours de la semaine pour chaque jour
#FONCTION UTILE POUR CONTROLE (ligne a enlever juste pour que tu te reperes)
affichage_cours_semaine() {
    local liste_jours=$(obtenir_dates_semaine "$1" "$2")
    for jour in $liste_jours; do
        echo "|-----------------------------------------------------|"
        affichage_cours_date $jour
    done
}

#Prend en parametre une date (par default la date actuelle)
#Renvoie les cours qui sont des controles apres la date passée en parametre
#FONCTION UTILE POUR CONTROLE (ligne a enlever juste pour que tu te reperes)
affichage_controles_a_venir() {
    if [ -z "$1" ]; then
        local date=$(date +%F)
    else
        local date="$1"
    fi

    echo "Liste des controles/evaluations suivant la date du $date :"
    jq -r --arg date "$date" '
        .rows[] | 
        select(.srvTimeCrDateFrom>=$date and .soffDeliveryMode=="DEVOIRECRIT") | 
        "\n- Date: \(.srvTimeCrDateFrom) \n- Heure Début: \(.timeCrTimeFrom/100)h \n- Heure Fin: \(.timeCrTimeTo/100)h \n- Nom du Cours: \(.prgoOfferingDesc) \n- Description du Cours: \(.valDescription)"' "$fichier_json"
}

#Prend en parametre un heure au format HHMM
#Renvoie l'heure passée en parametre au format HHhMMm
conversion_en_heures() {
    local heure=$(( $1 / 100 ))
    local minutes=$(( $1 % 100 ))

    echo "${heure}h${minutes}m"
}

#Prend en parametre 1 : l'heure de debut au format HHMM
#Prend en parametre 2 : l'heure de fin au format HHMM
#Renvoie la durée au format HHhMMm 
calculer_duree_periode() {
    local heure_debut=$1
    local heure_fin=$2

    # Extraire les heures et minutes
    if (( "$heure_debut" > "$heure_fin" )); then
        echo "Veuillez fournir une heure de début et une heure de fin valide"
        return 1
    fi

    local duree_minutes=$(( heure_fin - heure_debut ))

    echo $(conversion_en_heures $duree_minutes)
}

#Prend en parametre une date
#Renvoie le nombre d'heures de cours prévus pour cette date
duree_cours_journee() {
    local date=$1

    local heures_debut=$(
        jq -c --arg date "$date" '
        .rows[] |
        select(.srvTimeCrDateFrom | contains($date)) | 
        "\(.timeCrTimeFrom)"' "$fichier_json"
    )
    local heures_fin=$(
        jq -c --arg date "$date" '
        .rows[] |
        select(.srvTimeCrDateFrom | contains($date)) | 
        "\(.timeCrTimeTo)"' "$fichier_json"
    )

    declare -a tableau_heures_debut
    declare -a tableau_heures_fin

    while IFS= read -r ligne; do
        tableau_heures_debut+=("$ligne")
    done <<< "$heures_debut"

    while IFS= read -r ligne; do
        tableau_heures_fin+=("$ligne")
    done <<< "$heures_fin"

    local nombre_de_cours=${#tableau_heures_debut[*]}
    local total_heure_journee=0

    for ((i=0; i<=nombre_de_cours-1; i++)); do
        local heure_debut=${tableau_heures_debut[$i]//\"/}
        local heure_fin=${tableau_heures_fin[$i]//\"/}
        local total_heure_cours=$(( heure_fin - heure_debut ))
        total_heure_journee=$((total_heure_journee + total_heure_cours))
    done

    echo $total_heure_journee
    
}

#Prend en parametre 1 : l'année / en paramètre 2 : la semaine. 
#Renvoie le nombre d'heure de cours de cette semaine
#FONCTION UTILE POUR CONTROLE (ligne a enlever juste pour que tu te reperes)
extraction_heure_cours_semaine() {
    local liste_jours=$(obtenir_dates_semaine "$1" "$2")

    local total_hours=0
    for jour in $liste_jours; do
        duree_cours_jour=$(duree_cours_journee $jour)
        total_hours=$((total_hours + duree_cours_jour))
    done
    conversion_en_heures $total_hours
}


