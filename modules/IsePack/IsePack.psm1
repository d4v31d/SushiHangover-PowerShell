. $psScriptRoot\Add-ForeachStatement.ps1
. $psScriptRoot\Add-IfStatement.ps1
. $psScriptRoot\Add-InlineHelp.ps1
. $psScriptRoot\Add-IseMenu.ps1
. $psScriptRoot\Add-Parameter.ps1
. $psScriptRoot\Add-PInvoke.ps1
. $psScriptRoot\Add-SwitchStatement.ps1
. $psScriptRoot\Close-AllOpenedFiles.ps1
. $psScriptRoot\Colorize.ps1
. $psScriptRoot\ConvertTo-ShortcutKeyTable.ps1
. $psScriptRoot\Export-FormatView.ps1
. $psScriptRoot\Get-CurrentOpenedFileToken.ps1
. $psScriptRoot\Get-CurrentToken.ps1
. $psScriptRoot\Get-FunctionFromFile.ps1
. $psScriptRoot\Get-TokenFromFile.ps1
. $psScriptRoot\Invoke-Line.ps1
. $psScriptRoot\Move-ToLastGroup.ps1
. $psScriptRoot\Move-ToLastPowerShellTab.ps1
. $psScriptRoot\Move-ToNextGroup.ps1
. $psScriptRoot\Move-ToNextPowerShellTab.ps1
. $psScriptRoot\New-IseScript.ps1
. $psScriptRoot\New-ScriptModuleFromCurrentLocation.ps1
. $psScriptRoot\Push-CurrentFileLocation.ps1
. $psScriptRoot\Save-IseFileWithAutoName.ps1
. $psScriptRoot\Select-AllInFile.ps1
. $psScriptRoot\Select-CurrentText.ps1
. $psScriptRoot\Select-CurrentTextAsType.ps1
. $psScriptRoot\Select-CurrentTextAsCommand.ps1
. $psScriptRoot\Select-CurrentTextAsVariable.ps1
. $psScriptRoot\Show-SyntaxForCurrentCommand.ps1
. $psScriptRoot\Show-TypeConstructor.ps1
. $psScriptRoot\Show-TypeConstructorForCurrentType.ps1
. $psScriptRoot\Show-HelpForCurrentSelection.ps1
. $psScriptRoot\Show-Member.ps1
. $psScriptRoot\Split-IseFile.ps1
. $psScriptRoot\Switch-CommentOrText.ps1
. $psScriptRoot\Switch-SelectedCommentOrText.ps1

if (-not (Get-Command psEdit -ErrorAction SilentlyContinue)) {
    function psEdit {
        param([Parameter(Mandatory=$true)]$filenames)
        foreach ($filename in $filenames)
        {
            dir $filename | where {!$_.PSIsContainer} | %{
                $psISE.CurrentPowerShellTab.Files.Add($_.FullName) > $null
            }
        }        
    }    
}

