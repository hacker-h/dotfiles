#!/bin/bash

# Überprüfen, ob ein Argument gegeben wurde
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/appimage"
    exit 1
fi

# Pfad zur AppImage-Datei
appimage_path="$1"

# Stellen Sie sicher, dass die Datei existiert und ausführbar ist
if [ ! -f "$appimage_path" ]; then
    echo "Die angegebene Datei existiert nicht: $appimage_path"
    exit 1
fi
chmod +x "$appimage_path"

# Versuch, die Version direkt aus dem AppImage zu bekommen
echo "Versuche, die Version direkt zu erhalten:"
if version_info=$("$appimage_path" --version 2>/dev/null); then
    echo "Version gefunden: $version_info"
    exit 0
elif version_info=$("$appimage_path" -v 2>/dev/null); then
    echo "Version gefunden: $version_info"
    exit 0
else
    echo "Keine direkte Versionsinformation gefunden."
fi

## Verwenden von 'strings' um mögliche Versionsinformationen zu finden
#echo "Suche nach Version in den Binärdaten:"
#version_info=$(strings "$appimage_path" | grep -i "version" | head -1)
#if [ ! -z "$version_info" ]; then
#    echo "Mögliche Versionsinformation gefunden: $version_info"
#    exit 0
#else
#    echo "Keine Versionsinformation in den Binärdaten gefunden."
#fi

# Extrahieren des Inhalts
echo "Extrahiere AppImage-Inhalt..."
"$appimage_path" --appimage-extract >/dev/null 2>&1
pushd squashfs-root >/dev/null

# Suche nach Dateien, die Versionsinformationen enthalten könnten
echo "Suche in extrahierten Dateien nach Versionsinformationen:"
version_files=$(grep -ri "version" . | head -3)
if [ ! -z "$version_files" ]; then
    echo "Gefundene Versionsinformationen in Dateien:"
    echo "$version_files"
    popd >/dev/null
    exit 0
else
    echo "Keine Versionsinformationen in extrahierten Dateien gefunden."
fi

# Aufräumen und Verlassen
popd >/dev/null
echo "Aufräumen..."
#rm -rf squashfs-root

echo "Keine Versionsinformationen verfügbar."
exit 1

