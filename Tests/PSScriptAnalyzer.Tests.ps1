$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')

Describe "$FunctionName" {
    It 'Should not have any PSScriptAnalyzer warnings' {
        $ScriptWarnings = @(
            Get-ChildItem -LiteralPath "$here\..\PSDockerHub.psm1" | Invoke-ScriptAnalyzer
        )
        $ScriptWarnings | Format-Table -AutoSize | Out-String | Write-Warning
        $ScriptWarnings.Length | Should be 0
    }
}