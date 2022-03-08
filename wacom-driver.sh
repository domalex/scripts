#!/bin/bash
# This file was created by Dominik Schmid on 26.10.2021
# Einrichtung Wacom-Tablet

## Verältnis Tablet:Bildschirm korrigieren
xsetwacom set "Wacom Intuos BT M Pen stylus" Area 0 0 21600 12150	# Korrektur Verhältnis Wacom-Area:Bildschirmgrösse (Bereinigt Verzerrungen)

## Druckeinstellungen Stylus
#xsetwacom set "Wacom Intuos BT M Pen stylus" PressureCurve 0 0 100 100	# Druckeinstellungen Default: 0 0 100 100 
xsetwacom set "Wacom Intuos BT M Pen stylus" PressureCurve 0 40 85 100	# Druckeinstellungen Default: 0 0 100 100 - zum Ausprobieren

## Button Funktionszuweisung global ohne Remapping (Sämmtliche Tastaturbefehle sind unter /usr/include/X11/keysymdef.h zu finden)
# Bei vorgenommenem Remapping können die Tasten unter Umständen innerhalb jeder Anwendung zugewiesen werden.
#xsetwacom set "Wacom Intuos BT M Pad pad" Button 1 "key ctrl z"	# Knopf links
#xsetwacom set "Wacom Intuos BT M Pad pad" Button 2 "key crtl y"	# Knopf Mitte links
#xsetwacom set "Wacom Intuos BT M Pad pad" Button 3 "key p"	# Knopf Mitte rechts
#xsetwacom set "Wacom Intuos BT M Pad pad" Button 8 "key shift e"	# Knopf rechts
##xsetwacom set "Wacom Intuos BT M Pen stylus" Button 1 	# Schreibspitze
#xsetwacom set "Wacom Intuos BT M Pen stylus" Button 2 "key BackSpace"	# Kleiner Knopf: z.B. Tastaturbefehl -> "key BackSpace" für XK_BackSpace (Rückwärtslöschen)
#xsetwacom set "Wacom Intuos BT M Pen stylus" Button 3 	# Grosser Knopf
#
### Button Remapping
## Notwendig, falls die Funktionsweise der Tasten je nach Anwendung frei gestaltet werden soll. Andernfalls werden Maustasten 1-7 verwendet. Diese können in Anwendungen nicht anderweitig zugeordnet werden.
#xsetwacom set "Wacom Intuos BT M Pad pad" Button 1 11	# Knopf links
#xsetwacom set "Wacom Intuos BT M Pad pad" Button 2 12	# Knopf Mitte links
#xsetwacom set "Wacom Intuos BT M Pad pad" Button 3 13	# Knopf Mitte rechts
#xsetwacom set "Wacom Intuos BT M Pad pad" Button 8 14	# Knopf rechts
##xsetwacom set "Wacom Intuos BT M Pen stylus" Button 1 11	# Schreibspitze (Remapping macht keinen Sinn!)
#xsetwacom set "Wacom Intuos BT M Pen stylus" Button 2 12	# Kleiner Knopf: z.B. Tastaturbefehl -> "key BackSpace" für XK_BackSpace (Rückwärtslöschen)
#xsetwacom set "Wacom Intuos BT M Pen stylus" Button 3 13	# Grosser Knopf
#
### Button Funktionszuweisung global mit Remapping
## Sämmtliche Tastaturbefehle sind unter /usr/include/X11/keysymdef.h zu finden
## Zusätzliche Befehle oder Macros können auf freie F-Tasten gelegt werden. Die F-Tasten werden anschliessend den Buttons zugewiesen.
#xsetwacom set "Wacom Intuos BT M Pad pad" Button 11 "key ctrl z"	# Knopf links
#xsetwacom set "Wacom Intuos BT M Pad pad" Button 12 "key ctrl y"	# Knopf Mitte links
#xsetwacom set "Wacom Intuos BT M Pad pad" Button 13 "key p"	# Knopf Mitte rechts
#xsetwacom set "Wacom Intuos BT M Pad pad" Button 14 "key shift e"	# Knopf rechts
##xsetwacom set "Wacom Intuos BT M Pen stylus" Button 11	# Schreibspitze (Remapping macht keinen Sinn!)
#xsetwacom set "Wacom Intuos BT M Pen stylus" Button 12 "key BackSpace"	# Kleiner Knopf: z.B. Tastaturbefehl -> "key BackSpace" für XK_BackSpace (Rückwärtslöschen)
#xsetwacom set "Wacom Intuos BT M Pen stylus" Button 13	# Grosser Knopf
