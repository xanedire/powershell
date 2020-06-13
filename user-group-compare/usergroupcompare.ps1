#compare security groups between two users
#uses domain username
#author = dave & geoff


param (
    [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)][Alias("R", "ref")][String] $ReferenceUser,
    [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)][Alias("C", "comp")][String] $CompareUser
)

Begin {
    $ErrorActionPreference = ‘SilentlyContinue’
    clear
    Remove-Variable $comp, $ReferenceUserObj, $CompareUserObj -Force -EA SilentlyContinue
    
    while (([string]::IsNullOrEmpty($ReferenceUser)) -or ([string]::IsNullOrEmpty($CompareUser))) {
        if ([string]::IsNullOrEmpty($ReferenceUser)) { $ReferenceUser = Read-Host -Prompt 'Reference Username' }
        if ([string]::IsNullOrEmpty($CompareUser)) { $CompareUser = Read-Host -Prompt 'Username to compare to reference' }
    }
}

Process {
    $ReferenceUserObj = Get-ADPrincipalGroupMembership $ReferenceUser | select Name | Sort-Object -Property Name
    $CompareUserObj = Get-ADPrincipalGroupMembership $CompareUser | select Name | Sort-Object -Property Name

    $comp = Compare-Object -ReferenceObject $ReferenceUserObj -DifferenceObject $CompareUserObj -IncludeEqual -Property Name 

    $comp | foreach  {
        $_.SideIndicator = switch($_.SideIndicator) {
            '<=' { $ReferenceUser }
            '=>' { $CompareUser }
            '==' { "BOTH" }
            default { "¯\_(ツ)_/¯" }
        }
    }
}

End {
    $comp | Format-Table -AutoSize
    Remove-Variable $comp, $ReferenceUser, $ReferenceUserObj, $CompareUser, $CompareUserObj -Force
}