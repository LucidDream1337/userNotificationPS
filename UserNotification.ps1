function Set-RegisteredTask(){
    param (
        # Eindeutiger Bezeichner für den Task der Erstellt wird (Aufgabenplanung\Aufgabenplanungsbibliothek)
        [String]
        $TaskName,
        # Auszuführender Befehl
        [string]
        $Command,
        # Parameter für den Befehl
        [String]
        $Arguments,
        # Bei OneTimeRun $true wird der Befehl einmal ausgeführt und die Aufgabe im Anschluss entfernt
        [Switch]
        $OneTimeRun = $false,
        # Usercontext auf $true wenn der Befehl als der angemeldete Benutzer ausgeführt werden soll
        [Switch]
        $UserContext = $false,
        # Optionaler Parameter; Hinterlegt ein Ablauf-Datum zur Aufgabe
        [int]
        $ExpirationInMinutes
    )

    # Rufe derzeit angemeldeten Benutzer ab
    if ($UserContext) {
        $principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -expand UserName)
    } else {
        $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    }

    # Erstellung der Aufgabe
    $action = New-ScheduledTaskAction -Execute $Command -Argument $Arguments
    $taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable -DeleteExpiredTaskAfter:(New-TimeSpan -Start (Get-Date) -End (Get-Date).AddMinutes($ExpirationInMinutes))

    ## INFO: Derzeit ist der Trigger "Bei Login eines Benutzers"; Anpassungen können nach MS-Docs "New-ScheduledTaskTrigger" vorgenommen werden
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -expand UserName)
    if ($ExpirationInMinutes) {
        $trigger.EndBoundary = [DateTime]::Now.AddMinutes($ExpirationInMinutes).ToString("yyyy-MM-dd'T'HH:mm:ss")
    }


    $task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $taskSettings

    # Registrieren und ggf. Ausführen der Aufgabe
    Register-ScheduledTask -TaskName $TaskName -InputObject $task 

    if ($OneTimeRun) {
        Start-ScheduledTask -TaskName $TaskName
        Start-Sleep 5
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    }
}

Set-RegisteredTask -TaskName "Inform_User" -Command "powershell.exe" -Arguments "-ExecutionPolicy Bypass -WindowStyle hidden -File `"$PSScriptRoot\Notification.ps1`"" -OneTimeRun $false -UserContext $true