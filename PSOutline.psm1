if (!$env:OutlineApiURL) {
    $env:OutlineApiURL = Read-Host "Please enter API URL"
}

function Get-OUAccessKeys {
    $uri = "$env:OutlineApiURL/access-keys"
    ((Invoke-WebRequest -Uri $uri).Content | ConvertFrom-Json).AccessKeys
}
function New-OUAccessKey {
    $uri = "$env:OutlineApiURL/access-keys"
    (Invoke-WebRequest -Method Post -Uri $uri).Content | ConvertFrom-Json
}
function Rename-OUAccessKey {
    Param (
        [parameter(Mandatory = $true)][string]$KeyID,
        [parameter(Mandatory = $true)][string]$NewName
    )
    $uri = "$env:OutlineApiURL/access-keys/$KeyID/name"
    $body = @{
        name = $NewName
    }
    Invoke-WebRequest -Method Put -Uri $uri -ContentType "application/json" -Body ($body | ConvertTo-Json) | Out-Null
    [PSCustomObject]@{
        NewName = $NewName
        ID      = $KeyID
    }
}
function Remove-OUAccessKey {
    param (
        [parameter(Mandatory = $true)][string]$KeyID
    )
    $uri = "$env:OutlineApiURL/access-keys/$KeyID"
    Invoke-WebRequest -Method Delete -Uri $uri | Out-Null
}
function Get-OUInvite {
    param (
        [parameter(Mandatory = $true)][string]$accessUrl
    )

    @"
You're invited to connect to Outline vpn server. Use it to access the open internet, no matter where you are. Follow the instructions on your invitation link below to download the Outline App and get connected.

https://s3.amazonaws.com/outline-vpn/invite.html#$($accessUrl -replace 'ss:\/\/','ss%3A%2F%2F' -replace '@','%40' -replace ':','%3A' -replace '\/\?','%2F%3F' -replace '=','%3D')

-----

Having trouble accessing the invitation link?

Copy your access key: $accessUrl
Follow our invitation instructions on GitHub: https://github.com/Jigsaw-Code/outline-client/blob/master/docs/invitation-instructions.md
"@
}