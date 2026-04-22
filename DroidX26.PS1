Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===== GLOBAL PATH =====
$adbPathFile = "$env:LOCALAPPDATA\DroidX_adb_path.txt"

# ===== ICON SETUP =====
$iconFolder = "$PSScriptRoot\Icons"
if (!(Test-Path $iconFolder)) { New-Item -ItemType Directory -Path $iconFolder | Out-Null }
attrib +h $iconFolder

$icons = @{
    "Connect"     = "https://img.icons8.com/fluency/48/usb-connector.png"
    "Refresh"     = "https://raw.githubusercontent.com/icons8/fluency/48/refresh.png"
    "Bloatware"   = "https://raw.githubusercontent.com/icons8/fluency/48/delete.png"
    "Recovery"    = "https://raw.githubusercontent.com/icons8/fluency/48/system-task.png"
    "Screenshot"  = "https://raw.githubusercontent.com/icons8/fluency/48/screenshot.png"
    "Devices"     = "https://raw.githubusercontent.com/icons8/fluency/48/device-manager.png"
    "About"       = "https://raw.githubusercontent.com/icons8/fluency/48/info.png"

    # Recovery mini icons
    "RecRecovery" = "https://img.icons8.com/fluency/48/restart.png"
    "RecSystem"   = "https://img.icons8.com/fluency/48/power.png"
    "RecDownload" = "https://img.icons8.com/fluency/48/download.png"
}

foreach ($key in $icons.Keys) {
    $filePath = "$iconFolder\$key.png"
    if (!(Test-Path $filePath)) {
        try { Invoke-WebRequest $icons[$key] -OutFile $filePath -UseBasicParsing } catch {}
    }
}

# ===== FORM =====
$form = New-Object System.Windows.Forms.Form
$form.Text = "DroidX"
$form.Size = New-Object System.Drawing.Size(800,600)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# ===== TOOLSTRIP =====
$toolStrip = New-Object System.Windows.Forms.ToolStrip
$toolStrip.Dock = "Top"
$toolStrip.ImageScalingSize = New-Object System.Drawing.Size(24,24)

function Add-MenuButton($text) {
    $btn = New-Object System.Windows.Forms.ToolStripButton
    $btn.Text = $text
    $btn.DisplayStyle = "ImageAndText"
    $btn.Image = [System.Drawing.Image]::FromFile("$iconFolder\$text.png")
    $btn.TextImageRelation = "ImageAboveText"
    return $btn
}

$btnConnect   = Add-MenuButton "Connect"
$btnRefresh   = Add-MenuButton "Refresh"
$btnBloatware = Add-MenuButton "Bloatware"
$btnRecovery  = Add-MenuButton "Recovery"

$toolStrip.Items.Add($btnConnect)
$toolStrip.Items.Add($btnRefresh)
$toolStrip.Items.Add($btnBloatware)
$toolStrip.Items.Add($btnRecovery)
$btnScreenshot = Add-MenuButton "Screenshot"
$toolStrip.Items.Add($btnScreenshot)
$btnDevices = Add-MenuButton "Devices"
$toolStrip.Items.Add($btnDevices)
$btnUserGuide = Add-MenuButton "UserGuide"
$btnAbout     = Add-MenuButton "About"

$toolStrip.Items.Add($btnUserGuide)
$toolStrip.Items.Add($btnAbout)

# ===== HEADER =====
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Size = New-Object System.Drawing.Size(800,100)
$headerPanel.Location = New-Object System.Drawing.Point(0,50)
$headerPanel.BackColor = [System.Drawing.Color]::Black

$header = New-Object System.Windows.Forms.Label
$header.Text = "DroidX"
$header.Font = New-Object System.Drawing.Font("Segoe UI",20,[System.Drawing.FontStyle]::Bold)
$header.ForeColor = [System.Drawing.Color]::White
$header.Location = New-Object System.Drawing.Point(20,10)
$header.AutoSize = $true

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = "A complete Android Manager"
$subtitle.ForeColor = [System.Drawing.Color]::LightGray
$subtitle.Location = New-Object System.Drawing.Point(22,55)
$subtitle.AutoSize = $true

