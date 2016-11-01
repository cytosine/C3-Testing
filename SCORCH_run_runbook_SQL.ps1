#Required Input
$Cred = Get-Credential "tfayd\206503004"

$RunbookInputValue1="E"
$RunbookInputValue2=$Env:OSMOSIX_PRIVATE_IP
$RunbookInputValue3="Cliqr_POC"
$RunbookInputValue4=""
$RunbookInputValue5="S"
$RunbookInputValue6=""
$RunbookInputValue7="SP1"



#
# SQL Component ["E" or "R"]
$RunbookInputParameter1 = "a0157eff-4e4a-4420-8fde-46c14bad1ab6"
# Remote Target Machine FQDN
$RunbookInputParameter2 = "95314bfb-1d2e-4b27-8ed0-8489e0c425c2"
# Applicaton Name
$RunbookInputParameter3 = "1ef4250f-22ca-46c9-8900-87ee9f1d90ba"
# Server Family 
$RunbookInputParameter4 = "d10780a5-ed74-49ff-b1c3-8dba18cd86cc"
# SQL 2014 Edition ["E", "S", or "D"]
$RunbookInputParameter5 = "a5e37479-368c-4048-9b26-a9049e4a897f"
# Pre-Generated Instance Name [Specify if pre-created]
$RunbookInputParameter6 = "cb402b24-453d-4f86-a991-e596de2382b3"
# Service Pack Level ["RTM","SP1"]
$RunbookInputParameter7 = "03ea87b1-ee0e-4d27-922f-fdf3ea6d6861"
#

#Other Input
$ScorchServer="3.3.84.227"
$RunBookName = "Cliqr - SQL Server 2014 Standalone Installation on Windows 2012"
# Get RunBook ID
$ScorchURI        = "http://$($ScorchServer):81/Orchestrator2012/Orchestrator.svc/Runbooks?`$filter=Name eq '$RunBookName'" 
$ResponseObject = invoke-webrequest -Uri $ScorchURI -method Get -Credential $Cred
$XML            = [xml] $ResponseObject.Content
$RunbookGUIDURL = $XML.feed.entry.id

write-host "Runbook GUID URI = " $RunbookGUIDURL

$RunbookID = $RunbookGUIDURL.Substring($RunbookGUIDURL.Length - 38,36)
write-host "RunbookID = " $RunbookID

$ResponseObject = invoke-webrequest -Uri "$($RunbookGUIDURL)/Parameters" -method Get -Credential $Cred
[System.Xml.XmlDocument] $XML = $ResponseObject.Content
 
$POSTBody = @"
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<entry xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns="http://www.w3.org/2005/Atom">
<content type="application/xml">
<m:properties>
<d:RunbookId type="Edm.Guid">{$($RunbookID)}</d:RunbookId>
<d:Parameters>&lt;Data&gt;
&lt;Parameter&gt;&lt;ID&gt;{$($RunbookInputParameter1)}&lt;/ID&gt;&lt;Value&gt;$($RunbookInputValue1)&lt;/Value&gt;&lt;/Parameter&gt;
&lt;Parameter&gt;&lt;ID&gt;{$($RunbookInputParameter2)}&lt;/ID&gt;&lt;Value&gt;$($RunbookInputValue2)&lt;/Value&gt;&lt;/Parameter&gt;
&lt;Parameter&gt;&lt;ID&gt;{$($RunbookInputParameter3)}&lt;/ID&gt;&lt;Value&gt;$($RunbookInputValue3)&lt;/Value&gt;&lt;/Parameter&gt;
&lt;Parameter&gt;&lt;ID&gt;{$($RunbookInputParameter4)}&lt;/ID&gt;&lt;Value&gt;$($RunbookInputValue4)&lt;/Value&gt;&lt;/Parameter&gt;
&lt;Parameter&gt;&lt;ID&gt;{$($RunbookInputParameter5)}&lt;/ID&gt;&lt;Value&gt;$($RunbookInputValue5)&lt;/Value&gt;&lt;/Parameter&gt;
&lt;Parameter&gt;&lt;ID&gt;{$($RunbookInputParameter6)}&lt;/ID&gt;&lt;Value&gt;$($RunbookInputValue6)&lt;/Value&gt;&lt;/Parameter&gt;
&lt;Parameter&gt;&lt;ID&gt;{$($RunbookInputParameter7)}&lt;/ID&gt;&lt;Value&gt;$($RunbookInputValue7)&lt;/Value&gt;&lt;/Parameter&gt;
&lt;/Data&gt;</d:Parameters>
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
