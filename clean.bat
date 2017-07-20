rd /q /s build

REM forfiles /P %cd% /M OpenSSL-* /C "cmd /c if @isdir==TRUE rmdir /s /q @file"