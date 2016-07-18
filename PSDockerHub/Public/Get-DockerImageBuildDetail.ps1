<#
.Synopsis
    Get Docker image build details

.Description
    Get Docker image build details
    Build history is available only for some automated builds.

.Parameter Name
    Docker repository (image) name

.Parameter MaxResults
    Maximum number of results to return. Default is 100.

.Example
    Get-DockerImageBuildDetail -Name 'jwilder/nginx-proxy'

    Get build details for 'jwilder/nginx-proxy' image
#>
function Get-DockerImageBuildDetail
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
        $RequestTpl = 'repositories/{0}/autobuild/'
    }

    Process
    {
        foreach ($item in $Name) {
            $Request = $RequestTpl -f ($item | Resolve-DockerHubRepoName)
            (Invoke-DockerHubWebRequest -Request $Request) | Select-Object -Property (
                @{n = 'Name' ; e = {$_.build_name}},
                @{n = 'Provider' ; e = {$_.provider}},
                @{n = 'Type' ; e = {$_.repo_type}},
                @{n = 'Url' ; e = {$_.repo_web_url}},
                @{n = 'Repo' ; e = {$_.source_url}},
                @{n = 'Tags' ; e = {
                    $_.build_tags | Select-Object -Property (
                        @{n = 'Name' ; e = {$_.name}},
                        @{n = 'Source' ; e = {$_.source_name}},
                        @{n = 'Type' ; e = {$_.source_type}},
                        @{n = 'Dockerfile' ; e = {$_.dockerfile_location}},
                        @{n = 'Id' ; e = {$_.id}}
                    ) | Add-TypeName -TypeName ($PSCmdlet.MyInvocation.MyCommand.Name + '-Tags')
                }}
            ) | Add-TypeName -TypeName $PSCmdlet.MyInvocation.MyCommand.Name
        }
    }
}