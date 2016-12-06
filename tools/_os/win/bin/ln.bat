echo off

set src="%1"
set dst="%2"

set error=false
if not exist "%src%" set true_false=true
if not exist "%src%\" set true_false=true
if %true_false%==true (
    echo "No file exist %src%"
    exit /b 1
)

if exist "%src%\" ( 
    cmd /c mklink /D "%dst%" "%src%"
) else (
    cmd /c mklink "%dst%" "%src%"
)

