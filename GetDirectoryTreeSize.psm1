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
        Get-DirectoryTreeSize -Path C:\Temp\ -Attrib a,h,d,Normal -AllItemsAndAllFolders

        TotalFolderSize TotalFileCount Path     TotalDirectoryCount
        --------------- -------------- ----     -------------------
        2790,68Mb                  530 C:\Temp\                  15

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
# MIIyBAYJKoZIhvcNAQcCoIIx9TCCMfECAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBQ2ZgWTWgHHgjL
# sl5kWuavT9hUbMz08wqZroW/lIi7nqCCLC8wggWNMIIEdaADAgECAhAOmxiO+dAt
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
# 9uab3H4szP8XTE0AotjWAQ64i+7m4HJViSwnGWH2dwGMMIIJAzCCBuugAwIBAgIQ
# Qi2Wx+MyAYhFE03ldXYDqjANBgkqhkiG9w0BAQsFADBDMQswCQYDVQQGEwJERTEW
# MBQGA1UECgwNRGF0YXBvcnQgQcO2UjEcMBoGA1UEAwwTRGF0YXBvcnQgUm9vdCBD
# QSAwMjAeFw0xNTA1MTIxMjM5MzJaFw0yNzA1MTIxMjQ5MjlaMEMxCzAJBgNVBAYT
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
# HakWTg3EfR+ohsLopv8/xy2Upv10FV8Y0+8CAwEAAaOCA/EwggPtMA4GA1UdDwEB
# /wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEBMB0GA1UdDgQWBBS8xkstjZDsvSYM
# ILBzftzuBVVLqzCCA6YGA1UdIASCA50wggOZMIH2BgsrBgEEAYKpV4N9AjCB5jAr
# BggrBgEFBQcCARYfaHR0cDovL3BraS5zZXJ2aWNlZHBhb3IuZGUvY3BzADCBtgYI
# KwYBBQUHAgIwgakegaYARABhAHQAYQBwAG8AcgB0ACAAQQD2AFIAIAAtACAAWgBl
# AHIAdABpAGYAaQBrAGEAdABzAHIAaQBjAGgAdABsAGkAbgBpAGUAIAB1AG4AZAAg
# AEUAcgBrAGwA5AByAHUAbgBnACAAegB1AG0AIABaAGUAcgB0AGkAZgBpAHoAaQBl
# AHIAdQBuAGcAcwBiAGUAdAByAGkAZQBiACAAUwBIAEEALQAyMIGlBg0rBgEEAYKp
# V4N9gUgBMIGTMDEGCCsGAQUFBwIBFiVodHRwOi8vcGtpLnNlcnZpY2VkcGFvci5k
# ZS9jZXJ0Y2xhc3MAMF4GCCsGAQUFBwICMFIeUABEAGEAdABhAHAAbwByAHQAIABB
# APYAUgAgAC0AIABaAGUAcgB0AGkAZgBpAGsAYQB0AHMAawBsAGEAcwBzAGUAIAAx
# ACAAUwBIAEEALQAyMIGlBg0rBgEEAYKpV4N9gUgCMIGTMDEGCCsGAQUFBwIBFiVo
# dHRwOi8vcGtpLnNlcnZpY2VkcGFvci5kZS9jZXJ0Y2xhc3MAMF4GCCsGAQUFBwIC
# MFIeUABEAGEAdABhAHAAbwByAHQAIABBAPYAUgAgAC0AIABaAGUAcgB0AGkAZgBp
# AGsAYQB0AHMAawBsAGEAcwBzAGUAIAAyACAAUwBIAEEALQAyMIGlBg0rBgEEAYKp
# V4N9gUgDMIGTMDEGCCsGAQUFBwIBFiVodHRwOi8vcGtpLnNlcnZpY2VkcGFvci5k
# ZS9jZXJ0Y2xhc3MAMF4GCCsGAQUFBwICMFIeUABEAGEAdABhAHAAbwByAHQAIABB
# APYAUgAgAC0AIABaAGUAcgB0AGkAZgBpAGsAYQB0AHMAawBsAGEAcwBzAGUAIAAz
# ACAAUwBIAEEALQAyMIGlBg0rBgEEAYKpV4N9gUgEMIGTMDEGCCsGAQUFBwIBFiVo
# dHRwOi8vcGtpLnNlcnZpY2VkcGFvci5kZS9jZXJ0Y2xhc3MAMF4GCCsGAQUFBwIC
# MFIeUABEAGEAdABhAHAAbwByAHQAIABBAPYAUgAgAC0AIABaAGUAcgB0AGkAZgBp
# AGsAYQB0AHMAawBsAGEAcwBzAGUAIAA0ACAAUwBIAEEALQAyMA0GCSqGSIb3DQEB
# CwUAA4ICAQBXNgHgflmJY+a8SNk2oydOklLSRFYzmBrd/kVOLBrxJEhT0HE+T1la
# qG+OUNBiusci7uc1JnRTdK/xKJN/zy3wj4tpfT/yl2RxI1DLaMLY9BQOylOFlGH2
# atNVEx3/MGLCOZgy5YHCIDIn739GnknGbO/bkz7CyM9LKddYOQBzvWsicyXrmfcz
# l+WgYh++2FDcrKbJ4ilsEQzdoR1Tpbxu+saJPI9RzZ8my2ZMeAxuS5uD6YgtCo/7
# VhRf5sCgbu+fiaXTfmuCHWn2VKv4uBt97iEFzQNFixX+M0bgDyiWglM/RzVb4jTu
# YcopEgeomshOhY/p48mal1UL9Z+iMNJPrMANrEMFEER+1oPuCqc20PBOIFZIrzww
# XOOErCGas95qNie9wrbcWo4lTyKqcn2Tm+SD7eQliXp/I2TzmOAljjrNWMsvksFh
# bSAAvWX/Vwh8FUncr+/I4gD8QfM0ZGWfVpaSNKtbVfZf4yxwqhz9OlWdot66jfnE
# AOeKMOgbpkw0qqyifBWLPTIOePwZqM4OrBngp4aqrlYu8xAjrFdiIkUZzPb9pglx
# HXGHhHfF7j0guNaRvj+2VvJlucU+Bij3o8tt7aZoj5AcI6cg/E51ci1CL5Yy6INP
# jqROOu1BtzPcF4DXUcB4G9w3Cdxmmmi30invpyE9cmxDXKiy+Jgd1jCCCc0wgge1
# oAMCAQICE24AAAAOj6Qi5kPJXt0AAQAAAA4wDQYJKoZIhvcNAQELBQAwQzELMAkG
# A1UEBhMCREUxFjAUBgNVBAoMDURhdGFwb3J0IEHDtlIxHDAaBgNVBAMME0RhdGFw
# b3J0IFJvb3QgQ0EgMDIwHhcNMjEwNDI3MTcyODMzWhcNMjcwNDI3MTczODMzWjA+
# MQswCQYDVQQGEwJERTEWMBQGA1UECgwNRGF0YXBvcnQgQcO2UjEXMBUGA1UEAwwO
# RGF0YXBvcnQgQ0EgMDMwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCm
# lpPD42Pdj8Z5Uy/YwVRAi4rZ+48T/HX5PRENM1xkfM0QYpVEkpO68tTSe/zQ9WlE
# U9/hJ38RK1DpPuzDR2Gh3tgSCHH/CpxPvoOIDRXcingVUNEJRWUYbKlzzIFBlYUh
# 5c/DBpzZwXj1k6bgqeMILxL3/ogI7BZFFIKzAmsiv9OvegP3mz24PdAkZRAYHZym
# OqJta46t0y30BxwL41vLDFasbCTBvpizbYjPiR9+q4aviFPgRkDnHSLnEYi8Ws89
# +gvOm+oDOdyU0h/dM3GzH5jBIIWjoaxkCs8/F07zG0PhHHDddUmUa4Aekl+4EcT9
# T3eLc4KdwZOZUaGInSMP5vcQ3GeqsnfINP0AQDM60c9qlYQvshdpOdM/YADnfHju
# QqBSpI3In8HpZQgGSkHrhT5UwFFA3p78G4RFfl+D1K/ljygPscJt/GJ4uOI0N5pZ
# J6fBL4KE0CaMonkjtLXnqxvs24cOdzxNj2RoOEM62kH24FbMeTJILUuAWSSk2SeW
# SOaXUl3eD+8gDgnvlIDORRomgRg0VrYFWUwVWtM1CnbyM/fexw/xMB+sWw6zeZyA
# i/7KXn2XWEj2PGnktcII3YgtBtQTArvSEY+0+x+k1JAQCM7lqhCezYtMOgX78QDt
# ChZsSEV38utcuYEsnAL5EedvMhltVDjDeeA73YiJxQIDAQABo4IEvTCCBLkwDgYD
# VR0PAQH/BAQDAgEGMB0GA1UdDgQWBBRots8SDUx7xuiv1fkYvjrBZ7druDCCA6YG
# A1UdIASCA50wggOZMIH2BgsrBgEEAYKpV4N9AjCB5jArBggrBgEFBQcCARYfaHR0
# cDovL3BraS5zZXJ2aWNlZHBhb3IuZGUvY3BzADCBtgYIKwYBBQUHAgIwgakegaYA
# RABhAHQAYQBwAG8AcgB0ACAAQQD2AFIAIAAtACAAWgBlAHIAdABpAGYAaQBrAGEA
# dABzAHIAaQBjAGgAdABsAGkAbgBpAGUAIAB1AG4AZAAgAEUAcgBrAGwA5AByAHUA
# bgBnACAAegB1AG0AIABaAGUAcgB0AGkAZgBpAHoAaQBlAHIAdQBuAGcAcwBiAGUA
# dAByAGkAZQBiACAAUwBIAEEALQAyMIGlBg0rBgEEAYKpV4N9gUgBMIGTMDEGCCsG
# AQUFBwIBFiVodHRwOi8vcGtpLnNlcnZpY2VkcGFvci5kZS9jZXJ0Y2xhc3MAMF4G
# CCsGAQUFBwICMFIeUABEAGEAdABhAHAAbwByAHQAIABBAPYAUgAgAC0AIABaAGUA
# cgB0AGkAZgBpAGsAYQB0AHMAawBsAGEAcwBzAGUAIAAxACAAUwBIAEEALQAyMIGl
# Bg0rBgEEAYKpV4N9gUgCMIGTMDEGCCsGAQUFBwIBFiVodHRwOi8vcGtpLnNlcnZp
# Y2VkcGFvci5kZS9jZXJ0Y2xhc3MAMF4GCCsGAQUFBwICMFIeUABEAGEAdABhAHAA
# bwByAHQAIABBAPYAUgAgAC0AIABaAGUAcgB0AGkAZgBpAGsAYQB0AHMAawBsAGEA
# cwBzAGUAIAAyACAAUwBIAEEALQAyMIGlBg0rBgEEAYKpV4N9gUgDMIGTMDEGCCsG
# AQUFBwIBFiVodHRwOi8vcGtpLnNlcnZpY2VkcGFvci5kZS9jZXJ0Y2xhc3MAMF4G
# CCsGAQUFBwICMFIeUABEAGEAdABhAHAAbwByAHQAIABBAPYAUgAgAC0AIABaAGUA
# cgB0AGkAZgBpAGsAYQB0AHMAawBsAGEAcwBzAGUAIAAzACAAUwBIAEEALQAyMIGl
# Bg0rBgEEAYKpV4N9gUgEMIGTMDEGCCsGAQUFBwIBFiVodHRwOi8vcGtpLnNlcnZp
# Y2VkcGFvci5kZS9jZXJ0Y2xhc3MAMF4GCCsGAQUFBwICMFIeUABEAGEAdABhAHAA
# bwByAHQAIABBAPYAUgAgAC0AIABaAGUAcgB0AGkAZgBpAGsAYQB0AHMAawBsAGEA
# cwBzAGUAIAA0ACAAUwBIAEEALQAyMBIGA1UdEwEB/wQIMAYBAf8CAQAwHwYDVR0j
# BBgwFoAUvMZLLY2Q7L0mDCCwc37c7gVVS6swTQYDVR0fBEYwRDBCoECgPoY8aHR0
# cDovL3BraS5zZXJ2aWNlZHBhb3IuZGUvY3JsL0RhdGFwb3J0JTIwUm9vdCUyMENB
# JTIwMDIuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3Br
# aS5zZXJ2aWNlZHBhb3IuZGUvY2EvRGF0YXBvcnQlMjBSb290JTIwQ0ElMjAwMigx
# KS5jcnQwDQYJKoZIhvcNAQELBQADggIBAGQVb4nvCW0mFEs8YkBIINvv5A2Gl1Aa
# 0ooIdavAVZClL3WGMS3DA7+4SW186joz8KsW21sWhwOb5U7kvXGnJZkCvMMRUouF
# sgjhBvN9P9x60g5CsNIJBRziuz2/bcufuzexQIlUk4JoSv1n+jptzYH1sOrMV3LS
# Fw27AtIxGsreGcczRKZKAw3QOEfpTyT3OemjrL+Q5o0E+Oe55A2Flgp8JGPewz4N
# r1XNZ4W9g1U8r3XCwKEOdxSppq5Ey8nA125vsjwbhln97GwN706yv3kRAK11uMPC
# HtSt7N+W6M5XNXcGT+82koVtS+hYVF/MHjYajyUGwSBmZzRa7pG+V9uupPJjlLLW
# jRvMq1DhXSqSI9jxrsRfgY3+2FI08/vMnT1eZ76rnYrwEI8J4TkrXSMmEdMLlIXk
# kq1B2+rdra+H9HoD4nwCn6PrRiI7JABuRbrrJNDCBWO228kWUC9yCF20Ww0tc4sR
# wCGmBwbZ6hc+eB6uCLQMMi4Gx2la7MBEwpVtwC83E54F04DvGf5C4N1P4TwqDc62
# yJsXrAmpKjnrH+G5hMfSLy0g/Z5Y7CUizId33BwETwwy4XhdyFcmB0tuTXLrY7LJ
# nJtf5pNBZhBy4xXf0eYKCt9S2UMrj4UxdsBQKqqhxQfoNimG/znXGiM5fRsED9C5
# ytdePBrGZ9g4MYIFKzCCBScCAQEwVTA+MQswCQYDVQQGEwJERTEWMBQGA1UECgwN
# RGF0YXBvcnQgQcO2UjEXMBUGA1UEAwwORGF0YXBvcnQgQ0EgMDMCExQAAJjtUogZ
# KFaevxsAAgAAmO0wDQYJYIZIAWUDBAIBBQCggYQwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgatF5COezApNG8E5Y+PTF
# sonu01fIqLmL1YRkzYZtzxswDQYJKoZIhvcNAQEBBQAEggEAf6Mc2XsElfWI8Vm+
# 0bEDEZznAbmLacXvzrRONOZ3R0rqnJIOU1QOQZsi/SzqyFFgvzFpBrYRkzli8Vzf
# +DbM0YCa9sSPpuMTO9a55XIo+WmC8bbEatmvHtGnwQbb0e/hYUkOkKd3SLsVWh5a
# vMDJKvssOvemUJe/YkfbmddIxUUSB4WLlB9UhCRqk/QPEHqJq7HOqHyDZW2gGRow
# UqAEkyin3F9ZUFk/3cqYlM9nJievjzl1k1zbphA8S58FpZosvegRDwamXiSIQIAi
# 4PjoMFsSWZ23b0JRPAMoUWQjuOTMv3aRsoDeLKkCXRKjpGGuwvQepDXVBHymJVWe
# YXUCNaGCAyAwggMcBgkqhkiG9w0BCQYxggMNMIIDCQIBATB3MGMxCzAJBgNVBAYT
# AlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQg
# VHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAxNaXJL
# lPo8Kko9KQeAPVowDQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG9w0BCQMxCwYJKoZI
# hvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMjA5MjkxNTI5MjBaMC8GCSqGSIb3DQEJ
# BDEiBCDtGrRUEPO+gF03Ci8Oi8NUKcSLte7huCetXqfFR3tPxDANBgkqhkiG9w0B
# AQEFAASCAgABdWuYhtumg/pgqf17mPSNieFNeACtzB5iK1Kb1U3uC9AqAAyarX9S
# jTLcDHaLhkOIV2XGGHbwwKHOo251+aUOe/gnDjvKIQn/r2hb9I5dIMop6uNJNIux
# Ipheyz2Azh/quLdX7+MUzQdY3L3cvhzYIxr9WoB2Uej3Ys98JO9AEWwk6afzaWIE
# foecb3d85N1V/k63kpaH5MRYhlphylcOCb9caPc8PMEzaI2bWMbhUM9MhbYhP1D4
# dD2OfOLYnKvdGFK3+SHADvdXLli3pKPEOpySu3uy2lFhTQ99FT9V/8mKMW1Hqtd/
# bBu+MKW06wS9Dvi15vz4tKBMyg40dEyGlD0GRt4nptBi+U/sNgwKfud54RyigdKN
# KkiPq3ijVpu4xTx/fh7o7W1Q1u07Hz9a90nXaZMpoLdOpKDdrrPy9MQZCcg2oBsi
# QRQraKmubGuVxLqOz1zHCYIb2PdEWZSGwKTKaaWx37TZAD7cPXalJGkiaNKaHjle
# uqDESIbmGu6fLCF2MjJJxVWcGBciWiLW8dhy4MSEWu9XdnC4up3x1B1C8mKj3YYR
# sFAB3o+iSCTH1aWIAzXHbsCq8iPPkejpEImZL/ggkRAn+QrK4JktCYbDUKOn9Nb2
# BkjSO8C9LJCImf+vioYXsXJUZLQCDw0kH+4L2VPIxGThC3cOn0fGyg==
# SIG # End signature block
