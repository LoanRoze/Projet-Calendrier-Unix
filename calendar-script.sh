#!/bin/bash


json_calender="program_778.json"


if [ ! -f "$json_calender" ]; then
	echo "Le fichier $json_calender n'existe pas."
	exit 1
fi

echo "Calendrier des événements :"
jq -r '.rows[] | "Date: \(.srvTimeCrDateFrom)"' "$json_calender"

