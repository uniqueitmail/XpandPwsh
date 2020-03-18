[string[]]$global:pipelineTasksSet=@("ClearProjectDirectories","RemoveNugetImportTargets","RemoveProjectLicenseFile","RemoveProjectInvalidItems",
"UpdateProjectAutoGeneratedBindingRedirects","UpdateAppendTargetFrameworkToOutputPath","UpdateGeneratedAssemblyInfo","UpdateProjectTargetFramework",
"UpdateOutputPath","RemoveProjectReferences","UpdateAssemblyInfoVersion","UpdateProjectCopyRight","AddPackageReferenceNoWarning","UpdateProjectNoWarn","AddAssemblyBindingRedirects")
function Start-PipelineTasks {
    [CmdletBinding()]
    [CmdLetTag(("#Azure","AzureDevOps"))]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$ProjectFile,
        [ValidateScript({$_ -in $global:pipelineTasksSet})]
        [parameter()]
        [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
            $global:pipelineTasksSet
        })]
        [string[]]$Task=$global:pipelineTasksSet,
        [ValidateSet("4.5.2","4.6.1","4.7.1","4.7.2","4.8")]
        [string]$TargetFramework="4.7.2",
        [string]$OutputPath,
        [version]$AssemblyInfoVersion,
        [string]$CopyRight,
        [hashtable]$PackageReferenceNoWarning,
        [string[]]$ProjectNoWarning,
        [pscustomobject[]]$AssemblyBindingRedirectPackage
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        
        Invoke-Script{
            Push-Location $ProjectFile.DirectoryName
            Write-HostFormatted "Analyzing $($ProjectFile.BaseName)" -Section -ForegroundColor Yellow -Stream Verbose
            if ("ClearProjectDirectories" -in $global:pipelineTasksSet){
                Clear-ProjectDirectories 
            }
            
            if ("RemoveNugetImportTargets" -in $global:pipelineTasksSet){
                Remove-NugetImportsTargets $ProjectFile|Out-Null
            }
            
            
            if ("RemoveProjectLicenseFile" -in $global:pipelineTasksSet){
                Remove-ProjectLicenseFile -FilePath $ProjectFile.FullName|Out-Null    
            }
            
            if ("RemoveProjectInvalidItems" -in $global:pipelineTasksSet){
                Remove-ProjectInvalidItems $ProjectFile|Out-Null    
            }
    
            [xml]$project = Get-XmlContent $ProjectFile.FullName
            if ("UpdateProjectAutoGeneratedBindingRedirects" -in $global:pipelineTasksSet){
                Update-ProjectAutoGenerateBindingRedirects $project $true    
            }
            
            if ("UpdateAppendTargetFrameworkToOutputPath" -in $global:pipelineTasksSet){
                Update-AppendTargetFrameworkToOutputPath $project    
            }
            
            if ("UpdateGeneratedAssemblyInfo" -in $global:pipelineTasksSet){
                Update-GenerateAssemblyInfo  $project
            }
            
            if ("UpdateProjectTargetFramework" -in $global:pipelineTasksSet){
                Update-ProjectTargetFramework $TargetFramework $project
            }
            
            if ("UpdateOutputPath" -in $global:pipelineTasksSet -and $OutputPath){
                Update-OutputPath $project $ProjectFile.FullName $OutputPath
            }
            
            if ("UpdateProjectCopyRight" -in $global:pipelineTasksSet){
                Update-ProjectCopyRight $project $CopyRight 
            }
            
            if ("AddPackageReferenceNoWarning" -in $global:pipelineTasksSet -and $PackageReferenceNoWarning.Keys){
                $PackageReferenceNoWarning.Keys|ForEach-Object{
                    $noWarn=$PackageReferenceNoWarning[$_]
                    Add-PackageReferenceNoWarning $project $noWarn $_
                }
            }
            if ("UpdateProjectNoWarn" -in $global:pipelineTasksSet -and $ProjectNoWarning){
                Update-ProjectNoWarn $project -NoWarn $ProjectNoWarning
            }

            $project | Save-Xml $ProjectFile.FullName|Out-Null
    
            if ("RemoveProjectReferences" -in $global:pipelineTasksSet){
                Remove-ProjectReferences $ProjectFile.FullName -InvalidHintPath|Out-Null    
            }
            
            if ("AddAssemblyBindingRedirects" -in $global:pipelineTasksSet -and $AssemblyBindingRedirectPackage){
                (Get-ChildItem $ProjectFile.DirectoryName)|Where-Object{
                    $name=$_.Name
                    "app*.config","Web*.config"|Where-Object{$name -like $_}
                }|foreach{
                    $AssemblyBindingRedirectPackage|Add-AssemblyBindingRedirect -ConfigFile $_ -PublicToken (Get-XpandPublicKeyToken)
                }
            }
            
            if ("UpdateAssemblyInfoVersion" -in $global:pipelineTasksSet){
                Update-AssemblyInfoVersion $AssemblyInfoVersion "$($ProjectFile.DirectoryName)\Properties\AssemblyInfo.cs"    
            }
            
            Pop-Location
        }

    }
    
    end {
        
    }
}