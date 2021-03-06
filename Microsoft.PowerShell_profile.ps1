Set-StrictMode –Version latest
<#
    .NOTES
        Copyright 2012,2013 Robert Nees
        Licensed under the Apache License, Version 2.0 (the "License");
        http://sushihangover.blogspot.com
    .SYNOPSIS
        My PowerShell Personal Profile
    .DESCRIPTION
    .EXAMPLE
    .LINK
        http://sushihangover.blogspot.com
#>

########################################################
# Custom PS-only path settings
function script:append-path {
	$oldPath = get-content Env:\Path
	$newPath = $oldPath + ";" + $args
	set-content Env:\Path $newPath
}
append-path (Join-Path ([environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell")
append-path (Join-Path ([environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell\Modules")
append-path  "C:\Program Files (x86)\Vim\vim73"
########################################################

########################################################
# Load Modules
Import-Module PowerShellPack
Import-Module SushiHangover-Tools
Import-Module SushiHangover-Transcripts
Import-Module SushiHangover-RSACrypto
########################################################

########################################################
# Aliases
Set-Alias grep Process-Grep
set-alias wide format-wide
set-alias which get-command | format-list Path
set-alias vi vim.exe
set-alias edit vim.exe
set-alias gvi gvim.exe
#######################################################

########################################################
# Environment variables
set-item -path env:HOME -value (get-item ([environment]::GetFolderPath("MyDocuments"))).Parent.FullName
$provider = Get-PSProvider filesystem
$provider.Home = $env:HOME

set-item -path env:VISUAL -value "vim.exe"
set-item -path env:GIT_SSH -value "ssh.exe"
########################################################

########################################################
# Helper Functions
function ff ([string] $glob) { get-childitem -recurse -include $glob }
function reboot { shutdown /r /t 5 }
function halt { shutdown /s /t 5 }
function rmd ([string] $glob) { remove-item -recurse -force $glob }
function whoami { (get-content env:\userdomain) + "\" + (get-content env:\username); }
function strip-extension ([string] $filename) { [system.io.path]::getfilenamewithoutextension($filename) } 
########################################################

########################################################
# Prompt
function prompt {
	$nextId = (get-history -count 1).Id + 1;
	$promptText = "[" + $nextId + "] »";

	$wi = [System.Security.Principal.WindowsIdentity]::GetCurrent()
		$wp = new-object 'System.Security.Principal.WindowsPrincipal' $wi

		if ( $wp.IsInRole("Administrators") -eq 1 ) {
			$color = "Red"
			$title = "**ADMIN** - " + (get-location).Path;
		} else {
			$color = "Green"
			$title = (get-location).Path;
		}
	write-host $promptText -NoNewLine -ForegroundColor $color
		$host.UI.RawUI.WindowTitle = $title;
	return " "
}
########################################################

########################################################
# Custom 'cd' command to maintain directory history
if( test-path alias:\cd ) { remove-item alias:\cd }
$GLOBAL:PWD = get-location;
$GLOBAL:CDHIST = [System.Collections.Arraylist]::Repeat($PWD, 1);
function cd {
	$cwd = get-location;
	$l = $GLOBAL:CDHIST.count;

	if ($args.length -eq 0) { 
		set-location $HOME;
		$GLOBAL:PWD = get-location;
		$GLOBAL:CDHIST.Remove($GLOBAL:PWD);
		if ($GLOBAL:CDHIST[0] -ne $GLOBAL:PWD) {
			$GLOBAL:CDHIST.Insert(0,$GLOBAL:PWD);
		}
		$GLOBAL:PWD;
	}
	elseif ($args[0] -like "-[0-9]*") {
		$num = $args[0].Replace("-","");
		$GLOBAL:PWD = $GLOBAL:CDHIST[$num];
		set-location $GLOBAL:PWD;
		$GLOBAL:CDHIST.RemoveAt($num);
		$GLOBAL:CDHIST.Insert(0,$GLOBAL:PWD);
		$GLOBAL:PWD;
	}
	elseif ($args[0] -eq "-l") {
		for ($i = $l-1; $i -ge 0 ; $i--) { 
			"{0,6}  {1}" -f $i, $GLOBAL:CDHIST[$i];
		}
	}
	elseif ($args[0] -eq "-") { 
		if ($GLOBAL:CDHIST.count -gt 1) {
			$t = $CDHIST[0];
			$CDHIST[0] = $CDHIST[1];
			$CDHIST[1] = $t;
			set-location $GLOBAL:CDHIST[0];
			$GLOBAL:PWD = get-location;
		}
		$GLOBAL:PWD;
	}
	else { 
		set-location "$args";
		$GLOBAL:PWD = pwd; 
		for ($i = ($l - 1); $i -ge 0; $i--) { 
			if ($GLOBAL:PWD -eq $CDHIST[$i]) {
				$GLOBAL:CDHIST.RemoveAt($i);
			}
		}

		$GLOBAL:CDHIST.Insert(0,$GLOBAL:PWD);
		$GLOBAL:PWD;
	}

	$GLOBAL:PWD = get-location;
}
########################################################

########################################################
# Custom PS-only path settings
function script:append-path {
	$oldPath = get-content Env:\Path;
	$newPath = $oldPath + ";" + $args;
	set-content Env:\Path $newPath;
}
append-path (Join-Path ([environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell")
########################################################

########################################################
# Custom format filters
filter Format-Bytes {
	$units = 'B  ', 'KiB', 'MiB', 'GiB', 'TiB';
	$ln = [Int64]0 + $_;
	$u = 0;

	if($ln -eq 0) {
		return '0    ';
	}
	while(($ln -gt 1024) -and ($u -lt $units.Length)) {
		$ln /= 1024;
		$u++;
	}
	'{0,7:0.###} {1}' -f $ln, $units[$u];
}
########################################################

########################################################
# 'go' command and targets
$GLOBAL:go_locations = @{}
if( $GLOBAL:go_locations -eq $null ) {
	$GLOBAL:go_locations = @{}
}

function go ([string] $location) {
	if( $go_locations.ContainsKey($location) ) {
		set-location $go_locations[$location];
	} else {
		write-output "The following locations are defined:";
		write-output $go_locations;
	}
}
$go_locations.Add("home", (get-item ([environment]::GetFolderPath("MyDocuments"))).Parent.FullName)
$go_locations.Add("desktop", [environment]::GetFolderPath("Desktop"))
$go_locations.Add("dl", (Join-Path ($env:HOME) "Downloads"))
$go_locations.Add("docs", [environment]::GetFolderPath("MyDocuments"))
$go_locations.Add("scripts", (Join-Path ([environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell") )
$go_locations.Add("tools", (Join-Path ([environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell\modules\SushiHangover-Tools") )
$go_locations.Add("recent", [environment]::GetFolderPath("Recent"))
########################################################
go home

Initialize-TranscriptLocation
$go_locations.Add("transcripts", $Global:SH:TranscriptDir)
$go_locations.Add("logs", $Global:SH:TranscriptDir)
Initialize-Transcript
if (Test-IsElevatedUser) {
    Write-Host "Running as elevated user" -ForegroundColor Red
}