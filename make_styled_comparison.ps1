param(
    [string]$TemplatePath = 'D:\nutritionplanskill\Comparacion_Precios_Semanal_20260704_012300.xlsx',
    [string]$OutputPath = (Join-Path (Get-Location) ("Comparacion_Precios_Semanal_{0}.xlsx" -f (Get-Date -Format 'yyyyMMdd_HHmmss')))
)

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function E([string]$t) { [System.Security.SecurityElement]::Escape($t) }
function TC([string]$r, [string]$v, [int]$s) { "<c r=""$r"" s=""$s"" t=""inlineStr""><is><t>$(E $v)</t></is></c>" }
function NC([string]$r, [double]$v, [int]$s) { "<c r=""$r"" s=""$s"" t=""n""><v>$([string]::Format([cultureinfo]::InvariantCulture, '{0:0.00}', $v))</v></c>" }
function BC([string]$r, [int]$s) { "<c r=""$r"" s=""$s"" t=""inlineStr""><is><t></t></is></c>" }

$items = @(
    [pscustomobject]@{I='Huevos';Q='12 unidades';MP='Huevo Rosado Con Dha ARO';MQ='30 un';MV=17.40;MT=17.40;MU='https://www.makro.plazavea.com.pe/huevo-rosado-con-dha-aro-paquete-30un/p';PP='Huevos Pardos LA CALERA';PQ='15 un';PV=11.49;PT=11.49;PU='https://www.plazavea.com.pe/huevos-pardos-la-calera-bandeja-15un/p';TP='Huevos Pardos Tottus';TQ='1 bandeja (15 und)';TV=11.00;TT=11.00;TU='https://www.tottus.com.pe/tottus-pe/articulo/113927690/huevos-pardos-tottus-bandeja-15-und/113927691'}
    [pscustomobject]@{I='Pechuga de pollo';Q='750 g';MP='Filete de Pechuga de Pollo SADIA';MQ='1 kg';MV=14.90;MT=14.90;MU='https://www.makro.plazavea.com.pe/filete-de-pechuga-de-pollo-sadia-bolsa-1kg-20145201/p';PP='Filete de Pechuga de Pollo SADIA';PQ='1 kg';PV=14.90;PT=14.90;PU='https://www.plazavea.com.pe/filete-de-pechuga-de-pollo-sadia-bolsa-1kg-20145201/p';TP='Pechuga Especial De Pollo Importada';TQ='0.75kg (aprox)';TV=9.38;TT=9.38;TU='https://www.tottus.com.pe/tottus-pe/articulo/115844571/pechuga-especial-de-pollo-importada/115844572'}
    [pscustomobject]@{I='Tilapia';Q='800 g';MP='Filete de Tilapia ARO 2/3';MQ='1 kg';MV=13.40;MT=13.40;MU='https://www.makro.plazavea.com.pe/filete-de-tilapia-aro-23-balde-1kg-20568892/p';PP='Tilapia Entera AQUA PERU';PQ='1 kg';PV=9.90;PT=9.90;PU='https://www.plazavea.com.pe/tilapia-entera-aqua-peru-refrigerada-xkg/p';TP='Filete de Tilapia Tottus';TQ='0.8kg (aprox)';TV=14.32;TT=14.32;TU=$null}
    [pscustomobject]@{I='Lomo fino';Q='500 g';MP='Lomo Fino TERNEZ';MQ='1 kg';MV=84.90;MT=84.90;MU='https://www.makro.plazavea.com.pe/lomo-fino-ternez-x-kg-20215497/p';PP='Lomo Fino PORCIONADO FRIGON';PQ='0.8 kg';PV=69.90;PT=69.90;PU='https://www.plazavea.com.pe/lomo-fino-porcionado-frigon-x-kg-20328446/p';TP='No disponible';TQ='-';TV=$null;TT=$null;TU=$null}
    [pscustomobject]@{I='Yogur griego';Q='1 kg';MP='Yogurt Griego VAKIMU Original';MQ='960 g';MV=15.90;MT=15.90;MU='https://www.makro.plazavea.com.pe/yogurt-griego-vakimu-original-balde-1kg/p';PP='Yogurt Griego VAKIMU Original';PQ='960 g';PV=14.70;PT=14.70;PU='https://www.plazavea.com.pe/yogurt-griego-vakimu-original-balde-1kg/p';TP='Yogurt Griego TIGO Sin Azucar';TQ='1 pote (1kg)';TV=16.90;TT=16.90;TU=$null}
    [pscustomobject]@{I='Gloria Pro Power';Q='6 unidades';MP='Bebida Lactea GLORIA Pro Power Caramel Macchiato';MQ='1 botella';MV=7.50;MT=45.00;MU='https://www.makro.plazavea.com.pe/bebida-lactea-gloria-pro-power-caramel-macchiato-botella-320ml-20502734/p';PP='Bebida Lactea GLORIA Pro Power Caramel Macchiato';PQ='1 botella';PV=7.50;PT=45.00;PU='https://www.plazavea.com.pe/bebida-lactea-gloria-pro-power-caramel-macchiato-botella-320ml-20502734/p';TP='Gloria Pro Day Chocolate Sixpack';TQ='1 sixpack (6x320mL)';TV=29.90;TT=29.90;TU=$null}
    [pscustomobject]@{I='Palta';Q='700 g';MP='Palta Fuerte';MQ='x kg';MV=7.00;MT=4.90;MU='https://www.makro.plazavea.com.pe/palta-fuerte-x-k-g-1/p';PP='Palta Fuerte';PQ='x kg';PV=7.17;PT=5.02;PU='https://www.plazavea.com.pe/palta-fuerte-x-k-g-1/p';TP='Palta Fuerte Sin Madurar x Kg';TQ='0.7kg (aprox)';TV=5.10;TT=5.10;TU=$null}
    [pscustomobject]@{I='Tomate';Q='880 g';MP='Tomate Italiano';MQ='x kg';MV=6.20;MT=5.46;MU='https://www.makro.plazavea.com.pe/tomate-italiano-xk-g-1/p';PP='Tomate Italiano';PQ='x kg';PV=6.29;PT=5.54;PU='https://www.plazavea.com.pe/tomate-italiano-xk-g-1/p';TP='Tomate Italiano Tottus';TQ='0.88kg (aprox)';TV=5.02;TT=5.02;TU=$null}
    [pscustomobject]@{I='Pepino';Q='770 g';MP='Pepinillo Paquete';MQ='1 un';MV=0.99;MT=0.99;MU='https://www.makro.plazavea.com.pe/pepinillo-paquete-1un-mk/p';PP='Pepinillo x kg';PQ='2 x 0.5 kg';PV=2.29;PT=4.58;PU='https://www.plazavea.com.pe/pepinillo-x-k-g-1/p';TP='Pepino Tottus';TQ='0.77kg (aprox)';TV=1.46;TT=1.46;TU=$null}
    [pscustomobject]@{I='Camote';Q='600 g';MP='Camote Amarillo Procesado';MQ='x kg';MV=3.59;MT=2.15;MU='https://www.makro.plazavea.com.pe/camote-amarillo-procesado-x-k-g-1/p';PP='Camote Amarillo Procesado';PQ='x kg';PV=3.99;PT=2.79;PU='https://www.plazavea.com.pe/camote-amarillo-procesado-x-k-g-1/p';TP='Camote Amarillo Tottus';TQ='0.6kg (aprox)';TV=2.58;TT=2.58;TU=$null}
    [pscustomobject]@{I='Papa';Q='800 g';MP='Papa Blanca Yungay';MQ='x kg';MV=2.99;MT=2.39;MU='https://www.makro.plazavea.com.pe/papa-blanca-yung-1ay-x-k-g-1/p';PP='Papa Blanca Yungay';PQ='x kg';PV=2.99;PT=2.39;PU='https://www.plazavea.com.pe/papa-blanca-yung-1ay-x-k-g-1/p';TP='Papa Blanca Yungay Natural x Kg';TQ='0.8kg (aprox)';TV=2.56;TT=2.56;TU=$null}
    [pscustomobject]@{I='Fresas';Q='350 g';MP='Fresa Entera Bandeja';MQ='700 g';MV=14.50;MT=14.50;MU='https://www.makro.plazavea.com.pe/fresa-entera-bandeja-x-700g-1-aprox/p';PP='Fresa IMPERIAL Bandeja';PQ='500 g';PV=12.99;PT=12.99;PU='https://www.plazavea.com.pe/fresa-imperial-bandeja-500g-1/p';TP='Fresas Extra Tottus';TQ='1 empaque (500g)';TV=13.29;TT=13.29;TU=$null}
    [pscustomobject]@{I='Platano';Q='1 unidad';MP='Platano Palillo Bolsa';MQ='5 un';MV=5.89;MT=5.89;MU='https://www.makro.plazavea.com.pe/platano-palillo-bolsa-5un-mk/p';PP='Platano Palillo';PQ='1 un';PV=1.89;PT=1.89;PU='https://www.plazavea.com.pe/platano-palillo-x-k-g-1/p';TP='Platano Palillo';TQ='1 unidad';TV=1.89;TT=1.89;TU=$null}
    [pscustomobject]@{I='Galletas de arroz Costeno';Q='45 unidades';MP='No disponible';MQ='-';MV=$null;MT=$null;MU=$null;PP='Galleta de Arroz COSTENO Clasica';PQ='150 g';PV=7.20;PT=7.20;PU='https://www.plazavea.com.pe/galleta-de-arroz-costeno-clasica-150g/p';TP='Galletas Arroz Costeno 150g';TQ='1 bolsa (150 g)';TV=7.20;TT=7.20;TU='https://www.tottus.com.pe/tottus-pe/articulo/113707782/Galletas%20de%20Arroz%20Cl%C3%A1sicas%20Coste%C3%B1o%20150%20g/113707783'}
    [pscustomobject]@{I='Almendras';Q='80 g';MP='Almendra ARO';MQ='500 g';MV=33.90;MT=33.90;MU='https://www.makro.plazavea.com.pe/almendra-aro-taper-500g/p';PP='Almendras VILLA NATURA';PQ='80 g';PV=7.90;PT=7.90;PU='https://www.plazavea.com.pe/almendras-villa-natura-bolsa-80g/p';TP='Almendras Tottus';TQ='1 bolsa (100g)';TV=7.10;TT=7.10;TU=$null}
)

