[![Build status](https://ci.appveyor.com/api/projects/status/ga9uuklbvdexw8re?svg=true)](https://ci.appveyor.com/project/beatcracker/psdockerhub)

[![PSDockerHub](https://raw.githubusercontent.com/beatcracker/PSDockerHub/master/Media/PSDockerHub.png)](https://www.powershellgallery.com/packages/PSDockerHub)

# `PSDockerHub`

PSDockerHub is a PowerShell module written to access the official [Docker Hub/Registry](https://hub.docker.com).

# Requirements

* PowerShell 3.0 or higher


# Instructions

```powershell
# One time setup
    # Download the repository
    # Unblock the zip
    # Extract the PSDockerHub folder to a module path (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules\)

    #Simple alternative, if you have PowerShell 5, or the PowerShellGet module:
        Install-Module PSDockerHub

# Import the module.
    Import-Module PSDockerHub    #Alternatively, Import-Module \\Path\To\PSDockerHub

# Get commands in the module
    Get-Command -Module PSDockerHub

# Get help
    Get-Help Find-DockerImage -Full
    Get-Help about_PSDockerHub
```


# Functions

- [Find-DockerImage](#Find-DockerImage)
- [Get-DockerImageDetail](#Get-DockerImageDetail)
- [Get-DockerImageTag](#Get-DockerImageTag)
- [Get-DockerImageBuildDetail](#Get-DockerImageBuildDetail)
- [Get-DockerImageBuildHistory](#Get-DockerImageBuildHistory)
- [Get-DockerImageDockerfile](#Get-DockerImageDockerfile)

## Find-DockerImage
Search for docker images on Docker Hub via Docker Hub API. You can filter search by `Name/Description`, `Stars`, `Downloads`, `Official` images and `Automated` builds.

### Example

#### Search for [MariaDB](https://mariadb.org) docker images, sort by downloads. Then find images built on [Alpine Linux](https://www.alpinelinux.org) using PowerShell filtering.

```posh
'mariadb' | Find-DockerImage -SortBy Downloads -MaxResults 100 | ? Name -Like '*alpine*'
```
```no-highlight
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
'mariadb' | Find-DockerImage -SortBy Downloads -MaxResults 100 | Out-GridView
```

![Out-GridView](https://raw.githubusercontent.com/beatcracker/PSDockerHub/master/Media/Out-GridView.png)

#### Get most downloaded docker images:
```posh
Find-DockerImage -SortBy Downloads
```

#### Get most starred docker images:
```posh
Find-DockerImage -SortBy Stars
```

## Get-DockerImageDetail

Get detailed information for a Docker image, including full description in markdown.

### Example

```posh
'alpine' | Get-DockerImageDetail
```
```no-highlight
Name            : alpine
Owner           : library
Description     : A minimal Docker image based on Alpine Linux with a complete package index and only 5 MB in size!
Active          : True
Updated         : 23.06.2016 22:56:45
Private         : False
Stars           : 1153
Downloads       : 10834546
Official        : True
Automated       : False
FullDescription : # Supported tags and respective `Dockerfile` links...
```

## Get-DockerImageTag

Get Docker image tags for image.

### Example

```posh
'alpine' | Get-DockerImageTag
```
```no-highlight
Name   Size Updated             Id     
----   ---- -------             --     
edge   2 MB 23.06.2016 22:56:45 170603 
latest 2 MB 23.06.2016 22:56:28 170608 
3.4    2 MB 23.06.2016 22:56:22 3272293
3.3    2 MB 23.06.2016 22:56:10 1622498
3.2    2 MB 23.06.2016 22:55:56 170604 
3.1    2 MB 23.06.2016 22:55:39 170605 
2.7    2 MB 02.02.2016 22:50:30 170606 
2.6    2 MB 02.02.2016 22:50:22 170607 
```


## Get-DockerImageBuildDetail

Get Docker image build details. Build history is available only for some [automated builds](https://docs.docker.com/docker-hub/builds/).

### Example

```posh
'jwilder/nginx-proxy' | Get-DockerImageBuildDetail
```
```no-highlight
Name     : jwilder/nginx-proxy
Type     : git
Provider : github
Repo     : git://github.com/jwilder/nginx-proxy.git
Url      : https://github.com/jwilder/nginx-proxy


Tags     :                                                                                                                                                                                                                                       
----------                                                                                                                                                                                                                                       
Name   Source Type   Dockerfile Id                                                                                                                                                                                                               
----   ------ ----   ---------- --                                                                                                                                                                                                               
0.3.0  0.3.0  Tag    /          284672                                                                                                                                                                                                           
0.4.0  0.4.0  Branch /          317837                                                                                                                                                                                                           
0.2.0  0.2.0  Tag    /          143192                                                                                                                                                                                                           
0.1.0  0.1.0  Tag    /          119443                                                                                                                                                                                                           
latest master Branch /          13991     
```

## Get-DockerImageBuildHistory
Get Docker image build history. Build history is available only for some [automated builds](https://docs.docker.com/docker-hub/builds/).

### Example

```posh
'jwilder/nginx-proxy' | Get-DockerImageBuildHistory
```
```no-highlight
Tag       : latest
Status    : Success
Id        : 5581215
BuildCode : ba9fsgpkffixp8udcxdjp2j
Cause     : VCS_CHANGE
Created   : 13.06.2016 17:18:12
Updated   : 13.06.2016 17:24:31

Tag       : latest
Status    : Success
Id        : 5575244
BuildCode : bxvykrwfncpdhzsoypmajme
Cause     : VCS_CHANGE
Created   : 13.06.2016 9:21:40
Updated   : 13.06.2016 9:23:47

Tag       : 0.4.0
Status    : Success
Id        : 5574427
BuildCode : bcppfp2jtnt4s7ke2dhztrb
Cause     : TRIGGERED_VIA_API
Created   : 13.06.2016 6:45:57
Updated   : 13.06.2016 6:47:43   
```

## Get-DockerImageDockerfile
Get Docker image [Dockerfile](https://docs.docker.com/engine/reference/builder/). Build history is available only for some [automated builds](https://docs.docker.com/docker-hub/builds/).

### Example

```posh
'jwilder/nginx-proxy' | Get-DockerImageDockerfile
```
```no-highlight
FROM nginx:1.9.15
MAINTAINER Jason Wilder mail@jasonwilder.com

# Install wget and install/updates certificates
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    ca-certificates \
    wget \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*

# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i 's/^http {/&\n    server_names_hash_bucket_size 128;/g' /etc/nginx/nginx.conf

# Install Forego
ADD https://github.com/jwilder/forego/releases/download/v0.16.1/forego /usr/local/bin/forego
RUN chmod u+x /usr/local/bin/forego

ENV DOCKER_GEN_VERSION 0.7.3

RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && rm /docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

COPY . /app/
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"] 
```