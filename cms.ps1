$jsonFilePath = "\writepath\player_data.json"

# Load existing data from JSON file
if (Test-Path $jsonFilePath) {
    $dataStore = Get-Content -Path $jsonFilePath | ConvertFrom-Json
    if (-not $dataStore) {
        $dataStore = @{}  # Initialize as an empty hashtable if loading failed
    }
} else {
    $dataStore = @{}  # Initialize as an empty hashtable
}

# Function to save data to JSON file
function Save-Data {
    $dataStore | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonFilePath
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
    $choice = Read-Host "Select an option (1-5)"
    return $choice
}

# Function to lookup player data
function Lookup-PlayerData {
    $idType = Read-Host "Lookup by (1) Discord ID or (2) FiveM License?"
    $key = if ($idType -eq '1') { Read-Host "Enter Discord ID" } else { Read-Host "Enter FiveM License" }

    if ($dataStore.ContainsKey($key)) {
        $playerData = $dataStore[$key]
        Write-Host "Player Data:"
        Write-Host "Discord ID: $($playerData.DiscordID)"
        Write-Host "FiveM License: $($playerData.FiveMLicense)"
        Write-Host "Type: $($playerData.Type)"
        Write-Host "ID: $($playerData.ID)"
        Write-Host "Staff Issuing: $($playerData.StaffConduct)"
    } else {
        Write-Host "No data found for '$key'."
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

    # Create an object for player data
    $playerData = @{
        DiscordID = $discordID
        FiveMLicense = $fiveMLicense
        Type = $type
        ID = $id
        StaffConduct = $staffConduct
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
        default { Write-Host "Invalid option. Please try again." }
    }
}
