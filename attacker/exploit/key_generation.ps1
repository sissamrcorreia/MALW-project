# =============================================================================
#  SHADOWVAULT - RSA KEY PAIR GENERATOR
#  Generates the public/private key pair for the Hybrid Encryption attack.
# =============================================================================

# --- RSA KEY GENERATION (2048-bit) ---
$rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider(2048)

# 1. Public key
$publicKeyXML = $rsa.ToXmlString($false)

# 2. Private key
$privateKeyXML = $rsa.ToXmlString($true)

Write-Host "--- [1] PUBLIC KEY (COPY INTO: shadowvault.ps1) ---" -ForegroundColor Green
Write-Host $publicKeyXML
Write-Host ""
Write-Host "--- [2] PRIVATE KEY (COPY INTO: shadowvault_dec.ps1) ---" -ForegroundColor Green
Write-Host $privateKeyXML