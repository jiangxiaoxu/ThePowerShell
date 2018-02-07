function SendDistributeSuccessEmail 
{
  . .\Script\UtilityScript.ps1

  if ($env:bSendEmail -ne $True)
   {
    echo "Not Send Email"
     exit $LASTEXITCODE
   }
   
   echo "Send Email"
   
  if($env:EmailTo)
  {
    $ToArray = GetEmailArray $env:EmailTo
  } 
  
  if($env:EmailCc)   
  {
     $CcArray = GetEmailArray $env:EmailCc
  } 
  

  if ($ToArray -and $ToArray.Count -gt 0)
  {  
    echo "Send to $ToArray count: $($ToArray.Count) " 
  
    if ($CcArray -and $CcArray.Count -gt 0) 
    {
      echo "Cc to $CcArray count: $($CcArray.Count)" 
  
      SendEmailTo -To $ToArray -CC  $CcArray -Subject "{{$env:CI_COMMIT_REF_NAME}} Distribute Binaries Successed" -Body "{{$env:CI_COMMIT_REF_NAME}} Distribute Binaries Successed"
    }
    else
    {
      SendEmailTo -To $ToArray -Subject "{{$env:CI_COMMIT_REF_NAME}} Distribute Binaries Successed" -Body "{{$env:CI_COMMIT_REF_NAME}} Distribute Binaries Successed"
    }   
  }          

}


$dir= git rev-parse --show-toplevel
Set-Location $dir

$BuildBatDir=$env:UnrealEnginePathForCI+"\Engine\Build\BatchFiles\Build.bat"
$CleanBatDir=$env:UnrealEnginePathForCI+"\Engine\Build\BatchFiles\Clean.bat"



if((Test-Path $CleanBatDir) -ne $True)
{
  Write-Output "GG Can not Found Clean.bat"  
  exit -1
}

if((Test-Path $BuildBatDir) -ne $True)
{
  Write-Output "GG Can not Found Build.bat"  
  exit -1
}

& $CleanBatDir PaladinSevenEditor Win64 Development $(Resolve-Path .\PaladinSeven.uproject).ToString() -waitmutex

if(!$?) 
{
  exit $LASTEXITCODE
}

& $BuildBatDir PaladinSevenEditor Win64 Development $(Resolve-Path .\PaladinSeven.uproject).ToString() -waitmutex

if(!$?) 
{
  exit $LASTEXITCODE
}

SendDistributeSuccessEmail

exit $LASTEXITCODE





