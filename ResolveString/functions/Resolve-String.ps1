function Resolve-String
{
	<#
	.SYNOPSIS
		Resolves any placeholders in the input string.
	
	.DESCRIPTION
		Resolves any placeholders in the input string.
		You can define placeholders using the Register-StringMapping command.

		For example, you could have a string like this:
			"Today is %Date%"
		Expanded to:
			"Today is 2020-05-28"
		(or whatever your current date is).
	
	.PARAMETER Text
		The text to resolve.
	
	.PARAMETER Mode
		Whether to operate in Strict mode (default) or lax mode.
		- Strict Mode: Any error during conversion will fail the conversion with a terminating exception.
		- Lax Mode:    Any error will only cause a warning and return the original input value
	
	.PARAMETER ArgumentList
		Any arguments to send to any insertion scriptblock.
		Using Register-StringMapping, you can either assign a static value to an insertion tag, or you can offer a scriptblock.
		When storing a scriptblock, it will be executed at runtime, receiving the string it was matched to and these arguments as arguments.

	.PARAMETER ModuleName
		The name of the module to operate for.
		String mappings are automatically assigned per-module, to avoid multiple modules colliding.
		This is automatically detected based on the caller, but the detection might fail in some circumstances.
		Use this parameter to override the automatic detection.
	
	.EXAMPLE
		PS C:\> Resolve-String -Text $name -Mode Lax

		Resolves the string stored in $name, without throwing errors.

	.EXAMPLE
		PS C:\> Resolve-String -Text $path -ArgumentList $parameters

		Resolves the string stored in $path, providing the content of variable $parameters as argument to any scriptblock being executed as part of the resolution.
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
	[OutputType([string])]
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline = $true)]
		[AllowEmptyString()]
		[string[]]
		$Text,

		[ValidateSet('Strict', 'Lax')]
		[string]
		$Mode = 'Strict',

		$ArgumentList,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[string]
		$ModuleName = [PSFramework.Utility.UtilityHost]::Callstack.InvocationInfo[0].MyCommand.Module.Name
	)
	
	begin
	{
		#region Resolution Scriptblock
		$replacementScript = {
			param (
				[string]
				$Match
			)

			if ($script:mapping[$ModuleName][$Match]) {
				if($script:mapping[$ModuleName][$Match].Type -eq 'Scriptblock') {
					try { $script:mapping[$ModuleName][$Match].Scriptblock.Invoke($Match, $ArgumentList) -as [string] }
					catch {
						if ($Mode -eq 'Lax') {
							Write-PSFMessage -Level Warning -String 'Resolve-String.Resolution.ItemError' -StringValues $Match, $ModuleName -Exception $_.Exception.InnerException -FunctionName Resolve-String -ModuleName ResolveString
							return $Match
						}
						throw [System.Exception]::new("Error processing $($Match): $($_.Exception.InnerException.Message)", $_.Exception.InnerException)
					}
				}
				else {
					$script:mapping[$ModuleName][$Match].Value
				}
			}
			else { $Match }
		}
		#endregion Resolution Scriptblock
	}
	process
	{
		foreach ($textItem in $Text) {
			# Skip where continuing doesn't make sense
			if (-not $textItem -or
				-not $script:mapping[$ModuleName] -or
				$script:mapping[$ModuleName].Count -eq 0)
			{
				$textItem
				continue
			}

			$pattern = $script:mapping[$ModuleName].Keys -join "|"
			try { [regex]::Replace($textItem, $pattern, $replacementScript, 'IgnoreCase') }
			catch {
				Write-PSFMessage -Level Warning -String 'Resolve-String.Resolution.Error' -StringValues $textItem, $ModuleName -Exception $_.Exception.InnerException
				switch ($Mode) {
					'Strict' { throw }
					'Lax' { $textItem }
				}
			}
		}
	}
}
