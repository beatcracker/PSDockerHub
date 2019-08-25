<#
.Synopsis
    Get Docker image Dockerfile.

.Description
    Get Docker image Dockerfile.
    Build history is available only for some automated builds.

.Parameter Name
    Docker repository (image) name

.Example
    Get-DockerImageDockerfile -Name 'jwilder/nginx-proxy'

    Get Dockerfile for 'jwilder/nginx-proxy' image

#>
function Get-DockerImageDockerfile
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
        $RequestTpl = 'repositories/{0}/dockerfile/'
    }

    Process
    {
        foreach ($item in $Name) {
            $Request = $RequestTpl -f ($item | Resolve-DockerHubRepoName)
            (Invoke-DockerHubWebRequest -Request $Request).contents
        }
    }
}