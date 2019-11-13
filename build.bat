SET SED=C:\msys64\usr\bin\sed.exe

PUSHD .
FOR %%I IN (C:\WinDDK\7600.16385.1) DO CALL %%I\bin\setenv.bat %%I fre %Platform% WIN7 no_oacr
POPD

IF %_BUILDARCH%==x86 SET Lib=%Lib%\Crt\i386;%DDK_LIB_DEST%\i386;%Lib%
IF %_BUILDARCH%==AMD64 SET Lib=%Lib%\Crt\amd64;%DDK_LIB_DEST%\amd64;%Lib%

SET Include=%Include%;%CRT_INC_PATH%

FOR %%I IN (
clang-cl.exe
lld-link.exe
) DO ^
FOR /F "TOKENS=2 DELIMS=-" %%J IN ('ECHO %%I') DO ^
FOR /F "DELIMS=" %%K IN ('WHERE %%I') DO ^
SET Path=%%~dpK;%Path%& MKLINK /H "%%~dpK%%J" "%%K"

IF %Platform%==x64 (SET M64=-m64) ELSE SET M64=-m32

FOR %%I IN (
"libcmt.lib		msvcrt.lib"
"/MT			 "
) DO FOR /F "TOKENS=1,* DELIMS=	" %%J IN (%%I) DO %SED% "s@%%J@%%K@" -i MAKEFILE

%SED% "s@/GL@-flto %M64%@" -i win32.mak

%SED% "s@CBR_9600@CBR_115200@" -i INIT.C

nmake.exe
