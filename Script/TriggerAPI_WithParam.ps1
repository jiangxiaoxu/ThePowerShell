
param([switch]$UseCITag)

$CI_Compile_BinaryTag='ci_compile_binary'
if($UseCiTag)
{
 $Ref = $CI_Compile_BinaryTag
}
else 
{
    $BranchName = git for-each-ref --format="%(upstream:short)" $(git symbolic-ref -q HEAD)
    if ($BranchName.length -le 7)
    {
      echo "not valid Remote BranchName ,exit....."
      exit -1 
    }
    $Ref = $BranchName.Trim().Substring(7)
}


$Body = @{
    token="1c6a73ed4f419f6fa8cb889d6b16d9";
    ref = $Ref;
    "variables[ManualTrigger]"="true";
}
echo $Body 

Invoke-WebRequest -Method Post -Uri "http://gitlab.softstar.com/api/v4/projects/3/trigger/pipeline" -Body $Body -UseBasicParsing