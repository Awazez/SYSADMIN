#-------------------------------------------------------------#
#                                                             #
#          ██╗  ██╗ █████╗  ██████╗██╗  ██╗                   #
#          ██║  ██║██╔══██╗██╔════╝██║  ██║                   #
#          ███████║███████║██║     ███████║                   #
#          ██╔══██║██╔══██║██║     ██╔══██║                   #
#          ██║  ██║██║  ██║╚██████╗██║  ██║                   #
#          ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝                   #
#                                                             #
#        Script to change admin password with PowerShell      #
#-------------------------------------------------------------#

param (
    [string]$KeePassPath = "C:\Program Files\KeePass\KeePass.exe",
    [string]$DatabasePath = "C:\Users\martin.aubeut\Documents\KeePass\database.kdbx",
    [string]$MasterPassword = "MonMotDePassePrincipal",  # ⚠️ Utiliser une variable d’environnement pour plus de sécurité
    [string]$KeyFilePath = "",  # Ajoute le chemin du keyfile si nécessaire
    [string]$EntryTitle = "Admin Windows",
    [string]$Username = "Administrator",
    [int]$PasswordLength = 16
)

# 🔐 Génération d'un mot de passe aléatoire
$NewPassword = -join ((48..57) + (65..90) + (97..122) + (33..47) | Get-Random -Count $PasswordLength | ForEach-Object {[char]$_})
$SecurePassword = ConvertTo-SecureString $NewPassword -AsPlainText -Force

# 🔄 Modification du mot de passe administrateur
Set-LocalUser -Name $Username -Password $SecurePassword

# 🔍 Vérifier si KeePass.exe existe
if (-Not (Test-Path $KeePassPath)) {
    Write-Host "❌ Erreur : KeePass.exe introuvable ! Vérifie l'installation de KeePass."
    exit 1
}

# 🗝️ Construction de la ligne de commande pour ouvrir KeePass avec le mot de passe
$KeePassCommand = "`"$KeePassPath`" `"$DatabasePath`" -pw:$MasterPassword"

if ($KeyFilePath -ne "") {
    $KeePassCommand += " -keyfile:`"$KeyFilePath`""
}

# 🚀 Lancer KeePass en arrière-plan pour ouvrir la base de données
Start-Process -FilePath $KeePassPath -ArgumentList "`"$DatabasePath`" -pw:$MasterPassword" -NoNewWindow -Wait

# ⏳ Attendre un court instant pour que KeePass soit bien ouvert
Start-Sleep -Seconds 2

# 📝 Ajouter une nouvelle entrée avec le mot de passe généré
$KeePassEntryCommand = "AddEntry `"$DatabasePath`" `"$EntryTitle`" `"$Username`" `"$NewPassword`""
Start-Process -FilePath $KeePassPath -ArgumentList $KeePassEntryCommand -NoNewWindow -Wait

Write-Host "✅ Le mot de passe de $Username a été changé et enregistré dans KeePass."





