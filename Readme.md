[![Build status](https://ci.appveyor.com/api/projects/status/ga9uuklbvdexw8re?svg=true)](https://ci.appveyor.com/project/beatcracker/psdockerhub)


# `PSDockerHub` PowerShell module

PSDockerHub is a PowerShell module written to access the official [Docker Hub/Registry](https://hub.docker.com)


# Requirements

* PowerShell 3.0 or higher


# Functions
### Find-DockerImage
Search for docker images on Docker Hub via Docker Hub API. You can filter search by `Name/Description`, `Stars`, `Downloads`, `Official` images and `Automated` builds.

### Example

Search for [MariaDB](https://mariadb.org) docker images, sort by downloads. Then find images built on [Alpine Linux](https://www.alpinelinux.org) using PowerShell filtering.

```powershell
Find-DockerImage -SearchTerm mariadb -SortBy Downloads -MaxResults 100 | Where-Object {$_.Name -like '*alpine*'}

Name                 Description                             Stars Downloads Official Automated
----                 -----------                             ----- --------- -------- ---------
wodby/mariadb-alpine mariadb-alpine                              1      6533    False      True
k0st/alpine-mariadb  MariaDB/MySQL on Alpine (size: ~154 MB)     3      2939    False      True
dydx/alpine-mariadb                                              1       671    False      True
timhaak/docker-maria docker mariadb using alpine                 2       357    False      True
db-alpine                                                                                      
```
Or you can pipe output to `Out-GridView` and apply filters there:

```powershell
Find-DockerImage -SearchTerm mariadb -SortBy Downloads -MaxResults 100 | Out-GridView
```

![Out-GridView](https://raw.githubusercontent.com/beatcracker/PSDockerHub/master/Media/Out-GridView.png)


