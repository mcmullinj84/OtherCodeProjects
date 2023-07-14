# PowerShell Script to Update Default GP in Domain to Enable 'Password must meet complexity requirements'.
# Script developed with Microsoft Documentation and Chat GPT ... still needs work

# Import the Active Directory module
Import-Module ActiveDirectory

# Retrieve the Default Domain Policy
$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$gpo = Get-GPO -Domain $domain.Name -Name "Default Domain Policy"

# Enable 'Password must meet complexity requirements' in the Default Domain Policy
$gpoDisplayName = $gpo.DisplayName
$gpoId = $gpo.Id

# Retrieve the current settings of the Default Domain Policy
$gpoSecurityDescriptor = Get-GPPermissions -Guid $gpoId | Where-Object { $_.Trustee -eq 'NT AUTHORITY\Authenticated Users' }

# Set the 'Password must meet complexity requirements' flag in the Default Domain Policy
$gpoSecurityDescriptor.PermissionLevel = 'GpoApply'
Set-GPPermissions -Guid $gpoId -PermissionLevel $gpoSecurityDescriptor.PermissionLevel -TargetName $gpoSecurityDescriptor.Trustee -TargetType $gpoSecurityDescriptor.TrusteeType -Replace

# Apply the updated GPO
Invoke-GPUpdate -Force

# Check the updated setting
$updatedGpoSecurityDescriptor = Get-GPPermissions -Guid $gpoId | Where-Object { $_.Trustee -eq 'NT AUTHORITY\Authenticated Users' }
if ($updatedGpoSecurityDescriptor.PermissionLevel -eq 'GpoApply') {
    Write-Host "Password must meet complexity requirements policy is now enabled in '$gpoDisplayName'."
} else {
    Write-Host "Failed to enable password complexity policy in '$gpoDisplayName'."
}
