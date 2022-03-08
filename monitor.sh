#!/binbash

# Passt Bildschirmgrösse an Anzahl Eingänge an:
# Argument 1 = 1 Eingang
# Argument 2 = 2 Eingänge (halbierte Breite)

MONITOR=$1

if [ $MONITOR = 1 ]; then
	xrandr --output DP1 --mode 3840x2160
	echo "Auflösung: 3840x2160"
elif [ $MONITOR = 2 ]; then
	xrandr --output DP1 --mode 1920x2160
	echo "Auflösung: 1920x2160"
else
	echo "Kein gültiges Argument.
        1 für einen Eingang
	2 für zwei Eingänge
	Format: . <Script-Pfad> <Nummer>"
fi
