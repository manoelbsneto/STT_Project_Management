# Dell Pro 14 PC14250 — Security Feature Audit
# RUN AS ADMINISTRATOR on the Dell laptop
# Output saved to C:\dell_audit_report.txt

$report = @()
$report += "=" * 70
$report += "DELL PRO 14 PC14250 — SECURITY AUDIT REPORT"
$report += "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$report += "=" * 70

# 1. SYSTEM INFO
$report += "`n### 1. SYSTEM IDENTIFICATION ###"
$bios = Get-WmiObject Win32_BIOS
$sys = Get-WmiObject Win32_ComputerSystem
$board = Get-WmiObject Win32_BaseBoard
$report += "Model: $($sys.Model)"
$report += "Manufacturer: $($sys.Manufacturer)"
$report += "Serial Number: $($bios.SerialNumber)"
$report += "BIOS Version: $($bios.SMBIOSBIOSVersion)"
$report += "BIOS Date: $($bios.ReleaseDate)"
$report += "Board: $($board.Product) / $($board.Manufacturer)"
$report += "Domain Joined: $($sys.PartOfDomain) | Domain: $($sys.Domain)"

# 2. TPM
$report += "`n### 2. TPM STATUS ###"
try {
    $tpm = Get-Tpm -ErrorAction Stop
    $report += "TPM Present: $($tpm.TpmPresent)"
    $report += "TPM Ready: $($tpm.TpmReady)"
    $report += "TPM Enabled: $($tpm.TpmEnabled)"
    $report += "TPM Activated: $($tpm.TpmActivated)"
    $report += "TPM Owned: $($tpm.TpmOwned)"
    $report += "TPM Manufacturer: $($tpm.ManufacturerIdTxt)"
    $report += "TPM Version: $($tpm.ManufacturerVersion)"
} catch { $report += "ERROR: Requires admin privileges — $($_.Exception.Message)" }

# 3. SECURE BOOT
$report += "`n### 3. SECURE BOOT ###"
try {
    $sb = Confirm-SecureBootUEFI -ErrorAction Stop
    $report += "Secure Boot: $(if($sb){'ENABLED'}else{'DISABLED'})"
} catch { $report += "ERROR: $($_.Exception.Message)" }

# 4. BITLOCKER
$report += "`n### 4. BITLOCKER ENCRYPTION ###"
try {
    $bl = Get-BitLockerVolume -ErrorAction Stop
    foreach ($v in $bl) {
        $report += "Drive $($v.MountPoint): Status=$($v.VolumeStatus) | Protection=$($v.ProtectionStatus) | Method=$($v.EncryptionMethod) | Pct=$($v.EncryptionPercentage)%"
        foreach ($kp in $v.KeyProtector) {
            $report += "  KeyProtector: Type=$($kp.KeyProtectorType)"
        }
    }
} catch { $report += "ERROR: $($_.Exception.Message)" }

# 5. NETWORK ADAPTERS (checking for Intel i219-LM vs Realtek)
$report += "`n### 5. NETWORK ADAPTERS ###"
Get-NetAdapter | ForEach-Object {
    $report += "$($_.Name): $($_.InterfaceDescription) | MAC=$($_.MacAddress) | Status=$($_.Status)"
}

# 6. INTEL AMT STATUS
$report += "`n### 6. INTEL AMT / vPro ###"
try {
    $amt = Get-WmiObject -Namespace "root\Intel_ME" -Class ME_System -ErrorAction Stop
    $report += "AMT State: $($amt.State)"
    $report += "AMT Version: $($amt.FWVersion)"
} catch {
    try {
        $amtSvc = Get-Service -Name "LMS" -ErrorAction Stop
        $report += "Intel LMS Service: Status=$($amtSvc.Status) | StartType=$($amtSvc.StartType)"
    } catch {
        $report += "Intel LMS Service: NOT FOUND"
    }
}
# Check AMT via registry
$amtReg = Get-ItemProperty -Path "HKLM:\SOFTWARE\Intel\Setup and Configuration Software\MEBX" -ErrorAction SilentlyContinue
if ($amtReg) { $report += "AMT MEBX Registry: Found" } else { $report += "AMT MEBX Registry: NOT FOUND" }

# Check MEI driver
$mei = Get-WmiObject Win32_PnPEntity | Where-Object { $_.Name -like "*Management Engine*" -or $_.Name -like "*MEI*" -or $_.Name -like "*HECI*" }
foreach ($m in $mei) {
    $report += "ME Device: $($m.Name) | Status=$($m.Status) | Error=$($m.ConfigManagerErrorCode)"
}

