# GetDirectoryTreeSize
This is used to get the file count, subdirectory count and folder size for the path specified. The output will show the current folder stats unless you specify the "AllItemsAndAllFolders" property. Since this uses Get-ChildItem as the underlying structure, this supports local paths, network UNC paths and mapped drives.

<details>
 <summary>
EXAMPLES
</summary>
        Get-DirectoryTreeSize -Path C:\Temp\ -Attrib a,h,d -AllItemsAndAllFolders

|TotalFolderSize | TotalFileCount | Path     |   TotalDirectoryCount |
| :------------- | :------------- | :------- | :-------------------- |
|`258,68Mb`        | `30`             | `C:\Temp\` | `15`                    |

-----------------
 Get-DirectoryTreeSize -Path C:\Temp\ -Attrib a,h,s | select path,directorycount,filecount,foldersize
    
|Path   |  DirectoryCount | FileCount |FolderSize|
| :------------- | :------------- | :------- | :-------------------- |
|C:\Temp\        |      1        |30 |258,68Mb |

-----------------
Get-DirectoryTreeSize -Path C:\Temp\ -Attrib a,h,d -Recurse | select path,directorycount,filecount,foldersize
    
 |       Path     | DirectoryCount | FileCount | FolderSize        |
| :------------- | :------------- | :------- | :-------------------- |
| C:\Temp\                         |              14 |       30 | 258,68Mb |
| .\2020                           |               4 |        1 | 6,13Kb |
| .\DataportDCSNuGet               |               1 |        0 | Empty |
| .\GetProcess                     |               0 |        3 | 2,77Kb |
| .\Jahres-CD-2017                 |               2 |        4 | 10,21Kb |
| .\Jahres-CD-2018                 |               2 |        4 | 10,21Kb |
| .\Jahres-CD-2019                 |               2 |        4 | 10,21Kb |
| .\MeinModuleProjekt              |               6 |        4 | 6,58Kb |
| .\MikePoshScripts                |               3 |       10 | 609,82Kb |
| .\PolicyAnalyzer                 |               1 |       14 | 13,38Mb |
| .\PSFramework                    |               1 |        0 | Empty |
| .\PSModuleDevelopment            |               1 |        0 | Empty |
| .\string                         |               1 |        0 | Empty |
| .\Windows_10_VDI_Optimize-master |               6 |        5 | 41,61Kb |
| .\WinSCP_FTP                     |               1 |        0 | Empty |
| .\WinSCP_FTP.1.0.0               |               2 |        0 | Empty |
| .\2020\oaads_images              |               0 |        7 | 444,58Kb |
</details>
