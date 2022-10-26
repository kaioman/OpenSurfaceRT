@echo off
@setlocal enableextensions
@setlocal EnableDelayedExpansion
@cd /d "%~dp0"

REM To enable the option to remove Yahallo set change the setting below to True and run Jailbreak_USB_Menu.cmd as normal.

Set SkipCompatibilityCheck=False

@Title Surface RT/2 Jailbreak USB
mode con: cols=120 lines=30
echo Please wait...

REM
REM	jwa4
REM	

REM ====== Check if being run as admin =================================================================================================================================

For /f "tokens=1,2,3,4 USEBACKQ delims=," %%a in (`"%SystemRoot%\System32\whoami.exe /groups /fo csv /nh"`) Do (
	If %%c == "S-1-16-12288" Set RunAsAdmin=True
)

If not "%RunAsAdmin%" == "True" (
	echo Error: Please run as administrator.
	echo.
	goto Exit
)

REM ====== Check only one instance is running ==========================================================================================================================

9>&2 2>nul (Call :LockAndRestoreStdErr %* 8>>"%~f0") || (
	echo Error: Only one instance allowed - "%~f0" is already running >&2
	echo.
)
goto Exit

:LockAndRestoreStdErr
Call :SingleInstance %* 2>&9
exit /b 0

:SingleInstance

REM ====== Check is running form USB ===================================================================================================================================

If "%PROCESSOR_ARCHITECTURE%" == "ARM" (
	Goto ARMUSBCheck
) else (
	Goto NotARMUSBCheck
)

:ARMUSBCheck
For /F "usebackq skip=2 tokens=2-3 delims=," %%a in (`"wmic logicaldisk get caption, drivetype /format:csv"`) do (

	Set caption=%%a
	Set /a drivetype=%%b

	If "!drivetype!" equ "2" (
		If "%~d0\%~nx0"=="%~dpnx0" If  "!caption!" == "%~d0" (
			Set CD=%~d0
			Set RunningFromUSBDrive=True
			goto RunningFromUSB
		)
	)
)
goto USBCheck

:NotARMUSBCheck
for /f "skip=3 tokens=1,2 delims= " %%a in ('powershell -c "$ErrorActionPreference='Stop'; Get-CimInstance CIM_LogicalDisk | Select-Object DeviceID, DriveType"') do (

	Set caption=%%a
	Set /a drivetype=%%b

	If "!drivetype!" equ "2" (
		If "%~d0\%~nx0"=="%~dpnx0" If  "!caption!" == "%~d0" (
			Set CD=%~d0
			Set RunningFromUSBDrive=True
			goto RunningFromUSB
		)
	)
)
@Title Surface RT/2 Jailbreak USB
goto USBCheck

:USBCheck
If not "%RunningFromUSBDrive%" == "True" (
	echo Error: Not running from USB drive.
	echo.
	goto Exit
)

:RunningFromUSB

REM ====== Check nothing vital missing =================================================================================================================================

For %%c in (
	"%CD%\Jailbreak_USB_Menu.cmd"
	"%CD%\SecureBootDebugPolicy.p7b"
	"%CD%\efi\boot\bootarm.efi"
	"%CD%\efi\microsoft\boot\bcd"
	"%CD%\efi\microsoft\boot\fonts\segoe_slboot.ttf"
	"%CD%\efi\microsoft\boot\fonts\wgl4_boot.ttf"
	"%CD%\Firmware\Surface_2\Surface2FwUpdate.inf"
	"%CD%\Firmware\Surface_2\Surface2UEFI.bin"
	"%CD%\Firmware\Surface_2\Surface2UEFI.cat"
	"%CD%\Firmware\Surface_2\Surface_2.cmd"
	"%CD%\Firmware\Surface_RT_1_IDP\SurfaceRTUEFI.bin"
	"%CD%\Firmware\Surface_RT_1_IDP\SurfaceRTUEFI.cat"
	"%CD%\Firmware\Surface_RT_1_IDP\SurfaceRTUEFI.inf"
	"%CD%\Firmware\Surface_RT_1_IDP\Surface_RT_1_IDP.cmd"
	"%CD%\Jailbreak\WindowsUpdateManualMode.reg"
	"%CD%\Jailbreak\SecureBootDebugPolicy\SecureBootDebug.efi"
	"%CD%\Jailbreak\Yahallo\Yahallo.efi"
	"%CD%\Jailbreak\Yahallo\YahalloUndo.efi"
) do (
	If not exist %%c (
		echo Error: File Missing...
		echo %%c
		Set FileMissing=True
	)
)

