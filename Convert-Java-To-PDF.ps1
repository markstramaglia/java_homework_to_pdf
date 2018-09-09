<#
.SYNOPSIS
    Program to extract and convert .java source files to PDF.
.DESCRIPTION
    Program to extract .java source files from Canvas LMS Homework
    submission ZIP archives, and then convert those .java source files
    into combined PDF files per student, so that they be graded and
    annotated with notes in Adobe Acrobat.
.NOTES
    File Name     : Convert-Java-To-PDF.ps1
    Author        : Mark Stramaglia <markstramaglia@gmail.com>
    PDF Converter : iTextSharp: https://github.com/itext/itextsharp
.LINK
    https://github.com/markstramaglia/java_homework_to_pdf
#>

# IMPORT PDF CONVERSION MODULE
Add-Type -Path "$PSScriptRoot\itextsharp.dll"

# PROMPT USER FOR FILE PATH
$SubmissionsFileName = "submissions.zip"

Write-Host ""
$SubmissionsFilePath = Read-Host -Prompt "INPUT: Please provide full path to submissions.zip file"
Write-Host ""
$FolderSuffix = Read-Host -Prompt "INPUT: Please provide folder suffix to use"
Write-Host ""

If($SubmissionsFilePath.Substring($SubmissionsFilePath.Length-1,1) -ne "\")
{
    $SubmissionsFilePath = $SubmissionsFilePath + "\"
}

# VERIFY EXISTENCE OF ZIP FILE
$SubmissionsFullFilePath = $SubmissionsFilePath + $SubmissionsFileName
Write-Host " INFO: Checking for ZIP archive: $SubmissionsFullFilePath"
$FileExists = Test-Path -Path $SubmissionsFullFilePath -PathType leaf
If($FileExists)
{
    Write-Host " INFO: Found submissions.zip file!"
}
Else
{
    Write-Host "ERROR: Did not find submissions.zip file.  Please verify that file path is correct."
    Write-Host "ERROR: Exiting program."
    Exit
}

# EXTRACT ZIP ARCHIVE
$SubmissionsDestinationPath = $SubmissionsFilePath + "extracted_submissions\"
Write-Host " INFO: Expanding submissions.zip archive..."
Expand-Archive -LiteralPath $SubmissionsFullFilePath -DestinationPath $SubmissionsDestinationPath

# REPLACE SPACES WITH UNDERSCORES IN ZIP ARCHIVE FILE NAMES
$archives = Get-ChildItem -Path ($SubmissionsDestinationPath + "*") -Include *.zip
ForEach($archive In $archives)
{
    Rename-Item -Path $archive.FullName –NewName ($archive.Name –replace " ", "_")
}

# EXPAND STUDENT SUBMISSION ZIP ARCHIVES
$archives = Get-ChildItem -Path ($SubmissionsDestinationPath + "*") -Include *.zip
ForEach($archive In $archives)
{
    Write-Host "--------------------------------------------------------------"
    $archiveFolderName = $archive.Name -replace "\.zip", "\"
    $archiveFolderName = $archiveFolderName -replace "_late_", "_"

    # Normalize folder names after "studentname_studentid_submissionid_"
    $index1 = $archiveFolderName.IndexOf("_")
    $index2 = $archiveFolderName.IndexOf("_",$index1+1)
    $index3 = $archiveFolderName.IndexOf("_",$index2+1)
    $archiveFolderName = $archiveFolderName.Substring(0, $index3) + "_" + $FolderSuffix + "\"

    $DestinationPath = $archive.DirectoryName + "\" + $archiveFolderName
    Write-Host " INFO:   Expanding:" $archive.Name
    Write-Host " INFO: Destination:" $DestinationPath
    
    Expand-Archive -LiteralPath $archive.FullName -DestinationPath $DestinationPath

    # Delete the original ZIP file
    Remove-Item -Path $archive.FullName

    # Find all the .java source files in student folder
    $JavaFiles = Get-ChildItem -Path $DestinationPath -Recurse -Include *.java -Exclude .*
    ForEach($JavaFile In $JavaFiles)
    {
        Write-Host " INFO:   Java File:" $JavaFile.FullName

        # Create PDF from Java File
        $PDFOutputFilePath = $JavaFile.FullName -replace "\.java", ".pdf"
        Write-Host " INFO: Creating PDF: " $PDFOutputFilePath
        [System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\itextsharp.dll")

        $doc = New-Object iTextSharp.text.Document
        $fileStream = New-Object IO.FileStream("$PDFOutputFilePath", [System.IO.FileMode]::Create)
        [iTextSharp.text.pdf.PdfWriter]::GetInstance($doc, $filestream)

        #iTextSharp provides a class to work with fonts, but first we have to register them:
        [iTextSharp.text.FontFactory]::RegisterDirectories()
        $arial = [iTextSharp.text.FontFactory]::GetFont("arial", 10)

        $paragraph = New-Object iTextSharp.text.Paragraph

        $paragraph.add((gc $JavaFile.FullName|%{"$_`n"})) | Out-Null
        $doc.open()
        $doc.add($paragraph) | Out-Null
        $doc.close()
    }
}
