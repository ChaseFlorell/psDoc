function TrimAllLines([string] $str) {
	$lines = $str -split "`n"

	for ($i = 0; $i -lt $lines.Count; $i++) {
		$lines[$i] = $lines[$i].Trim()
	}

	# Trim EOL.
	($lines | Out-String).Trim()
}

function FixMarkdownString([string] $in = '', [bool] $includeBreaks = $false) {
	if ($in -eq $null) { return }

	$replacements = @{
		'\' = '\\'
		'`' = '\`'
		'*' = '\*'
		'_' = '\_'
		'{' = '\{'
		'}' = '\}'
		'[' = '\['
		']' = '\]'
		'(' = '\('
		')' = '\)'
		'#' = '\#'
		'+' = '\+'
		'!' = '\!'
	}

	$rtn = $in.Trim()
	foreach ($key in $replacements.Keys) {
		$rtn = $rtn.Replace($key, $replacements[$key])
	}

	$rtn = TrimAllLines $rtn

	if ($includeBreaks) {
		$crlf = [Environment]::NewLine
		$rtn = $rtn.Replace($crlf, "  $crlf")
	}
	$rtn
}

function FixMarkdownCodeString([string] $in) {
	if ($in -eq $null) { return }
	
	TrimAllLines $in
}

@"
# $moduleName
"@
$progress = 0
$commandsHelp | % {
	Update-Progress $_.Name 'Documentation'
	$progress++
@"
## $(FixMarkdownString($_.Name))
"@
	$synopsis = $_.synopsis.Trim()
	$syntax = $_.syntax | out-string
	if(-not ($synopsis -ilike "$($_.Name.Trim())*")){
		$tmp = $synopsis
		$synopsis = $syntax
		$syntax = $tmp
@"	
### Synopsis
$(FixMarkdownString($syntax))
"@
	}
@"	
### Syntax
$(FixMarkdownString($synopsis))
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
			<td><nobr>$(FixMarkdownString($_.Name))</nobr></td>
			<td class="visible-lg visible-md">$(FixMarkdownString($_.Aliases))</td>
			<td>$(FixMarkdownString(($_.Description  | out-string).Trim()) $true)</td>
			<td class="visible-lg visible-md">$(FixMarkdownString($_.Required))</td>
			<td class="visible-lg">$(FixMarkdownString($_.PipelineInput))</td>
			<td class="visible-lg">$(FixMarkdownString($_.DefaultValue))</td>
		</tr>
"@
		}
@"
	</tbody>
</table>			
"@
	}
	$inputTypes = $(FixMarkdownString($_.inputTypes  | out-string))
	if ($inputTypes.Length -gt 0 -and -not $inputTypes.Contains('inputType')) {
@"
### Inputs
 - $inputTypes

"@
	}
	$returnValues = $(FixMarkdownString($_.returnValues  | out-string))
	if ($returnValues.Length -gt 0 -and -not $returnValues.StartsWith("returnValue")) {
@"
### Outputs
 - $returnValues

"@
	}
	$notes = $(FixMarkdownString($_.alertSet  | out-string))
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
**$(FixMarkdownString($_.title.Trim(('-',' '))))**

		$(FixMarkdownCodeString($_.code | out-string ))
		
$(FixMarkdownString($_.remarks | out-string ) $true)
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