if (-not $ENV:BHProjectPath) {
    Set-BuildEnvironment -Path $PSScriptRoot\..
}

$FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name).Replace('.Tests', '')

Import-Module -Name (Join-Path $ENV:BHProjectPath $ENV:BHProjectName) -ErrorAction Stop

Describe "$FunctionName" {
    InModuleScope $ENV:BHProjectName {

        . (Join-Path $ENV:BHProjectPath '.\Tests\Invoke-DockerHubWebRequest.Mock.ps1')


        # Wildcard

        It 'Use wildcard "*" if invoked w/o "SearchTerm" parameter' {
            $Result = Find-DockerImage

            $Result | Should -Not -BeNullOrEmpty
        }


        # Wildcard + SortBy

        It 'Use wildcard "*" if invoked w/o "SearchTerm" parameter and with "-SortBy Downloads"' {
            $Result = Find-DockerImage -SortBy Downloads

            $Result[0].Downloads | Should -BeGreaterThan $Result[-1].Downloads
        }

        It 'Use wildcard "*" if invoked w/o "SearchTerm" parameter and with "-SortBy Stars"' {
            $Result = Find-DockerImage -SortBy Stars

            $Result[0].Stars | Should -BeGreaterThan $Result[-1].Stars
        }


        # Wildcard + SortBy + Official/Automated

        It 'Use wildcard "*" if invoked w/o "SearchTerm" parameter and with "-SortBy Downloads -Automated"' {
            $Result = Find-DockerImage -SortBy Downloads -Automated

            $Result.Automated | Should -Not -Contain $false
            $Result[0].Downloads | Should -BeGreaterThan $Result[-1].Downloads
        }

        It 'Use wildcard "*" if invoked w/o "SearchTerm" parameter and with "-SortBy Stars -Automated"' {
            $Result = Find-DockerImage -SortBy Stars -Automated

            $Result.Automated | Should -Not -Contain $false
            $Result[0].Stars | Should -BeGreaterThan $Result[-1].Stars
        }

        It 'Use wildcard "*" if invoked w/o "SearchTerm" parameter and with "-SortBy Downloads -Official"' {
            $Result = Find-DockerImage -SortBy Downloads -Official

            $Result.Official | Should -Not -Contain $false
            $Result[0].Downloads | Should -BeGreaterThan $Result[-1].Downloads
        }

        It 'Use wildcard "*" if invoked w/o "SearchTerm" parameter and with "-SortBy Stars -Official"' {
            $Result = Find-DockerImage -SortBy Stars -Official

            $Result.Official | Should -Not -Contain $false
            $Result[0].Stars | Should -BeGreaterThan $Result[-1].Stars
        }


        # Pipeline: SearchTerm

        It 'Accept "SearchTerm" via Pipeline parameter' {
            $Result = 'automated' | Find-DockerImage

            $Result.Name -like '*automated*' | Should -HaveCount $Result.Count
        }


        # Pipeline:  SearchTerm . Named: SortBy + Official/Automated

        It 'Accept "SearchTerm" via Pipeline parameter. Accept "-SortBy Downloads -Official" via Named parameters' {
            $Result = 'official' | Find-DockerImage -SortBy Downloads -Official

            $Result.Name -like '*official*' | Should -HaveCount $Result.Count
            $Result.Official | Should -Not -Contain $false
            $Result[0].Downloads | Should -BeGreaterThan $Result[-1].Downloads
        }

        It 'Accept "SearchTerm" via Pipeline parameter. Accept "-SortBy Stars -Official" via Named parameters' {
            $Result = 'official' | Find-DockerImage -SortBy Stars -Official

            $Result.Name -like '*official*' | Should -HaveCount $Result.Count
            $Result.Official | Should -Not -Contain $false
            $Result[0].Stars | Should -BeGreaterThan $Result[-1].Stars
        }

        It 'Accept "SearchTerm" via Pipeline parameter. Accept "-SortBy Downloads -Automated" via Named parameters' {
            $Result = 'automated' | Find-DockerImage -SortBy Downloads -Automated

            $Result.Name -like '*automated*' | Should -HaveCount $Result.Count
            $Result.Automated | Should -Not -Contain $false
            $Result[0].Downloads | Should -BeGreaterThan $Result[-1].Downloads
        }

        It 'Accept "SearchTerm" via Pipeline parameter. Accept "-SortBy Stars -Automated" via Named parameters' {
            $Result = 'official' | Find-DockerImage -SortBy Stars -Official

            $Result.Name -like '*official*' | Should -HaveCount $Result.Count
            $Result.Official | Should -Not -Contain $false
            $Result[0].Stars | Should -BeGreaterThan $Result[-1].Stars
        }


        # Named: SearchTerm

        It 'Accept "SearchTerm" via Pipeline parameter' {
            $Result = 'automated' | Find-DockerImage

            $Result.Name -like '*automated*' | Should -HaveCount $Result.Count
        }


        # Named: SearchTerm + SortBy

        It 'Accept "SearchTerm", "-SortBy Downloads" via Named parameters' {
            $Result = 'official' | Find-DockerImage -SortBy Downloads

            $Result.Name -like '*official*' | Should -HaveCount $Result.Count
            $Result[0].Downloads | Should -BeGreaterThan $Result[-1].Downloads
        }

        It 'Accept "SearchTerm", "-SortBy Stars" via Named parameters' {
            $Result = 'official' | Find-DockerImage -SortBy Downloads

            $Result.Name -like '*official*' | Should -HaveCount $Result.Count
            $Result[0].Stars | Should -BeGreaterThan $Result[-1].Stars
        }


        # Named: SearchTerm + SortBy + Official/Automated

        It 'Accept "SearchTerm", "-SortBy Downloads -Official" via Named parameters' {
            $Result = 'official' | Find-DockerImage -SortBy Downloads -Official

            $Result.Name -like '*official*' | Should -HaveCount $Result.Count
            $Result.Official | Should -Not -Contain $false
            $Result[0].Downloads | Should -BeGreaterThan $Result[-1].Downloads
        }

        It 'Accept "SearchTerm", "-SortBy Stars -Official" via Named parameters' {
            $Result = 'official' | Find-DockerImage -SortBy Stars -Official

            $Result.Name -like '*official*' | Should -HaveCount $Result.Count
            $Result.Official | Should -Not -Contain $false
            $Result[0].Stars | Should -BeGreaterThan $Result[-1].Stars
        }

        It 'Accept "SearchTerm", "-SortBy Downloads -Automated" via Named parameters' {
            $Result = 'automated' | Find-DockerImage -SortBy Downloads -Automated

            $Result.Name -like '*automated*' | Should -HaveCount $Result.Count
            $Result.Automated | Should -Not -Contain $false
            $Result[0].Downloads | Should -BeGreaterThan $Result[-1].Downloads
        }

        It 'Accept "SearchTerm", "-SortBy Stars -Automated" via Named parameters' {
            $Result = 'official' | Find-DockerImage -SortBy Stars -Automated

            $Result.Name -like '*official*' | Should -HaveCount $Result.Count
            $Result.Automated | Should -Not -Contain $false
            $Result[0].Stars | Should -BeGreaterThan $Result[-1].Stars
        }





        # Positional: SearchTerm

        It 'Accept "SearchTerm" via Positional parameter' {
            $Result = Find-DockerImage 'automated'

            $Result.Name -like '*automated*' | Should -HaveCount $Result.Count
        }


        # Positional: SearchTerm + SortBy

        It 'Accept "SearchTerm", "-SortBy Downloads" via Positional parameters' {
            $Result = Find-DockerImage 'official' 'Downloads'

            $Result.Name -like '*official*' | Should -HaveCount $Result.Count
            $Result[0].Downloads | Should -BeGreaterThan $Result[-1].Downloads
        }

        It 'Accept "SearchTerm", "-SortBy Stars" via Positional parameters' {
            $Result = Find-DockerImage 'official' 'Stars'

            $Result.Name -like '*official*' | Should -HaveCount $Result.Count
            $Result[0].Stars | Should -BeGreaterThan $Result[-1].Stars
        }


        # Positional: SearchTerm + SortBy

        It 'Accept "SearchTerm", "-SortBy Downloads -Official" via Positional parameters' {
            $Result = Find-DockerImage -SortBy Downloads -Official

            $Result.Name -like '*official*' | Should -HaveCount $Result.Count
            $Result.Official | Should -Not -Contain $false
            $Result[0].Downloads | Should -BeGreaterThan $Result[-1].Downloads
        }

    }
}