$makroTotal = [math]::Round((($items | ForEach-Object { if($null -ne $_.MT){ [double]$_.MT } else { 0 } } | Measure-Object -Sum).Sum), 2)
$plazaTotal = [math]::Round((($items | ForEach-Object { if($null -ne $_.PT){ [double]$_.PT } else { 0 } } | Measure-Object -Sum).Sum), 2)
$tottusTotal = [math]::Round((($items | ForEach-Object { if($null -ne $_.TT){ [double]$_.TT } else { 0 } } | Measure-Object -Sum).Sum), 2)
$tottusMissing = ($items | Where-Object { $null -eq $_.TT }).Count
$retrievedRows = ($items | Where-Object { $null -ne $_.MT -and $null -ne $_.PT -and $null -ne $_.TT }).Count
$retrievalRate = [math]::Round(($retrievedRows / [double]$items.Count), 4)
$allLinks = @()
foreach($it in $items){
    if($null -ne $it.MU){ $allLinks += $it.MU }
    if($null -ne $it.PU){ $allLinks += $it.PU }
    if($null -ne $it.TU){ $allLinks += $it.TU }
}
$directLinks = $allLinks | Where-Object { $_ -match '/(articulo|p)(/|$)' }
$directLinkRate = if($allLinks.Count -gt 0){ [math]::Round(($directLinks.Count / [double]$allLinks.Count), 4) } else { 0 }
$runStatus = if($retrievalRate -ge 0.9 -and $directLinkRate -ge 0.9){ 'successful' } else { 'partial' }
$winner = if($makroTotal -le $plazaTotal -and $makroTotal -le $tottusTotal){ 'Makro' } elseif($plazaTotal -le $makroTotal -and $plazaTotal -le $tottusTotal){ 'Plaza Vea' } else { 'Tottus' }
$lowestTotal = [math]::Round([math]::Min($makroTotal, [math]::Min($plazaTotal, $tottusTotal)), 2)

