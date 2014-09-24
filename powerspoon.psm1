<#
.Synopsis
   Log a user into the current remote registry.
.DESCRIPTION
   This is equivalent of 'spoon login'
.EXAMPLE
   PS C:\> Connect-SpoonUser -Credential (Get-Credential) -Verbose
	VERBOSE: Logged in as username
.LINK
	https://spoonium.net/docs/reference#command-line-login
#>
function Connect-SpoonUser
{
    [CmdletBinding()]
    [OutputType([Void])]
    Param
    (
        # Spoonium.net Username and Password as a PSCredential object
        [Parameter()]
        [PSCredential]
        $Credential = (Get-Credential)
    )

    $username = $Credential.UserName
    $password = $Credential.GetNetworkCredential().Password

    $command = "spoon login $username $password"

    $stringdata = Invoke-Expression $command

    if ($stringdata -eq "Logged in as $username")
    {
        Write-Verbose $stringdata
    }
    else
    {
        Write-Error $stringdata
    }
}

<#
.Synopsis
   Log the current user out of the remote registry.
.DESCRIPTION
   This is equivalent of 'spoon logout'
.EXAMPLE
   PS C:\> Connect-SpoonUser -Verbose
   VERBOSE: username logged out at 9/18/2014 1:27:44 PM
.LINK
	https://spoonium.net/docs/reference#command-line-logout
#>
function Disconnect-SpoonUser
{
    [CmdletBinding()]
    [OutputType([Void])]
    Param()

    $command = "spoon logout"

    $stringdata = Invoke-Expression $command

    if (($stringdata -like "*logged out at*") -or ($stringdata -eq "You are not currently logged into Spoon"))
    {
        Write-Verbose $stringdata
    }
    else
    {
        Write-Error $stringdata
    }
}

<#
.Synopsis
   Lists all of the images present in the local registry.
.DESCRIPTION
   This is equivalent of 'spoon images'. The output is converted to PSCustomObjects.
.EXAMPLE
   PS C:\temp> Get-SpoonImage | ? Name -like *scratch

	ID            : 16764d02a099
	Name          : spoonbrew/scratch
	Tag           :
	Created       : 8/27/2014 8:04:38 PM
	Size          : 0.0MB
	Startup files :
	Settings      : SpawnVm
	Registered    : No
.LINK
	https://spoonium.net/docs/reference#command-line-images
#>
function Get-SpoonImage
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    Param()

    $command = "spoon images --csv"

    $stringdata = Invoke-Expression $command

    $stringdata | ConvertFrom-Csv -Delimiter "`t"
}


<#
.Synopsis
   Syncs an image from a remote registry to your local registry.
.DESCRIPTION
   This is equivalent of 'spoon pull'. 

   The image to pull can be specified with up to 3 identifiers, only 1 of which (the name) is mandatory
.EXAMPLE
   PS C:\> Import-SpoonImage spoonbrew/scratch -Verbose
   VERBOSE: Pull complete
.EXAMPLE
   PS C:\> Import-SpoonImage -Name scratch -Namespace spoonbrew -Verbose
   VERBOSE: Pull complete
.LINK
	https://spoonium.net/docs/reference#command-line-pull
#>
function Import-SpoonImage
{
    [CmdletBinding()]
    [OutputType([Void])]
    Param
    (
        # Name of the remote repository
        [Parameter(Mandatory, Position=0)]
        [string]
        $Name,

        # Namespace (user or org on the remote hub)
        [Parameter(Position=1)]
        [string]
        $Namespace,

        # Tag
        [Parameter(Position=2)]
        [string]
        $Tag
    )

    $fqn = $Name

    if ($PSBoundParameters.ContainsKey("Namespace"))
    {
        $fqn = $Namespace + '/' + $fqn
    }

    if ($PSBoundParameters.ContainsKey("Tag"))
    {
        $fqn = $fqn + ':' + $Tag
    }

    $command = "spoon pull $fqn"

    $stringdata = Invoke-Expression $command | out-string

    Write-Verbose $stringdata
}

<#
.Synopsis
   Builds an image from a container.
.DESCRIPTION
   This is equivalent of 'spoon commit'.

   The image is built from the container's most recent state.
.EXAMPLE
   TODO
.NOTE
	A container must be stopped before it can be committed to an image.
.LINK
	https://spoonium.net/docs/reference#command-line-commit
#>
function Convert-SpoonContainerToImage
{
    [CmdletBinding()]
    [OutputType([Void])]
    Param
    (
        # Container ID
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0)]
        $ID,

        # Name of the image
		[Parameter(Mandatory,Position=1)]
        [string]
        $Name,

		# Overwrite            
		[Parameter()]
        [switch]
        $Force
    )

	$command = "spoon commit $ID $Name"

	$stringdata = Invoke-Expression $command | out-string

	Write-Verbose $stringdata
}


<#
.Synopsis
   Builds an image from a container.
.DESCRIPTION
   This is equivalent of 'spoon commit'.

   The image is built from the container's most recent state.
.EXAMPLE
   TODO
