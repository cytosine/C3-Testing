. 'C:\temp\userenv.ps1'
. "c:\Program Files\osmosix\service\utils\agent_util.ps1"
$username=$ENV:username
$password=$ENV:password

net user $username $password /add /passwordreq:yes
net localgroup Administrators $username /add


function Generate-Password {
$alphabets= "abcdefghijklmnopqstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()"

$char = for ($i = 0; $i -lt $alphabets.length; $i++) { $alphabets[$i] }

for ($i = 1; $i -le 9; $i++)
{
$TempPassword+=$(get-random $char)
}
return $TempPassword
}


$Password = Generate-Password

$admin = [ADSI]("WinNT://localhost/Administrator,user")
$admin.psbase.invoke("SetPassword", $Password)
$admin.psbase.CommitChanges()


#Send-NetworkData -Data "Administrator password is reset to $Password","" -Computer 127.0.0.1 -Port 8848 
agentSendLogMessage "Administrator password is reset to $Password" 
Get-Content "C:\temp\userenv.ps1" | %{$_ -creplace $ENV:password, ''} | Set-Content "C:\temp\userenv1.ps1"
. 'C:\temp\userenv1.ps1'
Remove-Item -Force C:\temp\userenv.ps1
Move-Item -Force C:\temp\userenv1.ps1 C:\temp\userenv.ps1
