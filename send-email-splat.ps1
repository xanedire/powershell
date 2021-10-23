<#
Run at end of shift on Saturday(s) & Sunday(s)
-

Total Calls Received: 
Total Handled out: 
Total Escalations: 
Trends or Major Issues (if any): 
Status of Unassigned Queue: 

#>
$totalcalls = read-host "Total Calls Received"
$escalations = read-host "Total Escalations"
$trends = read-host "Trends or Major Issues (if any)"
$queue = read-host "Status of Unassigned Queue"

$date = get-date
$dateform = get-date -format "MM/dd/yyy"
if ($date.DayOfWeek -eq "saturday"){
    $day = "6:00am - 1:30pm (PST)"
    }elseif($date.DayOfWeek -eq "sunday"){
        $day = "6:00am - 12:30pm (PST)"
        }else{write-host "It's not the weekend!!"; pause; exit}
$mail = get-aduser $env:USERNAME -Properties * | Select-Object mail

$properties = @{
    to         = "recipient@email.com"
    from       = $mail.mail
    subject    = "Completion of $day $($date.DayOfWeek) Shift $($dateform)"
    smtpserver = "smtpserver.com"
    body       = "Total Calls Received: $totalcalls (combined)`n- Total Escalations: $escalations`n- Trends or Major Issues (if any): $trends`n- Status of Unassigned Queue: $queue"
}

#
send-mailmessage @properties; 
write-host "Your email was sent!"; start-sleep 3; exit