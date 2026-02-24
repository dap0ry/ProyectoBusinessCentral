@echo off
setlocal EnableDelayedExpansion
title Business Central Docker - Comprobador de Requisitos

:: Enable ANSI colors trick for Windows 10
for /F "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "ESC=%%E"
set "Green=%ESC%[92m"
set "Red=%ESC%[91m"
set "Yellow=%ESC%[93m"
set "White=%ESC%[97m"
set "Reset=%ESC%[0m"

echo %White%=======================================================
echo     COMPROBADOR DE REQUISITOS - BUSINESS CENTRAL
echo =======================================================
echo.
echo Comprobando especificaciones del sistema...
echo.

set "PASSED=0"
set "FAILED=0"

:: 1. Comprobar Edicion de Windows
echo [1/3] Comprobando Edicion de Windows...
for /f "tokens=4-5 delims=[.] " %%i in ('ver') do set VERSION=%%i.%%j
for /f "tokens=2 delims==" %%A in ('wmic os get Caption /value ^| find "="') do set "OS_NAME=%%A"

echo Sistema detectado: %OS_NAME%
echo "%OS_NAME%" | findstr /I /C:"Pro" >nul
if not errorlevel 1 (
    echo %Green%[OK]%Reset% %White%Edicion Profesional detectada. Compatible con Docker de Windows.
    set /a PASSED+=1
) else (
    echo "%OS_NAME%" | findstr /I /C:"Enterprise" >nul
    if not errorlevel 1 (
         echo %Green%[OK]%Reset% %White%Edicion Enterprise detectada. Compatible con Docker de Windows.
         set /a PASSED+=1
    ) else (
         echo %Red%[ERROR]%Reset% %White%Se requiere Windows 10/11 Pro o Enterprise.
         echo Tu edicion actual no soporta nativamente contenedores de Windows.
         set /a FAILED+=1
    )
)
echo.

:: 2. Comprobar RAM (> 8GB)
echo [2/3] Comprobando Memoria RAM...
:: Use Powershell to do accurate math without 32bit CMD limitations
for /f %%A in ('powershell -command "[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)"') do set RAM_GB=%%A

if %RAM_GB% GEQ 8 (
    echo %Green%[OK]%Reset% %White%RAM detectada: %RAM_GB% GB.
    if %RAM_GB% LSS 16 (
        echo %Yellow%[INFO]%Reset% %White%Tienes la RAM basica requerida, pero se recomiendan 16GB.
    )
    set /a PASSED+=1
) else (
    echo %Red%[ERROR]%Reset% %White%RAM detectada: %RAM_GB% GB. Se requieren al menos 8GB.
    set /a FAILED+=1
)
echo.

:: 3. Comprobar Hyper-V / Virtualizacion
echo [3/3] Comprobando soporte de Virtualizacion...
systeminfo | findstr /C:"Virtualization Enabled In Firmware" /C:"Virtualization Enabled" > temp_virt.txt
set /p VIRT_STATUS=<temp_virt.txt
del temp_virt.txt
if not "!VIRT_STATUS!"=="" (
    echo "!VIRT_STATUS!" | findstr /I /C:"Yes" >nul
    if not errorlevel 1 (
        echo %Green%[OK]%Reset% %White%La virtualizacion esta habilitada en la BIOS.
        set /a PASSED+=1
    ) else (
        echo "!VIRT_STATUS!" | findstr /I /C:"Si" >nul
        if not errorlevel 1 (
            echo %Green%[OK]%Reset% %White%La virtualizacion esta habilitada.
            set /a PASSED+=1
        ) else (
            echo %Red%[ERROR]%Reset% %White%La virtualizacion NO esta habilitada. Debes habilitarla en la BIOS.
            set /a FAILED+=1
        )
    )
) else (
    :: Hyper-V might already be loaded making the generic virtualization line disappear
    systeminfo | findstr /C:"A hypervisor has been detected" /C:"Se ha detectado un hipervisor" >nul
    if not errorlevel 1 (
        echo %Green%[OK]%Reset% %White%Hipervisor detectado ^(Hyper-V esta activo^).
        set /a PASSED+=1
    ) else (
        echo %Yellow%[AVISO]%Reset% %White%No se pudo determinar el estado de la virtualizacion de forma segura.
        echo Asegurate de tenerla activada en la BIOS.
        set /a PASSED+=1
    )
)
echo.

:: Resultado
echo =======================================================
if %FAILED% EQU 0 (
    echo.
    echo %Green%[*** EL SISTEMA ES APTO PARA DOCKER CON BUSINESS CENTRAL ***]%Reset%
    echo.
) else (
    echo.
    echo %Red%[!!! EL SISTEMA NO CUMPLE LOS REQUISITOS !!!]%Reset%
    echo %White%Por favor, revisa los errores indicados en %Red%rojo%White%.
    echo.
)
echo =======================================================
echo.
pause
