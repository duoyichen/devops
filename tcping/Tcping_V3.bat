
@echo off
rem Author:   DuoyiChen
rem Email:    duoyichen@qq.com
rem Date:     20180521 20:50
rem Version:  3


color 02


echo;
echo 请执行任务之前暂时退出杀毒软件，或者选择放行本脚本！
echo;
echo 任务执行时间可能较长，请等待程序提示 “任务完成” 后再退出！
echo;
echo 请按任意键继续！
pause>nul


set datetime=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%

echo;
echo;
if exist "ip.txt" (
    echo tcping.exe exist! We will rename it as ip.txt.%datetime%
    echo;
    ren "ip.txt" ""ip.txt.%datetime%"
)
bitsadmin.exe /transfer "Download for IP List!" http://o.cloudmind.cn/o/tcping/ip.txt %cd%\ip.txt

echo;
echo;
if exist "tcping.exe" (
    echo tcping.exe exist!
) else (
    bitsadmin.exe /transfer "Download for Tcping!" http://o.cloudmind.cn/o/tcping/tcping.exe %cd%\tcping.exe
)


echo;
echo;
if exist "tcping.txt" (
    echo;
    echo tcping.txt exist! We will rename it as tcping.txt.%datetime%
    echo;
    ren "tcping.txt" ""tcping.txt.%datetime%"
)
echo;>> %cd%\tcping.txt
echo Get Info at [%datetime%] >> %cd%\tcping.txt
echo;>> %cd%\tcping.txt
echo;>> %cd%\tcping.txt


echo;
echo 任务开始，请耐心等待任务完成......
echo;


for /f %%i in (ip.txt) do (
echo;>> %cd%\tcping.txt
echo ------------------ %%i ---------------- >> %cd%\tcping.txt
tcping.exe -n 1000 %%i>> %cd%\tcping.txt
echo;>> %cd%\tcping.txt
echo;>> %cd%\tcping.txt
)


echo;
echo 任务完成，测试结果已经保存到 tcping.txt 文件中，请按任意键退出！
pause>nul
