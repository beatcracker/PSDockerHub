$script:FunctionsToExport = @()
$Folders = 'Public', 'Private'

foreach ($Scope in $Folders) {
    Get-ChildItem -LiteralPath (
        Join-Path -Path $PSScriptRoot -ChildPath $Scope
    ) -File -Filter '*.ps1' | ForEach-Object {
        $File = $_
        try {
            Write-Verbose "Dotsourcing file: $File"
            . $File.FullName

            switch ($Scope) {
                'Public' {
                    $script:FunctionsToExport += $File.BaseName
                }
            }
        } catch {
            throw "Can't import functions from file: $File"
        }
    }
}

Export-ModuleMember -Function $script:FunctionsToExport