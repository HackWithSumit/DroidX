::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAjk
::fBw5plQjdCyDJGyX8VAjFChhYS22AE+1EbsQ5+n//Na4o0MZRu02fLDS2buAbekQ5Uv3O5Ui20UMzZNcX1sQL1vlZww7yQ==
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSjk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFChhYS22AE+/Fb4I5/jHy/iIq0klGucnfe8=
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
<# :
@echo off
setlocal
set "POWERSHELL_BAT_ARGS=%*"
if defined POWERSHELL_BAT_ARGS set "POWERSHELL_BAT_ARGS=%POWERSHELL_BAT_ARGS:"=\"%"
fltmc >nul 2>&1 || (
    echo Requesting Administrator Privileges...
    powershell -Command "Start-Process -FilePath '%0' -Verb RunAs"
    exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "IEX ((Get-Content '%~f0' -Raw) -join \"`n\")"
exit /b
#>

# --- BEGIN POWERSHELL CODE ---
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$base="$env:USERPROFILE\AndroidDeviceManager"
$iconFolder="$base\icons"
$platformTools="$base\platform-tools"

if(!(Test-Path $base)){New-Item $base -ItemType Directory | Out-Null}
if(!(Test-Path $iconFolder)){New-Item $iconFolder -ItemType Directory | Out-Null}

function Write-Terminal($text){
    $terminal.AppendText("$text`r`n")
    $terminal.ScrollToCaret()
}

function Get-Icon($name,$url){
    $file="$iconFolder\$name.png"
    if(!(Test-Path $file)){
        Invoke-WebRequest $url -OutFile $file -UseBasicParsing
    }
    return [System.Drawing.Image]::FromFile($file)
}

function Install-ADB{
    $url="https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
    $zip="$base\platform-tools.zip"
    Write-Terminal "Downloading Android Platform Tools..."
    Invoke-WebRequest $url -OutFile $zip
    Expand-Archive $zip $base -Force
    $current=[Environment]::GetEnvironmentVariable("Path","User")
    if($current -notlike "*platform-tools*"){
        $new="$current;$platformTools"
        [Environment]::SetEnvironmentVariable("Path",$new,"User")
    }
    $env:Path=[Environment]::GetEnvironmentVariable("Path","Machine")+";"+[Environment]::GetEnvironmentVariable("Path","User")
    Write-Terminal "ADB Installed"
}

# Icons
$connectIcon = Get-Icon "connect" "https://cdn-icons-png.flaticon.com/512/1828/1828911.png"
$installIcon = Get-Icon "install" "https://cdn-icons-png.flaticon.com/512/2989/2989988.png"
$refreshIcon = Get-Icon "refresh" "https://cdn-icons-png.flaticon.com/512/545/545680.png"
$bloatIcon = Get-Icon "bloat" "https://cdn-icons-png.flaticon.com/512/483/483361.png"
$rebootIcon = Get-Icon "reboot" "https://cdn-icons-png.flaticon.com/512/1828/1828665.png"
$settingsIcon = Get-Icon "settings" "https://cdn-icons-png.flaticon.com/512/2099/2099058.png"
$aboutIcon = Get-Icon "about" "https://cdn-icons-png.flaticon.com/512/545/545705.png"

# Main Window
$form = New-Object Windows.Forms.Form
$form.Text="Android Device Manager"
$form.Size="900,550"
$form.StartPosition="CenterScreen"

# Header
$header=New-Object Windows.Forms.Panel
$header.Dock="Top"
$header.Height=40
$header.BackColor=[Drawing.Color]::FromArgb(45,45,48)

$title=New-Object Windows.Forms.Label
$title.Text="Android Device Manager"
$title.ForeColor="White"
$title.Font=New-Object Drawing.Font("Segoe UI",12,[Drawing.FontStyle]::Bold)
$title.Location="10,8"
$title.AutoSize=$true

$header.Controls.Add($title)
$form.Controls.Add($header)

# Toolbar
$toolbar=New-Object Windows.Forms.ToolStrip
$toolbar.Dock="Top"

$btnConnect=New-Object Windows.Forms.ToolStripButton
$btnConnect.Text="Connect"
$btnConnect.Image=$connectIcon

$btnInstall=New-Object Windows.Forms.ToolStripButton
$btnInstall.Text="Install APK"
$btnInstall.Image=$installIcon

$btnRefresh=New-Object Windows.Forms.ToolStripButton
$btnRefresh.Text="Refresh"
$btnRefresh.Image=$refreshIcon

$btnBloat=New-Object Windows.Forms.ToolStripButton
$btnBloat.Text="Bloatware"
$btnBloat.Image=$bloatIcon

$btnReboot=New-Object Windows.Forms.ToolStripDropDownButton
$btnReboot.Text="Reboot"
$btnReboot.Image=$rebootIcon

$rebootSystem=New-Object Windows.Forms.ToolStripMenuItem "System"
$rebootRecovery=New-Object Windows.Forms.ToolStripMenuItem "Recovery"
$rebootBootloader=New-Object Windows.Forms.ToolStripMenuItem "Bootloader"
$btnReboot.DropDownItems.AddRange(@($rebootSystem,$rebootRecovery,$rebootBootloader))

$btnSettings=New-Object Windows.Forms.ToolStripDropDownButton
$btnSettings.Text="Settings"
$btnSettings.Image=$settingsIcon
$bug=New-Object Windows.Forms.ToolStripMenuItem "Report Bug"
$btnSettings.DropDownItems.Add($bug)

$btnAbout=New-Object Windows.Forms.ToolStripButton
$btnAbout.Text="About"
$btnAbout.Image=$aboutIcon

$deviceLabel=New-Object Windows.Forms.ToolStripLabel
$deviceLabel.Text="Device:"
$deviceBox=New-Object Windows.Forms.ToolStripComboBox
$deviceBox.Width=140

$profileLabel=New-Object Windows.Forms.ToolStripLabel
$profileLabel.Text="Profile:"
$profileBox=New-Object Windows.Forms.ToolStripComboBox
$profileBox.Width=130
$profileBox.Items.AddRange(@("Samsung Safe","Xiaomi Safe","Google Pixel Safe"))
$profileBox.SelectedIndex=0
$applyProfile=New-Object Windows.Forms.ToolStripButton
$applyProfile.Text="Apply"

$toolbar.Items.AddRange(@(
    $btnConnect,$btnInstall,$btnRefresh,$btnBloat,
    $btnReboot,$btnSettings,$btnAbout,
    (New-Object Windows.Forms.ToolStripSeparator),
    $deviceLabel,$deviceBox,
    $profileLabel,$profileBox,$applyProfile
))
$form.Controls.Add($toolbar)

# Terminal
$terminal=New-Object Windows.Forms.RichTextBox
$terminal.Dock="Fill"
$terminal.BackColor="Black"
$terminal.ForeColor="Lime"
$terminal.Font=New-Object Drawing.Font("Consolas",10)
$terminal.ReadOnly=$true
$form.Controls.Add($terminal)

Write-Terminal "Android Device Manager Ready"

# EVENT HANDLERS
$btnConnect.Add_Click({
    $adb=Get-Command adb -ErrorAction SilentlyContinue
    if(!$adb){ Write-Terminal "ADB not found"; Install-ADB }else{ Write-Terminal "ADB detected" }
    Write-Terminal "> adb devices"
    adb devices | % {Write-Terminal $_}
})

$btnRefresh.Add_Click({
    $deviceBox.Items.Clear()
    $devices=adb devices
    foreach($line in $devices){
        Write-Terminal $line
        if($line -match "device$"){
            $id=$line.Split("`t")[0]
            $deviceBox.Items.Add($id)
        }
    }
    if($deviceBox.Items.Count -gt 0){ $deviceBox.SelectedIndex=0 }
})

$btnInstall.Add_Click({
    $device=$deviceBox.Text
    if(!$device){Write-Terminal "Select device first";return}
    $open=New-Object Windows.Forms.OpenFileDialog
    $open.Filter="APK (*.apk)|*.apk"
    if($open.ShowDialog() -eq "OK"){
        $apk=$open.FileName
        Write-Terminal "> adb install"
        adb -s $device install "`"$apk`"" | % {Write-Terminal $_}
    }
})

$btnBloat.Add_Click({
    $device=$deviceBox.Text
    if(!$device){Write-Terminal "Select device first";return}
    $bForm=New-Object Windows.Forms.Form
    $bForm.Text="Bloatware Manager"; $bForm.Size="500,520"
    $search=New-Object Windows.Forms.TextBox; $search.Dock="Top"
    $filter=New-Object Windows.Forms.ComboBox; $filter.Dock="Top"
    $filter.Items.AddRange(@("All Apps","User Apps","System Apps")); $filter.SelectedIndex=0
    $list=New-Object Windows.Forms.ListBox; $list.Dock="Fill"
    $panel=New-Object Windows.Forms.Panel; $panel.Dock="Bottom"; $panel.Height=40
    $btnUninstall=New-Object Windows.Forms.Button; $btnUninstall.Text="Uninstall"
    $btnDisable=New-Object Windows.Forms.Button; $btnDisable.Text="Disable"; $btnDisable.Left=100
    $btnRestore=New-Object Windows.Forms.Button; $btnRestore.Text="Restore"; $btnRestore.Left=200
    $btnPkgRefresh=New-Object Windows.Forms.Button; $btnPkgRefresh.Text="Refresh"; $btnPkgRefresh.Left=300
    $panel.Controls.AddRange(@($btnUninstall,$btnDisable,$btnRestore,$btnPkgRefresh))
    $bForm.Controls.AddRange(@($list,$filter,$search,$panel))

    function LoadPackages{
        $list.Items.Clear()
        switch($filter.SelectedItem){
            "User Apps" {$cmd="pm list packages -3"}
            "System Apps" {$cmd="pm list packages -s"}
            default {$cmd="pm list packages"}
        }
        Write-Terminal "> adb shell $cmd"
        $pkgs=adb -s $device shell $cmd
        foreach($p in $pkgs){ $list.Items.Add($p.Replace("package:","")) }
    }
    LoadPackages
    $filter.Add_SelectedIndexChanged({LoadPackages})
    $btnPkgRefresh.Add_Click({LoadPackages})
    $btnUninstall.Add_Click({
        $pkg=$list.SelectedItem
        Write-Terminal "> adb shell pm uninstall --user 0 $pkg"
        adb -s $device shell pm uninstall --user 0 $pkg
        LoadPackages
    })
    $btnDisable.Add_Click({
        $pkg=$list.SelectedItem
        Write-Terminal "> adb shell pm disable-user --user 0 $pkg"
        adb -s $device shell pm disable-user --user 0 $pkg
    })
    $btnRestore.Add_Click({
        $pkg=$list.SelectedItem
        Write-Terminal "> adb shell cmd package install-existing $pkg"
        adb -s $device shell cmd package install-existing $pkg
    })
    $search.Add_TextChanged({
        $list.Items.Clear()
        $pkgs=adb -s $device shell pm list packages
        foreach($p in $pkgs){
            $name=$p.Replace("package:","")
            if($name -like "*$($search.Text)*"){ $list.Items.Add($name) }
        }
    })
    $bForm.ShowDialog()
})

$bug.Add_Click({
    Start-Process "mailto:whitehatsumit@proton.me?subject=Android Device Manager Bug Report"
})

$btnAbout.Add_Click({
    $about=New-Object Windows.Forms.Form
    $about.Text="About"; $about.Size="350,200"
    $label=New-Object Windows.Forms.Label
    $label.Text="Android Device Manager 1.0`n`nDeveloped by SUMIT GHOSH`nEmail: whitehatsumit@proton.me"
    $label.AutoSize=$true; $label.Location="40,40"
    $about.Controls.Add($label)
    $about.ShowDialog()
})

[void]$form.ShowDialog()