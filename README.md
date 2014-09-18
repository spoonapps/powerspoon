powerspoon
==========

Powershell module wrapping Spoonium CLI

### Usage

#### Start a container

```powershell
PS C:\> Get-SpoonImage | ? Name -Like *scratch | Start-SpoonContainer

ID                                            ExitCode                                                                                           
-----------                                   --------                                                                                           
03887d95013a4ff9af50a498ab594646              0x0       
```

#### Pull down an image from [spoonium.net](http://spoonium.net)

```powershell
PS C:\> Connect-SpoonUser -Credential (Get-Credential) -Verbose
VERBOSE: Logged in as username

PS C:\> Import-SpoonImage spoonbrew/scratch -Verbose
VERBOSE: Pull complete

Get-SpoonImage | Format-Table -AutoSize

ID           Name                Tag   Created               Size   Startup files
--           ----                ---   -------               ----   -------------
16764d02a099 spoonbrew/scratch         8/27/2014 8:04:38 PM  0.0MB
67ca86a2d82c spoonbrew/wget            8/20/2014 12:45:43 PM 2.9MB

```
