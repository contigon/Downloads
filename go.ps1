<#	
	.NOTES
	===========================================================================
	 Created on:   	2/24/2020 1:11 PM
	 Created by:   	Omerf
	 Organization: 	Israel Cyber Directorate
	 Filename:     	Cybergo.ps1
	===========================================================================
	.DESCRIPTION
		Cyber Audit Tool - Cyber Audit tool launch from www Script
#>

# remote install command:
#Invoke-Expression (New-Object System.Net.WebClient).DownloadString('http://cyberaudittool.c1.biz/go.ps1')
#Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/contigon/Downloads/master/go.ps1')
$zipURLA = "https://raw.githubusercontent.com/contigon/Downloads/master/go.pdf"
$zipURLB = "http://cyberaudittool.c1.biz/go.pdf"

$Host.UI.RawUI.WindowTitle = "Cyber Audit Tool 2020 - Installing...."
$Host.UI.RawUI.BackgroundColor = ($bckgrnd = "Black")
$Host.UI.RawUI.ForegroundColor = "White"
$BufferSize = $Host.UI.RawUI.BufferSize
$BufferSize.Height = 500
$Host.UI.RawUI.BufferSize = $BufferSize

#Clean the Scoop environment variables from Path,GIT_SSH,SCOOP_GLOBAL,SCOOP,GIT_INSTALL_ROOT,JAVA_HOME,PSModulePath
function ScoopCleanEnv(){
    
    Get-ChildItem env: |  ? value -Match "scoop"

    #variables that can be deleted
    $delVars = @("SCOOP","SCOOP_GLOBAL","GIT_INSTALL_ROOT","GIT_SSH")
    foreach ($delVar in $delVars) {
        Write-Host "Deleting [$delVar] from Environment Variables" -ForegroundColor Green
        [Environment]::SetEnvironmentVariable($delVar,$null,"USER")
        [Environment]::SetEnvironmentVariable($delVar,$null,"MACHINE")
    }

    #Variables that needs to remove scoop from their paths
    $remVars = @("Path","JAVA_HOME","PSModulePath")
    foreach ($remVar in $remVars) {
        if ([System.Environment]::GetEnvironmentVariable($remVar,'USER') -match "Scoop") {
                $PathsUser = [System.Environment]::GetEnvironmentVariable($remVar,'USER').split(";")
            }
        if ([System.Environment]::GetEnvironmentVariable($remVar,'MACHINE') -match "Scoop") {
            $PathsMachine = [System.Environment]::GetEnvironmentVariable($remVar,'MACHINE').split(";")
            }
        $cleanPathsUser = $null
        $cleanPathsMachine = $null
        
        foreach ($path in $PathsUser) {
            if (!$path.Contains("Scoop"))
                {
                $cleanPathsUser += "$Path;"
                }    
             }

        foreach ($path in $PathsMachine) {
            if (!$path.Contains("Scoop"))
                {
                $cleanPathsMachine += "$Path;"
                }
        }
       
       if ($cleanPathsUser -match ";") { $cleanPathsUser = $cleanPathsUser.Replace(";;",";") }
       if ($cleanPathsMachine -match ";") { $cleanPathsMachine = $cleanPathsMachine.Replace(";;",";") }
       Write-Host "$remVar [User] = $cleanPathsUser" -ForegroundColor Yellow   
       Write-Host "$remVar [Machine] = $cleanPathsMachine" -ForegroundColor Yellow
       #[Environment]::SetEnvironmentVariable($remVar,$cleanPathsUser,"USER")
       #[Environment]::SetEnvironmentVariable($remVar,$cleanPathsMachine,"MACHINE")
  }

    if(Get-ChildItem env: |  ? value -Match "scoop") {
        Write-Host ""
        Write-Host "Cleaning the Environment Variables failed, Please try manually" -ForegroundColor Red
    }
    else {
        Write-Host ""
        Write-Host "Cleaning the Environment Variables was successfull" -ForegroundColor Green
    }
}

