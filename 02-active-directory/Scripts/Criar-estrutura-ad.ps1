<#
.SYNOPSIS
    Cria a estrutura de OUs, grupos e usuários da Nexora Logística.
.NOTES
    Executar no SRV-DC01 após a promoção a Domain Controller.
    Domínio: nexora.local
    STATUS: esqueleto — completar as OUs restantes e a criação de usuários.
#>

$Base = "OU=Nexora,DC=nexora,DC=local"

# --- 1. OU raiz ---
New-ADOrganizationalUnit -Name "Nexora" -Path "DC=nexora,DC=local" -ProtectedFromAccidentalDeletion $true

# --- 2. OUs de primeiro nível ---
"Usuarios","Computadores","Grupos","Admins","ContasServico" | ForEach-Object {
    New-ADOrganizationalUnit -Name $_ -Path $Base -ProtectedFromAccidentalDeletion $true
}

# --- 3. OUs de departamento (dentro de Usuarios) ---
$deptos = "Diretoria","TI","RH","Financeiro","Comercial"
foreach ($d in $deptos) {
    New-ADOrganizationalUnit -Name $d -Path "OU=Usuarios,$Base" -ProtectedFromAccidentalDeletion $true
}

# --- 4. OUs de computadores ---
"Workstations","Servidores" | ForEach-Object {
    New-ADOrganizationalUnit -Name $_ -Path "OU=Computadores,$Base" -ProtectedFromAccidentalDeletion $true
}

# --- 5. Grupos por departamento ---
foreach ($d in $deptos) {
    New-ADGroup -Name "GRP-$d" -GroupScope Global -GroupCategory Security `
        -Path "OU=Grupos,$Base" -Description "Membros do departamento $d"
}

# --- 6. Usuários (TAREFA) ---
# Opção recomendada: importar de um CSV para praticar automação.
# Cabeçalho do CSV: Nome,Sobrenome,Login,Departamento
#
# Import-Csv .\usuarios.csv | ForEach-Object {
#     $nomeCompleto = "$($_.Nome) $($_.Sobrenome)"
#     New-ADUser `
#         -Name $nomeCompleto `
#         -GivenName $_.Nome -Surname $_.Sobrenome `
#         -SamAccountName $_.Login `
#         -UserPrincipalName "$($_.Login)@nexora.local" `
#         -Path "OU=$($_.Departamento),OU=Usuarios,$Base" `
#         -AccountPassword (ConvertTo-SecureString "Nexora@2026!" -AsPlainText -Force) `
#         -ChangePasswordAtLogon $true `
#         -Enabled $true
#     Add-ADGroupMember -Identity "GRP-$($_.Departamento)" -Members $_.Login
# }

Write-Host "Estrutura de OUs e grupos criada. Complete a criacao de usuarios." -ForegroundColor Green
