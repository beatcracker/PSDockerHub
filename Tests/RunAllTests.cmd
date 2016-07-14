@echo off
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -Command "[Console]::SetBufferSize(1000, 3000) ; Import-Module -Name PSScriptAnalyzer ; Import-Module -Name Pester ; Invoke-Pester -Path '%~dp0'"
pause