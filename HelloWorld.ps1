. 'C:\temp\userenv.ps1'
. "c:\Program Files\osmosix\service\utils\agent_util.ps1"

$strString = "Hello World"
write-host $strString


$RunbookInputValue = $Env:OSMOSIX_PRIVATE_IP

write-host $RunbookInputValue
