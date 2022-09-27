# GetDirectoryTreeSize
This is used to get the file count, subdirectory count and folder size for the path specified. The output will show the current folder stats unless you specify the "AllItemsAndAllFolders" property. Since this uses Get-ChildItem as the underlying structure, this supports local paths, network UNC paths and mapped drives.

PARAMETER `#00ff00`<b>Recurse</b>
'Using this parameter will drill down to the end of the folder structure and output the filecount, foldercount and size of each folder respectively.'
     
PARAMETER `#00ff00`<b>AllItemsAndAllFolders</b>
'Using this parameter will get the total file count, total directory count and total folder size in MB for everything under that directory recursively.'
     
.ARAMETER `#00ff00`<b>Attrib</b>
'Using this addtitional array parameter, will give you the option to include/filter for e.g. (H)IDDEN, (S)YSTEM, (D)IRECTORY, (A)RCHIVE, (R)EADONLY files and directories'

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
|`C:\Temp\`        |      `1`        |`30` |`258,68Mb` |

-----------------
Get-DirectoryTreeSize -Path C:\Temp\ -Attrib a,h,d -Recurse | select path,directorycount,filecount,foldersize
    
|       Path                         | DirectoryCount | FileCount | FolderSize   |
| :--------------------------------- | :------------- | :-------- | :----------- |
| `C:\Temp\`                         | `14`           | `30`      | `258,68Mb`   |
| `.\2020              `             | `4`            | `1`       | `6,13Kb`     |
| `.\GetProcess        `             | `0`            | `3`       | `2,77Kb`     |
| `.\Jahres-CD-2017    `             | `2`            | `4`       | `10,21Kb`    |
| `.\Jahres-CD-2018    `             | `2`            | `4`       | `10,21Kb`    |
| `.\Jahres-CD-2019    `             | `2`            | `4`       | `10,21Kb`    |
| `.\MeinModuleProjekt `             | `6`            | `4`       | `6,58Kb`     |
| `.\PoshScripts       `             | `3`            |`10`       | `609,82Kb`   |
| `.\PolicyAnalyzer    `             | `1`            |`14`       | `13,38Mb`    |
| `.\PSFramework       `             | `1`            | `0`       | `Empty`      |
| `.\PSModuleDevelopment `           | `1`            | `0`       | `Empty`      |
| `.\string            `             | `1`            | `0`       | `Empty`      |
| `.\Windows_10_VDI_Optimize-master` | `6`            | `5`       | `41,61Kb`    |
| `.\WinSCP_FTP                    ` | `1`            | `0`       | `Empty`      |
| `.\WinSCP_FTP.1.0.0              ` | `2`            | `0`       | `Empty`      |
| `.\2020\oaads_images             ` | `0`            | `7`       | `444,58Kb`   |

-----------------------
Get-DirectoryTreeSize -Path C:\logs\  -Recurse | select path,directorycount,filecount,foldersize

|Path         | DirectoryCount | FileCount | FolderSize |
|:----        | :------------- | :---------|:---------- |
|`C:\logs\`   | `5`            | ` 4`      | `106,95Kb` |
|`.\msi`      | `0`            | `14`      | `30,26Mb`  |
|`.\MSU`      | `0`            | ` 0`      | `Empty`    |
|`.\PatchMgmt`| `0`            | ` 1`      | `77,70Kb`  |
|`.\PKGDB `   | `0`            | ` 3`      | `3,16Mb`   |
|`.\Trace`    | `0`            | ` 3`      | `148,17Kb` |


</details>
