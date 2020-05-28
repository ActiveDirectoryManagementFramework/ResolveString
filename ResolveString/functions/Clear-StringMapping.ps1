function Clear-StringMapping
{
	<#
	.SYNOPSIS
		Clears all string mappings for the target module.
	
	.DESCRIPTION
		Clears all string mappings for the target module.
		Use this to reset all mappings in one go.
	
	.PARAMETER ModuleName
		The name of the module to operate for.
		String mappings are automatically assigned per-module, to avoid multiple modules colliding.
		This is automatically detected based on the caller, but the detection might fail in some circumstances.
		Use this parameter to override the automatic detection.
	
	.EXAMPLE
		PS C:\> Clear-StringMapping

		Clears all string mappings for the current module.
	#>
	[CmdletBinding()]
	Param (
		[string]
		$ModuleName = [PSFramework.Utility.UtilityHost]::Callstack.InvocationInfo[0].MyCommand.Module.Name
	)
	
	process
	{
		$script:mapping.Remove($ModuleName)
	}
}
