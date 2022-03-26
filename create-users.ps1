# Workaround for disable certificates check
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# Create keys from csv
$users = Import-Csv .\users.csv
$currentKeys = Get-OUAccessKeys
foreach ($user in $users) {
    $exist = $false
    if ($currentKeys.name.Contains($user.keyname)) {
        Write-Host "Key for $($user.keyname) already exist"
    }
    else {
        $newKey = New-OUAccessKey
        Rename-OUAccessKey -KeyID $newKey.id -NewName $user.keyname | Out-Null
        Write-Host "Key for $($user.keyname) succesfully created"
    }
}

# Get invites
$users = Import-Csv .\users.csv
$currentKeys = Get-OUAccessKeys
foreach ($key in $currentKeys) {
    $tgname = ($users | where keyname -eq $key.name).telegram
    Write-Host "User '$($key.name)', id '$($key.id)', tg '$($tgname)'" -ForegroundColor Green
    Get-OUInvite -accessUrl $key.accessUrl
}
