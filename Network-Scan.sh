#!/bin/bash

#-------------------------------------------------------------#
#     Script de scan réseau complet avec rapport HTML         #
#        (affiche nom des machines + latence 🔥)              #
#-------------------------------------------------------------#

# Détection de l'IP locale automatiquement (première interface active)
INTERFACE=$(networksetup -listallhardwareports | awk '/Device/ {print $2}' | head -n 1)
IP_LOCAL=$(ipconfig getifaddr "$INTERFACE")
RESEAU=$(echo "$IP_LOCAL" | awk -F. '{print $1"."$2"."$3".0/24"}')
TIMESTAMP=$(date +"%Y-%m-%d_%H%M")
RAPPORT_HTML="scan_reseau_$TIMESTAMP.html"
TMP_DIR=$(mktemp -d)

echo "🔍 Scan du réseau local : $RESEAU"
echo "📄 Rapport HTML en cours de génération..."

# Génération de l'entête HTML
cat <<EOF > "$RAPPORT_HTML"
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Scan Réseau - $TIMESTAMP</title>
  <style>
    body { font-family: Arial, sans-serif; background: #f5f5f5; padding: 20px; }
    h1 { color: #333; }
    table { border-collapse: collapse; width: 100%; margin-bottom: 40px; }
    th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
    th { background-color: #333; color: white; }
    .open { background-color: #c8e6c9; }
    .closed { background-color: #eeeeee; color: #888; }
    .port { font-weight: bold; }
    .service { font-style: italic; }
    .latency { font-size: 0.9em; color: #666; }
  </style>
</head>
<body>
  <h1>🖧 Rapport de Scan Réseau - $TIMESTAMP</h1>
  <p>Plage scannée : <strong>$RESEAU</strong></p>
EOF

# Détection des hôtes actifs
nmap -sn "$RESEAU" -oG - | awk '/Up$/{print $2}' | sort > "$TMP_DIR/hosts.txt"

# Pour chaque hôte détecté
while read -r IP; do
    echo "📍 Scan de $IP"
    HOSTNAME=$(dig +short -x "$IP" | sed 's/\.$//')
    [ -z "$HOSTNAME" ] && HOSTNAME="(non résolu)"

    # Récupération de la latence (ping)
    LATENCY=$(ping -c 1 -W 1 "$IP" | grep 'time=' | sed -E 's/.*time=([0-9.]+) ms/\1 ms/')
    [ -z "$LATENCY" ] && LATENCY="N/A"

    echo "<h2>📍 $IP — <em>$HOSTNAME</em> <span class=\"latency\">(latence : $LATENCY)</span></h2>" >> "$RAPPORT_HTML"
    echo "<table><tr><th>Port</th><th>État</th><th>Service</th><th>Détail</th></tr>" >> "$RAPPORT_HTML"
    
    nmap -sV "$IP" -oG - | awk '/Ports: /{print $0}' | sed 's/.*Ports: //' | tr ',' '\n' | while read -r portline; do
        PORT=$(echo "$portline" | awk -F/ '{print $1}')
        STATE=$(echo "$portline" | awk '{print $2}')
        SERVICE=$(echo "$portline" | awk '{print $3}')
        DETAIL=$(echo "$portline" | cut -d ' ' -f4-)

        CSS_CLASS="closed"
        [ "$STATE" == "open" ] && CSS_CLASS="open"

        echo "<tr class=\"$CSS_CLASS\">
                <td class=\"port\">$PORT</td>
                <td>$STATE</td>
                <td class=\"service\">$SERVICE</td>
                <td>$DETAIL</td>
              </tr>" >> "$RAPPORT_HTML"
    done

    echo "</table>" >> "$RAPPORT_HTML"
done < "$TMP_DIR/hosts.txt"

# Pied de page HTML
cat <<EOF >> "$RAPPORT_HTML"
  <footer>
    <p style="font-size: 0.9em; color: #888;">Généré automatiquement avec ❤️ par ton script Bash</p>
  </footer>
</body>
</html>
EOF

# Nettoyage
rm -rf "$TMP_DIR"

echo "✅ Rapport HTML généré : $RAPPORT_HTML"
open "$RAPPORT_HTML "







