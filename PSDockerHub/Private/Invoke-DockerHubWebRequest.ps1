<#
.Synopsis
    Helper function to query Docker Hub API.

.Description
    Helper function to query Docker Hub API.
    Supports singular and paginated requests.

.Parameter Request
    Request part of the URL, e.g.: 'search/repositories/?query=alpine'

.Parameter Paginated
    Make paginated request. Automatically requests URL for a next page (Docker Hub API returns it as a part of responce).

.Parameter UsePageSize
    Hint function, that endpoint supports 'page_size' parameter and it should be used.

.Parameter PageSize
    Sets page size to use, if endpoint supports 'page_size' parameter

.Parameter MaxResults
    Maximum number of results to return, if request is paginated.
#>
function Invoke-DockerHubWebRequest
{
    [CmdletBinding(DefaultParameterSetName = 'Single')]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Single')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Paginated')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Request,

        [Parameter(Mandatory = $true, ParameterSetName = 'Paginated')]
        [switch]$Paginated,

        [Parameter(ParameterSetName = 'Paginated')]
        [Parameter(ParameterSetName = 'PageSize')]
        [switch]$UsePageSize,

        [Parameter(ParameterSetName = 'Paginated')]
        [Parameter(ParameterSetName = 'PageSize')]
        [int]$PageSize = 100,

        [Parameter(ParameterSetName = 'Paginated')]
        [int]$MaxResults = [int]::MaxValue
    )

    Begin
    {
        $DockerHub = 'https://hub.docker.com'
        $ApiVersion = 'v2'
        $PageSizeParam = 'page_size={0}'
    }

    Process
    {
        foreach ($item in $Request) {
            $Uri = ($DockerHub, $ApiVersion ,$item) -join '/'

            if ($Paginated) {
                if ($UsePageSize) {
                    if ([uri]$Uri.Query) {
                        $Joiner = '&'
                    } else {
                        $Joiner = '?'
                    }

                    if($MaxResults -lt $PageSize) {
                        $PageSize = $MaxResults
                    }

                    $Uri = ($Uri, ($PageSizeParam -f $PageSize)) -join $Joiner
                }

                Write-Verbose 'Making paginated request to DockerHub API'
                $ResultsCount = 0

                while ($Uri) {
                    try {
                        $Response = (Invoke-WebRequest -Uri $Uri -UseBasicParsing -ErrorAction Stop).Content
                    } catch {
                        throw $_
                    }

                    $Uri = $null

                    if ($Response) {
                        $ret = $Response | ConvertFrom-Json
                        $ResultsCount += $ret.results.Count

                        'Page size: {0}. Total tems available: {1}. Total items received : {2}. Items received in this batch: {3}. ' -f (
                            ($false, $PageSize)[[bool]$UsePageSize],
                            $ret.count,
                            $ResultsCount,
                            $ret.results.Count
                        ) |  Write-Verbose

                        if ($ResultsCount -gt $MaxResults) {
                            $SkipCount = $ResultsCount - $MaxResults
                            Write-Verbose "Results limit reached, skipping last: $SkipCount"
                            $ret.results | Select-Object -SkipLast $SkipCount
                        } elseif ($ResultsCount -eq $MaxResults) {
                            $ret.results
                        } else {
                            $Uri = $ret.next
                            $ret.results
                        }
                    }
                }
            } else {
                Write-Verbose "Making singular request to DockerHub API"
                try {
                    $Response = (Invoke-WebRequest -Uri $Uri -UseBasicParsing -ErrorAction Stop).Content
                } catch {
                    throw $_
                }

                if ($Response) {
                    $Response | ConvertFrom-Json
                }
            }
        }
    }
}