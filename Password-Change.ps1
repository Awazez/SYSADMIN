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
    [string]$DatabasePath = "C:\Users\martin.aubeut\Documents\KeePass\database.kdbx",
    [string]$MasterPassword = "MonMotDePassePrincipal", # ⚠️ À remplacer par une variable d'environnement idéalement
    [string]$EntryTitle = "Admin Windows",
    [string]$Username = "Administrator",
    [string]$KeePassCmdPath = "C:\Program Files\KeePass\KeePassCMD.exe",
    [int]$PasswordLength = 16
)

# 🔐 Génération d'un mot de passe aléatoire
$NewPassword = -join ((48..57) + (65..90) + (97..122) + (33..47) | Get-Random -Count $PasswordLength | ForEach-Object {[char]$_})
$SecurePassword = ConvertTo-SecureString $NewPassword -AsPlainText -Force

# 🔄 Modification du mot de passe administrateur
Set-LocalUser -Name $Username -Password $SecurePassword

# 🔍 Vérification de la présence de KeePassCMD
if (-Not (Test-Path $KeePassCmdPath)) {
    Write-Host "❌ Erreur : KeePassCMD.exe introuvable ! Vérifie l'installation de KeePass."
    exit 1
}

# 🔑 Ajout du mot de passe dans KeePass
$KeePassCommand = "`"$KeePassCmdPath`" --pw:$MasterPassword --add --db:`"$DatabasePath`" --title:`"$EntryTitle`" --user:`"$Username`" --password:`"$NewPassword`""
Invoke-Expression $KeePassCommand

Write-Host "✅ Le mot de passe de $Username a été changé et enregistré dans KeePass."




