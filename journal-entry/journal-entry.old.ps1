#for quick notes with time stamps

<#
.SYNOPSIS
#Quick notes with time stamps

.DESCRIPTION
Used to generate quick notes with time stamps. 
Also helps to identify previously closed 'journals' on first-run.
Will check to see if journal exists, and create if it doesn't.
Or, will make new entries to chosen journal.
.txt file extension is appended to any journal name; no need to call for it.

.EXAMPLE
PS /Users/[redacted]/Documents/scripts> ls
journal-entry.ps1	journal.txt
PS /Users/[redacted]/Documents/scripts> ./journal-entry.ps1
journal-entry.ps1
journal.txt
What is the name of your journal?: test

    Directory: /Users/[redacted]/Documents/scripts

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-----           6/14/2020  2:21 PM              0 test.txt

[clear]
 Are you going to make another journal entry? 
 Press [any key] to start another entry, or [X] to quit: 
What is your entry?: here is an entry

[clear]
 Are you going to make another journal entry? 
 Press [any key] to start another entry, or [X] to quit: x

PS /Users/[redacted]/Documents/scripts> ls
journal-entry.ps1	journal.txt		test.txt
PS /Users/[redacted]/Documents/scripts> cat test.txt 
14/06 14:21 2020
here is an entry
PS /Users/[redacted]/Documents/scripts> 

.NOTES
authored by g
#>
function new-journal{
    if (!(test-path .\"$journal".txt))
        {new-item -path .\"$journal".txt}
}
function journal-entry{
    get-date -format "dd/MM HH:mm yyyy" | Out-File -Append .\"$journal".txt
    read-host 'What is your entry?'| Out-File -Append .\"$journal".txt
}
function start-script{
    clear
    switch(read-host "`n Are you going to make another journal entry? `n Press [any key] to start another entry, or [X] to quit"){
        x{exit}
        default{journal-entry}
    }
}
gci -Path $PSScriptRoot/* -Name
$journal = read-host "What is the name of your journal?"
new-journal
while ($true) {
    start-script
    }