$headerPanel.Controls.Add($header)
$headerPanel.Controls.Add($subtitle)

$form.Controls.Add($toolStrip)
$form.Controls.Add($headerPanel)

# ===== OUTPUT BOX =====
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.Size = New-Object System.Drawing.Size(760,400)
$outputBox.Location = New-Object System.Drawing.Point(20,160)
$outputBox.Font = New-Object System.Drawing.Font("Consolas",10)
$outputBox.ReadOnly = $true

$form.Controls.Add($outputBox)

# ===== PROGRESS WINDOW =====
function Show-ProgressWindow {
    $progressForm = New-Object System.Windows.Forms.Form
    $progressForm.Text = "Downloading ADB..."
    $progressForm.Size = New-Object System.Drawing.Size(400,150)
    $progressForm.StartPosition = "CenterScreen"
    $progressForm.FormBorderStyle = "FixedDialog"

    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Size = New-Object System.Drawing.Size(350,25)
    $progressBar.Location = New-Object System.Drawing.Point(20,40)

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "0%"
    $label.Location = New-Object System.Drawing.Point(180,75)
    $label.AutoSize = $true

    $progressForm.Controls.Add($progressBar)
    $progressForm.Controls.Add($label)

    return @($progressForm,$progressBar,$label)
}

# ===== CONNECT =====
$btnConnect.Add_Click({
    if (Test-Path $adbPathFile) {
        $savedPath = Get-Content $adbPathFile
        if (Test-Path "$savedPath\platform-tools\adb.exe") {
            [System.Windows.Forms.MessageBox]::Show("ADB Exists at:`n$savedPath","DroidX")
            return
        }
    }

    $ui = Show-ProgressWindow
    $progressForm = $ui[0]
    $progressBar = $ui[1]
    $label = $ui[2]

    $progressForm.Show()

    Start-Job -ScriptBlock {
        param($adbPathFile)
        $url = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
        $zip = "$env:TEMP\platform-tools.zip"
        $dest = "$env:LOCALAPPDATA\DroidX"

        if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }

        Invoke-WebRequest $url -OutFile $zip
        Expand-Archive $zip -DestinationPath $dest -Force
        Set-Content -Path $adbPathFile -Value $dest

        return $dest

    } -ArgumentList $adbPathFile | Wait-Job | Receive-Job | ForEach-Object {

        $progressBar.Value = 100
        $label.Text = "100%"
        Start-Sleep -Milliseconds 500
        $progressForm.Close()

        [System.Windows.Forms.MessageBox]::Show("ADB Installed Successfully at:`n$_","DroidX")
    }
})

# ===== REFRESH =====
$btnRefresh.Add_Click({
    $outputBox.Clear()
    $outputBox.AppendText("Checking ADB status...`r`n")

    if (!(Test-Path $adbPathFile)) {
        $outputBox.AppendText("ADB not installed. Click Connect first.`r`n")
        return
    }

    $adbBase = Get-Content $adbPathFile
    $adbExe = "$adbBase\platform-tools\adb.exe"

    if (!(Test-Path $adbExe)) {
        $outputBox.AppendText("ADB path invalid.`r`n")
        return
    }

    $outputBox.AppendText("Running adb devices...`r`n`r`n")

    $script:adbOutput = ""

    Start-Job -ScriptBlock {
        param($adbExe)
        & $adbExe devices
    } -ArgumentList $adbExe | Wait-Job | Receive-Job | ForEach-Object {
        $script:adbOutput += "`r`n$_"
    }

    $outputBox.AppendText($script:adbOutput)
})

