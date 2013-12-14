Citrix Systems, Inc.
READ ME 
Citrix(R) Installation Manager(TM)
Application Packaging and Delivery
for MetaFrame XP(TM) for Windows, Feature Release 2


CONTENTS
--------
-Introduction
-System Requirements
-Installation and Licensing
-Where to Find Documentation
-Late Breaking Information and Known Issues
-Contact Information

INTRODUCTION
------------
This document contains last-minute information about 
Citrix Installation Manager for MetaFrame XP for Windows, 
Feature Release 2. Installation Manager enables you 
to package and install applications, service packs, 
upgrades, files, and other components on target servers 
simultaneously. Installation Manager lets you install 
packages on hundreds of servers in your farm from one 
MetaFrame XP server.

This document and the Citrix Installation Manager Getting
Started guide are installed with Installation Manager.

SYSTEM REQUIREMENTS
-------------------
-Pentium 3 or 4 processor, server grade computer
-A minimum of 256MB RAM plus additional RAM required by the
 application to be packaged
-Windows 2000 Server with Service Pack 2 and Terminal Services
-MetaFrame XP(TM)e Application Server for Windows, Version 1.0


WHERE TO FIND DOCUMENTATION
---------------------------
Installation Manager includes the following documentation:

* This Readme file

* Online help for Installation Manager features, 
  integrated into the help system for Citrix Management 
  Console and Citrix Packager

* The Citrix Installation Manager Getting Started guide, 
  in Adobe Portable Document format 
  (Installation_Manager_Get_Started.pdf)

* Citrix Application Compatibility Guide, in Adobe
  Portable Document format (App_Compatibility_Guide.pdf)

  Use the Adobe Acrobat Reader 4 or later or Exchange program 
  to view PDF files. You can download Acrobat Reader for free 
  from Adobe's Web site at http://www.adobe.com. 

This Readme file and the Citrix Installation Manager Getting Started 
guide are available in the following locations:

* In the \Doc directory of your MetaFrame Server CD-ROM disc.

* In the Documentation folder on your MetaFrame XP server. 
  <drive>/Program Files/Citrix/Documentation.

* On the Citrix Web site at http://www.citrix.com/support;
  under Support select Product Documentation. You can check the
  Product Documentation area of the Web site at any time 
  for the latest updates to Citrix technical manuals. 
  Any updates to the guide published after the release 
  of this product are posted there also.

Citrix Installation Manager Application Compatibility Guide. 
This guide is available at http://www.citrix.com/support 
in Product Documentation. The Japanese version is available 
on the Citrix Web site at http://www.citrix.com/support 
or http://www.citrix.co.jp/support/pdf/.

The Installation Script Reference that was included in
the Installation Management Services 1.0b (IMS 1.0b) hard copy 
documentation is available in the Packager online help.

To view the Installation Script Reference topics:
 
1. In Packager, choose Help > Contents. 
2. Click Content Topics and the Contents tab. 
3. Expand Introduction to Packager > Advanced Packaging Features 
   > Installation Script Reference.

LATE-BREAKING INFORMATION AND KNOWN ISSUES
------------------------------------------

******************************************************************
                          CAUTION
******************************************************************

Windows 2000 Server operating systems include Version 1.1 of the 
Windows Installer Service by default. Citrix recommends that you
install Windows Installer Version 2.0 or later on the server before
you install MetaFrame XP. Unrecoverable errors have been
encountered when attempting to install MetaFrame XP on a server
running Windows Installer Version 1.1. These errors may require 
you to reinstall the server operating system. MetaFrame XP Setup
checks for the presence of Windows Installer 2.0 or higher on the
server and exits if it is not installed. See the MetaFrame XP
Administrator’s Guide for important details.

*******************************************************************

USING IGNOREMSICHECK.MST TO OVERRIDE THE CHECK FOR WINDOWS INSTALLER
2.0 CAN CAUSE INSTALLATION OF METAFRAME XP FR2 ON A METAFRAME XP FR1
SERVER TO FAIL

