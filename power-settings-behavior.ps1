<#
Sets power settings on newly imaged laptops to do the following:

- shut down when shut down butten is pressed
- do nothing when the lid is closed

for the powercfg command, to set the settings, you need 3 guids in the correct order followed by your action
- active scheme guid, power (root) guid, then the [selected] guid (in this case power button action and lid close action)
    and finally a value to set it to (#) 0 = do nothing,1 = sleep,2 = hibernate,3 = shut down
-- command (a)(b)(c)(#)
#>

#active scheme GUID
$activeScheme = cmd /c "powercfg /getactivescheme"
$regEx = '(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}'
$asGuid = [regex]::Match($activeScheme,$regEx).Value
#
#root GUID for lid/button power settings
$powerGuid = '4f971e89-eebd-4455-a8de-9e59040e7347'
#
$lidClosedGuid = '5ca83367-6e45-459f-a27b-476b1d01c936'
##
$buttonActionGuid = '7648efa3-dd9c-4e3e-b566-50f929386280'
#
# DC Value // On Battery // 0 = do nothing,1 = sleep,2 = hibernate,3 = shut down
cmd /c "powercfg /setdcvalueindex $asGuid $powerGuid $lidClosedGuid 0"
cmd /c "powercfg /setdcvalueindex $asGuid $powerGuid $buttonActionGuid 3"
# DC Value // On Battery // 0 = do nothing,1 = sleep,2 = hibernate,3 = shut down
cmd /c "powercfg /setacvalueindex $asGuid $powerGuid $lidClosedGuid 0"
cmd /c "powercfg /setacvalueindex $asGuid $powerGuid $buttonActionGuid 3"
#
#apply settings
cmd /c "powercfg /s $asGuid"