function BuildSheet1 {
    $rows = New-Object System.Collections.Generic.List[string]
    $rows.Add('<row r="1" ht="22" customHeight="1">' + (TC 'A1' 'COMPARACION DE PRECIOS - COMPRA SEMANAL (TEMPORADA: CUT - FAT LOSS)' 1) + '</row>')
    $rows.Add('<row r="2">' + (TC 'A2' 'Precios consultados: 2026-07-04. Tottus resumen incluido; links exactos solo cuando fueron recuperables.' 2) + '</row>')
    $rows.Add('<row r="4" ht="30" customHeight="1">' +
        (TC 'A4' 'Ingrediente' 3) + (TC 'B4' 'Cantidad necesaria' 3) +
        (TC 'C4' 'Makro - Producto' 3) + (TC 'D4' 'Makro - Cantidad a comprar' 3) +
        (TC 'E4' 'Makro - Precio (S/)' 3) + (TC 'F4' 'Makro - Enlace' 3) +
        (TC 'G4' 'Plaza Vea - Producto' 3) + (TC 'H4' 'Plaza Vea - Cantidad a comprar' 3) +
        (TC 'I4' 'Plaza Vea - Precio (S/)' 3) + (TC 'J4' 'Plaza Vea - Enlace' 3) +
        (TC 'K4' 'Tottus - Producto' 3) + (TC 'L4' 'Tottus - Cantidad a comprar' 3) +
        (TC 'M4' 'Tottus - Precio (S/)' 3) + (TC 'N4' 'Tottus - Enlace' 3) +
        '</row>')
    $hyper = New-Object System.Collections.Generic.List[string]
    $rels = New-Object System.Collections.Generic.List[string]
    $rid = 1
    for($i=0; $i -lt $items.Count; $i++){
        $it = $items[$i]
        $r = $i + 5
        $mProdCell = if($it.MP -eq 'No disponible'){ TC "C$r" 'No disponible' 8 } else { TC "C$r" $it.MP 4 }
        $mQtyCell  = if($it.MQ -eq '-'){ TC "D$r" '-' 8 } else { TC "D$r" $it.MQ 4 }
        $mPriceCell = if($null -ne $it.MV){ NC "E$r" $it.MV 5 } else { TC "E$r" 'No disponible' 8 }
        $mLinkCell  = if($null -ne $it.MU){ TC "F$r" $it.MU 6 } else { TC "F$r" '-' 8 }
        $pProdCell = if($it.PP -eq 'No disponible'){ TC "G$r" 'No disponible' 8 } else { TC "G$r" $it.PP 4 }
        $pQtyCell  = if($it.PQ -eq '-'){ TC "H$r" '-' 8 } else { TC "H$r" $it.PQ 4 }
        $pPriceCell = if($null -ne $it.PV){ NC "I$r" $it.PV 5 } else { TC "I$r" 'No disponible' 8 }
        $pLinkCell  = if($null -ne $it.PU){ TC "J$r" $it.PU 6 } else { TC "J$r" '-' 8 }
        $tProdCell = if($it.TP -eq 'No disponible'){ TC "K$r" 'No disponible' 8 } else { TC "K$r" $it.TP 4 }
        $tQtyCell  = if($it.TQ -eq '-'){ TC "L$r" '-' 8 } else { TC "L$r" $it.TQ 4 }
        $tPriceCell = if($null -ne $it.TV){ NC "M$r" $it.TV 5 } else { TC "M$r" 'No disponible' 8 }
        $tLinkCell  = if($null -ne $it.TU){ TC "N$r" $it.TU 6 } else { TC "N$r" '-' 8 }
        $rows.Add('<row r="' + $r + '">' +
            (TC "A$r" $it.I 4) +
            (TC "B$r" $it.Q 4) +
            $mProdCell +
            $mQtyCell +
            $mPriceCell +
            $mLinkCell +
            $pProdCell +
            $pQtyCell +
            $pPriceCell +
            $pLinkCell +
            $tProdCell +
            $tQtyCell +
            $tPriceCell +
            $tLinkCell +
            '</row>')
        if($null -ne $it.MU){ $hyper.Add("<hyperlink xmlns:r=""http://schemas.openxmlformats.org/officeDocument/2006/relationships"" ref=""F$r"" r:id=""rId$rid"" />"); $rels.Add("<Relationship Type=""http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink"" Target=""$($it.MU)"" TargetMode=""External"" Id=""rId$rid"" />"); $rid++ }
        if($null -ne $it.PU){ $hyper.Add("<hyperlink xmlns:r=""http://schemas.openxmlformats.org/officeDocument/2006/relationships"" ref=""J$r"" r:id=""rId$rid"" />"); $rels.Add("<Relationship Type=""http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink"" Target=""$($it.PU)"" TargetMode=""External"" Id=""rId$rid"" />"); $rid++ }
    }
    $rows.Add('<row r="21">' + (TC 'A21' 'TOTALES' 11) + (BC 'B21' 12) + (BC 'C21' 12) + (BC 'D21' 12) + (NC 'E21' $makroTotal 13) + (BC 'F21' 12) + (BC 'G21' 12) + (BC 'H21' 12) + (NC 'I21' $plazaTotal 20) + (BC 'J21' 12) + (BC 'K21' 12) + (BC 'L21' 12) + (NC 'M21' $tottusTotal 13) + (BC 'N21' 12) + '</row>')
    [pscustomobject]@{
        Sheet = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheetPr><outlinePr summaryBelow="1" summaryRight="1" /><pageSetUpPr /></sheetPr>
  <dimension ref="A1:N21" />
  <sheetViews><sheetView zoomScale="90" workbookViewId="0"><pane ySplit="4" topLeftCell="A5" activePane="bottomLeft" state="frozen" /><selection pane="bottomLeft" activeCell="A1" sqref="A1" /></sheetView></sheetViews>
  <sheetFormatPr baseColWidth="8" defaultRowHeight="15" />
  <cols>
    <col width="34" customWidth="1" min="1" max="1" />
    <col width="20" customWidth="1" min="2" max="2" />
    <col width="27" customWidth="1" min="3" max="3" />
    <col width="28" customWidth="1" min="4" max="4" />
    <col width="14" customWidth="1" min="5" max="5" />
    <col width="48" customWidth="1" min="6" max="6" />
    <col width="29" customWidth="1" min="7" max="7" />
    <col width="32" customWidth="1" min="8" max="8" />
    <col width="14" customWidth="1" min="9" max="9" />
    <col width="48" customWidth="1" min="10" max="10" />
    <col width="34" customWidth="1" min="11" max="11" />
    <col width="29" customWidth="1" min="12" max="12" />
    <col width="14" customWidth="1" min="13" max="13" />
    <col width="48" customWidth="1" min="14" max="14" />
  </cols>
  <sheetData>
    $($rows -join "`n    ")
  </sheetData>
  <hyperlinks>
    $($hyper -join "`n    ")
  </hyperlinks>
  <pageMargins left="0.75" right="0.75" top="1" bottom="1" header="0.5" footer="0.5" />
</worksheet>
"@
        Rels = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  $($rels -join "`n  ")
</Relationships>
"@
    }
}