.NOTE
	A container must be stopped before it can be committed to an image.
.LINK
	https://spoonium.net/docs/reference#command-line-commit
#>
function New-SpoonImage
{
    [CmdletBinding(DefaultParameterSetName='Build',
				   HelpUri = 'https://github.com/spoonium/powerspoon/blob/master/README.md')]
    [OutputType([Void])]
    Param
    (
        # Container ID
        [Parameter(ParameterSetName='Commit', Mandatory, ValueFromPipelineByPropertyName,Position=0)]
        $ID,

        # Name of the image
		[Parameter(ParameterSetName='Commit', Mandatory, Position=1)]
		[Parameter(ParameterSetName='Build', Position=1)]
        [string]
        $Name,

		# New-SpoonImage can build images from a SpoonScript or a .xappl configuration file.
		[Parameter(ParameterSetName='Build', Mandatory, ValueFromPipelineByPropertyName, Position=0)]
        [string]
        $Path,

		# Set environment variables inside the container
		[Parameter(ParameterSetName='Build', Position=2)]
        [Hashtable]
        $EnvironmentVariables,

		# The Spoon VM version to run the container with
		[Parameter(ParameterSetName='Build', Position=3)]
		[ValidatePattern("\d{1,3}.\d{1,3}.\d{1,3}")]
        [string]
        $Version,

		# Set the initial working directory inside the container
		[Parameter(ParameterSetName='Build', Position=4)]
        [string]
        $WorkingDirectory,

        # Enable diagnotic logging
		[Parameter(ParameterSetName='Build')]
        [switch]
        $Diagnotic,

        # Do not merge the base image(s) into the new image
		[Parameter(ParameterSetName='Build')]
        [switch]
        $NoBase,

        # Leave program open after error
		[Parameter(ParameterSetName='Build')]
        [switch]
        $Wait,

		# Overwrite            
		[Parameter(ParameterSetName='Commit')]
		[Parameter(ParameterSetName='Build')]
        [switch]
        $Force
    )

	if ($PSCmdlet.ParameterSetName -eq  'Commit')
	{
		$command = "spoon commit $ID $Name"		

		if ($Force)
		{
			$command += ' --overwrite'
		}
	}
	else
	{
		$command = 'spoon build'
		
		switch ($PSBoundParameters)
		{
			$_.ContainsKey('Name') {$command += " --n=$Name"}
			$_.ContainsKey('EnvironmentVariables') {
				foreach ($key in $EnvironmentVariables.Keys)
				{
					$value = $EnvironmentVariables[$key]
					$command += " --env=$key=$value"
				}
			}
			$_.ContainsKey('Version') {$command += " --vm=$Version"}
			$_.ContainsKey('WorkingDirectory') {$command += " --working-dir=$WorkingDirectory"}
			$_.ContainsKey('Diagnotic') {$command += " --diagnostic "}
			$_.ContainsKey('NoBase') {$command += " --no-base"}
			$_.ContainsKey('Wait') {$command += " --wait-after-error "}
		}

		$command += " $Path"
	}

	$stringdata = Invoke-Expression $command
	
	Write-Verbose "COMMAND: $command"
	Write-Verbose "RESULTS: $stringdata"
}

<#
.Synopsis
   Start a new container with an specified image.
.DESCRIPTION
   This is equivalent of 'spoon run'.

   The image to run can be specified with up to 3 identifiers, only 1 of which (the name) is mandatory
.EXAMPLE
   PS C:\> Get-SpoonImage | ? Name -Like *scratch | Start-SpoonContainer

	ID                                            ExitCode                                                                                           
	-----------                                   --------                                                                                           
	03887d95013a4ff9af50a498ab594646              0x0      
#>
function Start-SpoonContainer
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    Param
    (
        # Name of the local repository
        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        # Namespace (user or org)
        [Parameter(Position=1)]
        [string]
        $Namespace,

        # Tag
        [Parameter(Position=2)]
        [string]
        $Tag
    )

    $fqn = $Name

    if ($PSBoundParameters.ContainsKey("Namespace"))
    {
        $fqn = $Namespace + '/' + $fqn
    }

    if ($PSBoundParameters.ContainsKey("Tag"))
    {
        $fqn = $fqn + ':' + $Tag
    }

    $command = "spoon run $fqn"

    $stringdata = Invoke-Expression $command

	Write-Output ([PSCustomObject]@{ID = $stringdata[0]
									ExitCode = $stringdata[1].Split(' ')[-1]}
				 )    
}

<#
.Synopsis
   Lists all containers on the local machine.
.DESCRIPTION
   This is equivalent of 'spoon containers'.
.EXAMPLE
   TODO
.LINK
	https://spoonium.net/docs/reference#command-line-containers
#>
function Get-SpoonContainer
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    Param
    (
        # List the most recently created container
        [Parameter()]
        [Switch]
        $Latest
    )


    $command = "spoon containers --csv"

	if ($Latest)
	{
		$command += " --latest"
	}

    $stringdata = Invoke-Expression $command

    $stringdata | ConvertFrom-Csv -Delimiter "`t"
}
