#Required Input
$Cred = Get-Credential "tfayd\206503004"
$RunbookInputValue = $Env:OSMOSIX_PRIVATE_IP

#Other Input
$ScorchServer="3.3.84.227"
$RunBookName = "Cliqr - IIS 8x Installation"

# Get RunBook ID
$ScorchURI        = "http://$($ScorchServer):81/Orchestrator2012/Orchestrator.svc/Runbooks?`$filter=Name eq '$RunBookName'" 
$ResponseObject = invoke-webrequest -Uri $ScorchURI -method Get -Credential $Cred
$XML            = [xml] $ResponseObject.Content
$RunbookGUIDURL = $XML.feed.entry.id

write-host "Runbook GUID URI = " $RunbookGUIDURL

$RunbookID = $RunbookGUIDURL.Substring($RunbookGUIDURL.Length - 38,36)
write-host "RunbookID = " $RunbookID 

#Runbook Parameter (change as needed)
#$RetreivedGUID="127e052a-046a-453e-b433-658497f2a737"
$RetreivedGUID="eb9c1cf8-5d09-4749-971f-de07de2fa3c3"

$POSTBody = @"
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<entry xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns="http://www.w3.org/2005/Atom">
<content type="application/xml">
<m:properties>
<d:RunbookId type="Edm.Guid">{$($RunbookID)}</d:RunbookId>
<d:Parameters>&lt;Data&gt;&lt;Parameter&gt;&lt;ID&gt;{$($RetreivedGUID)}&lt;/ID&gt;&lt;Value&gt;$($RunbookInputValue)&lt;/Value&gt;&lt;/Parameter&gt;&lt;/Data&gt;</d:Parameters>
</m:properties>
</content>
</entry>
"@

# Submit Orchestrator Request
$ScorchURI = "http://$($ScorchServer):81/Orchestrator2012/Orchestrator.svc/Jobs/"
write-host "POST request URI " $ScorchURI 
 
$ResponseObject = invoke-webrequest -Uri $ScorchURI -method POST -Credential $Cred -Body $POSTBody -ContentType "application/atom+xml" 
 
#Retrieve the Job ID from the submitted request
$XML               = [xml] $ResponseObject.Content
$RunbookJobURL     = $XML.entry.id

write-host "Runbook Job URI " $RunbookJobURL

