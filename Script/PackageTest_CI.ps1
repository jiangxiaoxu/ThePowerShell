$dir= git rev-parse --show-toplevel
Set-Location $dir

$UATDir=$env:UnrealEnginePathForCI+"\Engine\Build\BatchFiles\RunUAT.bat"

$UProjecFileDir=$(Resolve-Path .\PaladinSeven.uproject).ToString()
$ProjectFolder=$(Resolve-Path .\).ToString()

 if(Test-Path $UATDir)
         {
           & $UATDir "-ScriptsForProject=$UProjecFileDir" BuildCookRun -nocompileeditor -nop4 "-project=$UProjecFileDir" -stage -archive "-archivedirectory=$ProjectFolder" -package -clientconfig=Development -ue4exe="UE4Editor-Cmd.exe" -pak -prereqs -nodebuginfo -targetplatform=Win64 -build -cook -map=EmptyMapForCook -cmdline="EmptyMapForCook -Messaging" -utf8output -compile
            
           exit $LASTEXITCODE
         } 
         else
         {
          Write-Output "GG Can not Found RunUAT.bat" 
           exit -1
         }


         