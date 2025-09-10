#region functions
#region functions section
function list-customfunctions{
    write-host "The following are a list of known custom functions:" -ForegroundColor red 
    write-host "`n
                get-companyuser,`r
                get-access,`r
                add-oneoff,`r
                add-birthright,`r
                get-userfromemail,`r
                get-permissionfromemail,`r
                compare-usersgroups,`r
                search-adgroups,`r
                search-password,`r
                reset-password,`r
                unlock-user,`r
                get-userlocation,`r
                set-expiration,`r
                speak,`r
                add-proxyaddress,`r
                list-customfunctions,`r
                `n" -ForegroundColor Green 
}
#region get user
function get-companyuser{

    try
    {
        $companyuser = read-host "enter username"
        get-aduser -identity $companyuser -server $server 
    }
    catch
    {
        write-host "user not found by sam account name, try user's first or last name!" -ForegroundColor Yellow -BackgroundColor black
        $companyusername = read-host "enter user's first or last name"
        $companyusername = "*" + $companyusername + "*"
        get-aduser -filter 'name -like $companyusername' -server $server  | Sort-Object -property name
    }finally{
                write-host "If user not found by full name, system presence unlikely." -ForegroundColor Yellow -BackgroundColor black
            }
}
#region check ad permissions
function get-access{
        get-aduser -identity (read-host 'username') -server $server  | get-ADprincipalGroupMembership -server $server -resourcecontextserver $server  | Select-Object name | Sort-Object -Property name | format-table -AutoSize
    }
#region add one-off
function add-oneoff{
    get-aduser -id (read-host 'username') -server $server   | add-adprincipalGroupMembership -MemberOf (read-host 'memberof') -server $server   
}
#region get account from email
function get-userfromemail {
    $user = (read-host "UserPrincipalName"); get-aduser -filter 'UserPrincipalName -eq $user' -properties samaccountname -server $server   | Select-Object samaccountname | Format-Table -autosize
}
#region get access from email
function get-permissionfromemail {

    $user = (read-host "UserPrincipalName")
    get-aduser -filter 'UserPrincipalName -eq $user' -server $server   | Get-ADPrincipalGroupMembership -server $server -resourcecontextserver $server  | Select-object name | sort-object -Property name | Format-Table -AutoSize
}
#region compare users
function compare-usersgroups {

    param (
        [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)][Alias("R", "ref")][String] $ReferenceUser,
        [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)][Alias("C", "comp")][String] $CompareUser
    )

    Begin {

        while (([string]::IsNullOrEmpty($ReferenceUser)) -or ([string]::IsNullOrEmpty($CompareUser))) {
            if ([string]::IsNullOrEmpty($ReferenceUser)) { $ReferenceUser = Read-Host -Prompt 'Reference Username' }
            if ([string]::IsNullOrEmpty($CompareUser)) { $CompareUser = Read-Host -Prompt 'Username to compare to reference' }
        }
    }

    Process {
    $ReferenceUserObj = Get-ADPrincipalGroupMembership $ReferenceUser -server 'corp.company.com' -resourcecontextserver 'corp.company.com' | Select-Object Name | Sort-Object -Property Name    
    $CompareUserObj = Get-ADPrincipalGroupMembership $CompareUser -server 'corp.company.com' -resourcecontextserver 'corp.company.com' | Select-Object Name | Sort-Object -Property Name

    $comp = Compare-Object -ReferenceObject $ReferenceUserObj -DifferenceObject $CompareUserObj -IncludeEqual -Property Name

    $comp | ForEach-Object  {
        $_.SideIndicator = switch($_.SideIndicator) {
            '<=' { $ReferenceUser }
            '=>' { $CompareUser }
            '==' { "BOTH" }
            default { "default" }
        }
    }
}

End {
    $comp | Format-Table -AutoSize
    }
}
#region search ad groups
function search-adgroups {
    $variable = (read-host 'Please enter beginning of AD group name to search -->');
    get-adgroup -filter "name -like '$variable*'" -server $server  |Select-Object name |Sort-Object -property name
}
#region check password
function search-password {
    $account = read-host 'Enter User (SAM) Account Name'
    get-aduser -identity $account -properties "DisplayName","msDS-UserPasswordExpiryTimeComputed","PasswordExpired","PasswordLastSet","LockedOut","Enabled","AccountExpirationDate" -server 'corp.company.com'   |
    select-object -property "DisplayName","Enabled","AccountExpirationDate","PasswordExpired","PasswordLastSet",@{
        Name="PasswordExpiryDate";
        Expression={
            [datetime]::FromFileTime(
            $_."msDS-UserPasswordExpiryTimeComputed"
            )
        }
    },"LockedOut"
    #clear-variable -name account
}
#region reset password
function reset-password {
    $Username = Read-Host "Enter the Active Directory username"
    $Password = Read-Host "Enter the new password" -AsSecureString
    $PlainTextPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
    Set-ADAccountPassword -Identity $Username -NewPassword (ConvertTo-SecureString -String $PlainTextPassword -AsPlainText -Force) -Server $Server    -Reset
    #clear-variable username,password,plaintextpassword
}
#region unlock user
function unlock-user { 
    $account = read-host 'Enter User (SAM) Account Name'
    unlock-adaccount -Identity $($account) -server 'corp.company.com'  
    clear-variable -name account
}
#region expire user
function set-expiration{
    $date = read-host 'yyyy-mm-dd'
    $expiration = get-date "$date 00:00:00"
    $user = read-host 'username'
    set-aduser -identity $user -AccountExpirationDate $expiration -server $server
}
#region speak
function speak{
    $convo = read-host "What do you want me to say?"
    Add-Type -AssemblyName System.Speech
    $synthesizer = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
    $synthesizer.Speak($convo)
}
#region proxy address
function add-proxyaddress {
    $origin= read-host "enter email address to add account"
    $target= get-aduser -filter "emailaddress -eq '$origin'" -properties proxyAddresses -server $server
    $proxyaddress= read-host ("enter the new proxy address to add")
    if ($target) {
       set-aduser -id $target.samaccountname -add @{proxyAddresses="smtp:$proxyaddress"} -server $server
       write-host "proxy address for $origin added successfully."
    } else {
       write-host "user not found with email address $origin"
    }
}
#region add birthright access for cw
function add-birthright {
    $user = read-host ("enter username")
    $groups = 'VPN Users','Haiilo Contingent Workers','Haiilo Users','SG-IntuneTestPilot'
    $aduser = get-aduser -id $user -server $server
    if (-not $adUser) {
        Write-Error "User '$user' not found in Active Directory."
        return
    }
    Add-ADPrincipalGroupMembership -id $user -memberof $groups -server $server
    Write-Host "User '$user' has been added to the following groups:`n $($groups -join ", `n")" -ForegroundColor Green
}

#endregion
#region basics
set-strictmode -version latest

#
function prompt {"Domain:Corp PowerShell > "}

write-host "Welcome back $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)  `r`n" -ForegroundColor Yellow -BackgroundColor black

# Get the current date
function Get-DaysUntilFriday {
    # Get today's date
    $today = Get-Date
    
    # Get the day of week (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
    $currentDay = [int]$today.DayOfWeek
    
    # Friday is day 5 in the week (Sunday = 0)
    $friday = 5
    
    # Calculate days until Friday
    if ($currentDay -eq $friday) {
        Write-Output "Friday is today!"
    }
    else {
        $daysUntil = ($friday - $currentDay + 7) % 7
        if ($daysUntil -eq 1) {
            Write-Output "Friday is in 1 day"
        }
        else {
            Write-Output "Friday is $daysUntil days away"
        }
    }
}
Get-DaysUntilFriday
list-customfunctions

$server = "company.com"
#endregion