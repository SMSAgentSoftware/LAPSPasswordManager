####################################
##                                ##
## Contains PowerShell functions  ##
##                                ##
####################################

# Function to get the current local admin password
Function Get-CurrentPassword {
    Param($ComputerName)
    
    Try
    {
        $Searcher = [adsisearcher]""#([adsi]$OU)
        $Searcher.Filter = "(&(objectClass=computer)(cn=$ComputerName))"
        $Result = $Searcher.FindOne()
        $Password = $Result[0].Properties.'ms-mcs-admpwd'
        $ExpirationTimestamp = [datetime]::FromFileTime([Long]::Parse($Result[0].Properties.'ms-mcs-admpwdexpirationtime'))
        $UI.DataSource[4] = $ExpirationTimestamp
        $UI.DataSource[5] = $Password[0]
    }
    Catch
    {
        $UI.DataSource[1] = $false
        $UI.DataSource[2] = "Error"
        $text = "We couldn't find a password for that computer, or you don't have the required access."
        $UI.Window.Dispatcher.Invoke({
            $mds = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::Affirmative
            $ColourScheme = [MahApps.Metro.Controls.Dialogs.MetroDialogColorScheme]::Accented
            $settings = New-Object MahApps.Metro.Controls.Dialogs.MetroDialogSettings
            $settings.ColorScheme = $ColourScheme
            $result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($UI.Window,"Oh dear!",$Text,$mds,$settings)
        })
        Return
    }
    $UI.DataSource[1] = $false
    $UI.DataSource[2] = "Done"
}

# Function to set a new expiration date for the password
Function Reset-Password {
    Param($ComputerName,$SelectedDate)

    Try
    {
        Add-Type -AssemblyName System.DirectoryServices.Protocols -ErrorAction Stop
        $Searcher = [adsisearcher]""#([adsi]$OU)
        $Searcher.Filter = "(&(objectClass=computer)(cn=$ComputerName))"
        $Result = $Searcher.FindOne()

        $LdapConnection = New-Object System.DirectoryServices.Protocols.LdapConnection("$env:USERDNSDOMAIN")
        $LdapConnection.SessionOptions.ReferralChasing = [System.DirectoryServices.Protocols.ReferralChasingOptions]::All
        $LdapConnection.SessionOptions.Sealing = $true
        $LdapConnection.SessionOptions.Signing = $true

        $ModifyRequest = New-Object System.DirectoryServices.Protocols.ModifyRequest
        $ModifyRequest.DistinguishedName = $Result.Properties.distinguishedname
        $DirectoryAttributeModification = New-Object System.DirectoryServices.Protocols.DirectoryAttributeModification
        $DirectoryAttributeModification.Name = "ms-Mcs-AdmPwdExpirationTime"
        $DirectoryAttributeModification.Operation = [System.DirectoryServices.Protocols.DirectoryAttributeOperation]::Replace
        $DirectoryAttributeModification.Add($SelectedDate.ToFileTime().ToString("D",[System.Globalization.NumberFormatInfo]::InvariantInfo))
        $ModifyRequest.Modifications.Add($DirectoryAttributeModification)
        $Request = $LdapConnection.SendRequest($ModifyRequest)
    }
    Catch
    {
        $UI.DataSource[1] = $false
        $UI.DataSource[2] = "Error"
        $text = "Could not set the new expiration date."
        $UI.Window.Dispatcher.Invoke({
            $mds = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::Affirmative
            $ColourScheme = [MahApps.Metro.Controls.Dialogs.MetroDialogColorScheme]::Accented
            $settings = New-Object MahApps.Metro.Controls.Dialogs.MetroDialogSettings
            $settings.ColorScheme = $ColourScheme
            $result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($UI.Window,"Oops!",$Text,$mds,$settings)
        })
        Return
    }

    If ($Request.ResultCode -eq "Success")
    {
        $UI.DataSource[1] = $false
        $UI.DataSource[2] = "Done"
        $text = "The new expiration date was successfully set."
        $UI.Window.Dispatcher.Invoke({
            $mds = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::Affirmative
            $ColourScheme = [MahApps.Metro.Controls.Dialogs.MetroDialogColorScheme]::Accented
            $settings = New-Object MahApps.Metro.Controls.Dialogs.MetroDialogSettings
            $settings.ColorScheme = $ColourScheme
            $result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($UI.Window,"Yay!",$Text,$mds,$settings)
        })
        Return
    }
    Else
    {
        $UI.DataSource[1] = $false
        $UI.DataSource[2] = "Error"
        $text = "There was a problem setting the new expiration date. Result code: $($Request.ResultCode). ErrorMessage: $($Request.ErrorMessage)"
        $UI.Window.Dispatcher.Invoke({
            $mds = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::Affirmative
            $ColourScheme = [MahApps.Metro.Controls.Dialogs.MetroDialogColorScheme]::Accented
            $settings = New-Object MahApps.Metro.Controls.Dialogs.MetroDialogSettings
            $settings.ColorScheme = $ColourScheme
            $result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($UI.Window,"Oops!",$Text,$mds,$settings)
        })
        Return
    }
}