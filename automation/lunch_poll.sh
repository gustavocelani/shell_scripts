#!/bin/bash

###############################################################################
#
#       Filename:  lunch_poll.sh
#
#    Description:  Microsoft Teams Poll Builder for Polly.
#
#        Version:  1.0
#        Created:  28/01/2020 10:03:52 PM
#       Revision:  1
#
#         Author:  Gustavo P de O Celani
#
################################################################################

# Sleep Time
SLEEP_TIME=3

# Poll Title
TITLE="Almocinho [$(date +%A) - $(date +%D)]"

# Poll Options
declare -a OPTIONS=(
	"Ganash"             #01
	"Caza Carneiro"      #02
	"Dona Maria"         #03
	"Madalena"           #04
	"Villani"            #05
	"Fruttaria"          #06
	"Saladinha"          #07
	"Baru"               #08
	"Hotel Confort"      #09
	"Padaria Romana"     #10
	"Shopping"           #11
	"Carrefour"          #12
	"Padaria Primavera"  #13
	"Nao vou hoje"       #14
)

# Options Length
OPTIONS_LEN=${#OPTIONS[@]}

#
# Type title and skip to first list position
#
type_title()
{
	echo "Adding title \"${TITLE}\""
	xdotool type "${TITLE}"
	xdotool key Tab
	echo ""
}

#
# Type Option and skip to next list position
#
type_option()
{
	for WORD in "$@"
	do
		FORMATTED_OPTION="${FORMATTED_OPTION}${WORD} "
	done

	echo "Adding option \"${FORMATTED_OPTION}\""
	xdotool type "${FORMATTED_OPTION}"

	if [[ "${FORMATTED_OPTION}" != "${OPTIONS[${OPTIONS_LEN}-1]} " ]]
	then
		xdotool key Tab
		xdotool key Tab
	fi

	FORMATTED_OPTION=""
}

#
# Check the multiple votes checkbox
# The cursor must be on last choise position
#
enable_multiple_votes_after_last_choice_position()
{
	echo "Enabling Multiple Choices"
	echo ""

	xdotool key Tab
	xdotool key Tab
	xdotool key Tab
	xdotool key space
}

#
# Disble comments checkbox
# The cursor must be on multiple votes checkbox
#
disable_comments_after_multiple_votes_checkbox()
{
	echo "Disabling Comments"
	echo ""

	xdotool key Tab
	xdotool key Tab
	xdotool key space
}

#
# Poll Preview
# The cursor must be on comments checkbox
#
poll_preview_after_comments_checkbox()
{
	echo "Poll Preview"
	echo ""

	xdotool key Tab
	xdotool key Tab
	xdotool key Tab
	xdotool key space
}

#
# Main Loop
#

echo ""
echo "#############################################################"
echo "#           Microsoft Teams Poll Options Builder            #"
echo "#############################################################"
echo "#"
echo "# 1) Open the Polly Builder on Microsoft Teams chat"
echo "#"
echo "# 2) Configure audience"
echo "#"
echo "# 3) Configure send schedule"
echo "#"
echo "# 4) Configure Close date"
echo "#"
echo "# 5) Reserve exactly ${OPTIONS_LEN} positions on poll"
echo "#"
echo "# 6) Press Enter to start count"
echo "#        After that, you will have ${SLEEP_TIME} seconds"
echo "#        to execute the step 7"
echo "#"
echo "# 7) Position the mouse pointer on poll title field"
echo "#"
echo "# 8) Wait the form be filled"
echo "#"
echo "#############################################################"
echo ""

read -p "Press Enter to continue..."

# Sleep to position pointer on title poll field
echo ""
for COUNT in {3..0}; do printf "\rWaiting to start... [ %02d ]" "${COUNT}"; sleep 1; done; echo ""

# Type Title
type_title

# Type on option per list position
for OPTION in "${OPTIONS[@]}"
do
	type_option ${OPTION}
done

# Enabling Multiple Votes
enable_multiple_votes_after_last_choice_position

# Disabling Comments
disable_comments_after_multiple_votes_checkbox

# Poll Preview
poll_preview_after_comments_checkbox