# ===== BLOATWARE =====
$btnBloatware.Add_Click({
    if (!(Test-Path $adbPathFile)) { [System.Windows.Forms.MessageBox]::Show("ADB not installed."); return }

    $adbBase = Get-Content $adbPathFile
    $adbExe = "$adbBase\platform-tools\adb.exe"

    $bwForm = New-Object System.Windows.Forms.Form
    $bwForm.Text = "Bloatware Manager"
    $bwForm.Size = New-Object System.Drawing.Size(600,500)

    $searchBox = New-Object System.Windows.Forms.TextBox
    $searchBox.Location = New-Object System.Drawing.Point(10,10)
    $searchBox.Size = New-Object System.Drawing.Size(250,25)

    $filterBox = New-Object System.Windows.Forms.ComboBox
    $filterBox.Items.AddRange(@("All Apps","User Apps","System Apps"))
    $filterBox.SelectedIndex = 0
    $filterBox.Location = New-Object System.Drawing.Point(270,10)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Size = New-Object System.Drawing.Size(560,350)
    $listBox.Location = New-Object System.Drawing.Point(10,50)

    $btnRefreshApps = New-Object System.Windows.Forms.Button
    $btnRefreshApps.Text = "Refresh"
    $btnRefreshApps.BackColor = "LightBlue"
    $btnRefreshApps.Location = New-Object System.Drawing.Point(50,420)

    $btnDisable = New-Object System.Windows.Forms.Button
    $btnDisable.Text = "Disable"
    $btnDisable.BackColor = "Orange"
    $btnDisable.Location = New-Object System.Drawing.Point(230,420)

    $btnUninstall = New-Object System.Windows.Forms.Button
    $btnUninstall.Text = "Uninstall"
    $btnUninstall.BackColor = "Red"
    $btnUninstall.ForeColor = "White"
    $btnUninstall.Location = New-Object System.Drawing.Point(400,420)

    $bwForm.Controls.AddRange(@($searchBox,$filterBox,$listBox,$btnRefreshApps,$btnDisable,$btnUninstall))

    function Load-Apps {
        $listBox.Items.Clear()

        Start-Job -ScriptBlock {
            param($adbExe,$filter)
            if ($filter -eq "User Apps") { & $adbExe shell pm list packages -3 }
            elseif ($filter -eq "System Apps") { & $adbExe shell pm list packages -s }
            else { & $adbExe shell pm list packages }

        } -ArgumentList $adbExe,$filterBox.SelectedItem | Wait-Job | Receive-Job | ForEach-Object {
            $_.Replace("package:","")
        } | ForEach-Object { $listBox.Items.Add($_) }
    }

    $btnRefreshApps.Add_Click({ Load-Apps })
    $filterBox.Add_SelectedIndexChanged({ Load-Apps })

    $searchBox.Add_TextChanged({
        $search = $searchBox.Text.ToLower()
        for ($i=0; $i -lt $listBox.Items.Count; $i++) {
            if ($listBox.Items[$i].ToLower() -notlike "*$search*") {
                $listBox.Items.RemoveAt($i); $i--
            }
        }
    })

    $btnDisable.Add_Click({
        if ($listBox.SelectedItem) {
            $pkg = $listBox.SelectedItem
            Start-Job { param($adbExe,$pkg) & $adbExe shell pm disable-user --user 0 $pkg } -ArgumentList $adbExe,$pkg | Out-Null
            [System.Windows.Forms.MessageBox]::Show("Disabled: $pkg")
        }
    })

    $btnUninstall.Add_Click({
        if ($listBox.SelectedItem) {
            $pkg = $listBox.SelectedItem
            Start-Job { param($adbExe,$pkg) & $adbExe shell pm uninstall --user 0 $pkg } -ArgumentList $adbExe,$pkg | Out-Null
            [System.Windows.Forms.MessageBox]::Show("Uninstalled: $pkg")
        }
    })

    Load-Apps
    $bwForm.ShowDialog()
})

