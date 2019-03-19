function Get-DevExpressVersion {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ParameterSetName = "version",Position=0)]
        [string]$Version,
        [parameter(ParameterSetName = "version")]
        [switch]$Build,
        [parameter(ParameterSetName = "latest")]
        [switch]$Latest,
        [parameter(ParameterSetName = "latest")]
        [string]$LatestVersionFeed="https://xpandnugetserver.azurewebsites.net/nuget"
    )
    
    begin {
    }
    
    process {
        if ($PSCmdlet.ParameterSetName -eq "version") {
            $v = New-Object System.Version $version
            if (!$build) {
                "$($v.Major).$($v.Minor)"
            }    
            else {
                "$($v.Major).$($v.Minor).$($v.Build.ToString().Substring(0,1))"
            }
        }
        else{
            & (Get-NugetPath) list DevExpress.ExpressApp -source $LatestVersionFeed|ConvertTo-PackageObject|Select-Object -ExpandProperty Version -First 1
        }
        
    }
    
    end {
    }
}