If "%FileMissing%"=="True" (
	echo.	
	goto exit
)

REM ====== Get System Info =============================================================================================================================================

If not "%PROCESSOR_ARCHITECTURE%" == "ARM" goto Select

For /f "usebackq skip=2 tokens=1-3 delims==" %%a in (`wmic csproduct get name /format:list`) do (
	Set ProductName=%%b
	goto ProuctName
)
:ProuctName

For /f "usebackq skip=2 tokens=1-3 delims==" %%a in (`wmic /namespace:\\root\wmi path MS_SystemInformation get SystemSKU /format:list`) do (
	Set SystemSKU=%%b
	goto SystemSKU
)
:SystemSKU

For /f "usebackq skip=2 tokens=1-3 delims== " %%a in (`wmic bios get smbiosbiosversion /format:list`) do (
	Set BIOSVersion=%%b
	goto BIOSVersion
)
:BiosVersion

For /f "usebackq skip=2 tokens=1-3 delims== " %%a in (`wmic os get BuildNumber /format:list`) do (
	Set BuildNumber=%%b
	goto BuildNumber
)
:BuildNumber

For %%s in (
	"Surface_RT_1_IDP"
	"Surface_2"
) do (
	For %%a in (%%s) do (
		If %%a == "%SystemSKU%" If "%BuildNumber%" EQU "9600" (
			Set SupportedDevice=True
		)
	)

)

REM ====== Menu ========================================================================================================================================================

:Select
Set Target=
cls
echo ______________________________________________
echo.
echo Surface RT ^& 2 Jailbreak USB v1.4 - 10/01/2022
echo ______________________________________________
echo.
echo Yahallo - Copyright (C) 2019 - 2020, Bingxing Wang
echo Golden Keys - never_released ^& TheWack0lian
echo GoldenKeysUSB - lgibson02
echo.
echo All-in-on package to enable Surface RT ^& Surface 2 tablets to run third party applications under Windows RT 8.1 
echo or to boot alternative operating systems such as Windows 10 Build 15035 or Linux.
echo.
echo The use of this USB drive is entirely at your own risk.
echo ________________________________________________________________________________________________________________________
echo.
echo Please Select:
echo.
If "%PROCESSOR_ARCHITECTURE%" == "ARM" (
echo		=== USB Boot Menu Options ===		=== Test Signing ===		=== Misc ===
echo.
echo		1: Install Golden Keys			6: Enable Test Signing		8: Suspend BitLocker
echo		2: Uninstall Golden Keys		7: Disable Test Signing		9: Resume BitLocker
echo		3: Install Yahallo							10: Disable Windows Update	
echo		4: Uninstall Yahallo							11: Boot from USB
echo		5: Set Boot Menu Timeout						12: Reboot
) else (
echo		=== USB Boot Menu Options ===
echo.
echo		1: Install Golden Keys
echo		2: Uninstall Golden Keys
echo		3: Install Yahallo
echo		4: Uninstall Yahallo
echo		5: Set Boot Menu Timeout
)
echo.
echo		E: Exit	
echo.
Set /p Target=Enter Selection: 
echo.

If /i "%Target%"=="E" goto Exit

If "%Target%"=="1" (
	Set GoldenKeysMode=InstallGoldenKeys
	goto GoldenKeysCheck
)
If "%Target%"=="2" goto RemoveGoldenKeys

