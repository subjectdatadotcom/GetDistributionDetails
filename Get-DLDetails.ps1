<#
.SYNOPSIS
Retrieve details of multiple distribution groups from Exchange Online using a CSV input, including information on owners, members, and email addresses.

.DESCRIPTION
This PowerShell script reads a CSV file containing the primary SMTP addresses of distribution groups. For each distribution group, it retrieves the display name, owners, group type, email addresses, primary SMTP address, and members. Owners and members are resolved from GUIDs to email addresses for readability. The results are exported to a CSV file in the same directory as the script.

The script will check for and install the required ExchangeOnlineManagement module if it’s not already installed, connect to Exchange Online, and perform the necessary operations. Once completed, the script disconnects from Exchange Online.

.EXAMPLE
.\Get-DLDetails.ps1
Runs the script, connects to Exchange Online, reads from DLs.csv, and exports detailed distribution group information to DistributionGroupDetails.csv in the same directory as the script.

.NOTES
Written by: SubjectData
Requires: Exchange Online PowerShell Module (ExchangeOnlineManagement)

#>


# Set the directory to the script's location
$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$inputFile = "$myDir\DLs.csv"
$outputFile = "$myDir\DistributionGroupDetails.csv"

# Module name
$ExchangeOnlineModule = "ExchangeOnlineManagement"

# Check if the ExchangeOnlineManagement module is installed; if not, install it
if (-not(Get-Module -Name $ExchangeOnlineModule -ListAvailable)) {
    Write-Host "Installing the $ExchangeOnlineModule module..."
    Install-Module -Name $ExchangeOnlineModule -Force -Scope CurrentUser
}

# Import the ExchangeOnlineManagement module
Import-Module $ExchangeOnlineModule -Force

# Connect to Exchange Online
try {
    Connect-ExchangeOnline
} catch {
    Write-Host "Failed to connect to Exchange Online. Exiting script." -ForegroundColor Red
    exit
}

# Initialize the output CSV with headers
$outputHeaders = "Distribution Groups", "DisplayName", "Owners", "GroupType", "EmailAddresses", "PrimarySmtpAddress", "Members"
$outputData = @()

# Read the input CSV
$inputData = Import-Csv -Path $inputFile

foreach ($row in $inputData) {
    $primarySmtp = $row.DistributionGroupPrimarySMTP

    # Retrieve distribution group details
    $group = Get-DistributionGroup -Identity $primarySmtp -ErrorAction SilentlyContinue
    if (!$group) {
        Write-Host "Distribution group $primarySmtp not found." -ForegroundColor Yellow
        continue
    }

    # Retrieve group owners as GUIDs and resolve to email addresses
    $ownerGuids = Get-DistributionGroup -Identity $primarySmtp | Select-Object -ExpandProperty ManagedBy
    #$ownerGuids = $owners.ManagedBy
    $ownersEmails = if ($ownerGuids) { 
                        @($ownerGuids | ForEach-Object {
                            # Resolve each GUID to an email address of the owner
                            $recipient = Get-Recipient -Identity $_ -ErrorAction SilentlyContinue
                            if ($recipient) { $recipient.PrimarySmtpAddress }
                        }) -join ";"
                    } else { 
                        ""
                    }

    # Retrieve all email addresses
    $emailAddresses = if ($group.EmailAddresses) { 
                          @($group.EmailAddresses) -join ";" 
                      } else { 
                          ""
                      }

    # Retrieve group members
    $members = Get-DistributionGroupMember -Identity $primarySmtp -ResultSize Unlimited
    $membersEmails = if ($members) { 
                         @($members | ForEach-Object { $_.PrimarySmtpAddress }) -join ";" 
                     } else { 
                         ""
                     }

    # Create a custom object for the output row
    $outputRow = [pscustomobject]@{
        "Distribution Groups" = $primarySmtp
        "DisplayName" = $group.DisplayName
        "Owners" = $ownersEmails
        "GroupType" = "$($group.RecipientTypeDetails), $($group.GroupType)"
        "EmailAddresses" = $emailAddresses
        "PrimarySmtpAddress" = $group.PrimarySmtpAddress
        "Members" = $membersEmails
    }

    # Add the row to the output data array
    $outputData += $outputRow
}

# Export the output data to CSV
$outputData | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false

Write-Output "Output written to $outputFile in the same directory as the script."
