#Install EASendMail and run this script! 

[reflection.assembly]::LoadFile("C:\Program Files (x86)\EASendMail\Lib\net20\EASendMail.dll")
#change the path to the EASendMail.dll file if you have another build of run-time assembly for .NET Framework, .NET Core, or .NET Compact Framework

function SendMailTo($sendFrom, $name, $address, $subject, $body, $htmlFormat) {

    $mail = New-Object EASendMail.SmtpMail("TryIt") # you can replace “TryIt” with your license code for EASendMail SMTP component
    $mail.From.Address = $sendFrom

    $recipient = New-Object EASendMail.MailAddress($name, $address)
    $mail.To.Add($recipient) > $null

    $mail.Subject = $subject
    if($htmlFormat) {
        $mail.HtmlBody = $body
    }
    else {
        $mail.TextBody = $body
    }

    $server = New-Object EASendMail.SmtpServer("smtp.gmail.com")
    $server.User = "YourMail@mail.com"
    $server.Password = "Password"

    $server.Port = 587

    $server.ConnectType = [EASendMail.SmtpConnectType]::ConnectTryTLS
# specify your settings of the SMTP server, username, password, port, and connection type

    $smtp = New-Object EASendMail.SmtpClient
    $smtp.SendMail($server, $mail)
}

function SendMailFromPowerShell () {
    $sendFrom = "SenderMail@mail.com"
    $name = "Agent Alarm Server"
    $address = "ReceiverEmail@mail.com"
    $subject = "Sending messages from a PowerShell script!"
    $body = "Try it out!"
# specify your settings of sender’s email address and name, recipient’s email address, as well as subject and body text of the message
    try {
        "Start to send email to {0} ..." -f $address
        SendMailTo $sendFrom $name $address $subject $body ""
        "Email to {0} has been submitted to server!" -f $address
    }
    catch [System.Exception] {
        "Failed to send email: {0}" -f  $_.Exception.Message
    }
}

SendMailFromPowerShell








