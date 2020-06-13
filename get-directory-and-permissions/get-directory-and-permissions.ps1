function get-directory-permissions{ #($input){
    $folder = read-host 'input directory here'
    (get-acl "$folder").access | ft IdentityReference,FileSystemRights,AccessControlType,IsInherited -auto
    }
function get-permission-description{ #($input){
    $group = read-host 'enter group name'
    Get-ADGroup -identity "$group" -Properties Description | Select-Object Description
    }
function start-script{
    switch(read-host 'wat is needed? (1) permissions, (2) group, (3) exit'){
        1{get-directory-permissions;pause;start-script}
        2{get-permission-description;pause;start-script}
        3{write-host "later dude";pause;exit}
        default{write-host "say whaaaaaaat";start-script}
    }
}
start-script