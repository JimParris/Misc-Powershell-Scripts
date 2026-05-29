function Split-File {

<#
.SYNOPSIS
    Split a large binary file into chunks or reassemble chunks back into a file.

.LINK
    https://stackoverflow.com/questions/4533570/in-powershell-how-do-i-split-a-large-binary-file

.NOTES
    Author:  Jim Parris
    Email:   Jim@ConfigMan-Notes.com
    Version: 1.0.0.0
    Date:    2026-05-29
    Updated:
#>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true, ValueFromPipeLine = $true, ValueFromPipelineByPropertyName = $true)]
    [String]
    $InputFile,
    [Parameter(Mandatory = $true)]
    [String]
    $OutDirectory,
    [Parameter(Mandatory = $false)]
    [String]
    $OutputFilePrefix = "chunk",
    [Parameter(Mandatory = $false)]
    [Int32]
    $ChunkSize = 1024
  )

  Begin {
    Write-Output "Beginning to split your file.."
  }

  Process {
    $FileStream = [System.IO.File]::OpenRead($InputFile)
    $ByteChunks = New-Object byte[] $ChunkSize
    $ChunkNumber = 1
    While($BytesRead = $FileStream.Read($ByteChunks,0,$ChunkSize)) {
      $OutputFile = "$OutputFilePrefix$ChunkNumber"     
      $OutputStream = [System.IO.File]::OpenWrite("$OutDirectory`\$OutputFile")
      $OutputStream.Write($ByteChunks,0,$BytesRead)
      $OutputStream.Close()
      Write-Verbose "Wrote File $OutputFile"
      $ChunkNumber += 1
    }
  }

  End {
    Write-Output "Finished splitting your file!"
  }
}




function Reassemble-File {
    <#
    .SYNOPSIS
        Reassemble file chunks produced by Split-File back into a single file.

    .LINK
        http://configman-notes.com

    .NOTES
        Author:  Jim Parris
        Email:   Jim@ConfigMan-Notes.com
        Version: 1.0.0.0
        Date:    2026-05-29
        Updated:
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [String]
        $InputFileDirectory,
        [Parameter(Mandatory = $true)]
        [String]
        $InputfilePrefix = "chunk",
        [Parameter(Mandatory = $true)]
        [String]
        $OutputDirectory,
        [Parameter(Mandatory = $true)]
        [String]
        $OutputFile
    )

    Begin {
        Write-Output "Beginning to reassemble your files.."
    }

    Process {
        $OutputStream = [System.Io.File]::OpenWrite("$OutputDirectory`\$OutputFile")
        $ChunkNumber = 1
        $InputFilename = "$InputFileDirectory`\$InputfilePrefix$ChunkNumber"
        $Offset = 0
        while(Test-Path $InputFilename) {
            $FileBytes = [System.IO.File]::ReadAllBytes($InputFilename)
            $OutputStream.Write($FileBytes, 0, $FileBytes.Count)
            $ChunkNumber += 1
            $InputFilename = "$InputFileDirectory`\$InputfilePrefix$ChunkNumber"
        }
        $OutputStream.close()   
    }
    End {
        
        Write-Output "Finished assembly!"
    }   
}
