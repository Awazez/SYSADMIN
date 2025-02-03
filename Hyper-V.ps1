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
    [string]$ISOPath = "E:\SSS_X64FREE_FR-FR_DV9.iso"
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

# Création du dossier si inexistant
if (!(Test-Path $VHDPath)) {
    New-Item -ItemType Directory -Path $VHDPath | Out-Null
}

# Création de la VM
New-VM -Name $Name -MemoryStartupBytes $Memory -Generation 2 -Path $Path -NewVHDPath "$VHDPath\$Name.vhdx" -NewVHDSizeBytes ($VHDSizeGB * 1GB) -SwitchName $SwitchName
Write-Host "VM $Name créée avec succès." -ForegroundColor Green

# Ajout du lecteur DVD avec l'ISO
if (Test-Path $ISOPath) {
    Add-VMDvdDrive -VMName $Name -Path $ISOPath
    Write-Host "ISO $ISOPath attaché à la VM $Name." -ForegroundColor Green
} else {
    Write-Host "Le fichier ISO spécifié ($ISOPath) est introuvable." -ForegroundColor Red
}

# Activer la mémoire dynamique
Set-VMMemory -VMName $Name -DynamicMemoryEnabled $true -MinimumBytes 512MB -MaximumBytes 8GB
Write-Host "Mémoire dynamique activée pour la VM $Name." -ForegroundColor Cyan

Write-Host "Installation de la VM terminée avec succès !" -ForegroundColor Green

Read-Host "Appuie sur Entrée pour quitter"