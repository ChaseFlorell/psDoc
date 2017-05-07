function TrimAllLines([string] $str) {
	$lines = $str -split "`n"

	for ($i = 0; $i -lt $lines.Count; $i++) {
		$lines[$i] = $lines[$i].Trim()
	}

	# Trim EOL.
	($lines | Out-String).Trim()
}

function FixMarkdownString([string] $in = '', [bool] $includeBreaks = $false, [bool]$BlankStringToSpace = $False) {

	if ($in -eq $null) { return }
	
	if($in -eq "" -and $BlankStringToSpace ) { return " " }

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

function IncludeTableOfContents {

	return "{toc:printable=true|style=square|maxLevel=2|indent=5px|minLevel=2|class=bigpink|exclude=[1//2]|type=list|outline=true|include=.*}"
}


@"
h1. $moduleName

$(IncludeTableOfContents)

\\
\\
"@


$progress = 0
$commandsHelp | % {
	Update-Progress $_.Name 'Documentation'
	$progress++
@"
h2. $(FixMarkdownString($_.Name))
"@
	$synopsis = $_.synopsis.Trim()
	$syntax = $_.syntax | out-string
	if(-not ($synopsis -ilike "$($_.Name.Trim())*")){
		$tmp = $synopsis
		$synopsis = $syntax
		$syntax = $tmp
@"	
h3. Synopsis
$(FixMarkdownString($syntax))
"@
	}
	
	
@"
h3. Description
$(FixMarkdownString $(($_.Description  | out-string).Trim()) $true)
"@	

@"	
h3. Syntax
{code:theme=Confluence|linenumbers=false|language=Powershell|firstline=0001|collapse=false}
$(TrimAllLines $synopsis)
{code}
"@	

	if (!($_.alias.Length -eq 0)) {
@"
h3. $($_.Name) Aliases
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
h3. Parameters

||Name||Alias||Description||Required?||Pipeline Input||Default Value||
"@
		$_.parameters.parameter | % {
@"
|$(FixMarkdownString $_.Name $false $true)|$(FixMarkdownString $_.Aliases  $false $true)|$(FixMarkdownString $($_.Description  | out-string).Trim() $true $true)|$(FixMarkdownString $_.Required $false $true)|$(FixMarkdownString $_.PipelineInput $false $true)|$(FixMarkdownString $_.DefaultValue $false $true)|
"@
		}
@"


"@
	}
	$inputTypes = $(FixMarkdownString($_.inputTypes  | out-string))
	if ($inputTypes.Length -gt 0 -and -not $inputTypes.Contains('inputType')) {
@"
h3. Inputs
 - $inputTypes

"@
	}
	$returnValues = $(FixMarkdownString($_.returnValues  | out-string))
	if ($returnValues.Length -gt 0 -and -not $returnValues.StartsWith("returnValue")) {
@"
h3. Outputs
 - $returnValues

"@
	}
	$notes = $(FixMarkdownString($_.alertSet  | out-string))
	if ($notes.Trim().Length -gt 0) {
@"
h3. Note
$notes

"@
	}
	if(($_.examples | Out-String).Trim().Length -gt 0) {
@"
h3. Examples
"@
		$_.examples.example | % {
@"
{code:title=$(FixMarkdownString($_.title.Trim(('-',' '))))|theme=Confluence|linenumbers=true|language=Powershell|firstline=0001|collapse=false}
$(FixMarkdownCodeString($_.code | out-string ))
{code}

$(FixMarkdownString($_.remarks | out-string ) $true)
"@
		}
	}
	if(($_.relatedLinks | Out-String).Trim().Length -gt 0) {
@"
h3. Links

"@
		$_.links | % { 
@"
 - [$_.name]($_.link) 
"@
		}
	}
	
@"

\\
\\
\\
----
\\
\\
\\

"@

}