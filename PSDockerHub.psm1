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

<#
.Synopsis
    Search for docker images on Docker Hub

.Description
    Search for docker images on Docker Hub via Docker Hub API.
    You can filter search by Name/Description, Stars, Downloads, Official images and Automated builds.

.Parameter SearchTerm
    Search term. Docker Hub will search it in the Name and Description.

.Parameter SortBy
    Sort by Downloads or Stars. Sorting is performed on Docker Hub side.

.Parameter MaxResults
    Maximum number of results to return. Default is 25.

.Parameter Automated
    Search only for automated builds

.Parameter Official
    Search only for official images

.Example
    Find-DockerImage -SearchTerm mariadb -Official

    Search for official MariaDB docker images

.Example
    Find-DockerImage -SearchTerm ruby -SortBy Stars -Automated -MaxResults 5

    Search for automated builds of 'ruby', sort by stars, return 5 top results

.Example
    Find-DockerImage -SearchTerm mariadb -SortBy Downloads | Where-Object {$_.Name -like '*alpine*'}

    Search for MariaDB docker images, sort by downloads. Then find images built on Alpine Linux using PowerShell filtering.

#>
function Find-DockerImage
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SearchTerm,

        [ValidateSet('Downloads', 'Stars')]
        [string]$SortBy,

        [int]$MaxResults = 25,

        [switch]$Automated,

        [switch]$Official
    )

    Begin
    {
        $ApiUriTpl = 'https://hub.docker.com/v2/search/repositories/?query={0}'

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

            $Request = (
                @($ApiUriTpl -f [System.Net.WebUtility]::UrlEncode($SearchTerm)) + $QueryParams
            ) -join '&'

            $ResultsCount = 0
            while ($Request) {
                try {
                    $Response = (Invoke-WebRequest -Uri $Request -UseBasicParsing -ErrorAction Stop).Content
                } catch {
                    throw $_
                }

                $ret = $Response | ConvertFrom-Json
                $ResultsCount += $ret.results.Count

                $Output = if($ResultsCount -gt $MaxResults) {
                    $ret.results | Select-Object -SkipLast ($ResultsCount - $MaxResults)
                    $Request = $null
                } else {
                    $ret.results
                    $Request = $ret.next
                }

                $Output | Select-Object -Property (
                    @{n = 'Name' ; e = {$_.repo_name}},
                    @{n = 'Description' ; e = {$_.short_description}},
                    @{n = 'Stars' ; e = {$_.star_count}},
                    @{n = 'Downloads' ; e = {$_.pull_count}},
                    @{n = 'Official' ; e = {$_.is_official}},
                    @{n = 'Automated' ; e = {$_.is_automated}}
                )  | Add-TypeName -TypeName $PSCmdlet.MyInvocation.MyCommand.Name
            } 
    }
}