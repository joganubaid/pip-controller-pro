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

# Extract bottom-up BGRA XOR bytes + fully-opaque AND mask from a Bitmap.
function Get-IconImageBytes([System.Drawing.Bitmap]$bmp) {
    $w = $bmp.Width
    $h = $bmp.Height
    $rect = New-Object System.Drawing.Rectangle 0, 0, $w, $h
    $fmt = [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    $data = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, $fmt)
    $stride = $data.Stride
    $src = New-Object byte[] ($stride * $h)
    [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $src, 0, $src.Length)
    $bmp.UnlockBits($data)

    # ICO XOR bitmap is bottom-up, no row padding when width*4 is multiple of 4 (always true).
    $xor = New-Object byte[] ($w * $h * 4)
    for ($row = 0; $row -lt $h; $row++) {
        $srcRow = ($h - 1 - $row) * $stride
        $dstRow = $row * $w * 4
        for ($col = 0; $col -lt $w; $col++) {
            $si = $srcRow + $col * 4
            $di = $dstRow + $col * 4
            # src is ARGB; ICO 32bpp BMP expects BGRA
            $xor[$di + 0] = $src[$si + 2]  # B
            $xor[$di + 1] = $src[$si + 1]  # G
            $xor[$di + 2] = $src[$si + 0]  # R
            $xor[$di + 3] = $src[$si + 3]  # A
        }
    }

    # 1bpp AND mask, bottom-up, row size rounded up to 4 bytes. Fully opaque = all zeros.
    $andRowBytes = [math]::Ceiling($w / 32.0) * 4
    $and = New-Object byte[] ($andRowBytes * $h)

    return @{ xor = $xor; and = $and; andRowBytes = $andRowBytes }
}

New-Item -ItemType Directory -Path assets -Force | Out-Null
$sizes = 16, 32, 48, 256
$images = @()
foreach ($sz in $sizes) {
    $bmp = New-PipBitmap $sz
    $img = Get-IconImageBytes $bmp
    if ($sz -eq 256) {
        $bmp.Save("assets\icon-preview.png", [System.Drawing.Imaging.ImageFormat]::Png)
    }
    $bmp.Dispose()

    # BMP-based ICO image: BITMAPINFOHEADER + XOR + AND
    $header = [System.Collections.ArrayList]::new()
    [void]$header.AddRange([BitConverter]::GetBytes([uint32]40))        # biSize
    [void]$header.AddRange([BitConverter]::GetBytes([int32]$sz))         # biWidth
    [void]$header.AddRange([BitConverter]::GetBytes([int32]($sz * 2)))   # biHeight (XOR + AND)
    [void]$header.AddRange([BitConverter]::GetBytes([uint16]1))          # biPlanes
    [void]$header.AddRange([BitConverter]::GetBytes([uint16]32))         # biBitCount
    [void]$header.AddRange([BitConverter]::GetBytes([uint32]0))          # biCompression
    [void]$header.AddRange([BitConverter]::GetBytes([uint32]0))          # biSizeImage
    [void]$header.AddRange([BitConverter]::GetBytes([int32]0))           # biXPelsPerMeter
    [void]$header.AddRange([BitConverter]::GetBytes([int32]0))           # biYPelsPerMeter
    [void]$header.AddRange([BitConverter]::GetBytes([uint32]0))          # biClrUsed
    [void]$header.AddRange([BitConverter]::GetBytes([uint32]0))          # biClrImportant

    $data = [System.Collections.ArrayList]::new()
    [void]$data.AddRange($header)
    [void]$data.AddRange($img.xor)
    [void]$data.AddRange($img.and)

    $images += ,@{ size = $sz; data = [byte[]]$data.ToArray() }
}

# Pack ICO directory + images
$fs = [System.IO.File]::Create("assets\icon.ico")
$bw = New-Object System.IO.BinaryWriter $fs
$bw.Write([uint16]0)                        # Reserved
$bw.Write([uint16]1)                        # Type: icon
$bw.Write([uint16]$images.Count)            # Count
$offset = 6 + 16 * $images.Count
foreach ($img in $images) {
    $szByte = [byte]($img.size -band 0xFF)  # 256 wraps to 0
    $bw.Write($szByte)                      # Width
    $bw.Write($szByte)                      # Height
    $bw.Write([byte]0)                      # Colors
    $bw.Write([byte]0)                      # Reserved
    $bw.Write([uint16]1)                    # Planes
    $bw.Write([uint16]32)                   # BitCount
    $bw.Write([uint32]$img.data.Length)     # BytesInRes
    $bw.Write([uint32]$offset)              # ImageOffset
    $offset += $img.data.Length
}
foreach ($img in $images) {
    $bw.Write($img.data)
}
$bw.Close(); $fs.Close()
Write-Host "assets\icon.ico + assets\icon-preview.png written (BMP-based, $([String]::Join('/', $sizes))px)"
