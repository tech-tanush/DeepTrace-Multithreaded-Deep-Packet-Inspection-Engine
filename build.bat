@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo               DeepTrace Build Script (Windows)
echo ============================================================

REM Prioritize modern 64-bit GCC (MSYS2 UCRT64 / MINGW64 / w64devkit) over legacy C:\MinGW
if exist "C:\msys64\ucrt64\bin\g++.exe" set "PATH=C:\msys64\ucrt64\bin;%PATH%"
if exist "C:\msys64\mingw64\bin\g++.exe" set "PATH=C:\msys64\mingw64\bin;%PATH%"
if exist "C:\w64devkit\bin\g++.exe" set "PATH=C:\w64devkit\bin;%PATH%"

set "BIN_DIR=%~dp0bin"
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"

REM 1. Check for MSVC (cl.exe)
where cl >nul 2>&1
if %ERRORLEVEL% equ 0 goto use_msvc

REM 2. Check for modern GCC
where g++ >nul 2>&1
if %ERRORLEVEL% neq 0 goto no_compiler

set "GXX_PATH="
for /f "tokens=*" %%i in ('where g++') do (
    if not defined GXX_PATH set "GXX_PATH=%%i"
)

echo [Compiler] Using GCC: %GXX_PATH%

echo [Build] Compiling deeptrace-mt.exe (Multi-threaded Engine)...
g++ -std=c++17 -O2 -static -I include src/dpi_mt.cpp src/pcap_reader.cpp src/packet_parser.cpp src/sni_extractor.cpp src/types.cpp -o "%BIN_DIR%\deeptrace-mt.exe"
if errorlevel 1 goto build_err

echo [Build] Compiling deeptrace-simple.exe (Single-threaded Engine)...
g++ -std=c++17 -O2 -static -I include src/main_simple.cpp src/pcap_reader.cpp src/packet_parser.cpp src/sni_extractor.cpp src/types.cpp -o "%BIN_DIR%\deeptrace-simple.exe"
if errorlevel 1 goto build_err

echo [Build] Compiling packet-analyzer.exe (Packet Inspector)...
g++ -std=c++17 -O2 -static -I include src/main.cpp src/pcap_reader.cpp src/packet_parser.cpp src/types.cpp -o "%BIN_DIR%\packet-analyzer.exe"
if errorlevel 1 goto build_err

goto build_success

:use_msvc
echo [Compiler] Detected MSVC cl.exe
echo [Build] Compiling deeptrace-mt.exe...
cl /nologo /EHsc /std:c++17 /O2 /I include /Fe:"%BIN_DIR%\deeptrace-mt.exe" ^
    src\dpi_mt.cpp src\pcap_reader.cpp src\packet_parser.cpp src\sni_extractor.cpp src\types.cpp
if errorlevel 1 goto build_err

echo [Build] Compiling deeptrace-simple.exe...
cl /nologo /EHsc /std:c++17 /O2 /I include /Fe:"%BIN_DIR%\deeptrace-simple.exe" ^
    src\main_simple.cpp src\pcap_reader.cpp src\packet_parser.cpp src\sni_extractor.cpp src\types.cpp
if errorlevel 1 goto build_err

echo [Build] Compiling packet-analyzer.exe...
cl /nologo /EHsc /std:c++17 /O2 /I include /Fe:"%BIN_DIR%\packet-analyzer.exe" ^
    src\main.cpp src\pcap_reader.cpp src\packet_parser.cpp src\types.cpp
if errorlevel 1 goto build_err

goto build_success

:build_success
echo.
echo ============================================================
echo [Success] All executables successfully built in .\bin\
echo ============================================================
echo You can now run:
echo   .\bin\deeptrace-mt.exe test_dpi.pcap output.pcap --block-app YouTube
exit /b 0

:no_compiler
echo.
echo ============================================================
echo               C++17 Compiler Required
echo ============================================================
echo DeepTrace requires a 64-bit compiler with C++17 support.
echo.
echo Please install MSYS2 UCRT64:
echo   1. Download and install from https://www.msys2.org/
echo   2. Run in MSYS2 terminal: pacman -S mingw-w64-ucrt-x86_64-gcc
echo   3. Re-run .\build.bat
exit /b 1

:build_err
echo.
echo [Error] Compilation failed.
exit /b 1
