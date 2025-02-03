#-------------------------------------------------------------#
#                                                             #
#          ██╗  ██╗ █████╗  ██████╗██╗  ██╗                   #
#          ██║  ██║██╔══██╗██╔════╝██║  ██║                   #
#          ███████║███████║██║     ███████║                   #
#          ██╔══██║██╔══██║██║     ██╔══██║                   #
#          ██║  ██║██║  ██║╚██████╗██║  ██║                   #
#          ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝                   #
#                                                             #
#        Script Install a VM on Hyper-V with PowerShell       #
#-------------------------------------------------------------#

param (
    [string]$Name = "VM-W11",
    [string]$Path = "C:\ProgramData\Microsoft\Windows\Hyper-V\",
    [string]$VHDPath = "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\",
    [int]$VHDSizeGB = 64,
    [int64]$Memory = 4294967296,
    [string]$SwitchName = "LAN-Physique",
    [string]$ISOPath = "E:\SSS_X64FREE_FR-FR_DV9.iso",
    [int]$ProcessorCount = 4
)

# Vérification des prérequis
if (-not (Get-Command New-VM -ErrorAction SilentlyContinue)) {
    Write-Host "Hyper-V n'est pas installé sur ce système. Veuillez l'installer avant d'exécuter ce script." -ForegroundColor Red
    exit 1
}

# Vérifier si la VM existe déjà
if (Get-VM -Name $Name -ErrorAction SilentlyContinue) {
    Write-Host "Une VM avec le nom $Name existe déjà. Choisissez un autre nom ou supprimez l'existante." -ForegroundColor Yellow
    exit 1
}

# Vérification du chemin du VHD
if (!(Test-Path $VHDPath)) {
    New-Item -ItemType Directory -Path $VHDPath | Out-Null
    Write-Host "Création du dossier $VHDPath." -ForegroundColor Cyan
}

# Vérification du fichier ISO
if (!(Test-Path $ISOPath)) {
    Write-Host "Le fichier ISO spécifié ($ISOPath) est introuvable. Veuillez vérifier le chemin." -ForegroundColor Red
    exit 1
}

# Création de la VM
try {
    New-VM -Name $Name -MemoryStartupBytes $Memory -Generation 2 -Path $Path -NewVHDPath "$VHDPath\$Name.vhdx" -NewVHDSizeBytes ($VHDSizeGB * 1GB) -SwitchName $SwitchName
    Write-Host "VM $Name créée avec succès." -ForegroundColor Green
} catch {
    Write-Host "Erreur lors de la création de la VM : $_" -ForegroundColor Red
    exit 1
}

# Ajout du lecteur DVD avec l'ISO
try {
    Add-VMDvdDrive -VMName $Name -Path $ISOPath
    Write-Host "ISO $ISOPath attaché à la VM $Name." -ForegroundColor Green
} catch {
    Write-Host "Impossible d'attacher l'ISO : $_" -ForegroundColor Red
}

# Configuration du processeur
try {
    Set-VMProcessor -VMName $Name -Count $ProcessorCount
    Write-Host "Processeur configuré à $ProcessorCount cœurs pour la VM $Name." -ForegroundColor Cyan
} catch {
    Write-Host "Erreur lors de la configuration du processeur : $_" -ForegroundColor Red
}

# Activer la mémoire dynamique
try {
    Set-VMMemory -VMName $Name -DynamicMemoryEnabled $true -MinimumBytes 512MB -MaximumBytes 8GB
    Write-Host "Mémoire dynamique activée pour la VM $Name." -ForegroundColor Cyan
} catch {
    Write-Host "Erreur lors de la configuration de la mémoire dynamique : $_" -ForegroundColor Red
}

# Affichage du résumé de la configuration
$VMInfo = Get-VM -Name $Name
Write-Host "Résumé de la VM créée :" -ForegroundColor White
Write-Host "--------------------------------------"
Write-Host "Nom : $($VMInfo.Name)"
Write-Host "Mémoire de démarrage : $($VMInfo.MemoryStartup)"
Write-Host "Processeurs : $ProcessorCount"
Write-Host "Disque virtuel : $VHDPath\$Name.vhdx ($VHDSizeGB GB)"
Write-Host "ISO attaché : $ISOPath"
Write-Host "Commutateur réseau : $SwitchName"
Write-Host "--------------------------------------"

Write-Host "Installation de la VM terminée avec succès !" -ForegroundColor Green

Read-Host "Appuie sur Entrée pour quitter"