# ===== RECOVERY =====
$btnRecovery.Add_Click({

    if (!(Test-Path $adbPathFile)) {
        [System.Windows.Forms.MessageBox]::Show("ADB not installed.","DroidX")
        return
    }

    $adbBase = Get-Content $adbPathFile
    $adbExe = "$adbBase\platform-tools\adb.exe"

    $recForm = New-Object System.Windows.Forms.Form
    $recForm.Text = "Recovery Options"
    $recForm.Size = New-Object System.Drawing.Size(350,200)
    $recForm.StartPosition = "CenterScreen"
    $recForm.FormBorderStyle = "FixedDialog"

    function New-RecButton($text,$icon,$x) {
        $btn = New-Object System.Windows.Forms.Button
        $btn.Size = New-Object System.Drawing.Size(90,90)
        $btn.Location = New-Object System.Drawing.Point($x,40)
        $btn.Text = $text
        $btn.TextAlign = "BottomCenter"
        $btn.ImageAlign = "TopCenter"
        $btn.Image = [System.Drawing.Image]::FromFile("$iconFolder\$icon.png")
        return $btn
    }

    $btnRec = New-RecButton "Recovery" "RecRecovery" 20
    $btnSys = New-RecButton "System" "RecSystem" 120
    $btnDwn = New-RecButton "Download" "RecDownload" 220

    $recForm.Controls.AddRange(@($btnRec,$btnSys,$btnDwn))

    $btnRec.Add_Click({
        Start-Job { param($adbExe) & $adbExe reboot recovery } -ArgumentList $adbExe | Out-Null
        [System.Windows.Forms.MessageBox]::Show("Rebooting to Recovery...")
        $recForm.Close()
    })

    $btnSys.Add_Click({
        Start-Job { param($adbExe) & $adbExe reboot } -ArgumentList $adbExe | Out-Null
        [System.Windows.Forms.MessageBox]::Show("Rebooting to System...")
        $recForm.Close()
    })

    $btnDwn.Add_Click({
        Start-Job { param($adbExe) & $adbExe reboot download } -ArgumentList $adbExe | Out-Null
        [System.Windows.Forms.MessageBox]::Show("Rebooting to Download Mode...")
        $recForm.Close()
    })

    $recForm.ShowDialog()
})


# ===== SCREENSHOT FUNCTION =====
$btnScreenshot.Add_Click({

    # Check ADB
    if (!(Test-Path $adbPathFile)) {
        [System.Windows.Forms.MessageBox]::Show("ADB not installed.","DroidX")
        return
    }

    $adbBase = Get-Content $adbPathFile
    $adbExe = "$adbBase\platform-tools\adb.exe"

    if (!(Test-Path $adbExe)) {
        [System.Windows.Forms.MessageBox]::Show("ADB path invalid.","DroidX")
        return
    }

    # Screenshot paths
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $localPath = "$env:USERPROFILE\Pictures\DroidX_$timestamp.png"
    $devicePath = "/sdcard/droidx_screen.png"

    # Small loading popup
    $loading = New-Object System.Windows.Forms.Form
    $loading.Text = "Capturing Screenshot..."
    $loading.Size = New-Object System.Drawing.Size(300,120)
    $loading.StartPosition = "CenterScreen"
    $loading.FormBorderStyle = "FixedDialog"

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Please wait..."
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(100,30)

    $loading.Controls.Add($label)
    $loading.Show()

    # Run in background
    Start-Job -ScriptBlock {
        param($adbExe,$devicePath,$localPath)

        # Capture
        & $adbExe shell screencap -p $devicePath

        # Pull to PC
        & $adbExe pull $devicePath $localPath

        # Remove from device
        & $adbExe shell rm $devicePath

        return $localPath

    } -ArgumentList $adbExe,$devicePath,$localPath | Wait-Job | Receive-Job | ForEach-Object {

        $loading.Close()

        if (Test-Path $_) {
            # Show image in popup
            $imgForm = New-Object System.Windows.Forms.Form
            $imgForm.Text = "Screenshot Preview"
            $imgForm.Size = New-Object System.Drawing.Size(400,700)
            $imgForm.StartPosition = "CenterScreen"

            $pic = New-Object System.Windows.Forms.PictureBox
            $pic.Dock = "Fill"
            $pic.SizeMode = "Zoom"
            $pic.Image = [System.Drawing.Image]::FromFile($_)

            $imgForm.Controls.Add($pic)
            $imgForm.ShowDialog()
        } else {
            [System.Windows.Forms.MessageBox]::Show("Screenshot failed.","DroidX")
        }
    }
})


