# GetDirectoryTreeSize
This is used to get the file count, subdirectory count and folder size for the path specified. The output will show the current folder stats unless you specify the "AllItemsAndAllFolders" property. Since this uses Get-ChildItem as the underlying structure, this supports local paths, network UNC paths and mapped drives. Furthermore it was developed to work also in PowerShell constrained language mode.

PARAMETER <b>Recurse</b><br />
'Using this parameter will drill down to the end of the folder structure and output the filecount, foldercount and size of each folder respectively.'
     
PARAMETER <b>AllItemsAndAllFolders</b><br />
'Using this parameter will get the total file count, total directory count and total folder size in MB for everything under that directory recursively.'
     
PARAMETER <b>Attrib</b><br />
'–Attrib <FileAttributes>: This parameter gets files and folders with specified attributes. When you use this parameter, you can specify a complex combination of attributes.'<br />
<br />
You cannot use space between an operator and its attributes, but space is permitted before commas. The Attribute parameter supports the following attributes.

Archive	| Offline | Compressed| ReadOnly | Device | ReparsePoint | Directory | SparseFile | Encrypted | System | Hidden	| Temporary | Normal | NotContentIndexed

<br />
Following Operators can be used to combine attributes:
<br />

\! = NOT <br />
\+ = AND <br />
\, = OR <br />

Following abbreviations are used for attributes:
<br />
D: Directory <br />
A: Archive <br />
H: Hidden <br />
R: Read-Only <br />
S: System <br />
<br />
<details>
 <summary>
EXAMPLES
</summary>
        Get-DirectoryTreeSize -Path c:\temp -Attrib A,D,H,Normal -AllItemsAndAllFolders -Scale Mb

|TotalFolderSize | TotalFileCount | Path     |   TotalDirectoryCount |
| :------------- | :------------- | :------- | :-------------------- |
|`258,68Mb`        | `1025`             | `C:\Temp\` | `523`                    |

-----------------
 Get-DirectoryTreeSize -Path C:\Temp\ -Attrib a,h,s -Scale Mb | select path,directorycount,filecount,foldersize
    
|Path   |  DirectoryCount | FileCount |FolderSize|
| :------------- | :------------- | :------- | :-------------------- |
|`C:\Temp\`        |      `1`        |`30` |`258,68Mb` |

-----------------
Get-DirectoryTreeSize -Path C:\Temp\ -Attrib a,h,d -Recurse -Scal Kb | select path,directorycount,filecount,foldersize
    
|       Path                         | DirectoryCount | FileCount | FolderSize   |
| :--------------------------------- | :------------- | :-------- | :----------- |
|`C:\logs\`                          |  `5`               `81`  |  `622,76 Kb`
| `.\MSI`                            |  `1`               `41`  |  `34.084,91 Kb`
| `.\MSU`                            |  `0`               `0`   |  `Empty`
| `.\PatchMgmt`                      |  `0`               `1`   |  `16,25 Kb`
| `.\PKGDB`                          |  `0`               `0`   |  `Empty`
| `.\Trace`                          |  `0`               `33`  |  `552,52 Kb`
| `.\MSI\Enterprise-Erstinstallation_10.7.0-3299.1.log` | `0` |`22` |      `5.273,51 Kb`

</details>
