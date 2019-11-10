
function Invoke-PaketInstall {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [string]$Path = ".",
        [switch]$Force
    )
    
    begin {
        
    }
    
    process {
        $paketExe=(Get-PaketPath $path)
        if ($paketExe){
            $xtraArgs = @();
            if ($Force) {
                $xtraArgs += "--force"
            }
            & $paketExe install @xtraArgs
        }
    }
    
    end {
        
    }
}