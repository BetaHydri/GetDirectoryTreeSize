Import-Module .\GetDirectoryTreeSize.psm1 -Force
Get-DirectoryTreeSize -Path C:\windows\system32\drivers -Recurse -Scale Mb