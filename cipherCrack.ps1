
$original = "abcdefghijklmnopqrstuvwxyz"
$original += $original.ToUpper()

clear
while ($true)
{
	$messageFile = Read-Host -Promt "Enter filename to read: "
	# Check if file exists
	if ( Test-Path -PathType Leaf $messageFile )
	{
		[string]$secretMessage = Get-Content -Path $messageFile
		break
	}
	else
	{
		clear
		Write-Host "Could not find or open file with that name... Please try again."
	}
}

clear
$attempts = 0
while ($true)
{
	Write-Host "The encrypted message is: " -NoNewLine
	Write-Host $secretMEssage -Foreground Yellow
	
	$rotate = Read-Host -Prompt "Please provide the rotation key value: "
	$shift = $original.Substring($rotate)
	$shift += $original.Substring(0, $rotate)
	
	$cipher = ""
	foreach ($c in $secretMessage.ToCharArray())
	{
		if ($shift.Contains($c))
		{
			$cipher += $original[$shift.IndexOf($c)]
		}
		else
		{
			$cipher += $c
		}
	}
	
	Write-Host $cipher -Foreground Yellow
	$attempts += 1
	
	Write-Host "Did you get the result you wanted? (Y/N)"
	$tryAgain = Read-Host
	
	if ( $tryAgain -eq "Y" -or $tryAgain -eq "y" )
	{
		break
	}
	else
	{
		clear
		Write-Host "Let's try a different shift value."
		if ( $attempts -gt 3 )
		{
			Write-Host "Try examining the most common letter assuming that is e" -ForegroundColor Red
			$attempts = 0
		}
	}
}