function ShowINCD() {
$incd = @"               

                                                         
                         ..,co88oc.oo8888cc,..
  o8o.               ..,o8889689ooo888o"88888888oooc..
.88888             .o888896888".88888888o'?888888888889ooo....
a888P          ..c6888969""..,"o888888888o.?8888888888"".ooo8888oo.
088P        ..atc88889"".,oo8o.86888888888o 88988889",o888888888888.
888t  ...coo688889"'.ooo88o88b.'86988988889 8688888'o8888896989^888o
 888888888888"..ooo888968888888  "9o688888' "888988 8888868888'o88888
  ""G8889""'ooo888888888888889 .d8o9889""'   "8688o."88888988"o888888o .
           o8888'""""""""""'   o8688"          88868. 888888.68988888"o8o.
           88888o.              "8888ooo.        '8888. 88888.8898888o"888o.
           "888888'               "888888'          '""8o"8888.8869888oo8888o .
      . :.:::::::::::.: .     . :.::::::::.: .   . : ::.:."8888 "888888888888o
                                                        :..8888,. "88888888888.
                                                        .:o888.o8o.  "866o9888o
                                                         :888.o8888.  "88."89".
                                                        . 89  888888    "88":.
                   CyberAuditTool [CAT]                 :.     '8888o
                 Israel Cyber Directorate                .       "8888..
                   Prime Ministers Office                          888888o.
                     V1.0 (08-03-2020)                              "888889,
                                                             . : :.:::::::.: :.


"@
Write-Host $incd -ForegroundColor Green
}

ShowINCD

function checkAdmin {
    $admin = [security.principal.windowsbuiltinrole]::administrator
    $id = [security.principal.windowsidentity]::getcurrent()
    ([security.principal.windowsprincipal]($id)).isinrole($admin)
}

if (checkAdmin) {
    Write-Host "[Passed] Checking for Administrator creadentials" -ForegroundColor Green
}
else
{
    Write-Host "[Failed] Checking for Administrator creadentials" -ForegroundColor red
    Read-Host "Press [Enter] to quit the installation and start again in Elevated Powershell console"
    break
}

