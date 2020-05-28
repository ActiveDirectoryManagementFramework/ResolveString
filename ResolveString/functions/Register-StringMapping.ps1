function Register-StringMapping {
	<#
	.SYNOPSIS
		Registers a string to insert for the specified name label.
	
	.DESCRIPTION
		Registers a string to insert for the specified name label.
		Alternatively you can also store a scriptblock, that will be executed at runtime to generate the value to insert.
	
	.PARAMETER Name
		The name of the placeholder to insert into.
		Only accepts values that do not contain regex special characters (such as "\" or ".").
		Choose the name with care, as _and_ match will be replaced, so it should be unlikely to occur by accident.

		- Bad name: "computer"
		- Better name: "%computer%"
	
	.PARAMETER Value
		The string value to insert into the placeholder defined in the Name parameter.
	
	.PARAMETER Scriptblock
		A scriptblock that should be executed at runtime to calculate the values to insert.
		Keep scaling in mind as you use this parameter:
		If script execution takes a bit, and you use this command a lot, scriptblock execution time might add up to significant delays.
		Scriptblocks will only be executed if their values are actually used in the replacement string.
		Consider caching schemes if performance is a concern.
	
	.PARAMETER ModuleName
		The name of the module to operate for.
		String mappings are automatically assigned per-module, to avoid multiple modules colliding.
		This is automatically detected based on the caller, but the detection might fail in some circumstances.
		Use this parameter to override the automatic detection.
	
	.EXAMPLE
		PS C:\> Register-StringMapping -Name '%Date%' -Value (Get-Date -Format 'yyyy-MM-dd')

		Registers the current date under the placeholder %Date%
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[PsfValidateScript('ResolveString.Validate.NoRegex', ErrorString = 'ResolveString.Validate.NoRegex')]
		[string]
		$Name,

		[Parameter(Mandatory = $true, ParameterSetName = 'Value', ValueFromPipelineByPropertyName = $true)]
		[string]
		$Value,

		[Parameter(Mandatory = $true, ParameterSetName = 'Scriptblock', ValueFromPipelineByPropertyName = $true)]
		[Scriptblock]
		$Scriptblock,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[string]
		$ModuleName = [PSFramework.Utility.UtilityHost]::Callstack.InvocationInfo[0].MyCommand.Module.Name
	)
	
	process {
		if (-not $ModuleName) { $ModuleName = '<Unknown>' }

		if (-not $script:mapping[$ModuleName]) { $script:mapping[$ModuleName] = @{ } }
		$script:mapping[$ModuleName][$Name] = [PSCustomObject]@{
			PSTypeName  = 'ResolveString.StringMapping'
			Name        = $Name
			Value       = $Value
			Scriptblock = $Scriptblock
			Type        = $PSCmdlet.ParameterSetName
			ModuleName  = $ModuleName
		}
	}
}
