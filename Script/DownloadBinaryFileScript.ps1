#$my66=New-Object object

#Add-Member -InputObject $my66 -MemberType NoteProperty -Name $env:CI_COMMIT_REF_NAME -Value $env:CI_JOB_ID -Force

#$json=ConvertTo-Json -InputObject $my66 
#Out-File -InputObject $json -FilePath './ttt.json' -Encoding 'utf8'

#$artifactsURL=$env:CI_PROJECT_URL + '/-/jobs/' + $env:CI_JOB_ID + '/artifacts/download'

#echo $env:CI_PROJECT_URL
#echo $env:CI_JOB_ID
#echo $json
#echo $env:CI_JOB_TOKEN 

#$src = 'http://paladinserver.viphk.ngrok.org/root/PaladinSeven/-/jobs/134/artifacts/download'
#$des = '.\art.zip'

#Invoke-WebRequest -Uri $src -OutFile $des

#http://gitlab.softstar.com/root/PaladinSeven/-/jobs/134/artifacts/download


#ttp://paladinserver.viphk.ngrok.org/root/PaladinSeven/-/jobs/189/artifacts/download
#http://paladinserver.viphk.ngrok.org/root/PaladinSeven/-/jobs/134/artifacts/download

#http://paladinserver.viphk.ngrok.org/root/PaladinSeven/-/jobs/artifacts/<ref>/download?job=<job_name>

#http://paladinserver.viphk.ngrok.org/root/PaladinSeven/-/jobs/artifacts/GameDev/download?job=schedules-DistributeBinariesBuild

#$select0 = Read-Host "if you want download current upstream binary file,please input '1' key  ,or you want download  [$CI_Compile_BinaryTag] binary file please input 2 (usually you need input '2' key)" 

#TOKEN

chcp 65001

$dir= git rev-parse --show-toplevel
Set-Location $dir

$CI_Compile_BinaryTag='ci_compile_binary'

$BranchName = git for-each-ref --format="%(upstream:short)" $(git symbolic-ref -q HEAD)

if ($BranchName.length -le 7)
{
    echo "not valid Remote BranchName ,exit....."
    exit -1 
}

$UsedBranchName=$BranchName.Trim().Substring(7)
echo "Current upstream Branch name is:[$BranchName]" 

if ($UsedBranchName.Contains("develop-artist"))
 {
    $UsedCommitRef=$CI_Compile_BinaryTag  
}
else
{
    $UsedCommitRef=$UsedBranchName
}

echo "UsedCommitRef is:[$UsedCommitRef]" 

$ProgressPreference='silentlycontinue'

$url= "http://gitlab.softstar.com/api/v4/projects/3/jobs?scope[]=success&per_page=200"

$MyHeader= @{"PRIVATE-TOKEN"="7RNcvhf364KoPMcGtnLf"}
$rceceived = Invoke-WebRequest -UseBasicParsing -Headers $MyHeader -Uri $url 

$JsonData = ConvertFrom-Json -InputObject $rceceived.Content

$usedjob = $JsonData.Where( { (($_.ref -eq $UsedCommitRef)) -and ( (Get-Member -inputobject $_ -name "artifacts_file" ) -ne $null )},'first')

 if($null -eq $usedjob)
{
    echo "downloading artifacts failed,jot id can not found"

    echo "Finished ,press Any key to exit" 
    [Console]::Readkey() >$null
    Exit
}

echo "UsedJob is $usedjob"

$TempFilePath=".\.BinaryFile.zip"
$DownloadURL="http://gitlab.softstar.com/root/PaladinSeven/-/jobs/$($usedjob.id)/artifacts/download" 

echo "downloading artifacts...   from gitlab.softstar.com to $TempFilePath ,DownloadURL is $DownloadURL"

Invoke-WebRequest -UseBasicParsing -Headers $MyHeader -Uri $DownloadURL -OutFile $TempFilePath

if((Test-Path -Path $TempFilePath) -and ( (Get-Item $TempFilePath).length -gt 1000kb) )
{
 echo "successfully download "   
 Remove-Item -Path .\Binaries\Win64\*.target -ErrorAction "SilentlyContinue"
 Remove-Item -Path .\Binaries\Win64\*.dll -ErrorAction "SilentlyContinue"
 Remove-Item -Path .\Binaries\Win64\*.pdb -ErrorAction "SilentlyContinue"
 Remove-Item -Path .\Binaries\Win64\*.modules -ErrorAction "SilentlyContinue"

 Remove-Item -Path .\Plugins\*\Binaries\Win64\*.dll -ErrorAction "SilentlyContinue"
 Remove-Item -Path .\Plugins\*\Binaries\Win64\*.pdb -ErrorAction "SilentlyContinue"
 Remove-Item -Path .\Plugins\*\Binaries\Win64\*.modules -ErrorAction "SilentlyContinue"

 Remove-Item -Path .\Plugins\Runtime\*\Binaries\Win64\*.dll -ErrorAction "SilentlyContinue"
 Remove-Item -Path .\Plugins\Runtime\*\Binaries\Win64\*.pdb -ErrorAction "SilentlyContinue"
 Remove-Item -Path .\Plugins\Runtime\*\Binaries\Win64\*.modules -ErrorAction "SilentlyContinue"

 echo "successfully remove exist BinaryFile"

 Expand-Archive -Path $TempFilePath -DestinationPath .\ -Force
 echo "successfully Expand ZIP"
 
}
else 
{
 echo "Couldn't download file or download file size too small,not valid."  
}

if(Test-Path -Path $TempFilePath )
{
    Remove-Item -Path $TempFilePath
    echo "successfully delete download File"
}
echo "Finished ,press Any key to exit" 
[Console]::Readkey() >$null
Exit

