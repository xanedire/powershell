<#
Takes given [AccountName] and informs the following details:

DisplayName     :  [first last]
PasswordExpired :  $bool
PasswordLastSet :  [mo/da/ye hh:mm:ss pm]
ExpiryDate      :  [mo/da/ye hh:mm:ss pm]
LockedOut       :  $bool

loop added
need to retail $account to verify switch
#>
$account=''
function deliver-accountdetails {
    $account = read-host 'Enter User (SAM) Account Name'
    get-aduser -identity $($account) -properties "DisplayName","msDS-UserPasswordExpiryTimeComputed","PasswordExpired","PasswordLastSet","LockedOut" |
    select-object -property "DisplayName","PasswordExpired","PasswordLastSet",@{
        Name="ExpiryDate";
        Expression={
            [datetime]::FromFileTime(
            $_."msDS-UserPasswordExpiryTimeComputed"
            )
        }
    },"LockedOut"
    unlock
}
function unlock {
    if ($accountcount = 0){break;deliver-accountdetails}
    $locked = get-aduser -identity $($account) -Properties * | Select-Object "LockedOut" 
    if ($locked.LockedOut -eq $true) {
        switch (read-host  "User is Locked. Do you want to [UNLOCK]? Y/N"){
        y {write-host "Attempting Unlock`n";unlock-adaccount -Identity $($account)}
        n {write-host "Account not unlocked - Account still [LOCKED]`n"}
        default{unlock}
        }
    }
        else {write-host "Account not locked`n"}
     deliver-accountdetails
}

deliver-accountdetails;