# Distribution Group Details Retrieval Script

This PowerShell script retrieves detailed information for multiple distribution groups from Exchange Online using a CSV input file. For each distribution group, it gathers details such as display name, owners, group type, email addresses, primary SMTP address, and members, then exports this information to a CSV file.

## Prerequisites

1. **PowerShell**: Ensure you have PowerShell installed.
2. **Exchange Online Management Module**: This script uses the `ExchangeOnlineManagement` module, which will be automatically installed if not already available.

## Instructions

1. **Edit the Script (Optional)**:
   - By default, the script reads from `DLs.csv` and outputs to `DistributionGroupDetails.csv` in the same directory.
   - Ensure that the `DLs.csv` file is in the same directory as the script.

2. **Prepare the CSV File**:
   - Create a CSV file named `DLs.csv` with the following structure:
     ```
     DistributionGroupPrimarySMTP
     group1@example.com
     group2@example.com
     ```
   - Each line under `DistributionGroupPrimarySMTP` should list the primary SMTP address of a distribution group you want to retrieve information for.

3. **Run the Script**:
   - Open PowerShell as an administrator.
   - Navigate to the directory containing the script.
   - Run the script:
     ```powershell
     .\Get-DLDetails.ps1
     ```
   - Authenticate using an admin account with permissions to access Exchange Online.
   - The script will connect to Exchange Online, read the distribution group SMTP addresses from `DLs.csv`, and export the details to `DistributionGroupDetails.csv`.

4. **Check the Output**:
   - The output CSV file `DistributionGroupDetails.csv` will contain the following columns:
     - **Distribution Groups**: The primary SMTP address of the distribution group.
     - **DisplayName**: The display name of the distribution group.
     - **Owners**: The email addresses of the owners of the distribution group, separated by semicolons.
     - **GroupType**: The type and settings of the distribution group.
     - **EmailAddresses**: All email addresses associated with the distribution group.
     - **PrimarySmtpAddress**: The primary SMTP address of the distribution group.
     - **Members**: The email addresses of all members of the distribution group, separated by semicolons.

## Troubleshooting

- **CSV File Not Found**: Ensure `DLs.csv` exists in the same directory as the script and is correctly formatted.
- **Permission Issues**: Make sure you have the necessary permissions to retrieve details from Exchange Online.
- **Module Installation Errors**: If the script fails to install the `ExchangeOnlineManagement` module, try manually installing it:
  ```powershell
  Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force