If "%Target%"=="3" (
	Set YahalloMode=ApplyYahallo
	Goto YahalloCheck
)

If "%Target%"=="4" goto RemoveYahallo


If "%Target%"=="5" goto TimeOutSelect
If "%PROCESSOR_ARCHITECTURE%" == "ARM" (
	If "%Target%"=="6" goto TestSigningEnable
	If "%Target%"=="7" goto TestSigningDisable
	If "%Target%"=="8" goto BitLockerDisable
	If "%Target%"=="9" goto BitLockerEnable
	If "%Target%"=="10" goto WUManual
	If "%Target%"=="11" goto USBBoot
	If "%Target%"=="12" goto Reboot
)
cls
goto Select

REM ====== Golden Keys =================================================================================================================================================

:GoldenKeysCheck

If "%SkipCompatibilityCheck%" == "False" If "%SupportedDevice%" == "True" (

	For %%f in (
		hal.dll#6.3.9600.17196
		ntoskrnl.exe#6.3.9600.18505
		winload.efi#6.3.9600.18474
	) do (
		For /f "tokens=1,2 delims=#" %%a in ("%%f") do (

			For /f "tokens=4 delims=." %%r in ("%%b") do (
				Set /a VersionMax=%%r
			)

			For /f "tokens=5 delims==." %%i in ('wmic datafile where "name='%HomeDrive%\\Windows\\System32\\%%a'" get version /format:list') do (
				Set /a VersionFound=%%i
			)

			If !VersionFound! GTR !VersionMax! (
				Set JailbreakKiller=True
			)

		)

	)

	If "!JailbreakKiller!" == "True" (
		Set JailbreakKiller=False
		echo ________________________________________________________________________________________________________________________
		echo Warning: Golden Keys does support %ProductName% however it will not install correctly due to the presence
		echo of "Jailbreak Killing" updates on this device.
		echo.
		echo To install Golden Keys either remove any Windows Updates dated newer than November 2016, restore the device
		echo using a Bare metal recovery image or clear the eMMC before attempting to install Golden Keys.
		echo ________________________________________________________________________________________________________________________
	)

)

goto %GoldenKeysMode%

:InstallGoldenKeys
Set Selected=Install Golden Keys
bcdedit /store "%CD%\efi\microsoft\boot\bcd" /default {7619dcc9-fafe-11d9-b411-000476eba25f}
If "%ErrorLevel%" EQU "0" (
	Set Message=Default boot entry has been set to "%Selected%".
) else (
	Set Message=Failed to set default boot entry to "%Selected%".
)
goto Continue

:RemoveGoldenKeys
Set Selected=Uninstall Golden Keys
bcdedit /store "%CD%\efi\microsoft\boot\bcd" /default {d72f0582-d81c-11eb-a66c-00235422b3b4}
If "%ErrorLevel%" EQU "0" (
	Set Message=Default boot entry has been set to "%Selected%".
) else (
	Set Message=Failed to set default boot entry to "%Selected%".
)
goto Continue

REM ====== Yahallo =====================================================================================================================================================

:YahalloCheck

