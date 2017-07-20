@ECHO off
SETLOCAL ENABLEDELAYEDEXPANSION
:: usage:
::          vs_x64_build.cmd <config> <target> 
::                  <config> - configuration to be used for build (default: Debug) 
::                  <target> - target to be built (default: ALL_BUILD)
if NOT "%1" == "" (SET CMAKE_BUILD_TYPE=%1) else (SET CMAKE_BUILD_TYPE=Debug)
if NOT "%2" == "" (SET CMAKE_TARGET=%2) else (SET CMAKE_TARGET=ALL_BUILD)
SET CMAKE_BINARY_DIR=build


IF NOT EXIST "%CMAKE_BINARY_DIR%\*.sln" (
    cmake -H"." -B"%CMAKE_BINARY_DIR%" -T"v140_xp" -G"Visual Studio 14 2015" -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" -DBUILD_SHARED_LIBS=ON
)
cmake --build "%CMAKE_BINARY_DIR%" --target "%CMAKE_TARGET%" --config "%CMAKE_BUILD_TYPE%"

ENDLOCAL