# ===== DEVICES MANAGER =====
$btnDevices.Add_Click({

    # Check ADB
    if (!(Test-Path $adbPathFile)) {
        [System.Windows.Forms.MessageBox]::Show("ADB not installed.","DroidX")
        return
    }

    $adbBase = Get-Content $adbPathFile
    $adbExe = "$adbBase\platform-tools\adb.exe"

    if (!(Test-Path $adbExe)) {
        [System.Windows.Forms.MessageBox]::Show("ADB path invalid.","DroidX")
        return
    }

    # ===== POPUP =====
    $devForm = New-Object System.Windows.Forms.Form
    $devForm.Text = "Device Manager"
    $devForm.Size = New-Object System.Drawing.Size(500,400)
    $devForm.StartPosition = "CenterScreen"

    # List View (better than ListBox)
    $listView = New-Object System.Windows.Forms.ListView
    $listView.View = "Details"
    $listView.FullRowSelect = $true
    $listView.GridLines = $true
    $listView.Size = New-Object System.Drawing.Size(460,250)
    $listView.Location = New-Object System.Drawing.Point(10,10)

    $listView.Columns.Add("Device ID",250)
    $listView.Columns.Add("Status",150)

    # Buttons
    $btnRefreshDevices = New-Object System.Windows.Forms.Button
    $btnRefreshDevices.Text = "Refresh"
    $btnRefreshDevices.Location = New-Object System.Drawing.Point(50,300)

    $btnSelect = New-Object System.Windows.Forms.Button
    $btnSelect.Text = "Click Device"
    $btnSelect.Location = New-Object System.Drawing.Point(180,300)

    $btnClose = New-Object System.Windows.Forms.Button
    $btnClose.Text = "Close"
    $btnClose.Location = New-Object System.Drawing.Point(330,300)

    $devForm.Controls.AddRange(@($listView,$btnRefreshDevices,$btnSelect,$btnClose))

    # ===== LOAD DEVICES =====
    function Load-Devices {
        $listView.Items.Clear()

        Start-Job -ScriptBlock {
            param($adbExe)
            & $adbExe devices
        } -ArgumentList $adbExe | Wait-Job | Receive-Job | ForEach-Object {

            if ($_ -and $_ -notmatch "List of devices") {
                $parts = $_ -split "`t"
                if ($parts.Length -ge 2) {
                    $item = New-Object System.Windows.Forms.ListViewItem($parts[0])
                    $item.SubItems.Add($parts[1])
                    $listView.Items.Add($item)
                }
            }
        }
    }

    # ===== REFRESH =====
    $btnRefreshDevices.Add_Click({
        Load-Devices
    })

    # ===== SELECT DEVICE =====
    $btnSelect.Add_Click({
        if ($listView.SelectedItems.Count -gt 0) {
            $selected = $listView.SelectedItems[0].Text
            $global:selectedDevice = $selected
            [System.Windows.Forms.MessageBox]::Show("Selected Device:`n$selected","DroidX")
        }
    })

    $btnClose.Add_Click({ $devForm.Close() })

    # Initial load
    Load-Devices

    $devForm.ShowDialog()
})