If you are running Windows Installer version 1.1 on a server on which
you plan to install MetaFrame XP, please see the caution at the
beginning of this section. You can identify the version of Windows
Installer you are running by typing msiexec.exe at a command prompt.
If you must use Windows Installer version 1.1 to install MetaFrame XP
you can use A Windows Installer transform file, ignoremsicheck.mst, 
to override Setup’s check for Windows Installer Version 2.0. The
specific details for adding this override to an installation package
are in the MetaFrame XP Administrator’s Guide with the following
exception:  When using Installation Manager to install MetaFrame FR2
on a server on which MetaFrame FR1 is installed, the transform file, 
ignoremsicheck.mst, cannot be found unless it is placed in the same
directory as the Microsoft installer (MSI) package. If the transform
file cannot be found the installation fails.

INSTALLATION

-If you install and uninstall Installation Manager multiple 
times without rebooting your machine, Msiexec may stop running. 
The installation does not seem to finish, even though it does. 
Restart the server during the process to restart the service. 
Do not restart the server until the software prompts you to. 
This problem does not occur during MetaFrame XP installs. 

-Installing MetaFrame XP for Windows, Feature Release 1.
For instructions about how to install Feature Release 1 using 
Installation Manager, see the Installation Manager Application
Compatibility Guide on the Citrix Web site 
at http://www.citrix.com/support.

-Installing MetaFrame XP for Windows, Feature Release 2.
For instructions about how to install Feature Release 2 using 
Installation Manager, see the Installation Manager Application
Compatibility Guide on the Citrix Web site 
at http://www.citrix.com/support.


MIGRATION

-Upgrading from IMS 1.0b. This issue applies only if you
upgrade from IMS 1.0b to Installation Manager. Run the 
IM_APP_UPGRD utility prior to MetaFrame XP installation 
to ensure that IMS 1.0b applications publish correctly 
in the MetaFrame XP environment. 

If an IMS 1.0b published application is the desktop, 
the previous version of IM_APP_UPGRD terminates without 
upgrading other applications.

An updated version of IM_APP_UPGRD is available 
on the MetaFrame XP for Windows, Feature Release 1 CD-ROM disc 
in /IM/support which migrates the published application correctly.


CITRIX PACKAGER

-File names. The Packager utility does not acknowledge component 
file names that contain these special characters: \ / : * ? " < >

-Folders with attribute "Hidden." If you create a package that 
includes a folder with the Hidden attribute set, the hidden 
attribute is not retained when you deploy the package to 
target servers. 

CITRIX MANAGEMENT CONSOLE

-Installing packages. The console always reports "success"
for unattended program packages even if the install fails. 
This is a limitation of the Installer service. The Installer
service displays the success message immediately after 
starting the unattended program. The success message 
indicates only that the unattended program was started. 
After the package installs, the unattended program finishes. 
Check the target server to determine if it was successful. 

-Server Group names. When naming server groups, do not use 
the names that Citrix Management Console uses for special 
nodes, that is: Application, Citrix Administrators, Policies 
or Servers.


NETWORK

Installation Manager requires the Microsoft Windows Network 
sharepoint. Other networks are not supported.


MSI PACKAGES

-Microsoft Office XP requires that you run the command, 
msiexec /a proplus.msi, before you use Installation 
Manager. Office XP also requires that you add 
PIDKEY=<product ID, no dashes> to the command line 
options box in the Properties dialog box of the Installation 
Manager package. For information about how to install
Office XP, see the Citrix Installation Manager Application 
Compatibility Guide.


LOG FILES

The log file for a Feature Release 2 deployment on target servers 
appears in %SYSTEMROOT%\system32\xpfr2_out.log. If you use 
Installation Manager to deploy Feature Release 2, on Windows .NET
Server, the log file appears in ?????; 
on Windows 2000 Server with Terminal Services, the log file appears 
in %WINDIR%\Temp\mfxpfr1install.log. You can change the path 
to the log file in the Installation Manager .wfs file 
at %TEMPDIR%\Mfxpfr2install.log.


CONTACT INFORMATION
-------------------
Citrix Systems, Inc.
6400 NW 6th Way
Fort Lauderdale, Florida 33309 USA
954-267-3000
http://www.citrix.com