If "%SkipCompatibilityCheck%" == "False" If "%SupportedDevice%" == "True" (

REM 		"SKU"#"SupportBIOS1,SupportedBIOS2"#"MaxKnownBIOS"#"
	For %%s in (
		"Surface_RT_1_IDP"#"v3.31.500"#"v3.31.500"
		"Surface_2"#"v4.22.500,v2.6.500"#"v4.22.500"
	) do (
		For /f "tokens=1,2,3 delims=#" %%a in ("%%s") do (
			
			If %%a == "%SystemSKU%" (

				Set FoundBIOSVersionNumber=%BIOSVersion%
				Set FoundBIOSVersionNumber=!FoundBIOSVersionNumber:v=!
				Set /a FoundBIOSVersionNumber=!FoundBIOSVersionNumber:.=!

				Set MaxBIOSVersionNumber=%%c
				Set MaxBIOSVersionNumber=!MaxBIOSVersionNumber:v=!
				Set /a MaxBIOSVersionNumber=!MaxBIOSVersionNumber:.=!

				For %%a in (%%~b) do (

					Set CompatibleBIOSVersionNumber=%%a
					Set CompatibleBIOSVersionNumber=!CompatibleBIOSVersionNumber:v=!
					Set /a CompatibleBIOSVersionNumber=!CompatibleBIOSVersionNumber:.=!

					If !FoundBIOSVersionNumber! EQU !CompatibleBIOSVersionNumber! Set YahalloCompatible=True

					If not "!YahalloCompatible!" == "True" (
						If !FoundBIOSVersionNumber! GTR !MaxBIOSVersionNumber! Set NewBIOS=True
						If !FoundBIOSVersionNumber! LSS !CompatibleBIOSVersionNumber! Set OldBIOS=True
					)

				)

				If "!YahalloCompatible!" == "True" (
					goto %YahalloMode%
				) else (
					If "!OldBIOS!" == "True" (
						Set OfferUEFIUpdate=True
					)
					If "!NewBIOS!" == "True" (
						Set OfferUEFIUpdate=False
						echo ________________________________________________________________________________________________________________________
						echo Warning: The installed UEFI version %BIOSVersion% is newer than the last known version of %%~c available
						echo for the %ProductName%.
						echo.
						echo Please contact @jwa4 - https://forum.xda-developers.com/conversations/add?to=jwa4
						echo ________________________________________________________________________________________________________________________
					)

				)

			)

		)

	)

	If "!OfferUEFIUpdate!" == "True" (
		Set InfPath=%CD%\Firmware\%SystemSKU%
		If exist "!InfPath!\%SystemSKU%.cmd" (
			call "!InfPath!\%SystemSKU%.cmd" UEFIUpdateMenu
		)
	)

)

goto %YahalloMode%

:ApplyYahallo
Set Selected=Install Yahallo
bcdedit /store "%CD%\efi\microsoft\boot\bcd" /default {df8d36fd-9638-11eb-a5f9-00235422b3b4}
If "%ErrorLevel%" EQU "0" (
	Set Message=Default boot entry has been set to "%Selected%".
) else (
	Set Message=Failed to set default boot entry to "%Selected%".
)
goto Continue

:RemoveYahallo
Set Selected=Uninstall Yahallo
bcdedit /store "%CD%\efi\microsoft\boot\bcd" /default {1b9d580e-9639-11eb-a5f9-00235422b3b4}
If "%ErrorLevel%" EQU "0" (
	Set Message=Default boot entry has been set to "%Selected%".
) else (
	Set Message=Failed to set default boot entry to "%Selected%".
)
goto Continue

REM ====== Boot Menu Timeout ===========================================================================================================================================

:TimeOutSelect
Set "x="
Set /p TimeOutPrompt=Please enter a countdown duration in seconds: 
echo.
For /f "delims=0123456789" %%i in ("%TimeOutPrompt%") do set x=%%i
If "%TimeOutPrompt%" == "" goto TimeOutSelect

If defined x (
	goto TimeOutSelect
) else (
	bcdedit /store "%CD%\efi\microsoft\boot\bcd" /timeout %TimeOutPrompt%
	If "!ErrorLevel!" EQU "0" (
		Set Message=Default timeout set to %TimeOutPrompt% seconds.
	) else (
		Set Message=Failed to set default timeout to %TimeOutPrompt% seconds.
	)
)
goto Continue

REM ====== Test Signing ================================================================================================================================================

:TestSigningEnable
bcdedit /set {bootmgr} testsigning on
If "%ErrorLevel%" EQU "0" (
	Set bootmgr_testsigning=True
) else (
	Set bootmgr_testsigning=False
)

