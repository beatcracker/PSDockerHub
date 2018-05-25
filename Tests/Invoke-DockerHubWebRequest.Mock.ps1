function Invoke-DockerHubWebRequest {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        $Request,

        [Parameter(ValueFromRemainingArguments = $true)]
        $Dummy
    )

    Process {
        $Responce = '
            {
              "count":9,
              "next":"",
              "previous":"",
              "results":[
                {
                  "repo_name":"official-1",
                  "short_description":"Official image #1",
                  "star_count":1,
                  "pull_count":1,
                  "repo_owner":"",
                  "is_automated":false,
                  "is_official":true
                },
                {
                  "repo_name":"official-2",
                  "short_description":"Official image #2",
                  "star_count":2,
                  "pull_count":2,
                  "repo_owner":"",
                  "is_automated":false,
                  "is_official":true
                },
                {
                  "repo_name":"official-3",
                  "short_description":"Official image #3",
                  "star_count":3,
                  "pull_count":3,
                  "repo_owner":"",
                  "is_automated":true,
                  "is_official":false
                },
                {
                  "repo_name":"unofficial/not-automated",
                  "short_description":"Unofficial & not automated image",
                  "star_count":4,
                  "pull_count":4,
                  "repo_owner":"",
                  "is_automated":false,
                  "is_official":false
                },
                {
                  "repo_name":"unofficial/automated",
                  "short_description":"Unofficial & automated image",
                  "star_count":5,
                  "pull_count":5,
                  "repo_owner":"",
                  "is_automated":true,
                  "is_official":false
                },
                {
                  "repo_name":"unofficial/not-automated-stars",
                  "short_description":"Unofficial & not automated [High stars count]",
                  "star_count":666,
                  "pull_count":6,
                  "repo_owner":"",
                  "is_automated":false,
                  "is_official":false
                },
                {
                  "repo_name":"unofficial/not-automated-downloads]",
                  "short_description":"Unofficial & not automated [High downloads count]",
                  "star_count":7,
                  "pull_count":777,
                  "repo_owner":"",
                  "is_automated":false,
                  "is_official":false
                },
                {
                  "repo_name":"unofficial/automated-stars",
                  "short_description":"Unofficial & automated [High stars count]",
                  "star_count":888,
                  "pull_count":8,
                  "repo_owner":"",
                  "is_automated":true,
                  "is_official":false
                },
                {
                  "repo_name":"unofficial/automated-downloads]",
                  "short_description":"Unofficial & automated [High downloads count]",
                  "star_count":9,
                  "pull_count":999,
                  "repo_owner":"",
                  "is_automated":true,
                  "is_official":false
                }
              ]
            }
        ' | ConvertFrom-Json

        switch -Wildcard ($Request) {

            '*is_automated=1*' {
                Write-Verbose 'Mocking: is_automated'
                $Responce.results = $Responce.results | Where-Object {$_.is_automated}
            }

            '*is_official=1*' {
                Write-Verbose 'Mocking: is_official'
                $Responce.results = $Responce.results | Where-Object {$_.is_official}
            }

            '*ordering=-pull_count' {
                Write-Verbose 'Mocking: pull_count'
                $Responce.results = $Responce.results | Sort-Object -Property 'pull_count' -Descending
            }

            '*ordering=-star_count*' {
                Write-Verbose 'Mocking: star_count'
                $Responce.results = $Responce.results | Sort-Object -Property 'star_count' -Descending
            }

            '*query=*' {
                if ($Request -match 'query=([^\*]\w+)') {
                    Write-Verbose 'Mocking: query'
                    $Responce.results = $Responce.results | Where-Object {$_.repo_name -like ('*{0}*' -f $Matches[1])}
                }
            }
        }

        $Responce.results
    }
}