if (-not $ENV:BHProjectPath) {
    Set-BuildEnvironment -Path $PSScriptRoot\..
}

$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')

Describe "$FunctionName" {
    It 'Should not have any PSScriptAnalyzer warnings' {
        $ProjectRoot = $ENV:BHProjectPath
        $ModuleName = $ENV:BHProjectName

        $ScriptWarnings = @(
            Invoke-ScriptAnalyzer -Path "$ProjectRoot\$ModuleName" -Recurse -ExcludeRule 'PSUseToExportFieldsInManifest'
        )

        if ($ScriptWarnings) {
            $ScriptWarnings | Format-Table -AutoSize | Out-String | Write-Warning
        }

        $ScriptWarnings.Length | Should be 0
    }
}