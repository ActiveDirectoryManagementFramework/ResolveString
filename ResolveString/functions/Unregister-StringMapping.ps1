function Unregister-StringMapping
{
	<#
	.SYNOPSIS
		Removes a specific string mappping from the list of mappings.
	
	.DESCRIPTION
		Removes a specific string mappping from the list of mappings.
	
	.PARAMETER Name
		The specific name of the string mapping to unregister.
	
	.PARAMETER ModuleName
		The name of the module to operate for.
		String mappings are automatically assigned per-module, to avoid multiple modules colliding.
		This is automatically detected based on the caller, but the detection might fail in some circumstances.
		Use this parameter to override the automatic detection.
	
	.EXAMPLE
		PS C:\> Unregister-StringMapping -Name '%Date%'

		Removes the %Date% string mapping from the current module's string mapping store.
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[string]
		$Name,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[string]
		$ModuleName = [PSFramework.Utility.UtilityHost]::Callstack.InvocationInfo[0].MyCommand.Module.Name
	)
	
	process
	{
		if (-not $script:mapping[$ModuleName]) { return }

		$script:mapping[$ModuleName].Remove($Name)
	}
}
