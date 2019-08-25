<#
.Synopsis
    Adds 'library' path component to the piped name, if it has only one path component.
    Used to resolve names for official repositories like 'alpine' and 'mariadb'.

.Link
    https://docs.docker.com/registry/spec/api/
#>
filter Resolve-DockerHubRepoName {
    if ($_ -match '/') {
        $_
    } else {
        "library/$_"
    }
}