bcdedit /set {default} testsigning on
If "%ErrorLevel%" EQU "0" (
	Set default_testsigning=True
) else (
	Set default_testsigning=False
)

bcdedit /set {default} NoIntegrityChecks Yes
If "%ErrorLevel%" EQU "0" (
	Set default_NoIntegrityChecks=True
) else (
	Set default_NoIntegrityChecks=False
)

If "%bootmgr_testsigning%" == "True" If "%default_testsigning%" == "True" If "%default_NoIntegrityChecks%" == "True" (
	Set Message=Test Signing enabled, please reboot for changes to take effect.
	goto Continue
)

Set Message=Unable to enable Test Signing.

goto Continue

:TestSigningDisable
bcdedit /set {bootmgr} testsigning off
If "%ErrorLevel%" EQU "0" (
	Set bootmgr_testsigning=True
) else (
	Set bootmgr_testsigning=False
)

bcdedit /set {default} testsigning off
If "%ErrorLevel%" EQU "0" (
	Set default_testsigning=True
) else (
	Set default_testsigning=False
)

bcdedit /set {default} NoIntegrityChecks No
If "%ErrorLevel%" EQU "0" (
	Set default_NoIntegrityChecks=True
) else (
	Set default_NoIntegrityChecks=False
)

If "%bootmgr_testsigning%" == "True" If "%default_testsigning%" == "True" If "%default_NoIntegrityChecks%" == "True" (
	Set Message=Test Signing disabled, please reboot for changes to take effect.
	goto Continue
)

Set Message=Unable to disable Test Signing.

goto Continue

REM ====== BitLocker ===================================================================================================================================================

:BitLockerDisable
manage-bde -protectors %systemdrive% -disable
If "%ErrorLevel%" EQU "0" (
	Set Message=Bitlocker disabled.
) else (
	Set Message=Failed to disable bitlocker.
)
goto Continue

:BitLockerEnable
manage-bde -protectors %systemdrive% -enable
If "%ErrorLevel%" EQU "0" (
	Set Message=Bitlocker enabled.
) else (
	Set Message=Failed to enable bitlocker.
)
goto Continue

:WUManual
REG IMPORT "%CD%\Jailbreak\WindowsUpdateManualMode.reg"
If "%ErrorLevel%" EQU "0" (
	Set Message=Automatic Windows Update disabled.
) else (
	Set Message=Failed to disable automatic Windows Update.
)
goto Continue

REM ====== USB Boot ====================================================================================================================================================

:USBBoot
for /F "usebackq tokens=1-2" %%a in (`bcdedit /enum FIRMWARE`) DO (
	Set ID=%%b
	if /i "!ID:~0,1!"=="{" Set ID1=%%b
	if /I "%%b" == "USB" Set USBID=!ID1!
)

bcdedit /set {fwbootmgr} bootsequence !USBID!
If "%ErrorLevel%" EQU "0" (
	Set Message=Device will attempt to boot from USB after next reboot.
) else (
	Set Message=Unable to boot from USB after next reboot.
)
goto Continue

REM ====== Reboot ======================================================================================================================================================

:Reboot
Set /p ConfirmPrompt=Device will reboot immediately, would you like to continue? (Y/N)? 
If /i "%ConfirmPrompt%"=="Y" (
	Shutdown -r -f -t 0 -y
	Exit
)
If /i "%ConfirmPrompt%"=="N" (
	Set Message=Reboot aborted.
	goto Continue
)
If "%Confirm%" == "" goto Reboot

REM ====== Status ======================================================================================================================================================

:Continue
echo.
If not "!Message!" == "" (
	echo !Message!
	echo.
)
If "%Reboot%" == "True" (
	Set Reboot=False
	echo Rebooting...
	Shutdown -r -f -t 0 -y
)
pause
Set "Message="
goto Select

REM ====== Done ========================================================================================================================================================

:Exit

Echo Goodbye!
Pause
Exit