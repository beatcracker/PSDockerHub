<#
.Synopsis
    Get detailed information for a Docker image.

.Description
    Get detailed information for a Docker image, including full description in markdown.

.Parameter Name
    Docker repository (image) name

.Example
    Get-DockerImageDetail -Name 'mariadb'

.Example
    'alpine' | Get-DockerImageDetail
#>
function Get-DockerImageDetail
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Name
    )

    Begin
    {
        $RequestTpl = 'repositories/{0}/'
    }

    Process
    {
        foreach ($item in $Name) {
            $Request = $RequestTpl -f ($item | Resolve-DockerHubRepoName)
            (Invoke-DockerHubWebRequest -Request $Request) | Select-Object -Property (
                @{n = 'Name' ; e = {$_.name}},
                @{n = 'Owner' ; e = {$_.user}},
                @{n = 'Description' ; e = {$_.description}},
                @{n = 'Active' ; e = {[bool]$_.status}},
                @{n = 'Updated' ; e = {[Nullable[DateTime]]$_.last_updated}},
                @{n = 'Private' ; e = {$_.is_private}},
                @{n = 'Stars' ; e = {$_.star_count}},
                @{n = 'Downloads' ; e = {$_.pull_count}},
                @{n = 'Official' ; e = {if ($_.namespace -eq 'library') {$true} else {$false}}},
                @{n = 'Automated' ; e = {$_.is_automated}},
                @{n = 'FullDescription' ; e = {$_.full_description}}
            )
        }
    }
}