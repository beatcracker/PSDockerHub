<#
.Synopsis
    Adds TypeName to piped object

.Parameter TypeName
    String array of typenames
#>
filter Add-TypeName {
    Param([string[]]$TypeName)
    foreach ($name in $TypeName) {
        $_.PSObject.TypeNames.Insert(0, $name)
    }
    $_
}