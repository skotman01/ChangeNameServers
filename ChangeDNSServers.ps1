$NewDNSAddresses = "192.168.2.31","192.168.2.32"

Function Write-Log{
    param(
        [Parameter(Mandatory=$True,Position=0,ValueFromPipeline=$True)]
        [alias("message")]
        [string]$LogData,
        [Parameter(Mandatory=$False,Position=1)]
        [alias("foregroundcolor","FGC")]
        [string]$FGColor="white",
        [Parameter(Mandatory=$False,Position=2)]
        [alias("backgroundcolor","BGC")]
        [string]$BGColor="black"
        )
 
    $LogData = ((Get-Date -Format o) + " " + $LogData)
    add-content $Logfile $LogData
    Write-Host $LogData -foregroundcolor $FGColor -backgroundcolor $BGColor
}

Function Select-Folder {
    param(
        [Parameter(Mandatory=$True,Position=0)]
		[string[]]$Description        
    )
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $SelectFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $SelectFolderDialog.Description = $Description
    $SelectFolderDialog.ShowDialog() | Out-Null
    $SelectFolderDialog.SelectedPath
}

Function Get-FileName {
    param(
        [Parameter(Mandatory=$True,Position=0)]
		[alias("directory")]
		[string[]]$initialdirectory        
    )
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = $initialdirectory
#    $OpenFileDialog.Filter = "CSV (*.CSV)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.FileName
}
 
$TimeStamp = (Get-Date -Format o |forEach-Object {$_ -replace ":","."}) + "-"
$LogName = $MyInvocation.MyCommand.Name.TrimEnd("ps1") + "log"
$LogPath = $PSScriptRoot
$LogFile = $LogPath + $Timestamp + $LogName

$Servers = Import-CSV $(Get-FileName C:\temp)

#$ServerCredentials = Get-Credential -Message "Enter credentials for servers selected"

ForEach ($Server in $Servers){
    $ServerAddresses = Get-DnsClientServerAddress -AddressFamily IPv4 -CimSession $Server.ServerName
    ForEach ($ServerAddress in $ServerAddresses){
        If ($ServerAddress.ServerAddresses -contains "192.168.2.15"){
            Write-host "Found Address...need to change, Changing interface ($($ServerAddress.InterfaceIndex))"
            Set-DnsClientServerAddress -InterfaceIndex $ServerAddress.InterfaceIndex -Addresses $NewDNSAddresses -CimSession $Cim
        }
    }
}