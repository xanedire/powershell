<#
data-name-conflict
by geoffrey erickson
-
to identify duplicated (conflict) files, remove them from all filers cleanly, 
    with an option to remove all desktop items (all items, including conflict)

-
1) enter ticket number (to track case)
2) enter sam accountname (user in question)
3) select option:

Do you want to remove DATA & NAME CONFLICT files? 
 Press [Y] to start,  
 or [c] to count the files, 
 or [desktop] to DELETE ALL FILES from the desktop 
 or [X] to quit:

Y - start the conflict file remover process
desktop - type the word 'desktop' to remove all files from the user's desktop folder
    -----> do not do this under typical circumstances, recovery can be messy <------
c - count the files that are conflicting 
    (run (Y) the cleaner script for any result greater than 0 for any filer)
x - closes script run
--

#>
$VerbosePreference = "continue"

if (!(test-path $psscriptroot\tickets))
    {new-item -path $psscriptroot -name "tickets" -ItemType "directory"}

function purge-conflict {
       foreach ($filer in $filers){ 
            gci "\\$filer\users\$user\desktop\*conflict*" | remove-item -verbose # -WhatIf 
            }
       }
function count-conflict {
       foreach ($filer in $filers){ 
            gci "\\$filer\users\$user\desktop\*conflict*" | measure | select count 
            }
       } 
function purge-desktop {
       foreach ($filer in $filers){
        gci "\\$filer\users\$user\desktop\*" -include * -Recurse | remove-item -verbose
       }
}
function menu {
    switch(read-host "`n Do you want to remove DATA & NAME CONFLICT files? `n Press [Y] to start,  `n or [c] to count the files,  `n or [desktop] to clean the desktop `n or [X] to quit"){
        y{purge-conflict; menu;}
        c{count-conflict; menu;}
        desktop{purge-desktop; menu}
        x{stop-transcript; exit}
        default{menu;}
    }
}
$0 = 'domain.com'
$1 = 'storage'
$p1 = 'profilestore1'
$p2 = 'profilestore2'
$p3 = 'profilestore3'
$p4 = 'profilestore4'
$p4 = 'profilestore5'

$filers = $0,$1,$p1,$p2,$p3,$p4,$p5 

$ticket = read-host 'ticket number'
Start-Transcript -Path $PSScriptRoot\tickets\$ticket.txt -Verbose
$user = read-host 'Enter target user SAM accountname'

menu;