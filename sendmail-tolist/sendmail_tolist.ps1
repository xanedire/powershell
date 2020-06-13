#CSV Format
# LINE 1 User 1<user1@domain.org>
# LINE 2 User 2<user2@domain.org>
# LINE 3 User 3<user3@domain.org>

$var=get-content U:\samplelist.csv
$myemail = #'my.email@domain.com'
$smtp= #"smpt.domain.com"
[string[]]$to= $var
$subject = read-host "enter subject"
$body = read-host "enter message"

send-mailmessage -to $to -subject $subject -body $body -smtpserver $smtp -from $myemail