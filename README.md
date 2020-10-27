Azure: Generate a Self-Signed Certificate
=========================================



  *  This script sample demonstrates how to utilize Windows PowerShell to generate a self-signed Client Authentication certificate

  *  The sample must be executed in an administrative PowerShell console


  *  The user is prompted to enter a Subject, private key file (.pfx) password, validity in years, and whether or not to launch the .pfx installation wizard upon completion


  *  The sample creates two certificate files placed in the current directory:


  *  The public key portion (.cer) of the certificate, intended for upload to the Azure portal.


  *  The private key portion (.pfx) of the certificate, intended for installation on the Azure Backup client or Azure VPN Point-to-Site client.



 


 

 

 


        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
