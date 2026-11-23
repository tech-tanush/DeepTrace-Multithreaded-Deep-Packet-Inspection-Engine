@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo               DeepTrace Build Script (Windows)
echo ============================================================

set "BIN_DIR=%~dp0bin"
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"

REM 1. Check for MSVC (cl.exe)
where cl >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [Compiler] Detected MSVC cl.exe
    echo [Build] Building deeptrace-mt.exe...
    cl /nologo /EHsc /std:c++17 /O2 /I include /Fe:"%BIN_DIR%\deeptrace-mt.exe" ^
        src\dpi_mt.cpp src\pcap_reader.cpp src\packet_parser.cpp src\sni_extractor.cpp src\types.cpp
    if errorlevel 1 goto build_err

    echo [Build] Building deeptrace-simple.exe...
    cl /nologo /EHsc /std:c++17 /O2 /I include /Fe:"%BIN_DIR%\deeptrace-simple.exe" ^
        src\main_simple.cpp src\pcap_reader.cpp src\packet_parser.cpp src\sni_extractor.cpp src\types.cpp
    if errorlevel 1 goto build_err

    echo [Build] Building packet-analyzer.exe...
    cl /nologo /EHsc /std:c++17 /O2 /I include /Fe:"%BIN_DIR%\packet-analyzer.exe" ^
        src\main.cpp src\pcap_reader.cpp src\packet_parser.cpp src\types.cpp
    if errorlevel 1 goto build_err

    echo [Success] Executables successfully built in .\bin\
    exit /b 0
)

REM 2. Check for working GCC (test --version to avoid broken 32-bit runtimes)
set "GXX="

REM Check PATH
g++ --version >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set "GXX=g++"
) else if exist "C:\msys64\ucrt64\bin\g++.exe" (
    "C:\msys64\ucrt64\bin\g++.exe" --version >nul 2>&1
    if !ERRORLEVEL! equ 0 set "GXX=C:\msys64\ucrt64\bin\g++.exe"
) else if exist "C:\msys64\mingw64\bin\g++.exe" (
    "C:\msys64\mingw64\bin\g++.exe" --version >nul 2>&1
    if !ERRORLEVEL! equ 0 set "GXX=C:\msys64\mingw64\bin\g++.exe"
)

if defined GXX (
    echo [Compiler] Detected functional GCC: %GXX%
    echo [Build] Building deeptrace-mt.exe...
    "%GXX%" -std=c++17 -O2 -I include src/dpi_mt.cpp src/pcap_reader.cpp src/packet_parser.cpp src/sni_extractor.cpp src/types.cpp -o "%BIN_DIR%\deeptrace-mt.exe"
    if errorlevel 1 goto build_err

    echo [Build] Building deeptrace-simple.exe...
    "%GXX%" -std=c++17 -O2 -I include src/main_simple.cpp src/pcap_reader.cpp src/packet_parser.cpp src/sni_extractor.cpp src/types.cpp -o "%BIN_DIR%\deeptrace-simple.exe"
    if errorlevel 1 goto build_err

    echo [Build] Building packet-analyzer.exe...
    "%GXX%" -std=c++17 -O2 -I include src/main.cpp src/pcap_reader.cpp src/packet_parser.cpp src/types.cpp -o "%BIN_DIR%\packet-analyzer.exe"
    if errorlevel 1 goto build_err

    echo [Success] Executables successfully built in .\bin\
    exit /b 0
)

REM 3. Check for CMake
where cmake >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [Build] Detected CMake. Configuring build directory...
    cmake -B build
    if errorlevel 1 goto build_err
    cmake --build build --config Release
    if errorlevel 1 goto build_err
    exit /b 0
)

echo.
echo [!] No working C++17 compiler found on your system.
echo     (Note: Found 'C:\MinGW\bin\g++.exe' but it failed system runtime check)
echo.
echo To build DeepTrace on Windows, please install one of the following:
echo.
echo   Option 1 (Recommended - MSYS2 UCRT64):
echo     1. Download installer from: https://www.msys2.org/
echo     2. In MSYS2 terminal, run:
echo          pacman -S mingw-w64-ucrt-x86_64-gcc
echo     3. Add 'C:\msys64\ucrt64\bin' to your Windows PATH
echo.
echo   Option 2 (Visual Studio 2022 Community):
echo     1. Install 'Desktop development with C++' workload
echo     2. Run build.bat from 'Developer Command Prompt for VS 2022'
echo.
exit /b 1

:build_err
echo.
echo [Error] Compilation failed. Please check the compiler output above.
exit /b 1
