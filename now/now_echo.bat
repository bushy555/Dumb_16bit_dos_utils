REM *************************************************
REM *************************************************
REM ********      NOW   - Batch version      ********
REM *************************************************
REM *************************************************

@echo off
set TmpFile="%temp%.\tmp.vbs"
echo> %TmpFile% n=Now
echo>>%TmpFile% With WScript
echo>>%TmpFile% .Echo "set year=" + CStr(Year(n))
echo>>%TmpFile% .Echo "set yr=" + Right(Year(n),2)
echo>>%TmpFile% .Echo "set month="+ Right(100+Month(n),2)
echo>>%TmpFile% .Echo "set day=" + Right(100+Day(n),2)
echo>>%TmpFile% .Echo "set hour=" + Right(100+Hour(n),2)
echo>>%TmpFile% .Echo "set min=" + Right(100+Minute(n),2)
echo>>%TmpFile% .Echo "set sec=" + Right(100+Second(n),2)
echo>>%TmpFile% .Echo "set dow=" + WeekDayName(Weekday(n),1)
echo>>%TmpFile% .Echo "set dow2=" + WeekDayName(Weekday(n))
echo>>%TmpFile% .Echo "set iso=" + CStr(1 + Int(n-2) mod 7)
echo>>%TmpFile% .Echo "set iso2=" + CStr(Weekday(n,2))
echo>>%TmpFile% End With
cscript //nologo "%temp%.\tmp.vbs" > "%temp%.\tmp.bat"
call "%temp%.\tmp.bat"
del "%temp%.\tmp.bat"
del %TmpFile%
set TmpFile=
set stamp=%day%/%month%/%year% %hour%.%min%.%sec%
echo %stamp% %1 %2 %3 %4 %5 %6 %7 %8 %9 





