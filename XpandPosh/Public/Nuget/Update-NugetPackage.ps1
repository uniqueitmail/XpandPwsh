
function Update-NugetPackage{
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline)]
        [string]$SourcePath=".",
        [parameter(Mandatory)]
        [string]$RepositoryPath,
        [parameter()]
        [string]$Filter="*",
        [string]$sources=((Get-PackageSourceLocations Nuget) -join ";")
    )
    $configs=Get-ChildItem $sourcePath packages.config -Recurse|ForEach-Object{
        [PSCustomObject]@{
            Content = [xml]$(Get-Content $_.FullName)
            Config = $_
        }
    }

    $metadatas=$configs.Content.packages.package.id|Where-Object{$_ -like $Filter}|Select-Object -Unique |
    Get-NugetPackageSearchMetadata -Source $sources
    $metadatas|ForEach-Object{
        [PSCustomObject]@{
            Name = $_.Identity.Id
            Version=(Get-NugetPackageMetadataVersion $_).Version
        }
    }
    
    $packages=$configs|ForEach-Object{
        $config=$_.Config
        $_.Content.packages.package|Where-Object{$_.id -like $filter}|ForEach-Object{
            $packageId=$_.Id
            $metadata=$metadatas|Where-object{$_.Identity.Id -eq $packageId}
            if ($metadata){
                $csproj=Get-ChildItem $config.DirectoryName *.csproj|Select -first 1
                [PSCustomObject]@{
                    Id = $packageId
                    NewVersion = (Get-NugetPackageMetadataVersion $metadata).version
                    Config =$config.FullName
                    csproj =$csproj.FullName
                    Version=$_.Version
                }
            }
        }
    }|Where-Object{$_.NewVersion -and ($_.Version -ne $_.NewVersion)}
    $sortedPackages=$packages|Group-Object Config|ForEach-Object{
        $p=[PSCustomObject]@{
            Packages = ($_.Group|Sort-PackageByDependencies)
        }
        $p
    } 
    
    
    $sortedPackages|Invoke-Parallel -activityName "Update all packages" -VariablesToImport @("RepositoryPath","sources") -Script {
        ($_.Packages|ForEach-Object{
            & (Get-NugetPath) Update $_.Config -Id $_.Id -Version $($_.NewVersion) -Source $sources -NonInteractive -RepositoryPath $RepositoryPath
        })
    }
}


