<#
.SYNOPSIS
    Program to extract and convert .java source files to PDF.
.DESCRIPTION
    Program to extract .java source files from Canvas LMS Homework
    submission ZIP archives, and then convert those .java source files
    into combined PDF files per student, so that they be graded and
    annotated with notes in Adobe Acrobat.
.NOTES
    File Name  : Convert-Java-To-PDF.ps1
    Author     : Mark Stramaglia <markstramaglia@gmail.com>
.LINK
    https://github.com/markstramaglia/java_homework_to_pdf
#>


# PROMPT USER FOR FILE PATH
$SubmissionsFileName = "submissions.zip"

Write-Host ""
$SubmissionsFilePath = Read-Host -Prompt "INPUT: Please provide full path to submissions.zip file"
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
