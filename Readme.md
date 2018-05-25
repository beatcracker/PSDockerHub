|AppVeyor|PowerShell Gallery|
|:-:|:-:|
|[![Build status](https://ci.appveyor.com/api/projects/status/ga9uuklbvdexw8re?svg=true)](https://ci.appveyor.com/project/beatcracker/psdockerhub)|[![PSDockerHub](https://raw.githubusercontent.com/beatcracker/PSDockerHub/master/Media/PSDockerHub.png)](https://www.powershellgallery.com/packages/PSDockerHub)|

# `PSDockerHub`

PSDockerHub is a PowerShell module written to access the official [Docker Hub/Registry](https://hub.docker.com). Its main goal is to to make sure that you have never had to use the public part of Docker Hub site in the browser.

Most of the APIs used were sniffed using the Chrome DevTools, because there is [significant fragmentation](https://github.com/ngageoint/seed/blob/master/detail.adoc#discovery) of APIs between the various Docker offerings.

You can find API documentation here:

* [Docker Registry HTTP API V2](https://docs.docker.com/registry/spec/api/)

Search API is not documented and, the best I could find is this:

* [Public Docker v2 API Endpoints](http://stackoverflow.com/questions/35444178/public-docker-v2-api-endpoints)
* [docker/hub-feedback: Search uses OR instead of AND to combine terms](https://github.com/docker/hub-feedback/issues/451)

Please note, that at the moment I have no plans to introduce  support of authorization and private repositories.

Suggestions, pull requests and other contributions would be more than welcome!

# Requirements

* PowerShell 3.0 or higher


# Instructions

## Installation

### From [PowerShell Gallery](https://www.powershellgallery.com/)
If you have PowerShell 5, or the PowerShellGet module ([MSI Installer for PowerShell 3 and 4](http://go.microsoft.com/fwlink/?LinkID=746217&clcid=0x409)):

```posh
Install-Module PSDockerHub
```

### From GitHub repo

1. Download the repository
2. Unblock the zip
3. Extract the `PSDockerHub` folder to a module path (e.g. `$env:USERPROFILE\Documents\WindowsPowerShell\Modules\`)

## Usage

```posh
# Import the module
    Import-Module PSDockerHub 

#Alternatively
    Import-Module \\Path\To\PSDockerHub

# Get commands in the module
    Get-Command -Module PSDockerHub

# Get help
    Get-Help Find-DockerImage -Full
    Get-Help about_PSDockerHub
```

# Functions

- [Find-DockerImage](#find-dockerimage)
- [Get-DockerImageDetail](#get-dockerimagedetail)
- [Get-DockerImageTag](#get-dockerimagetag)
- [Get-DockerImageBuildDetail](#get-dockerimagebuilddetail)
- [Get-DockerImageBuildHistory](#get-dockerimagebuildhistory)
- [Get-DockerImageDockerfile](#get-dockerimagedockerfile)

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
'zzrot/whale-awkward' | Get-DockerImageDetail
```
```no-highlight
Name            : whale-awkward
Owner           : zzrot
Description     : Whale, this is awkward
Active          : True
Updated         : 07.04.2016 10:15:54
Private         : False
Stars           : 2
Downloads       : 216653529
Official        : False
Automated       : False
FullDescription : # Whale Awkward
                  [![Docker Pulls](https://img.shields.io/docker/pulls/zzrot/whale-awkward.svg)](https://hub.d
                  ocker.com/r/zzrot/whale-awkward/)
                  
                  
                  Welcome to Whale Awkward! This is a project created by the team at [ZZROT](https://zzrot.com
                  ). We decided it would be fun to build a simple image with a message, and then see how high 
                  we could get it on [Docker-Hub](https://hub.docker.com/).
                  
                  We are currently [ranked 8th](https://hub.docker.com/search/?isAutomated=0&isOfficial=0&page
                  =1&pullCount=1&q=%22%22&starCount=0) amongst all time pulls! [Check it out](https://hub.dock
                  er.com/r/zzrot/whale-awkward/) for yourself.
                  
                  Whale Awkward can be found on [Github](https://github.com/ZZROTDesign/whale-awkward)
                  
                  Whale Awkward was developed by:
                  - [Sean Kilgarriff](https://seankilgarriff.com)
                  - [Killian Brackey](https://killianbrackey.com)
                  
                  Through [ZZROT](https://zzrot.com) - [Github](https://github.com/ZZROTDesign)
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

Get Docker image build details. Build details are available only for some [automated builds](https://docs.docker.com/docker-hub/builds/).

### Example

```posh
'jwilder/nginx-proxy' | Get-DockerImageBuildDetail
```
```no-highlight
Name     : jwilder/nginx-proxy
Provider : github
Type     : git
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
Get Docker image [Dockerfile](https://docs.docker.com/engine/reference/builder/). Dockerfiles are available only for some [automated builds](https://docs.docker.com/docker-hub/builds/).

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
