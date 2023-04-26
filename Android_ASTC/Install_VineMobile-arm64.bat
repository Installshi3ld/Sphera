setlocal
if NOT "%UE_SDKS_ROOT%"=="" (call %UE_SDKS_ROOT%\HostWin64\Android\SetupEnvironmentVars.bat)
set ANDROIDHOME=%ANDROID_HOME%
if "%ANDROIDHOME%"=="" set ANDROIDHOME=C:/Users/Thoma/AppData/Local/Android/Sdk
set ADB=%ANDROIDHOME%\platform-tools\adb.exe
set AFS=.\win-x64\UnrealAndroidFileTool.exe
set DEVICE=
if not "%1"=="" set DEVICE=-s %1
for /f "delims=" %%A in ('%ADB% %DEVICE% shell "echo $EXTERNAL_STORAGE"') do @set STORAGE=%%A
@echo.
@echo Uninstalling existing application. Failures here can almost always be ignored.
%ADB% %DEVICE% uninstall com.niinko.phoneTest
@echo.
@echo Installing existing application. Failures here indicate a problem with the device (connection or storage permissions) and are fatal.
%ADB% %DEVICE% install VineMobile-arm64.apk
@if "%ERRORLEVEL%" NEQ "0" goto Error
%ADB% %DEVICE% shell pm list packages com.niinko.phoneTest
%ADB% %DEVICE% shell rm -r %STORAGE%/UnrealGame/VineMobile
%ADB% %DEVICE% shell rm -r %STORAGE%/UnrealGame/UECommandLine.txt
%ADB% %DEVICE% shell rm -r %STORAGE%/obb/com.niinko.phoneTest
%ADB% %DEVICE% shell rm -r %STORAGE%/Android/obb/com.niinko.phoneTest
%ADB% %DEVICE% shell rm -r %STORAGE%/Download/obb/com.niinko.phoneTest
@echo.
@echo Installing new data. Failures here indicate storage problems (missing SD card or bad permissions) and are fatal.
	%AFS% %DEVICE% -p com.niinko.phoneTest -k CD0076474C4A163ABF3C888F9CA2779E push main.1.com.niinko.phoneTest.obb "^mainobb"
if "%ERRORLEVEL%" NEQ "0" goto Error










%AFS% %DEVICE% -p com.niinko.phoneTest -k CD0076474C4A163ABF3C888F9CA2779E stop-all

@echo.
@echo Grant READ_EXTERNAL_STORAGE and WRITE_EXTERNAL_STORAGE to the apk for reading OBB file or game file in external storage.
%ADB% %DEVICE% shell pm grant com.niinko.phoneTest android.permission.READ_EXTERNAL_STORAGE
%ADB% %DEVICE% shell pm grant com.niinko.phoneTest android.permission.WRITE_EXTERNAL_STORAGE

@echo.
@echo Installation successful
goto:eof
:Error
@echo.
@echo There was an error installing the game or the obb file. Look above for more info.
@echo.
@echo Things to try:
@echo Check that the device (and only the device) is listed with "%ADB$ devices" from a command prompt.
@echo Make sure all Developer options look normal on the device
@echo Check that the device has an SD card.
@pause
