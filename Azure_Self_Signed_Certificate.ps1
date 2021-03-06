#------------------------------------------------------------------------------ 
# 
# Copyright © 2014 Microsoft Corporation.  All rights reserved. 
# 
# THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED “AS IS” WITHOUT 
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT 
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS 
# FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR  
# RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER. 
# 
#------------------------------------------------------------------------------ 
# 
# PowerShell Source Code 
# 
# NAME: 
#    Azure_Self_Signed_Certificate.ps1 
# 
# VERSION: 
#    1.1
# 
#------------------------------------------------------------------------------ 

"------------------------------------------------------------------------------ " | Write-Host -ForegroundColor Yellow
""  | Write-Host -ForegroundColor Yellow
" Copyright © 2014 Microsoft Corporation.  All rights reserved. " | Write-Host -ForegroundColor Yellow
""  | Write-Host -ForegroundColor Yellow
" THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED `“AS IS`” WITHOUT " | Write-Host -ForegroundColor Yellow
" WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT " | Write-Host -ForegroundColor Yellow
" LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS " | Write-Host -ForegroundColor Yellow
" FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR  " | Write-Host -ForegroundColor Yellow
" RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER. " | Write-Host -ForegroundColor Yellow
"------------------------------------------------------------------------------ " | Write-Host -ForegroundColor Yellow
""  | Write-Host -ForegroundColor Yellow
" PowerShell Source Code " | Write-Host -ForegroundColor Yellow
""  | Write-Host -ForegroundColor Yellow
" NAME: " | Write-Host -ForegroundColor Yellow
"    Azure_Self_Signed_Certificate.ps1 " | Write-Host -ForegroundColor Yellow
"" | Write-Host -ForegroundColor Yellow
" VERSION: " | Write-Host -ForegroundColor Yellow
"    1.0" | Write-Host -ForegroundColor Yellow
""  | Write-Host -ForegroundColor Yellow
"------------------------------------------------------------------------------ " | Write-Host -ForegroundColor Yellow
"" | Write-Host -ForegroundColor Yellow
"`n This script SAMPLE is provided and intended only to act as a SAMPLE ONLY," | Write-Host -ForegroundColor Yellow
" and is NOT intended to serve as a solution to any known technical issue."  | Write-Host -ForegroundColor Yellow
"`n By executing this SAMPLE AS-IS, you agree to assume all risks and responsibility associated."  | Write-Host -ForegroundColor Yellow

$ErrorActionPreference = "SilentlyContinue"
$ContinueAnswer = Read-Host "`n Do you wish to proceed at your own risk? (Y/N)"
If ($ContinueAnswer -ne "Y") { Write-Host "`n Exiting." -ForegroundColor Red;Exit }
Write-Host "`n This script will generate a self-signed Client Authentication certificate for use in Azure."  
[int]$Iterations = 1 
 
For ($Count = 1; $Count -le $Iterations; $Count++)
        { 
			Try
			{
	            $Subject = Read-Host "`n Enter the Subject for the certificate" 
				[int] $years = Read-Host "`n Enter the number of years for the certificate to be valid (Max 5)" 
	            $Password = Read-Host "`n Enter a .PFX (private key file) password" -AsSecureString
				$InstallAnswer = Read-Host "`n Would you like to install the .pfx on this machine? (Y/N)"
			}
			Catch [Exception]
			{
				#Check interaction and bail out if error
				Write-Host "`n`t[ERROR] - Input not vaild. Exiting.`n`n" -ForegroundColor Red
				Write-Host "`n Press any key to continue ...`n`n"
				$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
				Exit
			}

            #Set the max years to 5
			If ($years -ge 5 -or $years -lt 1) {$years = 5;Write-Host "`n`tYear integer is not between 1 and 5.`n`tDefaulting to 5 years." -ForegroundColor Yellow}
			[int] $days = ($years * 365)
			
			#Generate cert in local computer My store 
			$name = new-object -com "X509Enrollment.CX500DistinguishedName.1"  
            $name.Encode("CN=$Subject", 0) 
            $key = new-object -com "X509Enrollment.CX509PrivateKey.1"  
            $key.ProviderName = "Microsoft RSA SChannel Cryptographic Provider"  
            $key.KeySpec = 1 
            $key.Length = 2048 
            $key.SecurityDescriptor = "D:PAI(A;;0xd01f01ff;;;SY)(A;;0xd01f01ff;;;BA)(A;;0x80120089;;;NS)"  
            $key.MachineContext = 1 
            $key.ExportPolicy = 1 
            $key.Create() 
            $ekuoids = new-object -com "X509Enrollment.CObjectIds.1"  
			$clientauthoid = new-object -com "X509Enrollment.CObjectId.1"  
			$clientauthoid.InitializeFromValue("1.3.6.1.5.5.7.3.2") 
			$ekuoids.add($clientauthoid) 
            $ekuext = new-object -com "X509Enrollment.CX509ExtensionEnhancedKeyUsage.1"  
            $ekuext.InitializeEncode($ekuoids) 
            $cert = new-object -com "X509Enrollment.CX509CertificateRequestCertificate.1"  
            $cert.InitializeFromPrivateKey(2, $key, "") 
            $cert.Subject = $name  
            $cert.Issuer = $cert.Subject 
            $cert.NotBefore = get-date
            $cert.NotAfter = $cert.NotBefore.AddDays($days)
            $cert.X509Extensions.Add($ekuext) 
            $cert.Encode() 
            $enrollment = new-object -com "X509Enrollment.CX509Enrollment.1"  
            $enrollment.InitializeFromRequest($cert) 
            $certdata = $enrollment.CreateRequest(0) 
            $PublicKeyPath = "$pwd\Azure_Self_Sign_Public.cer"
            $PrivateKeyPath = "$pwd\Azure_Self_Sign_Private.pfx"
            If ($certdata){$certdata | Out-File $PublicKeyPath}
            If (Test-Path $PublicKeyPath) { $MyCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($PublicKeyPath);$MyThumb = $MyCert.Thumbprint}
            $enrollment.InstallResponse(2, $certdata, 0, "")
      } 

$myInstalledCert = get-childitem Cert:\LocalMachine\My | where {$_.thumbprint -eq $MyThumb}

#Export PFX and remove certificate
If ($myInstalledCert)
{
    Export-PfxCertificate -Cert $myInstalledCert -Force -Password $Password -FilePath $PrivateKeyPath | Out-Null
    $thumb = ($myInstalledCert).Thumbprint 
    Remove-Item -Path Cert:\LocalMachine\My\$thumb -Force
}
Else
{
    Write-Host "`n [ERROR] - Certificate Creation Failed. Exiting." -ForegroundColor Red
    Write-Host "`n [ERROR] - This script must be executed in an administrative PowerShell console." -ForegroundColor Red
	Write-Host "`n Press any key to continue ...`n`n"
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	Exit
}

Write-Host "`n [SUCCESS] - Certificate created."  -ForegroundColor Green
Write-Host "`n`t$PublicKeyPath"
Write-Host "`tThis is the public key portion of the certificate, intended for upload to the Azure portal." -ForegroundColor Green
Write-Host "`n`t$PrivateKeyPath"
Write-Host "`tThis is the private key portion of the certificate, intended for installation`n`ton the Azure Backup client or Azure VPN Point-to-Site client." -ForegroundColor Green

If ($InstallAnswer -eq "Y" -and $PrivateKeyPath)
{
	Write-Host "`n Invoking the .pfx installation wizard..."
	Invoke-Item $PrivateKeyPath
}

Write-Host "`n Press any key to continue ...`n`n"
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")