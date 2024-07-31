Write-Output "Hello World on C"
Copy-Item .\tests\test_helloworld.c .
python compile.py --name=hello_world.exe --use-profile=Release
Remove-Item test_helloworld.c
.\hello_world.exe

Write-Output "=============================="

Write-Output "Hello World on C++"
Copy-Item .\tests\test_helloworld.cpp .
python compile.py --name=hello_world2.exe --use-profile=Release
Remove-Item test_helloworld.cpp
.\hello_world2.exe

Write-Output "=============================="

Write-Output "Basic GoogleTest"
Copy-Item .\tests\test_googletest.cpp .
python compile.py --name=google.exe --use-profile=Release --include-libraries=GoogleTest --link-libraries=gtest.lib
Remove-Item test_googletest.cpp
.\google.exe
