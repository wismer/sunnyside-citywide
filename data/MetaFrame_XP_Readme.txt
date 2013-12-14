Citrix Systems
READ ME
Citrix MetaFrame XP (tm) Application Server for Windows, Version 1.0
January 2001


INTRODUCTION
This document contains last-minute information on MetaFrame XP for Windows, Version 1.0. MetaFrame XP is the server-based computing solution for organizations and large enterprises. MetaFrame XP provides integrated management capabilities for system administrators, along with ease of use and productivity enhancements for end-users who access applications on MetaFrame XP servers using Citrix ICA Clients.

Viewing this document:
When viewing this document in Notepad, if the text does not wrap in the window, choose Edit > Word Wrap (Windows NT 4) or Format > Word Wrap (Windows 2000). 

Printing this document:
Before printing this document, adjust the window width to fit your printer paper. To print the document, choose File > Print.


SYSTEM REQUIREMENTS
This section briefly summarizes the system requirements for MetaFrame XP for Windows. For a complete description of the system requirements, refer to the MetaFrame XP Administrator’s Guide.

MetaFrame XP for Windows requires Windows NT Server 4.0, Terminal Server Edition, or a Windows 2000 Server Family product (Windows 2000 Server, Advanced Server, or Datacenter Server).

MetaFrame XP requires the same system configuration as specified by Microsoft for its Windows server products. 

This release requires a minimum display setting of 800 x 600 pixels and 256 colors. To run the Citrix Management Console from Tivoli NetView, the recommended display setting is True Color (24-bit).

The following are recommended minimum configurations:

Windows NT Server 4.0, Terminal Server Edition:
	TSE Service Pack 5 or later recommended
	32-bit Pentium-compatible processor
	32 MB of RAM, plus 4-8 MB for each typical ICA Client connection
	Hard disk with 128 MB free space (SCSI disk interface recommended)
	High-density 3.5-inch disk drive and CD-ROM drive
	High-performance bus (EISA, MCA, PCI) recommended
	Transmission Control Protocol/Internet Protocol (TCP/IP)

