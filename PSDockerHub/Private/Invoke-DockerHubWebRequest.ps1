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
           [uri]$Uri = ($DockerHub, $ApiVersion ,$item) -join '/'

            if ($Paginated) {
                if ($UsePageSize) {
                    if ($Uri.Query) {
                        $Joiner = '&'
                    } else {
                        $Joiner = '?'
                    }

                    if($MaxResults -lt $PageSize) {
                        $PageSize = $MaxResults
                    }

                    [uri]$Uri = ($Uri, ($PageSizeParam -f $PageSize)) -join $Joiner
                }

                Write-Verbose "Making paginated request to DockerHub API: $Uri"
                $ResultsCount = 0

                while ($Uri) {
                    try {
                        $Response = (Invoke-WebRequest -Uri $Uri -UseBasicParsing -ErrorAction Stop).Content
                    } catch {
                        throw $_
                    }

                    if ($Response) {
                        try {
                            $ret = $Response | ConvertFrom-Json -ErrorAction Stop
                        } catch{
                            throw $_
                        }

                        $ResultsCount += $ret.results.Count

                        'Page size: {0}. Total items available: {1}. Total items received : {2}. Items received in this batch: {3}. ' -f (
                            ($false, $PageSize)[[bool]$UsePageSize],
                            $ret.count,
                            $ResultsCount,
                            $ret.results.Count
                        ) |  Write-Verbose

                        'Next result uri: {0}' -f $ret.next | Write-Verbose

                        if ($ResultsCount -gt $MaxResults) {
                            $Uri = $null
                            $SkipCount = $ResultsCount - $MaxResults
                            Write-Verbose "Results limit reached, skipping last: $SkipCount"
                            $ret.results | Select-Object -SkipLast $SkipCount
                        } else {
                            $NextUri = $null

                            if (-not [System.String]::IsNullOrEmpty($ret.next)) {
                                if([uri]::TryCreate($ret.next, [System.UriKind]::Absolute, [ref]$NextUri)) {
                                    if ($NextUri.Host -ne $Uri.Host) {
                                        $UriBuilder = New-Object -TypeName System.UriBuilder -ArgumentList $NextUri
                                        $UriBuilder.Host = $Uri.Host
                                        $NextUri = $UriBuilder.ToString()
                                        Write-Verbose "Fixing url for next result:  $NextUri -> $Uri"
                                    }
                                }
                            }

                            $Uri = $NextUri
                            $ret.results
                        }
                    }
                }
            } else {
                Write-Verbose "Making singular request to DockerHub API: $Uri"
                try {
                    $Response = (Invoke-WebRequest -Uri $Uri -UseBasicParsing -ErrorAction Stop).Content
                } catch {
                    throw $_
                }

                if ($Response) {
                    $Response | ConvertFrom-Json -ErrorAction Stop
                }
            }
        }
    }
}