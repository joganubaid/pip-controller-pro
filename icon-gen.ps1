Add-Type -AssemblyName System.Drawing

function New-RoundedRectPath([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function New-PipBitmap([int]$size) {
    $bmp = New-Object System.Drawing.Bitmap $size, $size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.Clear([System.Drawing.Color]::Transparent)
    $s = $size / 256.0

    # Background rounded square (dark slate)
    $bgPath = New-RoundedRectPath 0 0 $size $size (56 * $s)
    $bgBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 24, 26, 37))
    $g.FillPath($bgBrush, $bgPath)

    # Main "browser" window (light) with a title bar
    $wx = 28 * $s; $wy = 44 * $s; $ww = 172 * $s; $wh = 150 * $s
    $winBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 233, 236, 245))
    $g.FillRectangle($winBrush, $wx, $wy, $ww, $wh)
    $tbBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 148, 163, 184))
    $g.FillRectangle($tbBrush, $wx, $wy, $ww, 20 * $s)

    # PiP mini window (sky blue) overlapping the bottom-right corner
    $px = 116 * $s; $py = 128 * $s; $pw = 112 * $s; $ph = 84 * $s
    $pipBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 56, 189, 248))
    $g.FillRectangle($pipBrush, $px, $py, $pw, $ph)

    # Play triangle inside the PiP window
    $cx = $px + $pw / 2; $cy = $py + $ph / 2
    $tw = 30 * $s; $th = 36 * $s
    $pts = [System.Drawing.PointF[]]@(
        (New-Object System.Drawing.PointF ($cx - $tw / 2), ($cy - $th / 2)),
        (New-Object System.Drawing.PointF ($cx - $tw / 2), ($cy + $th / 2)),
        (New-Object System.Drawing.PointF ($cx + $tw / 2), $cy)
    )
    $triBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
    $g.FillPolygon($triBrush, $pts)

    $g.Dispose()
    return $bmp
}

New-Item -ItemType Directory -Path assets -Force | Out-Null
$sizes = 16, 32, 48, 256
$pngs = @()
foreach ($sz in $sizes) {
    $b = New-PipBitmap $sz
    $ms = New-Object System.IO.MemoryStream
    $b.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $pngs += ,@{ size = $sz; data = $ms.ToArray() }
    if ($sz -eq 256) { $b.Save("assets\icon-preview.png", [System.Drawing.Imaging.ImageFormat]::Png) }
    $b.Dispose()
}

# Pack the PNGs into a multi-size .ico (PNG-compressed entries, Vista+)
$fs = [System.IO.File]::Create("assets\icon.ico")
$bw = New-Object System.IO.BinaryWriter $fs
$bw.Write([uint16]0); $bw.Write([uint16]1); $bw.Write([uint16]$pngs.Count)
$offset = 6 + 16 * $pngs.Count
foreach ($p in $pngs) {
    $szByte = [byte]($p.size -band 0xFF)   # 256 wraps to 0 per the ICO spec
    $bw.Write($szByte); $bw.Write($szByte)
    $bw.Write([byte]0); $bw.Write([byte]0)
    $bw.Write([uint16]1); $bw.Write([uint16]32)
    $bw.Write([uint32]$p.data.Length)
    $bw.Write([uint32]$offset)
    $offset += $p.data.Length
}
foreach ($p in $pngs) { $bw.Write($p.data) }
$bw.Close(); $fs.Close()
Write-Host "assets\icon.ico + assets\icon-preview.png written"
