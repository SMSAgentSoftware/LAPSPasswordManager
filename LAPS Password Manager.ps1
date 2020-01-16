#############################################################
##                                                         ##
##                  LAPS PASSWORD MANAGER                  ##
##                                                         ##
## Author:      Trevor Jones                               ##
## Blog:        smsagent.blog                              ##
##                                                         ##
#############################################################


# Set the location we are running from
$Source = $PSScriptRoot

# Load the function library
. "$Source\bin\FunctionLibrary.ps1"

# Load the required assemblies
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase
Add-Type -Path "$Source\bin\System.Windows.Interactivity.dll"
Add-Type -Path "$Source\bin\ControlzEx.dll"
Add-Type -Path "$Source\bin\MahApps.Metro.dll"

# Load the main window XAML code
[XML]$Xaml = [System.IO.File]::ReadAllLines("$Source\Xaml\App.xaml") 

# Create a synchronized hash table and add the WPF window and its named elements to it
$UI = [System.Collections.Hashtable]::Synchronized(@{})
$UI.Window = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $xaml))
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | 
    ForEach-Object -Process {
        $UI.$($_.Name) = $UI.Window.FindName($_.Name)
    }

# Hold the background jobs here. Useful for querying the streams for any errors.
$UI.Jobs = @()
# View the error stream for the first background job, for example
#$UI.Jobs[0].PSInstance.Streams.Error

# Load in the other code libraries.
. "$Source\bin\ClassLibrary.ps1"
. "$Source\bin\EventLibrary.ps1"

# Set the logo image
$IMGBase64 = "iVBORw0KGgoAAAANSUhEUgAAABYAAAAYCAYAAAD+vg1LAAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAAOwwAADsMBx2+oZAAAAEF0RVh0Q29tbWVudABDUkVBVE9SOiBnZC1qcGVnIHYxLjAgKHVzaW5nIElKRyBKUEVHIHY2MiksIHF1YWxpdHkgPSA4NQrM8MbhAAAET0lEQVRIS6WUe0xVdRzA8Y82a/VPW2MuNm0O0mQVNSN8hArTizwMRHnHJaDLQ00BDQlKIefCqYQPUAsNSgYYiOwaqEBigoIy8UGQF73yiKeAcLkPXp/OPVwE5Ua0Pttv55zv+X4/v/P7nvM7JqOjo4yMjDCZ56/1GItNx4zF/5UZizsfq/jj3p+cz83iYmGJIfrPzEjc21FHa2U0PNgCjeGM1Idyt+AT0vf6U3zpMsNGFvivYo1Gha6zGLp+hAZ/eCTIHwZDs0yYKAh1VQRV5VcM2RNMKx5QazienEjJmWNcv5BNbfVv6G4EMNiVj649CxSC/HYA6vJNtLV3iTXjTCtOSU2lvb1VPB8dHUb58AHywssUZGWQm5bEr/LzqK+FQKWU/vocMW+cacXHvz+FWvWY9ocKPExn09ioICv7NG21t8X7itpbZBxPgqpghqpixdg4RsVCiMFBDd11J7gkP8NQfwMdbS1UVFaQk5HGWtOXxTyddoDInbvZHOjLpdRwMTaOUbGevvodwosKpKMokLKT0WTGrONEyDuUyPMYVjUwqOqgovou++KjiPC1x9fLy1A5hlHxkPDEKD6FugD6E4Op3+OEtng93PFG+Ysb13L281PSLjK+dER1zg2uSEHViL5sHCPiUaprKrkpjxI+4FCUsU4UfSyhxltKvu16SkOXoiuR0JppQ5/cAc0FPwbLItEMG8oNiGJ9T3W6AUaa4ji5bzWRXtZIpF8Rm5SM6o7Qu1uuKDOXUJJgyb1UO2iPgDZhYkUY3Ahi4FaaQTfBU7FW+wRaviMiVIqdrS1vWdvh+20uzjE5yBKSOJcXT0d1pLDzBFlDANT6QYU7jdk+1FaVGnQTTGnFz+npfGj5JmZmc/HZc5qQg2dZ5bsdhy2HWPbZIVaEHcZpUyIbpaG4+AWx3NGd38suGKonmCLOL77KB5INLPrIkc1HCrD3j2al5+e8a++Jf3waHjtTWBUYx0J7bxaYWxDkILSnQFjBc0wR58kLcZDtYusROT5fn0K2L4slLgG4bv4G39ijuG1NZLFHJG4SG8zfsGDB/IVYmM2BpqMGwxhTxHpkUTHC8rfhGZ3Mxi+O4hF9GJdtB/GKScF9exKeMuFHdNWT/SFLOXAgmUc3sxkptUGj0xgMRsQ/HEthwbx5zJ5jzmKJO+uCd+AQEMVa2W5ct+zFMSwBJ1kcVm4RuLquobOjTazr6+0Uj+NMEd9X3MfW+n1mvfASJq+8zmtz57No2RoWO/ux0iucFd7hrPYO5T2JhxCX0NvTjUqlYmh48vZ4TqxP0HOxqBATExOe9PaK13pefNUM0/lvY7ncgUXCcPaUUl5ejlKppLm5ma6uLgYGhL1gcD0j7mxtpa+7RzxXC0mTsbayEiebJYzrgrClqemptKenR9hgOkPmGM+I+/r76RWeUj+zVqsVj/qhVqvFnJqaGs6dzeevlhYxfzqm9FiPPvb/gL8BKNIE4hVIdREAAAAASUVORK5CYII="
$LogoImage = New-Object System.Windows.Media.Imaging.BitmapImage
$LogoImage.BeginInit()
$LogoImage.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($IMGBase64)
$LogoImage.EndInit()
$UI.Logo.Source = $LogoImage

# Set the current date as default for expiration date
$UI.NewPasswordExpiration.SelectedDate = Get-Date

# OC for data binding source
$UI.DataSource = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
$UI.DataSource.Add($null)   # [0] Not used
$UI.DataSource.Add($false)  # [1] Progress Bar Indeterminate
$UI.DataSource.Add("Ready") # [2] Status text
$UI.DataSource.Add("White") # [3] Status foreground
$UI.DataSource.Add($null)   # [4] Current password expiration 
$UI.DataSource.Add($null)   # [5] Current password

# Set the datacontext of the window to the OC for databinding
$UI.Window.DataContext = $UI.DataSource

# Display the main window
# If code is running in ISE, use ShowDialog()...
if ($psISE)
{
    $null = $UI.window.Dispatcher.InvokeAsync{$UI.window.ShowDialog()}.Wait()
}
# ...otherwise run as an application
Else
{
    # Hide the PowerShell console window
    $windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
    $asyncwindow = Add-Type -MemberDefinition $windowcode -Name Win32ShowWindowAsync -Namespace Win32Functions -PassThru
    $null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
    
    # Run the main window in an application
    $app = New-Object -TypeName Windows.Application
    $app.Properties
    $app.Run($UI.Window)
}