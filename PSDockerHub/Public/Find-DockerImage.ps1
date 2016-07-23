<#
.Synopsis
    Search for docker images on Docker Hub

.Description
    Search for docker images on Docker Hub via Docker Hub API.
    You can filter search by Name/Description, Stars, Downloads, Official images and Automated builds.

.Parameter SearchTerm
    Search term. Docker Hub will search it in the Name and Description.
    If search term is not specified, function will return all available images using wildcard query ('*').

.Parameter SortBy
    Sort by Downloads or Stars. Sorting is performed on Docker Hub side.

.Parameter Automated
    Search only for automated builds
    Note, that this parameter is not available, when SearchTerm is omitted (wildcard query)

.Parameter Official
    Search only for official images
    Note, that this parameter is not available, when SearchTerm is omitted (wildcard query)

.Parameter MaxResults
    Maximum number of results to return. Default is 25.

.Example
    Find-DockerImage -SearchTerm mariadb -Official

    Search for official MariaDB docker images

.Example
    Find-DockerImage -SearchTerm ruby -SortBy Stars -Automated -MaxResults 5

    Search for automated builds of 'ruby', sort by stars, return 5 top results

.Example
    Find-DockerImage -SearchTerm mariadb -SortBy Downloads | Where-Object {$_.Name -like '*alpine*'}

    Search for MariaDB docker images, sort by downloads. Then find images built on Alpine Linux using PowerShell filtering.

.Example
    Find-DockerImage -SortBy Downloads

    Get most downloaded docker images


.Example
    Find-DockerImage -SortBy Stars

    Get most starred docker images
#>
function Find-DockerImage
{
    [CmdletBinding(DefaultParameterSetName = 'Wildcard')]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'SearchTerm_Automated')]
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'SearchTerm_Official')]
        [Parameter(Position = 0, ParameterSetName = 'Wildcard')]
        [ValidateNotNullOrEmpty()]
        [string[]]$SearchTerm = '*',

        [Parameter(Position = 1, ParameterSetName = 'SearchTerm_Automated')]
        [Parameter(Position = 1, ParameterSetName = 'SearchTerm_Official')]
        [Parameter(Position = 1, ParameterSetName = 'Wildcard')]
        [ValidateSet('Downloads', 'Stars')]
        [string]$SortBy,

        [Parameter(Position = 2, ParameterSetName = 'SearchTerm_Automated')]
        [switch]$Automated,

        [Parameter(Position = 2, ParameterSetName = 'SearchTerm_Official')]
        [switch]$Official,
        
        [Parameter(Position = 3)]
        [int]$MaxResults = 25
    )

    Begin
    {
        $RequestTpl = 'search/repositories/?query={0}'
        $QueryParamMap = @{
            Automated = 'is_automated=1'
            Official = 'is_official=1'
            Downloads = 'ordering=-pull_count'
            Stars = 'ordering=-star_count'
        }
    }

    Process
    {
        $QueryParams = @()

        if ($Automated) {
            $QueryParams += $QueryParamMap.Automated
        }

        if ($Official) {
            $QueryParams += $QueryParamMap.Official
        }

        if ($SortBy) {
            $QueryParams += $QueryParamMap.$SortBy
        }

        $Request = $SearchTerm | ForEach-Object {
            (
                @($RequestTpl -f [System.Net.WebUtility]::UrlEncode($_)) + $QueryParams
            ) -join '&'
        }

        Invoke-DockerHubWebRequest -Request $Request -Paginated -MaxResults $MaxResults |
            Select-Object -Property (
                @{n = 'Name' ; e = {$_.repo_name}},
                @{n = 'Description' ; e = {$_.short_description}},
                @{n = 'Stars' ; e = {$_.star_count}},
                @{n = 'Downloads' ; e = {$_.pull_count}},
                @{n = 'Official' ; e = {$_.is_official}},
                @{n = 'Automated' ; e = {$_.is_automated}}
            ) | Add-TypeName -TypeName $PSCmdlet.MyInvocation.MyCommand.Name
    }
}