# 7. ABSOLUTE / COMPUTRACE
$report += "`n### 7. ABSOLUTE PERSISTENCE (COMPUTRACE) ###"
$absServices = @("rpcnet", "rpcnetp", "AbsoluteService", "CTSvc")
foreach ($svc in $absServices) {
    $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($s) { $report += "Service '$svc': Status=$($s.Status) | StartType=$($s.StartType)" }
}
$absProc = Get-Process -Name "rpcnet","rpcnetp" -ErrorAction SilentlyContinue
if ($absProc) { $report += "Absolute Agent Process: RUNNING" } else { $report += "Absolute Agent Process: NOT RUNNING" }
$absReg = Get-ItemProperty -Path "HKLM:\SOFTWARE\Absolute Software Corp." -ErrorAction SilentlyContinue
if ($absReg) { $report += "Absolute Registry: FOUND" } else { $report += "Absolute Registry: NOT FOUND" }

# 8. DELL TRUSTED DEVICE / SAFEBIOS
$report += "`n### 8. DELL TRUSTED DEVICE (SAFEBIOS) ###"
$dtd = Get-WmiObject Win32_Product | Where-Object { $_.Name -like "*Dell Trusted*" -or $_.Name -like "*SafeBIOS*" }
if ($dtd) { foreach ($d in $dtd) { $report += "Installed: $($d.Name) v$($d.Version)" } }
else { $report += "Dell Trusted Device: NOT INSTALLED" }
$dtdSvc = Get-Service -Name "DellTrustedDevice" -ErrorAction SilentlyContinue
if ($dtdSvc) { $report += "DTD Service: $($dtdSvc.Status)" } else { $report += "DTD Service: NOT FOUND" }

# 9. INTUNE / MDM ENROLLMENT
$report += "`n### 9. INTUNE / MDM ENROLLMENT ###"
$mdm = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Enrollments\*" -ErrorAction SilentlyContinue | Where-Object { $_.ProviderID }
if ($mdm) {
    foreach ($e in $mdm) {
        $report += "MDM Provider: $($e.ProviderID) | UPN: $($e.UPN)"
    }
} else { $report += "MDM Enrollment: NOT ENROLLED" }
# Autopilot
$ap = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Provisioning\AutopilotPolicy" -ErrorAction SilentlyContinue
if ($ap) { $report += "Autopilot Policy: FOUND" } else { $report += "Autopilot Policy: NOT FOUND" }

# 10. WINDOWS HELLO
$report += "`n### 10. WINDOWS HELLO ###"
$pin = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{D6886603-9D2F-4EB2-B667-1971041FA96B}" -ErrorAction SilentlyContinue
$bio = Get-WmiObject -Class Win32_PnPEntity | Where-Object { $_.Name -like "*fingerprint*" -or $_.Name -like "*biometric*" }
if ($bio) { foreach ($b in $bio) { $report += "Biometric Device: $($b.Name) | Status=$($b.Status)" } }
else { $report += "Biometric Devices: NONE DETECTED" }

# 11. DELL COMMAND CONFIGURE
$report += "`n### 11. DELL TOOLS ###"
$dcc = Get-WmiObject Win32_Product | Where-Object { $_.Name -like "*Dell Command*" }
if ($dcc) { foreach ($d in $dcc) { $report += "Installed: $($d.Name) v$($d.Version)" } }
else { $report += "Dell Command tools: NOT INSTALLED" }

# 12. FIREWALL & DEFENDER
$report += "`n### 12. WINDOWS SECURITY ###"
$fw = Get-NetFirewallProfile | Select-Object Name, Enabled
foreach ($f in $fw) { $report += "Firewall $($f.Name): Enabled=$($f.Enabled)" }
$defender = Get-MpComputerStatus -ErrorAction SilentlyContinue
if ($defender) {
    $report += "Defender RealTime: $($defender.RealTimeProtectionEnabled)"
    $report += "Defender AntiSpyware: $($defender.AntiSpywareEnabled)"
    $report += "Defender Signatures: $($defender.AntiVirusSignatureLastUpdated)"
}

# OUTPUT
$report += "`n" + "=" * 70
$report += "END OF AUDIT"
$report += "=" * 70

$output = $report -join "`r`n"
$output | Out-File -FilePath "C:\dell_audit_report.txt" -Encoding UTF8
Write-Host $output
Write-Host "`n>>> Report saved to C:\dell_audit_report.txt"