function BuildSheet2 {
    @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <sheetPr><outlinePr summaryBelow="1" summaryRight="1" /><pageSetUpPr /></sheetPr>
  <dimension ref="A1:B11" />
  <sheetViews><sheetView zoomScale="100" workbookViewId="0"><pane ySplit="2" topLeftCell="A3" activePane="bottomLeft" state="frozen" /><selection pane="bottomLeft" activeCell="A1" sqref="A1" /></sheetView></sheetViews>
  <sheetFormatPr baseColWidth="8" defaultRowHeight="15" />
  <cols><col width="22" customWidth="1" min="1" max="1" /><col width="18" customWidth="1" min="2" max="2" /></cols>
  <sheetData>
    <row r="1"><c r="A1" s="14" t="inlineStr"><is><t>Resumen de la comparacion</t></is></c></row>
    <row r="3"><c r="A3" s="15" t="inlineStr"><is><t>Makro total</t></is></c><c r="B3" s="16" t="n"><v>$([string]::Format([cultureinfo]::InvariantCulture, '{0:0.00}', $makroTotal))</v></c></row>
    <row r="4"><c r="A4" s="15" t="inlineStr"><is><t>Plaza Vea total</t></is></c><c r="B4" s="16" t="n"><v>$([string]::Format([cultureinfo]::InvariantCulture, '{0:0.00}', $plazaTotal))</v></c></row>
    <row r="5"><c r="A5" s="15" t="inlineStr"><is><t>Tottus total</t></is></c><c r="B5" s="16" t="n"><v>$([string]::Format([cultureinfo]::InvariantCulture, '{0:0.00}', $tottusTotal))</v></c></row>
    <row r="6"><c r="A6" s="15" t="inlineStr"><is><t>Tottus sin precio</t></is></c><c r="B6" s="16" t="n"><v>$tottusMissing</v></c></row>
    <row r="7"><c r="A7" s="15" t="inlineStr"><is><t>Menor total</t></is></c><c r="B7" s="16" t="n"><v>$([string]::Format([cultureinfo]::InvariantCulture, '{0:0.00}', $lowestTotal))</v></c></row>
    <row r="8"><c r="A8" s="15" t="inlineStr"><is><t>Ganador</t></is></c><c r="B8" s="21" t="inlineStr"><is><t>$winner</t></is></c></row>
    <row r="9"><c r="A9" s="15" t="inlineStr"><is><t>Run status</t></is></c><c r="B9" s="16" t="inlineStr"><is><t>$runStatus</t></is></c></row>
    <row r="10"><c r="A10" s="15" t="inlineStr"><is><t>Retrieval rate</t></is></c><c r="B10" s="16" t="inlineStr"><is><t>$([string]::Format([cultureinfo]::InvariantCulture, '{0:P0}', $retrievalRate))</t></is></c></row>
    <row r="11"><c r="A11" s="15" t="inlineStr"><is><t>Direct link rate</t></is></c><c r="B11" s="16" t="inlineStr"><is><t>$([string]::Format([cultureinfo]::InvariantCulture, '{0:P0}', $directLinkRate))</t></is></c></row>
  </sheetData>
  <mergeCells count="1"><mergeCell ref="A1:D1" /></mergeCells>
  <pageMargins left="0.75" right="0.75" top="1" bottom="1" header="0.5" footer="0.5" />
  <legacyDrawing xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" r:id="anysvml" />
</worksheet>
"@
}