Add-IseMenu -name IsePack @{
    "Snippets" = @{
        "Add-ForeachStatemnt" = {Add-ForeachStatement} | 
            Add-Member NoteProperty ShortcutKey "CTRL + SHIFT + F" -PassThru
        "Add-IfStatement" = {Add-IfStatement} | 
            Add-Member NoteProperty ShortcutKey "CTRL + SHIFT + I" -PassThru
        "Add-SwitchStatement" = {Add-SwitchStatement} | 
            Add-Member NoteProperty ShortcutKey "CTRL + SHIFT + S" -PassThru

        "Add-InlineHelp" = {Add-InlineHelp} | 
            Add-Member NoteProperty ShortcutKey "Alt + H" -PassThru
        "Add-Parameter" = {Add-Parameter} |
            Add-Member NoteProperty ShortcutKey "ALT + P" -PassThru        
    }
    "Export-FormatView" = {
        [Windows.Clipboard]::SetText((
            Select-CurrentTextAsType | Export-FormatView
        ))
    } | Add-Member NoteProperty ShortcutKey "CTRL+ALT+F" -PassThru
    "Edit" = @{
        "Clear-Output"  = {cls} | Add-Member NoteProperty ShortcutKey "F12" -PassThru
        "Copy-Colored" = {Copy-Colored} |
            Add-Member NoteProperty ShortcutKey "CONTROL+SHIFT+C" -PassThru
        "Copy-ColoredAsHtml" = {Copy-ColoredHTML} |
            Add-Member NoteProperty ShortcutKey "CONTROL+ALT+SHIFT+C" -PassThru
        "Copy-FilePathToClipboard" = {
            [Windows.Clipboard]::SetText($psise.CurrentFile.FullPath)
        } | Add-Member NoteProperty Shortcutkey "CTRL+P" -PassThru
        "ConvertTo-Function" = {
            $cmd = Get-Command $psise.CurrentFile.FullPath -ErrorAction SilentlyContinue
            if ($cmd) { $cmd | New-IseScript }
        } | Add-Member NoteProperty ShortcutKey "ALT+SHIFT+F" -PassThru
        "Profile" = {
            psedit $Profile
        } | Add-Member NoteProperty ShortcutKey "CTRL+E" -PassThru
        "Move-ToNextGroup" = {Move-ToNextGroup} |
            Add-Member NoteProperty ShortcutKey "ALT+SHIFT+RIGHT" -PassThru
        "Move-ToLastGroup" = {Move-ToLastGroup} |
            Add-Member NoteProperty ShortcutKey "ALT+SHIFT+LEFT" -PassThru
        "AutoSave" = {
            if ($psise.CurrentFile.IsUntitled) {
                $psise.CurrentFile | Save-IseFileWithAutoName
            } else {
                $psise.CurrentFile.Save()
            }
        } | Add-Member NoteProperty ShortcutKey "CTRL+F12" -PassThru
        "Split-CurrentFile" = {
            Split-IseFile $psise.CurrentFile
        } | Add-Member NoteProperty ShortcutKey "CTRL+ALT+MINUS" -PassThru
        "Toggle Comments" = {Switch-SelectedCommentOrText} |
            Add-Member NoteProperty ShortcutKey "CTRL+ALT+C" -PassThru
    }
    "Modules" = @{
        "Import-CurrentModule" = {
            Get-Command | 
            Where-Object {
                $_.ScriptBlock.File -eq $psise.CurrentFile.FullPath
            } | ForEach-Object {
                Import-Module $_.ModuleName -Force
            }    
        } | Add-Member NoteProperty ShortcutKey "CONTROL+ALT+M" -PassThru
        "New-ScriptModuleFromCurrentLocation" = {New-ScriptModuleFromCurrentLocation} |
            Add-Member NoteProperty ShortcutKey "CONTROL+M" -PassThru
    }
    "Navigation" = @{
        "Push-CurrentFileLocation" = {Push-CurrentFileLocation} | 
            Add-Member NoteProperty ShortcutKey "CONTROL+ALT+D" -PassThru
        "Show-ExplorerForCurrentFile" = {explorer (Split-Path $psise.CurrentFile.FullPath)} |
            Add-Member NoteProperty ShortcutKey "CTRL+ALT+E" -PassThru
        "Close-AllOpenedFiles" = { Close-AllOpenedFiles } |
            Add-Member NoteProperty ShortcutKey "CTRL+SHIFT+F4" -PassThru
        "Move-ToNextPowerShellTab" = { Move-ToNextPowerShellTab } |
            Add-Member NoteProperty ShortcutKey "CTRL+ALT+SHIFT+RIGHT" -PassThru
        "Move-ToLastPowerShellTab" = { Move-ToLastPowerShellTab } |
            Add-Member NoteProperty ShortcutKey "CTRL+ALT+SHIFT+LEFT" -PassThru
        "Rename-CurrentPowerShellTab" = { $psise.CurrentPowerShellTab.DisplayName = Read-Host "Please enter the name of the tab"  } | 
            Add-Member NoteProperty ShortcutKey "CTRL+ALT+N" -PassThru

    }    
    "Show-HelpForCurrentSelection" = {Show-HelpForCurrentSelection} |
        Add-Member NoteProperty ShortcutKey "CTRL+ALT+H" -PassThru
    "Show-Member" = {Show-Member} |
        Add-Member NoteProperty ShortcutKey "ALT+M" -PassThru        
    "Show-SyntaxForCurrentCommand" = {Show-SyntaxForCurrentCommand} |
        Add-Member NoteProperty ShortcutKey "ALT+Y" -PassThru
    "Show-TypeConstructorForCurrentType" = {Show-TypeConstructorForCurrentType} |
        Add-Member NoteProperty ShortcutKey "ALT+C" -PassThru
    "Invoke-Line" = { Invoke-Line } | Add-Member NoteProperty ShortcutKey "F6" -PassThru
    "Search-Bing" = {
        $Shell = New-Object -ComObject Shell.Application
        Select-CurrentText | Where-Object { $_ } | ForEach-Object {
            $shell.ShellExecute("http://www.bing.com/search?q=$_")
        } 
    } | Add-Member NoteProperty ShortcutKey "CTRL+B" -PassThru
}