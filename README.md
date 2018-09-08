# Java Homework to PDF (PowerShell Script)
PowerShell Script to Convert Java Homework to PDF Files for Grading

## Background

Computer Science students are instructed to upload a ZIP archive to Canvas LMS containing their .java source code files for each programming homework assignment.

The instructor may then download a single "submissions.zip" file from the assignment page in Canvas, containing all of the student ZIP files within.  See [How do I download all student submissions for an assignment in SpeedGrader?](https://community.canvaslms.com/docs/DOC-13086-415255025)

For grading, it would be useful to be able to merge each student's .java source files into a PDF, which the instructor can annotate with notes using a tablet computer with digital pen/stylus.  This can be done manually using a program such as Adobe Acrobat, but is time-consuming to do for an entire class of student submissions.

## Script Overview

Taking the "submissions.zip" file as an input, this PowerShell script should:

1. Extract the "submissions.zip" archive file.
1. Extract each individual student submission ZIP archive file.
1. For each extracted student submission folder locate all .java files, and convert to a combined single PDF file.
