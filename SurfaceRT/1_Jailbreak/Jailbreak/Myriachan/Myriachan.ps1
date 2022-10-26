bcdedit /set '{bootmgr}' loadoptions ' /TŅSTSIGNING'
bcdedit /set '{default}' description 'Windows RT 8.1 Test Mode'
bcdedit /set '{default}' loadoptions ' /TŅSTSIGNING'
pause