function Get-StringMapping
{
	<#
	.SYNOPSIS
		Lists registered string mappings.
	
	.DESCRIPTION
		Lists registered string mappings.
		By default, this command filters by ModuleName.
	
	.PARAMETER Name
		Default: '*'
		Name filter for the search, filtering entries by their placeholder using wildcard comparison.
	
	.PARAMETER ModuleName
		The name of the module to operate for.
		String mappings are automatically assigned per-module, to avoid multiple modules colliding.
		This is automatically detected based on the caller, but the detection might fail in some circumstances.
		Use this parameter to override the automatic detection.
	
	.EXAMPLE
		PS C:\> Get-StringMapping

		Lists all string mappings of the current module

	.EXAMPLE
		PS C:\> Get-StringMapping -ModuleName *

		Lists ALL string mappings, irrespective of module.
	#>
	[CmdletBinding()]
	Param (
		[string]
		$Name = '*',

		[string]
		$ModuleName = [PSFramework.Utility.UtilityHost]::Callstack.InvocationInfo[0].MyCommand.Module.Name
	)
	
	process
	{
		foreach ($key in $script:mapping.Keys) {
			if ($key -notlike $ModuleName) { continue }
			$script:mapping[$key].Values | Where-Object Name -like $Name
		}
	}
}
