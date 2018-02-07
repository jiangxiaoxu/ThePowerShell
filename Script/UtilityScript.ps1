function OpenProject-Development() 
{
    $dir= git rev-parse --show-toplevel
    $UE4EditorDir= Resolve-Path -Path "$dir\..\Paladin-UnrealEngine\Engine\Binaries\Win64\UE4Editor.exe"
    $UprojectFileDir =Resolve-Path -Path "$dir\PaladinSeven.uproject"

    & $UE4EditorDir $UprojectFileDir
}




function SendEmailTo($To,[Parameter(Mandatory=$false)][array]$Cc,$Subject,$Body)
{
#  Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject `
#  -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl `
#  -Credential (Get-Credential) -Attachments $Attachment

#$CC="jiangxiaoxu_soft@foxmail.com","jxx732598913@hotmail.com","jiangxiaoxu@softstar.net.cn"

$ss=ConvertTo-SecureString -String "Softstar168xj" -AsPlainText -force
$ss|Write-Host
$cre= New-Object System.Management.Automation.PSCredential("pal7service@softstar.net.cn",$ss)

    if( $PSBoundParameters.ContainsKey('Cc') -and $Cc)
    {
       Send-MailMessage -SmtpServer "smtp.exmail.qq.com" -UseSsl -Port 25 -Body $Body -Subject $Subject -To $To -Cc $CC -From "pal7service@softstar.net.cn" -Credential $cre
    }
    else
    {
        Send-MailMessage -SmtpServer "smtp.exmail.qq.com" -UseSsl -Port 25 -Body $Body -Subject $Subject -To $To -From "pal7service@softstar.net.cn" -Credential $cre
    }
}


function GetEmailArray ($InCCString) {
    $CCArray=$InCCString.Trim().split("|",[StringSplitOptions]::RemoveEmptyEntries)|Where-Object {$_.Trim() -ne ''} ;
  return $CCArray;
}


function TriggerCIByUpstreamAndSendEmail([String]$EmailTo, [Parameter(Mandatory=$false)][String]$EmailCc)
{
        $BranchName = git for-each-ref --format="%(upstream:short)" $(git symbolic-ref -q HEAD)
        if ($BranchName.length -le 7)
        {
          echo "not valid Remote BranchName ,exit....."
          exit -1 
        }
        $Ref = $BranchName.Trim().Substring(7)
    
    $Body = 
    @{
        token="1c6a73ed4f419f6fa8cb889d6b16d9";
        ref = $Ref;
        "variables[bSendEmail]"=$True;
        "variables[EmailTo]"=$EmailTo;
    }

    if( $PSBoundParameters.ContainsKey('EmailCc') -and $EmailCc)
    {
        $Body["variables[EmailCc]"]=$EmailCc;
    }  

    echo $Body   
    Invoke-WebRequest -Method Post -Uri "http://gitlab.softstar.com/api/v4/projects/3/trigger/pipeline" -Body $Body -UseBasicParsing
}


function TriggerCIByUpstreamAndSendDefaultNotifyEmail()
{
   # . .\..\Script\UtilityScript.ps1

    $CC="askavsk@softstar.net.cn|duyu@softstar.net.cn|wuguangzhi@softstar.net.cn|qianjiaming@softstar.net.cn|ryuzaki@softstar.net.cn"; 
    
    $To="732598913@qq.com"

    TriggerCIByUpstreamAndSendEmail -EmailTo $To  -EmailCc $CC
}