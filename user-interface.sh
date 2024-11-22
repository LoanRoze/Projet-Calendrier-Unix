source calendar-script.sh


echo "Bienvenue! Êtes-vous un(e) professeur(e) ou un(e) étudiant(e)?"
echo "1) Professeur"
echo "2) Étudiant(e)"
read -p "Veuillez entrer 1 ou 2: " choice
echo "-------------------------------------------------------------------"




case $choice in
    1)
        echo "Vous avez choisi Professeur."
        ;;
    2)
        echo "Vous avez choisi Étudiant(e)."
        ;;
    *)
        echo "Choix invalide. Veuillez entrer 1 pour Professeur ou 2 pour Étudiant(e)."
        exit 1
        ;;
esac




echo "-------------------------------------------------------------------"


if [ "$choice" == 2 ]; then
    echo "Voici les fonctionnalités proposées aux etudiants:"
    echo "1) Visualiser les cours d'une semaine"
    echo "2) Prochaines dates et heures des exams"
    echo "3) Compter les nombres d'heures de cours par semaine"
    read -p "Veuillez entrer 1,2 ou 3: " choice
    echo "-------------------------------------------------------------------"
    case $choice in
        1)
            read -p "Veuillez entrer l'annnée de la semaine: " annee
            if ! [[ "$annee" =~ ^[0-9]{4}$ ]]; then
                echo "Erreur : l'année doit être un nombre à 4 chiffres."
                exit 1
            fi
            read -p "Veuillez entrer le numéro de la semaine: " semaine
            if ! [[ "$semaine" =~ ^[0-9]{1,2}$ ]] || [ "$semaine" -lt 1 ] || [ "$semaine" -gt 52 ]; then
                echo "Erreur : le numéro de la semaine doit être entre 1 et 52."
                exit 1
            fi
            affichage_cours_semaine $calendrier_eleve $annee $semaine
            ;;
        2)
            affichage_controles_a_venir $calendrier_eleve
            ;;
        3)
            read -p "Veuillez entrer l'annnée de la semaine: " annee
            if ! [[ "$annee" =~ ^[0-9]{4}$ ]]; then
                echo "Erreur : l'année doit être un nombre à 4 chiffres."
                exit 1
            fi
            read -p "Veuillez entrer le numéro de la semaine: " semaine
            if ! [[ "$semaine" =~ ^[0-9]{1,2}$ ]] || [ "$semaine" -lt 1 ] || [ "$semaine" -gt 52 ]; then
                echo "Erreur : le numéro de la semaine doit être entre 1 et 52."
                exit 1
            fi
            extraction_heure_cours_semaine $calendrier_eleve $annee $semaine
            ;;
        *)
            echo "Choix invalide."
            exit 1
            ;;
    esac
else
    echo "Voici les fonctionnalités proposées aux professeurs:"
    echo "1) Visualiser les cours d'une semaine"
    echo "2) Prochaines dates et heures d'un module"
    echo "3) Compter les nombres d'heures de cours par semaine"
    echo "4) Trouver un créneau libre en commun avec celui d'une classe"
    read -p "Veuillez entrer 1,2,3 ou 4: " choice
    echo "-------------------------------------------------------------------"
    case $choice in
        1)
            read -p "Veuillez entrer l'annnée de la semaine: " annee
            if ! [[ "$annee" =~ ^[0-9]{4}$ ]]; then
                echo "Erreur : l'année doit être un nombre à 4 chiffres."
                exit 1
            fi
            read -p "Veuillez entrer le numéro de la semaine: " semaine
            if ! [[ "$semaine" =~ ^[0-9]{1,2}$ ]] || [ "$semaine" -lt 1 ] || [ "$semaine" -gt 52 ]; then
                echo "Erreur : le numéro de la semaine doit être entre 1 et 52."
                exit 1
            fi
            affichage_cours_semaine $calendrier_prof $annee $semaine
            ;;
        2)
            read -p "Veuillez entrer le nom du module: " module
            affichage_cours_module $calendrier_prof $module
            ;;
        3)
            read -p "Veuillez entrer l'annnée de la semaine: " annee
            if ! [[ "$annee" =~ ^[0-9]{4}$ ]]; then
                echo "Erreur : l'année doit être un nombre à 4 chiffres."
                exit 1
            fi
            read -p "Veuillez entrer le numéro de la semaine: " semaine
            if ! [[ "$semaine" =~ ^[0-9]{1,2}$ ]] || [ "$semaine" -lt 1 ] || [ "$semaine" -gt 52 ]; then
                echo "Erreur : le numéro de la semaine doit être entre 1 et 52."
                exit 1
            fi
            extraction_heure_cours_semaine $calendrier_prof $annee $semaine
            ;;
        4)
            read -p "Veuillez entrer la date pour le creneau commun (format YYYY-MM-DD): " date
            if ! [[ "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                echo "Erreur : la date doit être au format YYYY-MM-DD."
                exit 1
            fi
            trouver_creneau_communs_jour $calendrier_eleve $calendrier_prof $date
            ;;
        *)
            echo "Choix invalide."
            exit 1
            ;;
    esac
fi