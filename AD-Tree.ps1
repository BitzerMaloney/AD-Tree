Param ( 
	[Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="DN of the OU.")]
	[string]$searchBase,
	[ValidateSet("Green","Red","Blue","White","Black")]
	[string]$TreeColour = "Green"
)

Function Get-OUNesting ([string]$identity, [int]$level, [bool]$lastOuOfTheLevel){
	$OU = $null
	$OU = Get-ADObject -SearchBase $identity -Filter * -SearchScope Base
	if ($lastOUAtALevelFlags.Count -le $level){
		$lastOUAtALevelFlags = $lastOUAtALevelFlags + 0
	}
	if ($OU -ne $null){
		for ($i = 0; $i -lt $level - 1; $i++){
		if ($lastOUAtALevelFlags[$i] -ne 0){
			Write-Host -ForegroundColor $TreeColour -NoNewline "  "
		} else {
			Write-Host -ForegroundColor $TreeColour -NoNewline "│ "
		}
	}
	if ($level -ne 0){
		if ($lastOUOfTheLevel){
			Write-Host -ForegroundColor $TreeColour -NoNewline "└─"
		} else { 
			Write-Host -ForegroundColor $TreeColour -NoNewline "├─"
		}
	}
	Write-Host -ForegroundColor $TreeColour $($OU.Name)

	}
	$subOUs = Get-ADObject -SearchBase $OU.distinguishedName -SearchScope OneLevel -Filter {objectClass -eq "organizationalUnit"} | Select-Object -ExpandProperty distinguishedName
	$subOUCount = $subOUs.count
	if ($SubOUCount -gt 0){
		$maxMemberOULevel = 0
		$count = 0
		ForEach ($ouDN in $subOUs){
			$count++
			$lastOUOfThisLevel = $false
			if($count -eq $subOUCount){
				$lastOUOfThisLevel = $true
				$lastOUAtALevelFlags[$level] = 1
			}
			Get-OUNesting -Identity $ouDN -Level $($level+1) -lastOUOfTheLevel $lastOUOfThisLevel
		}
		$level = $maxMemberOULevel
	}
}

$lastOUAtALevelFlags = @() 
$level = 0

$OUobj = Get-ADObject -SearchBase $searchBase -Filter * -SearchScope Base
if ($OUObj){
	Get-OUNesting -Identity $searchBase -Level 0 -lastOuOfTheLevel $false
} 