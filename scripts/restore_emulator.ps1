$pattern='Pixel|Android Emulator|emulator'
Add-Type -AssemblyName System.Windows.Forms
$code=@"
using System;
using System.Runtime.InteropServices;
public struct RECT{ public int Left; public int Top; public int Right; public int Bottom;}
public static class WinUser {
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd,int nCmdShow);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd,out RECT lpRect);
    [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr hWnd,int X,int Y,int nWidth,int nHeight,bool bRepaint);
}
"@
Add-Type -TypeDefinition $code -Language CSharp
$found=Get-Process | Where-Object { $_.MainWindowHandle -ne 0 -and $_.MainWindowTitle -match $pattern }
if(-not $found){ Write-Output 'No emulator window found'; exit 0 }
foreach($p in $found){
  $h=$p.MainWindowHandle
  [WinUser]::ShowWindow($h,9) # SW_RESTORE
  Start-Sleep -Milliseconds 100
  [WinUser]::SetForegroundWindow($h) | Out-Null
  [WinUser]::BringWindowToTop($h) | Out-Null
  $r = New-Object RECT
  [WinUser]::GetWindowRect($h,[ref]$r) | Out-Null
  $w = $r.Right - $r.Left
  $hgt = $r.Bottom - $r.Top
  $sw = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Width
  $sh = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Height
  $x = [int](($sw - $w)/2)
  $y = [int](($sh - $hgt)/2)
  [WinUser]::MoveWindow($h,$x,$y,$w,$hgt,$true) | Out-Null
  Write-Output "Restored and centered: $($p.MainWindowTitle) (PID $($p.Id))"
}
