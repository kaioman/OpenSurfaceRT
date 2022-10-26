@echo off

REM ====== Set =========================================================================================================================================================

Set Stage=%1

If "%Stage%" == "" (
	goto UEFIUpdateComplete
) else (
	goto %Stage%
)

REM ====== UEFI Update Options =========================================================================================================================================

:UEFIUpdateMenu

Set UEFI_BIN=Surface2UEFI.bin
Set UEFI_BIN_SHA1=9e502f4238f8403f69b6f34d0fe81ce07f1f0111
Set UEFI_CAT=Surface2UEFI.cat
Set UEFI_CAT_SHA1=a4ed90ea8d618c658eaed3f6076d7ad13435236c
Set UEFI_INF=Surface2FwUpdate.inf
Set UEFI_INF_SHA1=9f7a23e0cab2abdc5c079ba31453bb9b3fd0287f
Set UEFI_Version=v4.22.500

:UEFIUpdateSelect
Set UEFIUpdatePrompt=
Set UEFIUpdate=
echo ________________________________________________________________________________________________________________________
echo Warning: Yahallo does support %ProductName% but it does not support the currently installed UEFI Version %BIOSVersion%.
echo.
echo Would you like to update the UEFI? Selecting "Yes" will install the UEFI Update, when prompted click OK. If 
echo the update is successful the device will immediately reboot.
echo.
Set /p UEFIUpdatePrompt=Attempt to install UEFI %UEFI_Version% (Y/N)? 

If /i "%UEFIUpdatePrompt%"=="Y" (
	Set UEFIUpdate=True
	goto UEFIUpdate
)
If /i "%UEFIUpdatePrompt%"=="N" (
	Set UEFIUpdate=False
	Set Reboot=False
	echo ________________________________________________________________________________________________________________________
	goto UEFIUpdateComplete
)

goto UEFIUpdateSelect

REM ====== UEFI Update =================================================================================================================================================

:UEFIUpdate

Set Reboot=False

If "%UEFIUpdate%" == "True" (

	echo.
	echo Verifying UEFI Update Files.
	echo Please wait...
	echo.

	For %%a in (
		%UEFI_BIN_SHA1%#"!InfPath!\%UEFI_BIN%"
		%UEFI_CAT_SHA1%#"!InfPath!\%UEFI_CAT%"
		%UEFI_INF_SHA1%#"!InfPath!\%UEFI_INF%"
	) do (

		For /f "tokens=1,2 delims=#" %%b in ("%%a") do (

			Set UEFI_FileSHA1=%%b
			Set UEFI_File=%%c

	 		For /f "delims=" %%d in ('%SystemRoot%\System32\certutil.exe -hashfile !UEFI_File! SHA1 ^| %SystemRoot%\System32\find.exe /v ":"') do (
				Set z=%%d
				Set UEFI_FileFoundSHA1=!z: =!
			)

			If not !UEFI_FileSHA1! equ !UEFI_FileFoundSHA1! (
				echo File Bad: %%~nxc
				Set UEFIAbort=True
			) else (
				echo File OK: %%~nxc
			)
		)

	)

	If "!UEFIAbort!" == "True" (
		Set Reboot=False
		Set UEFIUpdate=False
		Set UEFIAbort=False
		echo.
		echo Aborting UEFI Update.
		echo ________________________________________________________________________________________________________________________
		goto UEFIUpdateComplete
	)

	echo.
	echo Updating UEFI.
	echo Please wait...
	echo.
	"%SystemRoot%\System32\InfDefaultInstall.exe" "!InfPath!\!UEFI_INF!"
	If "!ErrorLevel!" EQU "0" (
		echo Installation Complete.
		Set Reboot=True
	) else (
		Set Reboot=False
		echo Error: Unable to install UEFI Update.
		echo InfDefaultInstall Error: !ErrorLevel!
	)

	echo ________________________________________________________________________________________________________________________

)

goto UEFIUpdateComplete

REM ====== End =========================================================================================================================================================

:UEFIUpdateComplete

If "%Stage%" == "" (
	echo.
	Echo Goodbye!
	pause
)

Set "Stage="