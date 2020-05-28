# Description

Module to implement string mappings and inserting values into strings.

## Installation

To install the module from the PSGallery, run:

```powershell
Install-Module ResolveString
```

## Examples

```powershell
# Register a new mapping
Register-StringMapping -Name '%Date%' -Value (Get-Date -Format 'yyyy-MM-dd') -ModuleName MyModule

# Resolve a string based on the available mappings
Resolve-String -Text 'Today is the date %Date%, it is going to be awesome' -ModuleName MyModule
```

> Note: The ModuleName parameter is optional and will automatically insert the caller's module name.
It is only specified in order to be able to run the demo code interactively.

```powershell
# Register a new mapping, the value of which will be calculated at resolution time
Register-StringMapping -Name '%Date%' -Scriptblock { Get-Date -Format 'yyyy-MM-dd' } -ModuleName MyModule

# Resolve a string based on the available mappings, inserting the dynamically calculated date
Resolve-String -Text 'Today is the date %Date%, it is going to be awesome' -ModuleName MyModule
```