$sheet1 = BuildSheet1
$sheet2 = BuildSheet2

if(Test-Path $OutputPath){ Remove-Item -LiteralPath $OutputPath -Force }
$base = [System.IO.Compression.ZipFile]::OpenRead($TemplatePath)
try {
    $out = [System.IO.Compression.ZipFile]::Open($OutputPath, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach($entry in $base.Entries){
            if($entry.FullName -in @('xl/worksheets/sheet1.xml','xl/worksheets/_rels/sheet1.xml.rels','xl/worksheets/sheet2.xml')) { continue }
            $ne = $out.CreateEntry($entry.FullName)
            $inS = $entry.Open(); $outS = $ne.Open(); $inS.CopyTo($outS); $outS.Dispose(); $inS.Dispose()
        }
        $e = $out.CreateEntry('xl/worksheets/sheet1.xml'); $w = New-Object IO.StreamWriter($e.Open()); $w.Write($sheet1.Sheet); $w.Dispose()
        $e = $out.CreateEntry('xl/worksheets/_rels/sheet1.xml.rels'); $w = New-Object IO.StreamWriter($e.Open()); $w.Write($sheet1.Rels); $w.Dispose()
        $e = $out.CreateEntry('xl/worksheets/sheet2.xml'); $w = New-Object IO.StreamWriter($e.Open()); $w.Write($sheet2); $w.Dispose()
    } finally { $out.Dispose() }
} finally { $base.Dispose() }

Write-Output $OutputPath
