param(
    [string]$InputRoot = "docs/audit/output",
    [string]$Pattern = "consolidated.json",
    [string]$OutputFile = "docs/audit/output/global/consolidated-global.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-ModuleId {
    param(
        [object]$JsonData,
        [string]$FilePath
    )

    if ($null -ne $JsonData.module_id -and $JsonData.module_id.ToString().Trim().Length -gt 0) {
        return $JsonData.module_id.ToString().Trim().ToUpperInvariant()
    }

    $parent = Split-Path -Path $FilePath -Parent
    $leaf = Split-Path -Path $parent -Leaf
    return $leaf.ToUpperInvariant()
}

function Get-IntSafe {
    param(
        [object]$Value
    )

    if ($null -eq $Value) { return 0 }
    if ($Value -is [int]) { return $Value }
    if ($Value -is [long]) { return [int]$Value }

    $parsed = 0
    if ([int]::TryParse($Value.ToString(), [ref]$parsed)) {
        return $parsed
    }

    return 0
}

if (-not (Test-Path -Path $InputRoot)) {
    throw "Diretorio de entrada nao encontrado: $InputRoot"
}

$files = @(
    Get-ChildItem -Path $InputRoot -Recurse -File -Filter $Pattern |
        Where-Object { $_.FullName -notmatch "[\\/]global[\\/]" }
)

if (-not $files -or $files.Count -eq 0) {
    throw "Nenhum arquivo '$Pattern' encontrado em '$InputRoot'."
}

$moduleMap = @{}
$warnings = New-Object System.Collections.Generic.List[string]

foreach ($file in $files) {
    try {
        $raw = Get-Content -Path $file.FullName -Raw
        $jsonData = $raw | ConvertFrom-Json

        $moduleId = Get-ModuleId -JsonData $jsonData -FilePath $file.FullName
        if ([string]::IsNullOrWhiteSpace($moduleId)) {
            $warnings.Add("Arquivo sem module_id valido: $($file.FullName)")
            continue
        }

        if ($moduleMap.ContainsKey($moduleId)) {
            $warnings.Add("Modulo duplicado '$moduleId'. Mantendo o ultimo arquivo lido: $($file.FullName)")
        }

        $moduleMap[$moduleId] = [PSCustomObject]@{
            module_id = $moduleId
            source_file = $file.FullName
            consolidated_json = $jsonData
        }
    }
    catch {
        $warnings.Add("Falha ao processar JSON em '$($file.FullName)': $($_.Exception.Message)")
    }
}

if ($moduleMap.Count -eq 0) {
    throw "Nenhum consolidated_json valido foi carregado."
}

$orderedModules = $moduleMap.Values | Sort-Object module_id

$aggTotalFindings = 0
$aggBloqueantes = 0
$aggImportantes = 0
$aggMenores = 0
$aggCoberto = 0
$aggParcial = 0
$aggNaoCoberto = 0

foreach ($entry in $orderedModules) {
    $summary = $entry.consolidated_json.executive_summary
    $coverage = $summary.coverage

    $aggTotalFindings += Get-IntSafe -Value $summary.total_findings
    $aggBloqueantes += Get-IntSafe -Value $summary.bloqueantes
    $aggImportantes += Get-IntSafe -Value $summary.importantes
    $aggMenores += Get-IntSafe -Value $summary.menores
    $aggCoberto += Get-IntSafe -Value $coverage.coberto
    $aggParcial += Get-IntSafe -Value $coverage.parcial
    $aggNaoCoberto += Get-IntSafe -Value $coverage.nao_coberto
}

$output = [ordered]@{
    generated_at = (Get-Date).ToString("s")
    input_root = (Resolve-Path -Path $InputRoot).Path
    total_modules = $orderedModules.Count
    module_ids = @($orderedModules.module_id)
    aggregate_executive_summary = [ordered]@{
        total_findings = $aggTotalFindings
        bloqueantes = $aggBloqueantes
        importantes = $aggImportantes
        menores = $aggMenores
        coverage = [ordered]@{
            coberto = $aggCoberto
            parcial = $aggParcial
            nao_coberto = $aggNaoCoberto
        }
    }
    modules = @($orderedModules)
    warnings = @($warnings)
}

$outDir = Split-Path -Path $OutputFile -Parent
if (-not (Test-Path -Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

$output | ConvertTo-Json -Depth 30 | Set-Content -Path $OutputFile -Encoding UTF8

Write-Host "Relatorio global gerado em: $OutputFile"
Write-Host "Modulos agregados: $($orderedModules.Count)"
if ($warnings.Count -gt 0) {
    Write-Warning "Gerado com avisos: $($warnings.Count). Verifique o campo 'warnings' no JSON de saida."
}
