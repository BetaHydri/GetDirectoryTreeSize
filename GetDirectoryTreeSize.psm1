Function Get-DirectoryTreeSize {
    <#
    .SYNOPSIS
        This is used to get the file count, subdirectory count and folder size for the path specified. The output will show the current folder stats unless you specify the "AllItemsAndAllFolders" property.
        Since this uses Get-ChildItem as the underlying structure, this supports local paths, network UNC paths and mapped drives.
          
    .PARAMETER Recurse
        Using this parameter will drill down to the end of the folder structure and output the filecount, foldercount and size of each folder respectively.
     
    .PARAMETER AllItemsAndAllFolders
        Using this parameter will get the total file count, total directory count and total folder size in MB for everything under that directory recursively.
     
    .PARAMETER Attrib
        Using this addtitional array parameter, will give you the option to include/filter for e.g. (H)IDDEN, (S)YSTEM, (D)IRECTORY, (A)RCHIVE, (R)EADONLY files and directories 
    
    .EXAMPLE
        Get-DirectoryTreeSize -Path C:\Temp\ -Attrib a,h,d -AllItemsAndAllFolders

        TotalFolderSize TotalFileCount Path     TotalDirectoryCount
        --------------- -------------- ----     -------------------
        258,68Mb                    30 C:\Temp\                  15

    .EXAMPLE
        Get-DirectoryTreeSize -Path C:\Temp\ -Attrib a,h,s | select path,directorycount,filecount,foldersize
    
        Path     DirectoryCount FileCount FolderSize
        ----     -------------- --------- ----------
        C:\Temp\              1        30 258,68Mb

    .EXAMPLE
        Get-DirectoryTreeSize -Path C:\Temp\ -Attrib a,h,d -Recurse | select path,directorycount,filecount,foldersize
    
        Path                               DirectoryCount FileCount FolderSize
        ----                               -------------- --------- ----------
        C:\Temp\                                       14        30 258,68Mb
        .\2020                                          4         1 6,13Kb
        .\DataportDCSNuGet                              1         0 Empty
        .\GetProcess                                    0         3 2,77Kb
        .\Jahres-CD-2017                                2         4 10,21Kb
        .\Jahres-CD-2018                                2         4 10,21Kb
        .\Jahres-CD-2019                                2         4 10,21Kb
        .\MeinModuleProjekt                             6         4 6,58Kb
        .\MikePoshScripts                               3        10 609,82Kb
        .\PolicyAnalyzer                                1        14 13,38Mb
        .\PSFramework                                   1         0 Empty
        .\PSModuleDevelopment                           1         0 Empty
        .\string                                        1         0 Empty
        .\Windows_10_VDI_Optimize-master                6         5 41,61Kb
        .\WinSCP_FTP                                    1         0 Empty
        .\WinSCP_FTP.1.0.0                              2         0 Empty
        .\2020\oaads_images                             0         7 444,58Kb

#>
     
    [CmdletBinding(DefaultParameterSetName="Default")]
     
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [string]  $Path,
     
     
     
        [Parameter(
            Mandatory = $false,
            ParameterSetName = "ShowRecursive"
        )]
        [switch]  $Recurse,
     
        [Parameter(
            Mandatory = $false
        )]
        [array]  $Attrib,     
     
        [Parameter(
            Mandatory = $false,
            ParameterSetName = "ShowTopFolderAllItemsAndAllFolders"
        )]
        [switch]  $AllItemsAndAllFolders
    )
     
        BEGIN {
            #Adding a trailing slash at the end of $path to make it consistent.
            if (-not $Path.EndsWith('\')) {
                $Path = "$Path\"
            }
            $results = @()
          }
     
        PROCESS {
            try {
                if ((-not $AllItemsAndAllFolders) -and (-not $Recurse)) {
                    if ($Attrib) {
                        $FileStats = (Get-ChildItem -Path $Path -File -Attributes $Attrib -ErrorAction Stop | Measure-Object -Property Length -Sum)
                        $FileCount = $FileStats.Count
                        $DirectoryCount = Get-ChildItem -Path $Path -Directory -Attributes $Attrib | Measure-Object | Select-Object -ExpandProperty Count
                    }
                    else {
                        $FileStats = (Get-ChildItem -Path $Path -File -ErrorAction Stop | Measure-Object -Property Length -Sum)
                        $FileCount = $FileStats.Count
                        $DirectoryCount = Get-ChildItem -Path $Path -Directory | Measure-Object | Select-Object -ExpandProperty Count
                    }
                    if(($FileStats).sum -ge 1000000) {
                        $Size =  "{0}" -f ((($FileStats).sum)/1Mb).ToString('N') + 'Mb'
                    }
                    elseif ($FileCount -eq 0) {
                        $Size =  'Empty'
                    }
                    else {
                        $Size =  "{0}" -f ((($FileStats).sum)/1kb).ToString('N') + 'Kb'
                    }
     
                    $DirHashTable = [Ordered]@{
                        Path                 = $Path
                        FileCount            = $FileCount
                        DirectoryCount       = $DirectoryCount
                        FolderSize           = $Size
                    }
                    ConvertTo-PsObject $DirHashTable
                    #$results += $DirHashTable
                }
     
                if  ($AllItemsAndAllFolders) {
                    if ($Attrib) {
                        $FileStats = (Get-ChildItem -Path $Path -File -Attributes $Attrib -ErrorAction Stop | Measure-Object -Property Length -Sum)
                        $FileCount = $FileStats.Count
                        $DirectoryCount = Get-ChildItem -Path $Path -Directory -Attributes $Attrib | Measure-Object | Select-Object -ExpandProperty Count
                    }
                    else {
                        $FileStats = (Get-ChildItem -Path $Path -File -ErrorAction Stop | Measure-Object -Property Length -Sum)
                        $FileCount = $FileStats.Count
                        $DirectoryCount = Get-ChildItem -Path $Path -Directory | Measure-Object | Select-Object -ExpandProperty Count
                    }
                    if(($FileStats).sum -ge 1000000) {
                        $Size =  "{0}" -f ((($FileStats).sum)/1Mb).ToString('N') + 'Mb'
                    }
                    elseif ($FileCount -eq 0) {
                        $Size =  'Empty'
                    }
                    else {
                        $Size =  "{0}" -f ((($FileStats).sum)/1kb).ToString('N') + 'Kb'
                    }
     
                    $DirHashTable = [Ordered]@{
                        Path                 = $Path
                        TotalFileCount       = $FileCount
                        TotalDirectoryCount  = $DirectoryCount
                        TotalFolderSize      = $Size
                    }
                    ConvertTo-PsObject $DirHashTable
                    #$results += $DirHashTable
                }  
                if ($Recurse) {
                    If ($Attrib) {
                        Get-DirectoryTreeSize -Path $Path -Attrib $Attrib
                        $FolderList = Get-ChildItem -Path $Path -Directory -Attributes $Attrib -Recurse | Select-Object -ExpandProperty FullName
                    }
                    else {
                        Get-DirectoryTreeSize -Path $Path
                        $FolderList = Get-ChildItem -Path $Path -Directory -Recurse | Select-Object -ExpandProperty FullName
                    }
                    if ($FolderList) {
                        foreach ($Folder in $FolderList) {
                            if ($Attrib) {
                                $FileStats = (Get-ChildItem -Path $Folder -File -Attributes $Attrib | Measure-Object -Property Length -Sum)
                                $FileCount = $FileStats.Count
                                $DirectoryCount = Get-ChildItem -Path $Folder -Directory -Attributes $Attrib | Measure-Object | Select-Object -ExpandProperty Count
                            }
                            else {
                                $FileStats = (Get-ChildItem -Path $Folder -File | Measure-Object -Property Length -Sum)
                                $FileCount = $FileStats.Count
                                $DirectoryCount = Get-ChildItem -Path $Folder -Directory | Measure-Object | Select-Object -ExpandProperty Count
                            }
                            if(($FileStats).sum -ge 1000000) {
                                $Size =  "{0}" -f ((($FileStats).sum)/1Mb).ToString('N') + 'Mb'
                            }
                            elseif ($FileCount -eq 0) {
                                $Size =  'Empty'
                            }
                            else {
                                $Size =  "{0}" -f ((($FileStats).sum)/1kb).ToString('N') + 'Kb'
                            }
                            
                            $DirHashTable = [Ordered]@{
                                Path                 = $Folder.Replace($Path,".\")
                                FileCount            = $FileCount
                                DirectoryCount       = $DirectoryCount
                                FolderSize           = $Size
                            }
                            ConvertTo-PsObject $DirHashTable
                            #$results += $DirHashTable
                        }
                    }
                }
            } 
            catch {
                Write-Error $_.Exception.Message
                #Write-Error $_.CategoryInfo
                #Write-Error $_.FullyQualifiedErrorId
            }
     
        }
     
        END {

            #$results
            # Clear Variables
            $null = $FileStats
            $null = $FileCount
            $null = $DirectoryCount
            $null = $Size
            $null = $DirHashTable
            $null = $results
        }
    }

    function ConvertTo-PsObject {
        param (
            [hashtable]$Value = [Ordered]@{}
        )
    
        foreach ( $key in $Value.Keys | Where-Object { $Value[$_].GetType() -eq @{}.GetType() } ) {
            $Value[$key] = ConvertTo-PsObject [Ordered]$Value[$key]
        }
    
        New-Object PSObject -Property $Value | Write-Output
    }