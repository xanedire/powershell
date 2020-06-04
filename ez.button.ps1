#creates a red 'easy button'

#target - %windir%\system32\WindowsPowerShell\v1.0\PowerShell.exe -windowstyle hidden -file "\\<#path to script#>\ez.button.ps1"
#create shortcut - start in: %windir%\system32\WindowsPowerShell\v1.0

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")  
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Windows.Forms.Application]::EnableVisualStyles()

$Form = New-Object system.Windows.Forms.Form
$Form.Size = New-Object System.Drawing.Size(160,80)
$form.MaximizeBox = $false
$Form.StartPosition = 'CenterScreen' 
$Form.FormBorderStyle = 'fixedsingle'
$Form.Opacity = 1
$Form.BackColor = "maroon"
$form.TopMost = $True
$Form.Text = "Easy"

$EZbutton = New-Object System.Windows.Forms.Button 
$EZbutton.Location = New-Object System.Drawing.Size(-10,-20) 
$EZbutton.Size = New-Object System.Drawing.Size(166,105) 
$EZbutton.Text = "E A S Y" 
$Font = New-Object System.Drawing.Font("Stencil",30,[System.Drawing.FontStyle]::Bold) 
$form.Font = $Font 
$Form.Controls.Add($EZbutton)
$EZbutton.Add_Click( 
{ 
    Add-Type -AssemblyName presentationCore
     $filepath = [uri] "$env:userprofile\desktop\ez_button\ez.mp3" #ensure 'ez.mp3' is in this location
     $wmplayer = New-Object System.Windows.Media.MediaPlayer
     $wmplayer.Open($filepath)
     Start-Sleep 1
     $duration = $wmplayer.NaturalDuration.TimeSpan.TotalSeconds
     $wmplayer.Play()
     Start-Sleep $duration
     $wmplayer.Stop()
     $wmplayer.Close()
} 
)
$Form.Controls.Add($EZbutton)

<# showdialog @ end #>
$Form.ShowDialog()
<# showdialog @ end #>