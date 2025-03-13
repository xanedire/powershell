#region CHECK MODULE
# Function to check and install Microsoft.Graph module
function Ensure-MgGraphModule {
    try {
        if (-not (Get-Module -ListAvailable -Name Microsoft.Graph -ErrorAction SilentlyContinue)) {
            Write-Host "Microsoft.Graph module not found. Attempting to install..." -ForegroundColor Yellow
            # Check if running with admin privileges
            $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
            if (-not $isAdmin) {
                Write-Host "Warning: Installing the module requires admin privileges. Please run as administrator if this fails." -ForegroundColor Yellow
            }
            Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            Write-Host "Microsoft.Graph module installed successfully." -ForegroundColor Green
        } else {
            Write-Host "Microsoft.Graph module is already installed." -ForegroundColor Green
        }
        # Import the module
        # Import-Module Microsoft.Graph -ErrorAction Stop
    } catch {
        Write-Host "Failed to install or import Microsoft.Graph module. Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please install the module manually with 'Install-Module -Name Microsoft.Graph' and try again." -ForegroundColor Red
        exit
    }
}


# Run initial checks
Ensure-MgGraphModule

#region CONNECT TO MICROSOFT GRAPH
#Connect to Microsoft Graph
Connect-MgGraph

# Get the current user's context and ID
$context = Get-MgContext
$currentUser = (Get-MgUser -UserId $context.Account).Id

#region CHECK ROLES
# Fetch all eligible roles for the current user
$myRoles = Get-MgRoleManagementDirectoryRoleEligibilitySchedule -ExpandProperty RoleDefinition -All -Filter "principalId eq '$currentUser'"

# Check if any roles were found
if (-not $myRoles) {
    Write-Host "No eligible roles found for user $currentUser."
    exit
}

# Track processed role names to avoid duplicates
$processedRoles = @{}

# Loop through each role in $myRoles
foreach ($role in $myRoles) {
    # Get the role display name from the RoleDefinition
    $roleName = $role.RoleDefinition.DisplayName

    # Skip if this role name has already been processed
    if ($processedRoles.ContainsKey($roleName)) {
        Write-Host "Skipping duplicate role: $roleName" -ForegroundColor Yellow
        continue
    }

    # Generate a dynamic justification based on the role name
    $justification = "Enable $roleName role"

    # Use the first instance if properties are arrays, otherwise use the single value
    $principalId = if ($role.PrincipalId -is [array]) { $role.PrincipalId[0] } else { $role.PrincipalId }
    $roleDefinitionId = if ($role.RoleDefinitionId -is [array]) { $role.RoleDefinitionId[0] } else { $role.RoleDefinitionId }
    $directoryScopeId = if ($role.DirectoryScopeId -is [array]) { $role.DirectoryScopeId[0] } else { $role.DirectoryScopeId }

    # Define the parameters for this role
    $params = @{
        Action = "selfActivate"
        PrincipalId = $principalId
        RoleDefinitionId = $roleDefinitionId
        DirectoryScopeId = $directoryScopeId
        Justification = $justification
        ScheduleInfo = @{
            StartDateTime = Get-Date
            Expiration = @{
                Type = "AfterDuration"
                Duration = "PT8H" # 8 hours duration
            }
        }
    }
    
#region ACTIVATE
    # Activate the role with error handling
    try {
        Write-Host "Activating role: $roleName"
        New-MgRoleManagementDirectoryRoleAssignmentScheduleRequest -BodyParameter $params -ErrorAction Stop
        Write-Host "Successfully activated $roleName" -ForegroundColor Green
        # Mark this role as processed
        $processedRoles[$roleName] = $true
    } catch {
        $errorMessage = $_.Exception.Message
        if ($errorMessage -match "RoleAssignmentExists") {
            Write-Host "Role $roleName is already active. Skipping activation." -ForegroundColor Yellow
            # Mark as processed to avoid retrying duplicates
            $processedRoles[$roleName] = $true
        } else {
            Write-Host "Failed to activate $roleName. Error: $errorMessage" -ForegroundColor Red
        }
    }
}
#region OUTPUT
# Output all detected roles for verification
Write-Host "`nDetected roles for user $currentUser -" -ForegroundColor Cyan
$myRoles | ForEach-Object { 
    $roleName = $_.RoleDefinition.DisplayName
    $instances = if ($_.RoleDefinitionId -is [array]) { $_.RoleDefinitionId.Count } else { 1 }
    Write-Host "- $roleName ($instances instance(s))"
}
#endregion
