@"
# $moduleName
"@
$progress = 0
$commandsHelp | % {
	Update-Progress $_.Name 'Documentation'
	$progress++
@"
## $(FixString($_.Name))
"@
	$synopsis = $_.synopsis.Trim()
	$syntax = $_.syntax | out-string
	if(-not ($synopsis -ilike "$($_.Name.Trim())*")){
		$tmp = $synopsis
		$synopsis = $syntax
		$syntax = $tmp
@"	
### Synopsis
$(FixString($syntax))
"@
	}
@"	
### Syntax
$(FixString($synopsis))
"@	

	if (!($_.alias.Length -eq 0)) {
@"
### $($_.Name) Aliases
"@
		$_.alias | % {
@"
 - $($_.Name)
"@
		}
@"

"@
	}
	
    if($_.parameters){
@"
### Parameters

<table class="table table-striped table-bordered table-condensed visible-on">
	<thead>
		<tr>
			<th>Name</th>
			<th class="visible-lg visible-md">Alias</th>
			<th>Description</th>
			<th class="visible-lg visible-md">Required?</th>
			<th class="visible-lg">Pipeline Input</th>
			<th class="visible-lg">Default Value</th>
		</tr>
	</thead>
	<tbody>
"@
        $_.parameters.parameter | % {
@"
		<tr>
			<td><nobr>$(FixString($_.Name))</nobr></td>
			<td class="visible-lg visible-md">$(FixString($_.Aliases))</td>
			<td>$(FixString(($_.Description  | out-string).Trim()) $true)</td>
			<td class="visible-lg visible-md">$(FixString($_.Required))</td>
			<td class="visible-lg">$(FixString($_.PipelineInput))</td>
			<td class="visible-lg">$(FixString($_.DefaultValue))</td>
		</tr>
"@
        }
@"
	</tbody>
</table>			
"@
    }
    $inputTypes = $(FixString($_.inputTypes  | out-string))
    if ($inputTypes.Length -gt 0 -and -not $inputTypes.Contains('inputType')) {
@"
### Inputs
 - $inputTypes

"@
	}
    $returnValues = $(FixString($_.returnValues  | out-string))
    if ($returnValues.Length -gt 0 -and -not $returnValues.StartsWith("returnValue")) {
@"
### Outputs
 - $returnValues

"@
	}
    $notes = $(FixString($_.alertSet  | out-string))
    if ($notes.Trim().Length -gt 0) {
@"
### Note
$notes

"@
	}
	if(($_.examples | Out-String).Trim().Length -gt 0) {
@"
### Examples
"@
		$_.examples.example | % {
@"
**$(FixString($_.title.Trim(('-',' '))))**

		$(FixString($_.code | out-string ))
		
$(FixString($_.remarks | out-string ))
"@
		}
	}
	if(($_.relatedLinks | Out-String).Trim().Length -gt 0) {
@"
### Links

"@
		$_.links | % { 
@"
 - [$_.name]($_.link)
"@
		}
	}
}