if (-not $ENV:BHProjectPath) {
    Set-BuildEnvironment -Path $PSScriptRoot\..
}

$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')

Describe "$FunctionName" {
    It 'Should not have any PSScriptAnalyzer warnings' {
        $ProjectRoot = $ENV:BHProjectPath
        $ModuleName = $ENV:BHProjectName

        $ScriptWarnings = @(
            Get-ChildItem -LiteralPath "$ProjectRoot\$ModuleName\$ModuleName.psm1" | Invoke-ScriptAnalyzer
        )

        if ($ScriptWarnings) {
            $ScriptWarnings | Format-Table -AutoSize | Out-String | Write-Warning
        }

        $ScriptWarnings.Length | Should be 0
    }
}