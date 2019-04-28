if (!(Get-Module XpandPosh -ListAvailable)) {
    Install-Module XpandPosh
}
$lastSha = Get-GitLastSha "https://github.com/eXpandFramework/XpandPosh.git"
$lastSha
$needNewVersion = (git diff --name-only "$lastSha" HEAD|Select-Object -First 1)|Where-Object {$_ -like "XpandPosh/*" -and $_ -notlike "*.md" -and $_ -notlike "*.yml" }
"needNewVersion=$needNewVersion"
$needNewMinor = git diff --name-only |Where-Object{$_ -like "*ReadMe.md"}
"needNewMinor=$needNewMinor"
if ($needNewVersion -or $needNewMinor) {
    $file = "$PSScriptRoot\..\XpandPosh\XpandPosh.psd1"
    $data = Get-Content $file -Raw
    $manifest = Invoke-Expression $data
    $moduleVersion = New-Object System.Version($manifest.ModuleVersion)
    "moduleVersion=$moduleVersion"
    if ($needNewMinor) {
        $newMinor = $moduleVersion.Minor + 1
        $newBuild = 0
    }
    else {
        $onlineVersion = New-Object System.Version ((Find-Module XpandPosh -Repository PSGallery).Version)
        $newMinor = $onlineVersion.Minor
        $newBuild = $onlineVersion.Build + 1
    }
    
    $newVersion = "$($moduleVersion.Major).$newMinor.$newBuild"
    if ($manifest.ModuleVersion -ne $newVersion) {
        Set-Content $file $data.Replace($manifest.ModuleVersion, $newVersion)
        & git commit -a -m $newVersion
        & git tag $newVersion
        Write-Error "Version Changed" -ErrorAction Continue
        exit 1
    }
}