#Downloding the CyberAuditTool Files (compressed/zip and renamed to CyberAuditTool.pdf)
Function Get-Folder($initialDirectory) {
    [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    $FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderBrowserDialog.RootFolder = 'MyComputer'
    if ($initialDirectory) { $FolderBrowserDialog.SelectedPath = $initialDirectory }
    [void] $FolderBrowserDialog.ShowDialog()
    return $FolderBrowserDialog.SelectedPath
}

Write-Host "Browse and Create a new path for the installation..."
$BasePath = Get-Folder
While([bool](Get-ChildItem $BasePath)){
    if ([string]::IsNullOrEmpty($BasePath)) {
        exit
    }
    write-host "[Fail] The folder $BasePath is not empty" -ForegroundColor Red
    Write-Host "Would you like to empty the chosen folder?(y\[N]) If the answer is No, you must choose an empty folder" -ForegroundColor Yellow
    $input = Read-Host 
    if ($input -eq "y"){
        Get-ChildItem -Path $BasePath | foreach { rm -Recurse $BasePath\$_ -Force}
        if ([bool](Get-ChildItem $BasePath)) {
             write-host "[Fail] Failed to delete all files. Please delete manualy" -ForegroundColor Red
             read-host “Press ENTER to continue (or Ctrl+C to quit)”
        }
    } else {
        Write-Host "Please choose a different folder"
        $BasePath = ""
        $BasePath = Get-Folder
    }
}
write-host "[Success] The folder $BasePath is empty" -ForegroundColor Green
Set-Location $BasePath

function Get-UserAgent() {
    return "CyberAuditTool/1.0 (+http://cyberaudittool.c1.biz/) PowerShell/$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor) (Windows NT $([System.Environment]::OSVersion.Version.Major).$([System.Environment]::OSVersion.Version.Minor); $(if($env:PROCESSOR_ARCHITECTURE -eq 'AMD64'){'Win64; x64; '})$(if($env:PROCESSOR_ARCHITEW6432 -eq 'AMD64'){'WOW64; '})$PSEdition)"
}

function fname($path) { split-path $path -leaf }
function strip_ext($fname) { $fname -replace '\.[^\.]*$', '' }
function strip_filename($path) { $path -replace [regex]::escape((fname $path)) }
function strip_fragment($url) { $url -replace (new-object uri $url).fragment }
function url_filename($url) {
    (split-path $url -leaf).split('?') | Select-Object -First 1
}

function dl($url,$to) {
    $wc = New-Object Net.Webclient
    $wc.headers.add('Referer', (strip_filename $url))
    $wc.Headers.Add('User-Agent', (Get-UserAgent))
    $wc.downloadFile($url,$to)
}

# download CyberAuditTool sources in pdf/zip format
try {
    $zipfile = "$BasePath\go.pdf"
    Write-Host "Trying to Download Cyber Audit Tool from $zipurlA to $BasePath"
    dl $zipurlA $zipfile
    }
catch {
    Write-Host "[Failed] Error connecting to 1st download site, trying 2nd download option"
    $zipfile = "$BasePath\go.pdf"
    Write-Host "Trying to Download Cyber Audit Tool from $zipurlB to $BasePath"
    dl $zipurlB $zipfile
    }

Write-Output 'Extracting Cyber Audit Tool core files...'
Add-Type -Assembly "System.IO.Compression.FileSystem"
[IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $BasePath) 

Write-Host "Checking computer for minimal installation requirements "

#Check Powershell version
$PSver = $PSVersionTable.PSVersion.Major
if (($PSVersionTable.PSVersion.Major) -lt 5) {
    Write-Host "[Failed] PowerShell 5.1 is required to run CyberAuditTool installation" -ForegroundColor Red
    Read-Host "Press Enter to quit and open you browser for more help on how to upgrade"
    Start-Process "https://www.microsoft.com/en-us/download/details.aspx?id=54616"
    break
} 
else
{
    Write-Host "[Passed] Powershell version is $PSver" -ForegroundColor Green
}

# show notification to change execution policy:
$allowedExecutionPolicy = @('Unrestricted', 'RemoteSigned', 'ByPass')
$execPolicy = (Get-ExecutionPolicy).ToString()
if ((Get-ExecutionPolicy).ToString() -notin $allowedExecutionPolicy) {
    Write-Host "[Failed] PowerShell requires an execution policy in [$($allowedExecutionPolicy -join ", ")] to run the CyberAuditTool" -ForegroundColor Red
    Write-Host "Please run this command from an elevated powershell console: Set-ExecutionPolicy Unrestricted" -ForegroundColor Yellow
    break
}
else
{
    Write-Host "[Passed] Powershell Execution Policy is $execPolicy" -ForegroundColor green
}

#Check .Net version
if ([System.Enum]::GetNames([System.Net.SecurityProtocolType]) -notcontains 'Tls12') {
    Write-Host "[Failed] CyberAuditTool installation requires at least .NET Framework 4.5" -ForegroundColor Red
    Write-Host "Download latest .Net for your system and install before continuing with the installation" -ForegroundColor Yellow
    Read-Host "Press Enter to quit installation and open the browser for more help"
    Start-Process "https://dotnet.microsoft.com/download/dotnet-framework"
    break
}
else
{
    Write-Host "[Passed] Minimal Microsoft .Net version was found"  -ForegroundColor Green
}

# Checking if scoop is already installed, if so we will uninstall it and remove scoop from environment variables
if (Get-Command scoop -ErrorAction SilentlyContinue)
 {
    Write-Host "[Failed] Scoop needs to be uninstalled before we can continue with installation" -ForegroundColor Red
    $input = Read-host "Press [U] to uninstall or [Enter] to continue without uninstalling scoop"
    If ($input -eq "U") {
        scoop uninstall scoop
        ScoopCleanEnv
        }
} 
else 
{
    write-host "[Passed] Scoop is not installed on this computer, It will be installed later on" -f Green
}

Write-Host "We will continue to the CyberAuditTool Build script" -ForegroundColor Green
$ScriptToRun = $BasePath+"\CyberBuild.ps1"
&$ScriptToRun

