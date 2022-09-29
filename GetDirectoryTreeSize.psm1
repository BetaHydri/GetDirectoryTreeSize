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
                        $FileStats = (Get-ChildItem -Path $Path -File -Recurse -Attributes $Attrib -ErrorAction Stop | Measure-Object -Property Length -Sum)
                        $FileCount = $FileStats.Count
                        $DirectoryCount = Get-ChildItem -Path $Path -Directory -Recurse -Attributes $Attrib | Measure-Object | Select-Object -ExpandProperty Count
                    }
                    else {
                        $FileStats = (Get-ChildItem -Path $Path -File -Recurse -ErrorAction Stop | Measure-Object -Property Length -Sum)
                        $FileCount = $FileStats.Count
                        $DirectoryCount = Get-ChildItem -Path $Path -Directory -Recurse | Measure-Object | Select-Object -ExpandProperty Count
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
# SIG # Begin signature block
# MIIx/wYJKoZIhvcNAQcCoIIx8DCCMewCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBmieizcU8LFcrp
# Hg6rb6LJpd5mLH2vlKlnF0ZlEcbNvqCCLCowggWNMIIEdaADAgECAhAOmxiO+dAt
# 5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBa
# Fw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3E
# MB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKy
# unWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsF
# xl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU1
# 5zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJB
# MtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObUR
# WBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6
# nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxB
# YKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5S
# UUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+x
# q4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIB
# NjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwP
# TzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMC
# AYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
# LmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0Nc
# Vec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnov
# Lbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65Zy
# oUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFW
# juyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPF
# mCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9z
# twGpn1eqXijiuZQwggZMMIIENKADAgECAhMUAACY7VKIGShWnr8bAAIAAJjtMA0G
# CSqGSIb3DQEBCwUAMD4xCzAJBgNVBAYTAkRFMRYwFAYDVQQKDA1EYXRhcG9ydCBB
# w7ZSMRcwFQYDVQQDDA5EYXRhcG9ydCBDQSAwMzAeFw0yMTA5MTQwNzEzMTFaFw0y
# NDA5MTMwNzEzMTFaMFMxCzAJBgNVBAYTAkRFMRIwEAYDVQQIDAlBbHRlbmhvbHox
# ETAPBgNVBAoMCERhdGFwb3J0MR0wGwYDVQQDDBREYXRhcG9ydCBDb2RlU2lnbmlu
# ZzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANWC05TKTGHxtsCEm+ey
# lfRLaaLyUInI/rGB5zNIpWtWLLntVtuYSRfslyDSl0g17rSexKnj7QcColDM7jNh
# fF175g1oTjD/0B3Gk6AAMsbgGySAzly/nyIk6EabjWSp39mgQZ2CKLpDjEA98hAa
# b24mhRpEcW4URVZQc112/PChvvwcANmhvLguWRe6rI21IqD3LsBjmHRCLnciQYiB
# df4mxNhdNgC8PHh3tNdpS3XuVjsBYOvu1enRcqgrfiKhhx8dnuLSV96DTpbqBLUB
# 9OXBrUhKzFk8xrXJonq0Zvo32/stXn9/x4tvDpzyl72EFZ9VBvwurZHoC4G+Yy+N
# O00CAwEAAaOCAiwwggIoMB0GA1UdDgQWBBSjBNtLNKVgBMwQINjTjp8DgcaupzAf
# BgNVHSMEGDAWgBRots8SDUx7xuiv1fkYvjrBZ7druDBGBgNVHR8EPzA9MDugOaA3
# hjVodHRwOi8vcGtpLnNlcnZpY2VkcGFvci5kZS9jcmwvRGF0YXBvcnQlMjBDQSUy
# MDAzLmNybDCBgAYIKwYBBQUHAQEEdDByMCsGCCsGAQUFBzABhh9odHRwOi8vcGtp
# LnNlcnZpY2VkcGFvci5kZS9vY3NwMEMGCCsGAQUFBzAChjdodHRwOi8vcGtpLnNl
# cnZpY2VkcGFvci5kZS9jYS9EYXRhcG9ydCUyMENBJTIwMDMoMikuY3J0MAwGA1Ud
# EwEB/wQCMAAwDgYDVR0PAQH/BAQDAgeAMDsGCSsGAQQBgjcVBwQuMCwGJCsGAQQB
# gjcVCOraY4XM3ECCqZcghNTjc4H4pXaBXsu2Zdf7WQIBZAIBJzAfBgNVHSUEGDAW
# BggrBgEFBQcDAwYKKwYBBAGCNwoDDDApBgkrBgEEAYI3FQoEHDAaMAoGCCsGAQUF
# BwMDMAwGCisGAQQBgjcKAwwwJAYDVR0RBB0wG4EZamFuLnRpZWRlbWFubkBkYXRh
# cG9ydC5kZTBOBgNVHSAERzBFMEMGDSsGAQQBgqlXg32BSAQwMjAwBggrBgEFBQcC
# ARYkaHR0cDovL3BraS5zZXJ2aWNlZHBhb3IuZGUvY2VydGNsYXNzMA0GCSqGSIb3
# DQEBCwUAA4ICAQAiWD1gyjjnATlYkGrKEhwqR5ZDuWYxV5lBr6W37kVx7++ZKOrP
# BNzGmR5dUppi6ujn9eQlCnSRIY0bYs6pg+f+omJeXl2B3ySZ1pWQ/zhr9QP0Z4mq
# 7mvXTOuj3wBCdjsIfRRjmnoRYvTY2CkAvaYC7mUx6njdFbZLxhR8rd0WZlgWFsn5
# 3hRaQeCg8FIkhySQw1SyolFZIH77Z0rdqd+GTUdov6Qf6FwvcYaLxG8JuV0lMGp9
# sE5+8+sFkeRUm+7+a9MjZe6dONJA5DAzNJEaTZoq8C8TqHRv09Fu6zXr3gSS9BZ8
# UbfAZCln7eu6ohyimq1zcX58eYZY89ioWmFzxbfxs4p9evoEpYQrBXYOjguj+YZW
# dAGUSLamMiD8PkROJeHHK5KBt62A5DUre/k8IRhX+nGQOm+Zuv5ffTtQl6PnAG86
# w2ajllJTQbXjH1702TfnpjQO/473LMf4kYqIbHYtztkr2M86PjSfUlH2OCGsq3A4
# rjgwuTFth+PTPzYyQhIdJx0Xg5LWPfbu9CLQc4vlm36vjEk5+GzZOzK0XyXmxmZZ
# uHsju3dWF9biAMIEBsSCyygpHb+AvwzFfqTkFFl68eyhHrb7hbpFTXOZaZPzs5rK
# x3a4X/wKYMlLVx+pbOnHT1fI3a1rc/lvPCQlcvRyELvNjpFZCXlzVV7CUDCCBq4w
# ggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcNAQELBQAwYjELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MB4X
# DTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkGA1UEBhMCVVMxFzAV
# BgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVk
# IEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8TykTepl1Gh1tKD0Z5M
# om2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsmc5Zt+FeoAn39Q7SE
# 2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r07G1decfBmWN
# lCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2R/dhgxndX7RUCyFo
# bjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0QKfAcsW6Th+xtVhN
# ef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/oBpHIEPjQ2OAe3Vu
# JyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1pslPJSlRErWHRAKKtz
# Q87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0z9JMq++bPf4O
# uGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y99xh3pP+OcD5
# sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkUEBIDfV8ju2TjY+Cm
# 4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1GnrXTdrnSDmuZDNIz
# tM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBS6
# FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/57qY
# rhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgwdwYIKwYB
# BQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20w
# QQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAGA1UdIAQZ
# MBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEAfVmO
# wJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7cIoNqilp/GnBzx0H
# 6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2pVs8Vc40BIiXOlWk/
# R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxkJodskr2dfNBwCnzv
# qLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpknG6skHibBt94q6/ae
# sXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2n82HhyS7T6NJuXdm
# kfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HNT7ZAmyEhQNC3
# EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvtCl8zOYdBeHo46Zzh
# 3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU5vIXmVnKcPA3v5gA
# 3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8KvYHZE/6/pNHzV9m8
# BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/GqSFD/yYlvZVVCsf
# gPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwggbAMIIEqKADAgECAhAMTWly
# S5T6PCpKPSkHgD1aMA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYD
# VQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBH
# NCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwHhcNMjIwOTIxMDAwMDAw
# WhcNMzMxMTIxMjM1OTU5WjBGMQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGlnaUNl
# cnQxJDAiBgNVBAMTG0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIyIC0gMjCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAM/spSY6xqnya7uNwQ2a26HoFIV0Mxom
# rNAcVR4eNm28klUMYfSdCXc9FZYIL2tkpP0GgxbXkZI4HDEClvtysZc6Va8z7GGK
# 6aYo25BjXL2JU+A6LYyHQq4mpOS7eHi5ehbhVsbAumRTuyoW51BIu4hpDIjG8b7g
# L307scpTjUCDHufLckkoHkyAHoVW54Xt8mG8qjoHffarbuVm3eJc9S/tjdRNlYRo
# 44DLannR0hCRRinrPibytIzNTLlmyLuqUDgN5YyUXRlav/V7QG5vFqianJVHhoV5
# PgxeZowaCiS+nKrSnLb3T254xCg/oxwPUAY3ugjZNaa1Htp4WB056PhMkRCWfk3h
# 3cKtpX74LRsf7CtGGKMZ9jn39cFPcS6JAxGiS7uYv/pP5Hs27wZE5FX/NurlfDHn
# 88JSxOYWe1p+pSVz28BqmSEtY+VZ9U0vkB8nt9KrFOU4ZodRCGv7U0M50GT6Vs/g
# 9ArmFG1keLuY/ZTDcyHzL8IuINeBrNPxB9ThvdldS24xlCmL5kGkZZTAWOXlLimQ
# prdhZPrZIGwYUWC6poEPCSVT8b876asHDmoHOWIZydaFfxPZjXnPYsXs4Xu5zGcT
# B5rBeO3GiMiwbjJ5xwtZg43G7vUsfHuOy2SJ8bHEuOdTXl9V0n0ZKVkDTvpd6kVz
# HIR+187i1Dp3AgMBAAGjggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/
# BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEE
# AjALBglghkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8w
# HQYDVR0OBBYEFGKK3tBh/I8xFO2XC809KpQU31KcMFoGA1UdHwRTMFEwT6BNoEuG
# SWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQw
# OTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQG
# CCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKG
# TGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJT
# QTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIB
# AFWqKhrzRvN4Vzcw/HXjT9aFI/H8+ZU5myXm93KKmMN31GT8Ffs2wklRLHiIY1UJ
# RjkA/GnUypsp+6M/wMkAmxMdsJiJ3HjyzXyFzVOdr2LiYWajFCpFh0qYQitQ/Bu1
# nggwCfrkLdcJiXn5CeaIzn0buGqim8FTYAnoo7id160fHLjsmEHw9g6A++T/350Q
# p+sAul9Kjxo6UrTqvwlJFTU2WZoPVNKyG39+XgmtdlSKdG3K0gVnK3br/5iyJpU4
# GYhEFOUKWaJr5yI+RCHSPxzAm+18SLLYkgyRTzxmlK9dAlPrnuKe5NMfhgFknADC
# 6Vp0dQ094XmIvxwBl8kZI4DXNlpflhaxYwzGRkA7zl011Fk+Q5oYrsPJy8P7mxNf
# arXH4PMFw1nfJ2Ir3kHJU7n/NBBn9iYymHv+XEKUgZSCnawKi8ZLFUrTmJBFYDOA
# 4CPe+AOk9kVH5c64A0JH6EE2cXet/aLol3ROLtoeHYxayB6a1cLwxiKoT5u92Bya
# UcQvmvZfpyeXupYuhVfAYOd4Vn9q78KVmksRAsiCnMkaBXy6cbVOepls9Oie1FqY
# yJ+/jbsYXEP10Cro4mLueATbvdH7WwqocH7wl4R44wgDXUcsY6glOJcB0j862uXl
# 9uab3H4szP8XTE0AotjWAQ64i+7m4HJViSwnGWH2dwGMMIII/jCCBuagAwIBAgIQ
# cpdzudEVA4dLBRRudhfFuDANBgkqhkiG9w0BAQsFADBDMQswCQYDVQQGEwJERTEW
# MBQGA1UECgwNRGF0YXBvcnQgQcO2UjEcMBoGA1UEAwwTRGF0YXBvcnQgUm9vdCBD
# QSAwMjAeFw0xNTA1MTIxMjM5MzJaFw0zMzA0MjcxNzA5MDNaMEMxCzAJBgNVBAYT
# AkRFMRYwFAYDVQQKDA1EYXRhcG9ydCBBw7ZSMRwwGgYDVQQDDBNEYXRhcG9ydCBS
# b290IENBIDAyMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA5FxNtonA
# wgvllFOiEfM8KMSFGq8VxolE7uFC6hahzT63BTZ9gbdDxuybN7XPJ7uK02e62vXe
# hsH8XPAwcnoeRKX4w8lCJl+3n3drjMLBGuDq+ZbcoQTTvbIZU7VZH5duN5q2Ib1w
# LrzxeibO/SZxO7zjgA1GPDUBTMaF9xwi2XCo+ukvjDP1b9zzqsQ6d1GPNrpCbNgv
# uQL2gUsZ52X33YqPwNUVri3KDdGdMEMheSarN9fxkhyaF+BoYB5SEuu5mQeZHPwO
# WkO+ArmnRuf8U0ImRGhbHucvyj/ArcZHuHicFx8B8nLJN3VCu1ERq3Cdr7hN2vCD
# 4HzK/Cw1vEbevfjiCtLTkQCXGt0TA+YApStEJs2gcm94u3p2AeEBR+JdR0DvooGA
# HCm8bAPNINAz+tRYiunetSmoRZXYXo4aDC0/SXCeGpd118oYzivgq6GzmqZAfG3v
# Y7aAIF0V58nr982G8sGLb94yFNuBnMXmfRKzZY2daCSrRS0pBNB8NS8iLnoPCkEu
# xqmQn9C8jrtby0e4VrD8/kYFe3bm6hkx9Cujpt68N5SQWqgmAoX8vAmqWcPckCvr
# k9rGml+2ae538oJuxwAVN9f0W6vZnTune0yWkvF12SfAwpuKoTsqdcRuXmtuTn/v
# HakWTg3EfR+ohsLopv8/xy2Upv10FV8Y0+8CAwEAAaOCA+wwggPoMA4GA1UdDwEB
# /wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEBMB0GA1UdDgQWBBS8xkstjZDsvSYM
# ILBzftzuBVVLqzCCA6EGA1UdIASCA5gwggOUMIH1BgsrBgEEAYKpV4N9AjCB5TAq
# BggrBgEFBQcCARYeaHR0cDovL3BraS5zZXJ2aWNlZHBhb3IuZGUvY3BzMIG2Bggr
# BgEFBQcCAjCBqR6BpgBEAGEAdABhAHAAbwByAHQAIABBAPYAUgAgAC0AIABaAGUA
# cgB0AGkAZgBpAGsAYQB0AHMAcgBpAGMAaAB0AGwAaQBuAGkAZQAgAHUAbgBkACAA
# RQByAGsAbADkAHIAdQBuAGcAIAB6AHUAbQAgAFoAZQByAHQAaQBmAGkAegBpAGUA
# cgB1AG4AZwBzAGIAZQB0AHIAaQBlAGIAIABTAEgAQQAtADIwgaQGDSsGAQQBgqlX
# g32BSAEwgZIwMAYIKwYBBQUHAgEWJGh0dHA6Ly9wa2kuc2VydmljZWRwYW9yLmRl
# L2NlcnRjbGFzczBeBggrBgEFBQcCAjBSHlAARABhAHQAYQBwAG8AcgB0ACAAQQD2
# AFIAIAAtACAAWgBlAHIAdABpAGYAaQBrAGEAdABzAGsAbABhAHMAcwBlACAAMQAg
# AFMASABBAC0AMjCBpAYNKwYBBAGCqVeDfYFIAjCBkjAwBggrBgEFBQcCARYkaHR0
# cDovL3BraS5zZXJ2aWNlZHBhb3IuZGUvY2VydGNsYXNzMF4GCCsGAQUFBwICMFIe
# UABEAGEAdABhAHAAbwByAHQAIABBAPYAUgAgAC0AIABaAGUAcgB0AGkAZgBpAGsA
# YQB0AHMAawBsAGEAcwBzAGUAIAAyACAAUwBIAEEALQAyMIGkBg0rBgEEAYKpV4N9
# gUgDMIGSMDAGCCsGAQUFBwIBFiRodHRwOi8vcGtpLnNlcnZpY2VkcGFvci5kZS9j
# ZXJ0Y2xhc3MwXgYIKwYBBQUHAgIwUh5QAEQAYQB0AGEAcABvAHIAdAAgAEEA9gBS
# ACAALQAgAFoAZQByAHQAaQBmAGkAawBhAHQAcwBrAGwAYQBzAHMAZQAgADMAIABT
# AEgAQQAtADIwgaQGDSsGAQQBgqlXg32BSAQwgZIwMAYIKwYBBQUHAgEWJGh0dHA6
# Ly9wa2kuc2VydmljZWRwYW9yLmRlL2NlcnRjbGFzczBeBggrBgEFBQcCAjBSHlAA
# RABhAHQAYQBwAG8AcgB0ACAAQQD2AFIAIAAtACAAWgBlAHIAdABpAGYAaQBrAGEA
# dABzAGsAbABhAHMAcwBlACAANAAgAFMASABBAC0AMjANBgkqhkiG9w0BAQsFAAOC
# AgEAGDl9+U+Cq5l0SECvwDpKiOEF6GBm6cwI0++rqO2rDzg5MiCmiMCGlYmGgJnF
# e6cxNWGEQsGHMDUnnCbefQH8xt8kg6PPXAl57Va6ZOa+Eb+tI/ohoM7XfKR6Mchm
# wIr29lv2D9LkjupP/MEG5+gB+nq0f1ZfjxzJrTod2U+WIY8w0ya4StnXwkAtzBnx
# LReAEYOyp6Z3EFPhy8CkjtxVer1H3PoZYZI7sGvaIbBVkmKd0XGyte/Vm6ml75em
# QuK2SpWubP2w/bangi8T8x3NTSXU7eJ3hevK9ebkS7cVqmtd+JaJSi8kI6LS5udA
# OHtwa4Yseoslb+8h0NsOjDmzfrWOTF/fcmpAGEqhcXdncKLjqJR6gb7wo88VF53K
# KhmRe2//fwZGMkJwVTCV4t5ZJFR3m0zb5ZqNu5GlNylXkZPOepZ5mKavPFJMj14P
# AtYDvWzbLyo66GSxMAhhHem0+Y7V3arl2uYyPWj3AD0YM6aR7HT0FFF2/VlBP7dL
# O0ZNz2fEMAeFXf0NbvIPhcyJR6Mmx8bWhWUS5iygAHyBSpeSDWAE9nCx9Bmt1oUd
# pT9uJrV53wocG4hkQAR81halNXMO6kwI/hB16/daOA2dD9ewIqmR7zRykMDVboF5
# 1oWp6A9CrmGODGXXPAgDnAhzCNJ1Ryy5PwJlqrcMLSLzz88wggnNMIIHtaADAgEC
# AhNuAAAADo+kIuZDyV7dAAEAAAAOMA0GCSqGSIb3DQEBCwUAMEMxCzAJBgNVBAYT
# AkRFMRYwFAYDVQQKDA1EYXRhcG9ydCBBw7ZSMRwwGgYDVQQDDBNEYXRhcG9ydCBS
# b290IENBIDAyMB4XDTIxMDQyNzE3MjgzM1oXDTI3MDQyNzE3MzgzM1owPjELMAkG
# A1UEBhMCREUxFjAUBgNVBAoMDURhdGFwb3J0IEHDtlIxFzAVBgNVBAMMDkRhdGFw
# b3J0IENBIDAzMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAppaTw+Nj
# 3Y/GeVMv2MFUQIuK2fuPE/x1+T0RDTNcZHzNEGKVRJKTuvLU0nv80PVpRFPf4Sd/
# EStQ6T7sw0dhod7YEghx/wqcT76DiA0V3Ip4FVDRCUVlGGypc8yBQZWFIeXPwwac
# 2cF49ZOm4KnjCC8S9/6ICOwWRRSCswJrIr/Tr3oD95s9uD3QJGUQGB2cpjqibWuO
# rdMt9AccC+NbywxWrGwkwb6Ys22Iz4kffquGr4hT4EZA5x0i5xGIvFrPPfoLzpvq
# AznclNIf3TNxsx+YwSCFo6GsZArPPxdO8xtD4Rxw3XVJlGuAHpJfuBHE/U93i3OC
# ncGTmVGhiJ0jD+b3ENxnqrJ3yDT9AEAzOtHPapWEL7IXaTnTP2AA53x47kKgUqSN
# yJ/B6WUIBkpB64U+VMBRQN6e/BuERX5fg9Sv5Y8oD7HCbfxieLjiNDeaWSenwS+C
# hNAmjKJ5I7S156sb7NuHDnc8TY9kaDhDOtpB9uBWzHkySC1LgFkkpNknlkjml1Jd
# 3g/vIA4J75SAzkUaJoEYNFa2BVlMFVrTNQp28jP33scP8TAfrFsOs3mcgIv+yl59
# l1hI9jxp5LXCCN2ILQbUEwK70hGPtPsfpNSQEAjO5aoQns2LTDoF+/EA7QoWbEhF
# d/LrXLmBLJwC+RHnbzIZbVQ4w3ngO92IicUCAwEAAaOCBL0wggS5MA4GA1UdDwEB
# /wQEAwIBBjAdBgNVHQ4EFgQUaLbPEg1Me8bor9X5GL46wWe3a7gwggOmBgNVHSAE
# ggOdMIIDmTCB9gYLKwYBBAGCqVeDfQIwgeYwKwYIKwYBBQUHAgEWH2h0dHA6Ly9w
# a2kuc2VydmljZWRwYW9yLmRlL2NwcwAwgbYGCCsGAQUFBwICMIGpHoGmAEQAYQB0
# AGEAcABvAHIAdAAgAEEA9gBSACAALQAgAFoAZQByAHQAaQBmAGkAawBhAHQAcwBy
# AGkAYwBoAHQAbABpAG4AaQBlACAAdQBuAGQAIABFAHIAawBsAOQAcgB1AG4AZwAg
# AHoAdQBtACAAWgBlAHIAdABpAGYAaQB6AGkAZQByAHUAbgBnAHMAYgBlAHQAcgBp
# AGUAYgAgAFMASABBAC0AMjCBpQYNKwYBBAGCqVeDfYFIATCBkzAxBggrBgEFBQcC
# ARYlaHR0cDovL3BraS5zZXJ2aWNlZHBhb3IuZGUvY2VydGNsYXNzADBeBggrBgEF
# BQcCAjBSHlAARABhAHQAYQBwAG8AcgB0ACAAQQD2AFIAIAAtACAAWgBlAHIAdABp
# AGYAaQBrAGEAdABzAGsAbABhAHMAcwBlACAAMQAgAFMASABBAC0AMjCBpQYNKwYB
# BAGCqVeDfYFIAjCBkzAxBggrBgEFBQcCARYlaHR0cDovL3BraS5zZXJ2aWNlZHBh
# b3IuZGUvY2VydGNsYXNzADBeBggrBgEFBQcCAjBSHlAARABhAHQAYQBwAG8AcgB0
# ACAAQQD2AFIAIAAtACAAWgBlAHIAdABpAGYAaQBrAGEAdABzAGsAbABhAHMAcwBl
# ACAAMgAgAFMASABBAC0AMjCBpQYNKwYBBAGCqVeDfYFIAzCBkzAxBggrBgEFBQcC
# ARYlaHR0cDovL3BraS5zZXJ2aWNlZHBhb3IuZGUvY2VydGNsYXNzADBeBggrBgEF
# BQcCAjBSHlAARABhAHQAYQBwAG8AcgB0ACAAQQD2AFIAIAAtACAAWgBlAHIAdABp
# AGYAaQBrAGEAdABzAGsAbABhAHMAcwBlACAAMwAgAFMASABBAC0AMjCBpQYNKwYB
# BAGCqVeDfYFIBDCBkzAxBggrBgEFBQcCARYlaHR0cDovL3BraS5zZXJ2aWNlZHBh
# b3IuZGUvY2VydGNsYXNzADBeBggrBgEFBQcCAjBSHlAARABhAHQAYQBwAG8AcgB0
# ACAAQQD2AFIAIAAtACAAWgBlAHIAdABpAGYAaQBrAGEAdABzAGsAbABhAHMAcwBl
# ACAANAAgAFMASABBAC0AMjASBgNVHRMBAf8ECDAGAQH/AgEAMB8GA1UdIwQYMBaA
# FLzGSy2NkOy9JgwgsHN+3O4FVUurME0GA1UdHwRGMEQwQqBAoD6GPGh0dHA6Ly9w
# a2kuc2VydmljZWRwYW9yLmRlL2NybC9EYXRhcG9ydCUyMFJvb3QlMjBDQSUyMDAy
# LmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly9wa2kuc2Vy
# dmljZWRwYW9yLmRlL2NhL0RhdGFwb3J0JTIwUm9vdCUyMENBJTIwMDIoMSkuY3J0
# MA0GCSqGSIb3DQEBCwUAA4ICAQBkFW+J7wltJhRLPGJASCDb7+QNhpdQGtKKCHWr
# wFWQpS91hjEtwwO/uEltfOo6M/CrFttbFocDm+VO5L1xpyWZArzDEVKLhbII4Qbz
# fT/cetIOQrDSCQUc4rs9v23Ln7s3sUCJVJOCaEr9Z/o6bc2B9bDqzFdy0hcNuwLS
# MRrK3hnHM0SmSgMN0DhH6U8k9znpo6y/kOaNBPjnueQNhZYKfCRj3sM+Da9VzWeF
# vYNVPK91wsChDncUqaauRMvJwNdub7I8G4ZZ/exsDe9Osr95EQCtdbjDwh7Urezf
# lujOVzV3Bk/vNpKFbUvoWFRfzB42Go8lBsEgZmc0Wu6RvlfbrqTyY5Sy1o0bzKtQ
# 4V0qkiPY8a7EX4GN/thSNPP7zJ09Xme+q52K8BCPCeE5K10jJhHTC5SF5JKtQdvq
# 3a2vh/R6A+J8Ap+j60YiOyQAbkW66yTQwgVjttvJFlAvcghdtFsNLXOLEcAhpgcG
# 2eoXPngergi0DDIuBsdpWuzARMKVbcAvNxOeBdOA7xn+QuDdT+E8Kg3OtsibF6wJ
# qSo56x/huYTH0i8tIP2eWOwlIsyHd9wcBE8MMuF4XchXJgdLbk1y62OyyZybX+aT
# QWYQcuMV39HmCgrfUtlDK4+FMXbAUCqqocUH6DYphv851xojOX0bBA/QucrXXjwa
# xmfYODGCBSswggUnAgEBMFUwPjELMAkGA1UEBhMCREUxFjAUBgNVBAoMDURhdGFw
# b3J0IEHDtlIxFzAVBgNVBAMMDkRhdGFwb3J0IENBIDAzAhMUAACY7VKIGShWnr8b
# AAIAAJjtMA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKEC
# gAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwG
# CisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIOxlIuepP4dIuJZ4ORK137erCjR9
# Ut05LeL0aPpMhqedMA0GCSqGSIb3DQEBAQUABIIBAEMIxbdBECgYzW/tJgHpmM0N
# u9evEVKWm1KvvilCzO4D/0+wY2r78WljCdlgTkI8/jL5P1gviS6KUDnR509j7tzA
# y7SQlZrIoOjPRSlMiiO5GtZsP8F5EtbPsSa9sufY9+JNFy/7GS26G2ntlilvFhUO
# 3axn1o2H/ydadhs8WFiUYEGqPaw7TJSamLrQd6Nx+l6l8kMV3DUz9TCGn+81Ajr5
# FpA2L2R3GuTdsrX5biaSmkvq12w/PKgofG0UodCk4A46qQQziPiCspz+nctevNdN
# skajtJUYSIuLo1ti4jZ7EyVua61Fn6CXpKsRSOaKoce4egUdh5udZcMFM++BST+h
# ggMgMIIDHAYJKoZIhvcNAQkGMYIDDTCCAwkCAQEwdzBjMQswCQYDVQQGEwJVUzEX
# MBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0
# ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBAhAMTWlyS5T6PCpK
# PSkHgD1aMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEH
# ATAcBgkqhkiG9w0BCQUxDxcNMjIwOTI5MDk0MTM5WjAvBgkqhkiG9w0BCQQxIgQg
# TSOR33dquaABYkieTkPoKB6NIBPPavX8uAIZCgfWwcYwDQYJKoZIhvcNAQEBBQAE
# ggIAMKGtlztW6eGdz8HQxXhYCI5i48PgmVuKf8hK2G60Cx2Ugk6NZexGp1tz3tvr
# isUWpPn48MvG8IvTYuhFxURB/V2ct84yF9WqDC6FsBFJh0iyKILmTErImGyyJ8FY
# ij7CTnd7TItS0y2U1GVFki6WOeRa1/wHRRKrD/rqZ/jZzbumDUj/lqIP1es8vco9
# Lws3Bc0vyjZrG7vmuQVVLADXx4n1jChYZyX+dmJKWcMs7fZ5+gYLENLw8ii/p5Pm
# 96W0i8TJjMb09nMER5YXkzo689XIZ6++TyU3RqbhilRX4gfZLZwjKlMxQ6i7V18p
# 5t981kO0wVcXv6RPpZtH1hDLAT1mj3hyiTo7a7acSeTGQXemdXz97+KDdwQLgBB+
# fSUtId1NLq7x1wPqZKp5u3gwc5+AYC4mjjudn1ieA73iF2h+SP62o90LqF9qCdbl
# nhoJuzJgaaz4IqD5MZMziX3tU2I5R7AKb2nS6IAZJMWQVTHI6KdspiFm+en1zuo4
# WdopslRIOXG0H9mbwZNHnnUON7Ul/GM0L4fmQ8hqioBIBITk09ACX4pn91huhuMB
# KB9DtJyW3OA5rIMzaHAhCrBQwutEQ56ezkdcO451VdIcarVAmWeUcP3kgktCPoRw
# Vt9swaMO2K938Hb7Fb2GeJSrqMa7YcJF03SjGBVIilvKGuE=
# SIG # End signature block
