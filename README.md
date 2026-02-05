p3ng0s
=========
*A self made linux distro - NOT MADE FOR CONVENIENT PUBLIC USE MADE FOR SELFISH NEEDS*

![iso_logo](https://github.com/p3ng0s/archlive/raw/main/assets/favicon.png)


# IMPORTANT NOTICE
Currently the project is going through a restructure. I have the following problem
the iso is based from arch linux of years ago so now a lot changed and is super broken
the old iso is so outdated its not worth using. The idea is this I am going to change
the structure so that most of the work will be done on packager to properly package
everything needed for the repo. this actual repo will be some sort of auto generated
this where it will take the files in airootfs and just inject them in the latest
mkarchiso template then from there hopefully it will be easier to maintain for me down
the line. This idea will also hopefully make the docker container good for anyone else
to use instead of just beeing fucking useless. If you want to follow the restructure
along you can look at the branch named V1 basically this old one was V0 something
where i was learninig all of this now V1 will be the proper distro so that i can ship
it out for people to use.

Please view [this](https://leosmith.wtf/rice/) wiki for more informaiton.

## build tutorial
To build the iso just download the dependencies and run the command build.sh as
a normal user.

```
$ ./build.sh
```