Windows 2000 Servers:
	133 MHz or higher Pentium-compatible CPU
	256 MB of RAM (128 MB minimum supported; 4 GB maximum (8 GB on Advanced Server)
	2 GB hard disk with 1.0 GB free space (more for network installation)


WHERE TO FIND DOCUMENTATION

MetaFrame XP includes the following documentation:

* This readme file (MetaFrame_XP_Readme.txt)

* Online help for all MetaFrame XP features and utilities

* The MetaFrame XP Administrator’s Guide in Adobe Portable Document Format  
  (Windows_MetaFrame_XP_Guide.pdf). 
  The file is located in the DOC directory on the MetaFrame XP CD.
  Use the Adobe Acrobat Reader or Exchange program to view PDF files.
  You can download the free Acrobat Reader from Adobe’s web site at
  http://www.adobe.com.

ICA Client documentation

* The ICA Client CD readme file (ICA_Client_CD_readme.txt).
  The file is located in the root directory of the ICA Client CD.

* The Client Administrator's Guides for each ICA Client
  (Win32, Win16, WinCE, Java, Macintosh, UNIX, DOS), in Adobe
  Portable Document Format. The files are located in the DOC directory
  of the ICA Client CD.

* The ICA Client Object Guide in Adobe Portable Document Format  
  (ICA_Client_Object_Guide.pdf). The file is located in the DOC directory
  of the ICA Client CD.

NFuse documentation

* The NFuse readme file (NFuse_Readme.txt).
  The file is located in the root directory of the NFuse CD.

* The Citrix Web-based ICA Client Installation file (Readme.htm).
  The file is located in the WEBINST directory of the NFuse CD.

* The NFuse Administrator's Guide in Adobe Portable Document Format
  (NFuse_Guide.pdf).
  The file is located in the root directory of the NFuse CD.

After MetaFrame XP installation, the Documentation folder can be displayed from a button on the ICA Administrator Toolbar or the Start menu. Click the folder icon on the ICA Administrator Toolbar to display the Documentation folder, or from the Start menu, choose Programs > Citrix > Documentation.

All documentation files installed with MetaFrame XP are available from the following locations:

* In the DOC directory of your MetaFrame XP CD-ROM

* Installed into the documentation folder of your
  MetaFrame XP server. From the Start Menu, choose 
  Start > Programs > Citrix > Documentation.

* On the Citrix Web site at http://www.citrix.com/support,
  select the Product Documentation tab. You can check the
  Product Documentation area of the Web site at any time for the
  latest updates to Citrix technical manuals. Any updates to this
  manual published after the release of this product will be
  posted there.


PUBLICATIONS ERRATA

MetaFrame XP Administrator’s Guide (pages 57 and 58): In the description (including diagrams) of communication between ICA Clients and Citrix servers, references to a dynamic port number assigned during network communication are not specific to the ICA protocol. The assignment of a dynamic port number is standard TCP behavior.


USAGE NOTES, RESTRICTIONS, AND KNOWN PROBLEMS

This section includes important last-minute notes and tips.
PLEASE READ IT CAREFULLY BEFORE INSTALLING THE PRODUCT.


METAFRAME SERVER REMOVAL: It is possible to remove the MetaFrame XP server containing the data store from a server farm. This action should not be performed under any circumstances. Doing so will render the entire server farm unusable.

CHANGING ZONE MEMBERSHIP: If you move a MetaFrame XP server from one zone to another, you must reboot the server after making the change. Rebooting the server ensures the integrity of data collector information. 

IMA REQUIRES TCP/IP: The MetaFrame IMA service requires TCP/IP. If TCP/IP is uninstalled, the following error is displayed during system boot: The IMA service terminated with service-specific error 2147483656.

NETWARE CLIENT: To use the NetWare Client with MetaFrame XP on Windows NT Server 4.0, Terminal Server Edition, you must install the NetWare Client before installing MetaFrame XP.

RAS SERVICES ON WINDOWS 2000 SERVERS: If you install RAS services on a Windows 2000 server after IMA is running, the IMA service (or the server) must be restarted to allow MetaFrame servers with RAS services to respond to ICA Client broadcasts. 

HOTFIX LISTINGS IN CITRIX MANAGEMENT CONSOLE: Hotfixes applied to a MetaFrame server do not appear in Citrix Management Console until the IMA service is restarted on the server.


Installation

MICROSOFT SQL SERVER USING NT AUTHENTICATION: During MetaFrame XP installation, the Setup program asks you for the user account that the IMA Service will use to access the data store. If you configure the ODBC DSN to use Windows NT authentication to access the SQL Server database, the user account that you enter must have administrator privileges on the machine that MetaFrame XP is being installed on. The user account that you enter must be a domain account that has administrator privileges to all MetaFrame XP servers in the farm. It is not necessary that the user account be an administrator of the SQL Server, but the user account must at least have "public" and "db_owner" permissions to the SQL Server database that you use for the data store. The user account name must be entered in the format "<domain>\<username>".

SIMULTANEOUS INSTALLATION: If you try to install MetaFrame XP on more than one server at the same time, in some cases the installation is suspended because more than one server may become the data collector. 

To avoid this problem:

1. Install the server that you want to be the data collector first.

2. In the Zones tab of the farm's Properties dialog box, set the
   server to be the preferred data collector. For more information,
   refer to Setting data collectors in the online help
   for Citrix Management Console. 

3. Reboot the server and install MetaFrame XP on the other servers. 

INSTALLSHIELD ERROR: When installing Citrix Management Console on NT 4.0 Workstation, if the installation path includes spaces, an error message appears at the end of the installation: "Installation Failed." This error is generated by InstallShield and can be ignored.

DATA STORE ACCESS PORT: When installing MetaFrame using indirect access to the data store, do not change the port number on the Indirect access information page from the default value of 2512.

CHANGING SERVER DRIVE LETTERS: If you intend to change a server’s drive letters, do it during MetaFrame XP installation. If you change server drive letters after MetaFrame XP installation, you must do it before installing any applications.
Certain applications, including Microsoft SQL Server 7.0, can be affected by drive letter reassignment. A Citrix utility (SQLREMAP.EXE) is available for download from http://knowledgebase.citrix.com or ftp://ftp.citrix.com/utilities/. 
If you experience problems with your SQL database(s) after you have reassigned server drive letters for MetaFrame XP, run this utility to solve this problem.

EXPLORER STOPS RESPONDING: If you install MetaFrame XP and add the server to an existing farm, in some cases the server appears to stop responding after the desktop icons are populated, but before the ICA Administrator Toolbar appears. If this happens, use the Task Manager to terminate the Explorer process (Explorer.exe), which fixes the problem and displays the toolbar. You can restart Explorer after the ICA Administrator Toolbar appears.

SWITCHING MODES IN METAFRAME XP: When switching from native mode (IMA-only) to mixed mode (MetaFrame XP and MetaFrame 1.8 servers), run the following command on a server in the farm to confirm that the servers in the farm have properly synchronized their published applications:
  qserver /resetfarm <farmname>


MetaFrame XP and UNIX Integration Services 1.x

If you want to use UNIX Integration Services (UIS) 1.x with MetaFrame XP, you need to use a hotfix for UIS.
Refer to http://www.citrix.com/support for details about the hotfix and installation instructions.


ICA Clients 

PASS-THROUGH CLIENTS: If a user adds an application set with a version 6.0 ICA Client using Program Neighborhood and later reconnects to the same application set using an earlier version of the ICA Client, the application set is not displayed to the user. 

The difference in ICA Client versions can cause a problem for users who display application sets by connecting to Program Neighborhood as a published application (pass-through client). If some servers have version 6.0 ICA Clients using Program Neighborhood and others have earlier client versions, a user might connect to a server and use the version 6.0 ICA Client to add an application set. On another occasion, the user could connect to a server that has the older client, in which the application set added with the version 6.0 ICA Client is not displayed.

To avoid problems with viewing application sets, upgrade all pass-through clients to the version 6.0 ICA Client version (available on the ICA Client CD included with MetaFrame XP).

SHADOWING: If your user is running a version 6.0 ICA Client and you try to shadow that session from an earlier version of an ICA Client, you will see the following error message: Shadow failed. Version 6.0 of the ICA Clients supports only the new ICA display protocol. Earlier versions of the ICA Clients do not support the new ICA display protocol and therefore cannot display the shadowed ICA session generated by version 6.0 ICA Clients.

WINDOWS MULTIPLE MONITOR DISPLAY: If you have configured multiple monitors on your Windows client device and you are running a published application in seamless mode on a secondary monitor, secondary windows for the published application (such as popup menus or dialog boxes) may appear on the desktop of the primary monitor.


CONTACT INFORMATION

Citrix Systems, Inc.
6400 NW 6th Way
Fort Lauderdale, Florida 33309 USA
954-267-3000
http://www.citrix.com

------------------------
document code: rcd1218mfw