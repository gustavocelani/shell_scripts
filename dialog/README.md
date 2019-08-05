# Shell Script Dialog

## Dialog Types

**Dialog**       | **Option**    | **Description**
|----------------|---------------|----------------|
Build List       | --buildlist   | Displays two lists, side-by-side. The list on the left contains unselected items, the list on the right selected items. The user can move items from one list to the other.
Calendar         | --calendar    | Displays a calendar and allow the user to select a date.
Checklist        | --checklist   | Presents a list of choices and allow the user to select one or more items.
Directory Select | --dselect     | Displays a directory selection dialog.
Edit Box         | --editbox     | Displays a rudimentary text file editor.
Form             | --form        | Allows the user to enter text into multiple fields.
File Select      | --fselect     | A file selection dialog.
Gauge            | --gauge       | Displays a progress indicator showing the percentage of completion.
Info Box         | --infobox     | Displays a message (with an optional timed pause) and terminates.
Input Box        | --inputbox    | Prompts the user to enter/edit a text field.
Menu Box         | --menubox     | Displays a list of choices.
Message Box      | --msgbox      | Displays a text message and waits for the user to respond.
Password Box     | --passwordbox | Similar to an input box, but hides the user's entry.
Pause            | --pause       | Displays a text message and a countdown timer. The dialog terminates when the timer runs out or when the user presses either the OK or Cancel button.
Program Box      | --programbox  | Displays the output of a piped command. When the command completes, the dialog waits for the user to press an OK button.
Progress Box     | --progressbox | Similar to the program box except the dialog terminates when the piped command completes, rather than waiting for the user to press OK.
Radio List       | --radiolist   | Displays a list of choices and allows the user to select a single item. Any previously selected item becomes unselected.
Range Box        | --rangebox    | Allows the user to select a numerical value from within a specified range using a keyboard-based slider.
Tail Box         | --tailbox     | Displays a text file with real-time updates. Works like the command tail -f.
Text Box         | --textbox     | A simple text file viewer. Supports many of the same keyboard commands as less.
Time Box         | --timebox     | A dialog for entering a time of day.
Tree View        | --treeview    | Displays a list of items in a tree-shaped hierarchy.
Yes/No Box       | --yesno       | Displays a text message and gives the user a chance to respond with either "Yes" or "No.".
