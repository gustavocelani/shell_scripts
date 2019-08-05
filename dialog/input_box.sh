#!/bin/bash

# Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

# Dialog Dimens
HEIGHT=16
WIDTH=51

# Duplicate file descriptor 1 on descriptor 3
exec 3>&1

# Generate the dialog box
result=$(dialog \
	--title "INPUT BOX" \
	--clear  \
	--inputbox \
		"Hi, this is an input dialog box. You can use \n
		this to ask questions that require the user \n
		to input a string as the answer. You can \n
		input strings of length longer than the \n
		width of the input box, in that case, the \n
		input field will be automatically scrolled. \n
		You can use BACKSPACE to correct errors. \n\n
		Try entering your name below:" ${HEIGHT} ${WIDTH} 2>&1 1>&3)

# Get dialog's exit status
return_value=$?

# Close file descriptor 3
exec 3>&-

# Clearing Dialog Env
clear

# Act on it
case $return_value in

	$DIALOG_OK)
		printf "\nResult: ${result}\n\n"
	;;
	$DIALOG_CANCEL)
		printf "\nCancel pressed.\n\n"
	;;
	$DIALOG_HELP)
		printf "\nHelp pressed.\n\n"
	;;
	$DIALOG_EXTRA)
		printf "\nExtra button pressed.\n\n"
	;;
	$DIALOG_ITEM_HELP)
		printf "\nItem-help button pressed.\n\n"
	;;
	$DIALOG_ESC)
		if test -s $tmp_file ;
		then
			printf "\nResult: ${result}\n\n"
		else
			printf "\nESC pressed.\n\n"
		fi
	;;
	*)
		printf "\nInvalid return...\n\n"
	;;
esac

