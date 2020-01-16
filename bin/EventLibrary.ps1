#############################
##                         ##
## Defines event handlers  ##
##                         ##
#############################

# Bring the main window to the front once loaded
$UI.Window.Add_Loaded({
    $This.Activate()
})

# Allow windows drag
$UI.Grid.Add_MouseLeftButtonDown({
    $UI.Window.DragMove()
})

# Computername text changed
$UI.ComputerName.add_TextChanged({
    If ($this.Text.Length -ge 5)
    {
        $UI.GetCurrent.IsEnabled = "True"
    }
    Else
    {
        $UI.GetCurrent.IsEnabled = $false
    }
})

# Current password text changed
$UI.CurrentPassword.add_TextChanged({
    If ($this.Text.Length -ge 1)
    {
        $UI.Set.IsEnabled = "True"
    }
    Else
    {
        $UI.Set.IsEnabled = $false
    }
})

# Get current password button
$UI.GetCurrent.Add_Click({

    $UI.DataSource[1] = "True"
    $UI.DataSource[2] = "Searching..."
    $UI.DataSource[4] = $null
    $UI.DataSource[5] = $null

    # Main code to run in background job
    $Code = {
        # Always declare as parameters any variables passed to the background job in the same order
        Param($UI,$ComputerName)
        
        Get-CurrentPassword -ComputerName $ComputerName
    }

    $ComputerName = $UI.ComputerName.Text

    # Start a background job
    # Using code, parameters and functions
    $Job = [BackgroundJob]::New($Code,@($UI,$ComputerName),@("Function:\Get-CurrentPassword"))
    $UI.Jobs += $Job
    $Job.Start()
})


# Set new expiration date button
$UI.Set.Add_Click({
    
    $UI.DataSource[1] = "True"
    $UI.DataSource[2] = "Setting password expiration date..."

    # Main code to run in background job
    $Code = {
        # Always declare as parameters any variables passed to the background job in the same order
        Param($UI,$ComputerName,$SelectedDate)
        
        Reset-Password -ComputerName $ComputerName -SelectedDate $SelectedDate
    }

    $ComputerName = $UI.ComputerName.Text
    $SelectedDate = $UI.NewPasswordExpiration.SelectedDate

    # Start a background job
    # Using code, parameters and functions
    $Job = [BackgroundJob]::New($Code,@($UI,$ComputerName,$SelectedDate),@("Function:\Reset-Password"))
    $UI.Jobs += $Job
    $Job.Start()
})

# Close button
$UI.Close.Add_Click({

    $UI.Window.Close()

})