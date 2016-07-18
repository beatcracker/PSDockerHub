@echo off
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -Command "[Console]::SetBufferSize(1000, 3000) ;  Import-Module -Name PSScriptAnalyzer, Pester, BuildHelpers ; Invoke-Pester -Path '%~dp0'"
pause