# ===== ABOUT WINDOW =====
$btnAbout.Add_Click({

    $aboutForm = New-Object System.Windows.Forms.Form
    $aboutForm.Text = "About DroidX"
    $aboutForm.Size = New-Object System.Drawing.Size(380,260)
    $aboutForm.StartPosition = "CenterScreen"
    $aboutForm.FormBorderStyle = "FixedDialog"
    $aboutForm.MaximizeBox = $false
    $aboutForm.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)

    # Title
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "DroidX"
    $title.Font = New-Object System.Drawing.Font("Segoe UI",18,[System.Drawing.FontStyle]::Bold)
    $title.ForeColor = [System.Drawing.Color]::White
    $title.AutoSize = $true
    $title.Location = New-Object System.Drawing.Point(20,20)

    # Subtitle
    $subtitle = New-Object System.Windows.Forms.Label
    $subtitle.Text = "A complete Android Manager"
    $subtitle.Font = New-Object System.Drawing.Font("Segoe UI",9)
    $subtitle.ForeColor = [System.Drawing.Color]::LightGray
    $subtitle.AutoSize = $true
    $subtitle.Location = New-Object System.Drawing.Point(22,60)

    # Divider
    $line = New-Object System.Windows.Forms.Panel
    $line.Size = New-Object System.Drawing.Size(320,1)
    $line.Location = New-Object System.Drawing.Point(20,85)
    $line.BackColor = [System.Drawing.Color]::Gray

    # Programmer
    $dev = New-Object System.Windows.Forms.Label
    $dev.Text = "Programmer: SUMIT GHOSH"
    $dev.ForeColor = [System.Drawing.Color]::White
    $dev.AutoSize = $true
    $dev.Location = New-Object System.Drawing.Point(20,100)

    # Phone
    $phone = New-Object System.Windows.Forms.Label
    $phone.Text = "Phone: (+91) 7076501101"
    $phone.ForeColor = [System.Drawing.Color]::White
    $phone.AutoSize = $true
    $phone.Location = New-Object System.Drawing.Point(20,125)

    # Email
    $email = New-Object System.Windows.Forms.Label
    $email.Text = "Email: sumitghosh1994@outlook.com"
    $email.ForeColor = [System.Drawing.Color]::LightGray
    $email.AutoSize = $true
    $email.Location = New-Object System.Drawing.Point(20,150)

    # Close button
    $btnClose = New-Object System.Windows.Forms.Button
    $btnClose.Text = "Close"
    $btnClose.Size = New-Object System.Drawing.Size(80,30)
    $btnClose.Location = New-Object System.Drawing.Point(140,185)
    $btnClose.BackColor = [System.Drawing.Color]::FromArgb(60,60,60)
    $btnClose.ForeColor = [System.Drawing.Color]::White

    $btnClose.Add_Click({ $aboutForm.Close() })

    # Add controls
    $aboutForm.Controls.AddRange(@(
        $title,$subtitle,$line,$dev,$phone,$email,$btnClose
    ))

    $aboutForm.ShowDialog()
})



# ===== USER GUIDE WINDOW =====
$btnUserGuide.Add_Click({

    $guideForm = New-Object System.Windows.Forms.Form
    $guideForm.Text = "User Guide"
    $guideForm.Size = New-Object System.Drawing.Size(500,400)
    $guideForm.StartPosition = "CenterScreen"
    $guideForm.FormBorderStyle = "FixedDialog"
    $guideForm.MaximizeBox = $false
    $guideForm.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)

    # Title
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "Enable USB Debugging"
    $title.Font = New-Object System.Drawing.Font("Segoe UI",14,[System.Drawing.FontStyle]::Bold)
    $title.ForeColor = [System.Drawing.Color]::White
    $title.AutoSize = $true
    $title.Location = New-Object System.Drawing.Point(20,20)

    # Text box (scrollable instructions)
    $guideText = New-Object System.Windows.Forms.TextBox
    $guideText.Multiline = $true
    $guideText.ScrollBars = "Vertical"
    $guideText.ReadOnly = $true
    $guideText.Size = New-Object System.Drawing.Size(440,260)
    $guideText.Location = New-Object System.Drawing.Point(20,60)
    $guideText.BackColor = [System.Drawing.Color]::FromArgb(45,45,45)
    $guideText.ForeColor = [System.Drawing.Color]::White
    $guideText.Font = New-Object System.Drawing.Font("Segoe UI",10)

    $guideText.Text = @"
1. Open Settings:
Open your Android phone's Settings app.

2. Locate Build Number:
Go to About phone or About device (sometimes under System or Software Information).

3. Activate Developer Mode:
Scroll down and tap Build number 7 times until you see "You are now a developer."

4. Access Developer Options:
Go back to Settings and open Developer options.

5. Enable USB Debugging:
Turn on Developer options, then enable USB debugging.

6. Authorize Connection:
When prompted, select "Always allow" and tap OK.
"@

    # Close button
    $btnClose = New-Object System.Windows.Forms.Button
    $btnClose.Text = "Close"
    $btnClose.Size = New-Object System.Drawing.Size(80,30)
    $btnClose.Location = New-Object System.Drawing.Point(200,330)
    $btnClose.BackColor = [System.Drawing.Color]::FromArgb(60,60,60)
    $btnClose.ForeColor = [System.Drawing.Color]::White

    $btnClose.Add_Click({ $guideForm.Close() })

    # Add controls
    $guideForm.Controls.AddRange(@($title,$guideText,$btnClose))

    $guideForm.ShowDialog()
})




# ===== RUN =====
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::Run($form)