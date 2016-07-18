<#
.Synopsis
    Get Docker image tags for image

.Description
    Get Docker image tags for image via Docker Hub API

.Parameter Name
    Docker repository (image) name

.Parameter MaxResults
    Maximum number of results to return. Default is 100.

.Example
    Get-DockerImageTag -Name 'mariadb'

    Get tags for 'mariadb' image

.Example
    Find-DockerImage 'alpine' -Official | Get-DockerImageTag

    Search for official Alpine Linux docker image, then get its tags.

#>
function Get-DockerImageTag
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Name,

        [int]$MaxResults = 100
    )

    Begin
    {
        $RequestTpl = 'repositories/{0}/tags/'
    }

    Process
    {
        $Request = $Name | ForEach-Object {
            $RequestTpl -f ($_ | Resolve-DockerHubRepoName)
        }

        Invoke-DockerHubWebRequest -Request $Request -Paginated -UsePageSize -MaxResults $MaxResults |
            Select-Object -Property (
                @{n = 'Name' ; e = {$_.name}},
                @{n = 'Size' ; e = {$_.full_size}},
                @{n = 'Updated' ; e = {[Nullable[DateTime]]$_.last_updated}},
                @{n = 'Id' ; e = {$_.id}}
            ) | Add-TypeName -TypeName $PSCmdlet.MyInvocation.MyCommand.Name
    }
}