<#
.Synopsis
    Get Docker image build history

.Description
    Get Docker image build history
    Build history is available only for some automated builds.

.Parameter Name
    Docker repository (image) name

.Parameter MaxResults
    Maximum number of results to return. Default is 100.

.Example
    Get-DockerImageBuildHistory -Name 'jwilder/nginx-proxy'

    Get build history for 'jwilder/nginx-proxy' image
#>
function Get-DockerImageBuildHistory
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
        $RequestTpl = 'repositories/{0}/buildhistory/'

        # https://github.com/badges/shields/issues/241
        $StatusMap = @{
            0 = 'Queued'
            -1 = 'Error'
            3 = 'Building'
            10 = 'Success'
        }
    }

    Process
    {
        $Request = $Name | ForEach-Object {
            $RequestTpl -f ($_ | Resolve-DockerHubRepoName)
        }

        Invoke-DockerHubWebRequest -Request $Request -Paginated -UsePageSize -MaxResults $MaxResults |
            Select-Object -Property (
                @{n = 'Tag' ; e = {$_.dockertag_name}},
                @{n = 'Status' ; e = {$StatusMap.($_.status)}},
                @{n = 'Id' ; e = {$_.id}},
                @{n = 'BuildCode' ; e = {$_.build_code}},
                @{n = 'Cause' ; e = {$_.cause}},
                @{n = 'Created' ; e = {[Nullable[DateTime]]$_.created_date}},
                @{n = 'Updated' ; e = {[Nullable[DateTime]]$_.last_updated}}
            ) | Add-TypeName -TypeName $PSCmdlet.MyInvocation.MyCommand.Name
    }
}