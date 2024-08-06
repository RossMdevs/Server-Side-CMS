$jsonFilePath = "\\datastore1\player_data.json"

# Load existing data from JSON file
if (Test-Path $jsonFilePath) {
    $jsonData = Get-Content -Path $jsonFilePath | ConvertFrom-Json
    if ($jsonData -is [hashtable]) {
        $dataStore = $jsonData
    } else {
        $dataStore = @{}  # Initialize as an empty hashtable if loading failed
    }
} else {
    $dataStore = @{}  # Initialize as an empty hashtable
}

# Function to save data to JSON file
function Save-Data {
    $dataStore | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonFilePath
}

# Function to connect to SQL Server and fetch player data
function Get-SQLPlayerData {
    param (
        [string]$connectionString,
        [string]$idType,
        [string]$idValue
    )

    $query = if ($idType -eq "DiscordID") {
        "SELECT * FROM PlayerData WHERE DiscordID = '$idValue'"
    } else {
        "SELECT * FROM PlayerData WHERE FiveMLicense = '$idValue'"
    }

    try {
        $result = Invoke-Sqlcmd -ConnectionString $connectionString -Query $query
        if ($result -is [PSObject] -and $result.Count -gt 0) {
            return $result[0]  # Return the first record if it exists
        }
        return $null  # No results found
    } catch {
        Write-Host "Error retrieving data from SQL Server: $_"
        return $null
    }
}

# Function to display the main menu
function Show-MainMenu {
    Clear-Host
    Write-Host "Welcome to the Internal Player CMS!"
    Write-Host "---------------------------------------"
    Write-Host "1. Lookup Player Data"
    Write-Host "2. Add Player Ban/Warning"
    Write-Host "3. Edit Player Ban/Warning"
    Write-Host "4. Delete Player Ban/Warning"
    Write-Host "5. Exit"
    Write-Host "6. About"
    $choice = Read-Host "Select an option (1-6)"
    return $choice
}

# Function to display About information
function Show-About {
    Clear-Host
    Write-Host "About the Player CMS"
    Write-Host "---------------------"
    Write-Host "This is a simple Player Ban/Warn CMS developed in PowerShell."
    Write-Host "It allows staff to manage player data including bans and warnings."
    Write-Host "Version: 1.0"
    Write-Host "Created by: Your Name"
    Write-Host "Contact: your.email@example.com"
    Pause
}

# Function to lookup player data
function Lookup-PlayerData {
    $idType = Read-Host "Lookup by (1) Discord ID or (2) FiveM License?"
    $key = if ($idType -eq '1') { Read-Host "Enter Discord ID" } else { Read-Host "Enter FiveM License" }
    
    # Check local data first
    if ($dataStore.ContainsKey($key)) {
        $playerData = $dataStore[$key]
        Write-Host "Player Data (Local):"
        Write-Host "Discord ID: $($playerData.DiscordID)"
        Write-Host "FiveM License: $($playerData.FiveMLicense)"
        Write-Host "Type: $($playerData.Type)"
        Write-Host "ID: $($playerData.ID)"
        Write-Host "Staff Issuing: $($playerData.StaffConduct)"
    } else {
        Write-Host "No local data found for '$key'. Checking SQL Server..."
        # Replace with your SQL Server connection string
        $connectionString = "Server=your_server;Database=your_database;Integrated Security=True;"
        $sqlData = Get-SQLPlayerData -connectionString $connectionString -idType (if ($idType -eq '1') { "DiscordID" } else { "FiveMLicense" }) -idValue $key
        
        if ($sqlData) {
            Write-Host "Player Data (SQL):"
            Write-Host "Discord ID: $($sqlData.DiscordID)"
            Write-Host "FiveM License: $($sqlData.FiveMLicense)"
            Write-Host "Type: $($sqlData.Type)"
            Write-Host "ID: $($sqlData.ID)"
            Write-Host "Staff Issuing: $($sqlData.StaffConduct)"
        } else {
            Write-Host "No data found for '$key' in SQL Server."
        }
    }
    Pause
}

# Function to add player ban/warning
function Add-PlayerBanWarning {
    $discordID = Read-Host "Enter Discord ID"
    $fiveMLicense = Read-Host "Enter FiveM License"
    $type = Read-Host "Enter Type (Warning/Ban)"
    $id = Read-Host "Enter ID (for tracking)"
    $staffConduct = Read-Host "Enter Staff Issuing Conduct"

    # Create a hashtable for player data
    $playerData = @{
        DiscordID     = $discordID
        FiveMLicense  = $fiveMLicense
        Type          = $type
        ID            = $id
        StaffConduct  = $staffConduct
    }

    # Ensure $dataStore is initialized as a hashtable
    if (-not $dataStore -is [hashtable]) {
        $dataStore = @{}
    }

    # Store data using Discord ID as key
    $dataStore[$discordID] = $playerData
    Save-Data
    Write-Host "Player ban/warning added successfully."
    Pause
}

# Function to edit player ban/warning
function Edit-PlayerBanWarning {
    $idType = Read-Host "Edit by (1) Discord ID or (2) FiveM License?"
    $key = if ($idType -eq '1') { Read-Host "Enter Discord ID" } else { Read-Host "Enter FiveM License" }

    if ($dataStore.ContainsKey($key)) {
        $playerData = $dataStore[$key]
        Write-Host "Editing Player Data for '$key':"
        $playerData.DiscordID = Read-Host "Edit Discord ID ($($playerData.DiscordID))" -Default $playerData.DiscordID
        $playerData.FiveMLicense = Read-Host "Edit FiveM License ($($playerData.FiveMLicense))" -Default $playerData.FiveMLicense
        $playerData.Type = Read-Host "Edit Type (Warning/Ban) ($($playerData.Type))" -Default $playerData.Type
        $playerData.ID = Read-Host "Edit ID ($($playerData.ID))" -Default $playerData.ID
        $playerData.StaffConduct = Read-Host "Edit Staff Issuing Conduct ($($playerData.StaffConduct))" -Default $playerData.StaffConduct
        
        $dataStore[$key] = $playerData
        Save-Data
        Write-Host "Player data updated successfully."
    } else {
        Write-Host "No data found for '$key'."
    }
    Pause
}

# Function to delete player ban/warning
function Delete-PlayerBanWarning {
    $idType = Read-Host "Delete by (1) Discord ID or (2) FiveM License?"
    $key = if ($idType -eq '1') { Read-Host "Enter Discord ID" } else { Read-Host "Enter FiveM License" }

    if ($dataStore.ContainsKey($key)) {
        $dataStore.Remove($key)
        Save-Data
        Write-Host "Player ban/warning deleted successfully."
    } else {
        Write-Host "No data found for '$key'."
    }
    Pause
}

# Main loop to run the CMS
while ($true) {
    $userChoice = Show-MainMenu
    switch ($userChoice) {
        '1' { Lookup-PlayerData }
        '2' { Add-PlayerBanWarning }
        '3' { Edit-PlayerBanWarning }
        '4' { Delete-PlayerBanWarning }
        '5' { exit }
        '6' { Show-About }
        default { Write-Host "Invalid option. Please try again." }
    }
}
