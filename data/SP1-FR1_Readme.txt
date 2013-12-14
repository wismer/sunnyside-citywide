Citrix Systems

READ ME
Service Pack 1 and Feature Release 1 
for Citrix MetaFrame XP (tm) 
Application Server for Windows, Version 1.0

August 2001


INTRODUCTION

This document contains last-minute information about Service Pack 1 and Feature Release 1 for MetaFrame XP for Windows.  It contains the following sections:

	Viewing this Document
	Printing this Document
	Where to Find Documentation	
	Known Issues in this Release
	Hotfixes incorporated in Service Pack 1


VIEWING THIS DOCUMENT

When viewing this document in Notepad, if the text does not wrap in the window, choose Edit > Word Wrap on Windows NT or choose Format > Word Wrap on Windows 2000. 


PRINTING THIS DOCUMENT

Before printing from Notepad, adjust the width of the window to fit your printer paper. To print the document, choose File > Print.


WHERE TO FIND DOCUMENTATION

Documentation for MetaFrame XP and advanced management features of MetaFrame XPa and MetaFrame XPe is available in Adobe Portable Document Format (PDF) in the Docs directory of the CD-ROM. 

Use Adobe Acrobat to view PDF files. You can download the free Acrobat Reader program from Adobe's Web site at http://www.adobe.com.

Documentation for NFuse is available in PDF format in the Doc directory on the NFuse CD-ROM.

Information on installing Feature Release 1 or Service Pack 1 using Installation Manager (a component of MetaFrame XPe) is in the Citrix Installation Manager Application Compatibility Guide. The guide is available in English at http://www.citrix.com/support. The Japanese version is available on the Citrix Web site at http://www.citrix.com/support or http://www.citrix.co.jp/support/pdf/.

Documentation for ICA Client software includes a Read Me file in the root directory of the ICA Client CD-ROM and an ICA Client Administrator's Guide for each ICA Client. These guides are in PDF files in the Doc directory on the ICA Client CD-ROM.

Some documentation files are installed on the server with MetaFrame XP. Updates to these documents are installed with Feature Release 1 and Service Pack 1. To display the installed documentation, click the folder icon on the ICA Administrator Toolbar or choose Start > Programs > Citrix > Documentation.

All current documentation is available on the Citrix Web site at http://www.citrix.com/support. Select the Product Documentation tab. Updates to Citrix technical manuals are posted on the Web site.

Caution: Instructions in Known Issues sometimes direct you to use the Registry Editor. Using Registry Editor incorrectly can cause serious problems that can require you to reinstall the operating system. Citrix cannot guarantee that problems resulting from incorrect use of Registry Editor can be solved. Use Registry Editor at your own risk. Make sure you back up the registry before you edit it. If you are running Windows NT, make sure you also update your Emergency Repair Disk.

KNOWN ISSUES IN THIS RELEASE
----------------------------

INSTALLING ON TSE SYSTEMS

On Windows NT, Terminal Server Edition (TSE) systems, you must install Service Pack 6 (SP6) for compatibility with the MetaFrame COM Server (MFCom) service. The Setup program checks for the presence of SP6 when you install Feature Release 1 or Service Pack 1 on TSE systems. If SP6 is not installed, Setup asks if you want to continue without MFCom. If you choose to continue, Setup installs MFCom but does not register the service so it does not start.

If MFCom is not registered, Citrix administrators cannot use the Citrix Web Console. MFCom is required to authenticate Citrix administrators who are not local administrators of the server that hosts the Web console. MFCom might also be required if you use custom applications created with the Citrix Software Development Kit (SDK) that depend on MFCom.

If you install SP6 and want to enable MFCom, run the following command on the TSE system:

MFCom /regserver 

This command registers MFCom as a service, sets it to start automatically, and starts the service.


MIGRATING APPLICATIONS FROM METAFRAME 1.8

If you have a MetaFrame 1.8 server farm and you want to use  mixed mode to migrate to MetaFrame XP, you must follow the instructions in the MetaFrame XP Administrator's Guide about using the identical farm name when you install MetaFrame XP.

If you install MetaFrame XP in mixed mode and create a new server farm, but you enter a farm name that is different from the name of the MetaFrame 1.8 server farm, and then you migrate published applications from the MetaFrame 1.8 server farm to the new server farm, users cannot launch the published applications in the MetaFrame 1.8 server farm. If you try to connect to a published application, a message tells you that the application set data is out of date, and when you click OK, you are connected to the published application in the new server farm.


CLIENT BROWSING FAILS AFTER CHANGE TO NATIVE MODE

ICA Clients might fail to locate published applications in a MetaFrame XP server farm after the farm is in mixed mode (for interoperability with MetaFrame 1.8) and is changed to native mode. This issue occurs only if the Citrix XML Service shares the HTTP port with Internet Information Server (IIS) on MetaFrame XP servers.

If this problem occurs, you can correct it by restarting the IIS Admin Service (IISADMIN) on the MetaFrame XP servers.


USING THE UNIVERSAL PRINT DRIVER WITH POSTSCRIPT PRINTERS

PostScript client printers with constrained memory (typically 2-4 MB of printer memory) can run out of memory when printing full-page graphics. If this happens, the print job spools completely but does not print correctly. The printer may output a diagnostic page or error code.

The Citrix Universal Print Driver renders print jobs as full-page graphics. It sends bitmap data to a client printer driver for printing. PostScript drivers for client printers typically consume more memory than PCL drivers, so out-of-memory errors are more likely on a client printer with a PostScript driver.

The Citrix Universal Print Driver feature minimizes the memory required for printing by sending 300-dpi output to client printers. However, some printer drivers always use a higher resolution, which consumes more memory.

The following workarounds can be used to avoid client printer memory problems with the Citrix Universal driver:

	-- Add more physical memory to the client printer.

	-- Use PCL or other emulations instead of PostScript for the client printer.

	-- Install and use a native printer driver on the MetaFrame server for client printing.


EXTENDED CHARACTERS WITH MULTI-BYTE SQL SERVER

Problems with some data not being written to the server farm's data store can arise with the following configuration:

	-- The MetaFrame XP server environment contains extended characters in the domain name, server name, or zone name

	-- A multi-byte version of Microsoft SQL Server (such as Japanese, Korean, or Chinese language) is used for the server farm's data store.

With this configuration, it is important to deselect the option "Perform translation for character data" when you configure the DSN for SQL Server. If you are not sure if the environment contains extended characters, Citrix recommends that you deselect the option.

If you use the Japanese version of MetaFrame XP with a multi-byte SQL Server, the farm operates correctly when the "Perform translation for character data" option is selected.


USING CITRIX WEB CONSOLE

Citrix Web Console uses an authentication method that is different than the method that Citrix Management Console uses. Citrix administrators can access the Citrix Web Console only if the console can authenticate their user credentials.

The Web console can authenticate local users of the server that hosts the Web console. After authenticating a local user account, the console uses the MFCom service to verify Citrix administrator privileges. Citrix administrators cannot log on to the Web console by using local user accounts on other servers, NDS user accounts, or Windows domain accounts in domains other than the Web console's domain and domains trusted by the domain of the Web console server. 

Citrix administrators who cannot log on to the Citrix Management Console can use the Citrix Web Console to perform all monitoring and management tasks for MetaFrame XP server farms.

When you click Logoff for the first time in the Web console, a message asks for permission to download and install an ActiveX control from Citrix Systems. This control clears the authentication cache on the system, so that choosing Refresh does not log on to the Web console again with cached user credentials. The ActiveX control needs to be downloaded only once on a client system that you use to connect to Citrix Web Console.

If you click "No" when the download message appears, an error message states "The object does not support the property or method."


ALTERNATIVE USER INPUT AND METAFRAME SERVERS

To avoid getting errors, disable the Alternative User Input when you install Microsoft Office XP on a MetaFrame server. Alternative User Input provides handwriting recognition and microphone dictation functions. The MetaFrame environment does not currently support these functions.



JOINING SERVER FARMS

A server that has Service Pack 1 installed cannot join a server farm in which the direct server (the server that connects directly to the data store) does not have SP1 installed. Do not use the Chfarm command to move a server that has SP1 installed unless the direct server in the target farm already has SP1 installed.


FEATURE RELEASE LEVEL

A MetaFrame Feature Release 1 server will lose its Feature Release level if you run the CHFARM (Change Farm) command. To correct this, reset the Feature Release level after the server is joined to a new farm.


CPU PRIORITY

Even though you are able to set a CPU priority for a published desktop, MetaFrame XP Feature Release 1 does not adhere to your settings; therefore, the published desktop and all processes that start in the session run at their default CPU priority status. 


SERVER AND DATA STORE CONNECTIVITY

If a MetaFrame XP 1.0 server and the data store lose connectivity before at least one ICA session is connected to the MetaFrame XP 1.0 server, the server cannot process any ICA connection requests and returns a "system has reached its licensed logon limit" error. To correct this problem, restore connectivity between the MetaFrame XP 1.0 server and the data store. To prevent this problem from occurring, make sure that at least one ICA connection has been made to each MetaFrame XP 1.0 server when data store connectivity is available.


MIGRATION TO ORACLE VERSION 8.1.7

If you use DSMAINT to migrate from an Access database to Oracle 8.1.7 for the server farm's data store, the IMA service fails to start because the Oracle 8.1.7.0 driver alters the logon authentication method.

The Oracle 8.1.7.0 driver installs a security feature named NTS, which uses Windows NT credentials to authenticate to the Oracle server. The IMA service is configured to use the System account to access the data store and IMA fails to connect to the Oracle server with the NTS feature. If this happens, IMA reports error code 2147483649.

To avoid this problem if you migrate from Access to Oracle 8.1.7, disable the Oracle NTS feature using the Net8 Assistant.

1. Run the Net8 Assistant, navigate to Net8 Configuration\Local\Profile and select Oracle Advanced Security.
2. Select the Authentication tab.
3. Remove NTS from the Selected Methods list.


ADDITIONAL PROCESSES FOR FARM SERVERS CONNECTED TO THE ORACLE DATABASE

If you are using an Oracle server in dedicated mode, plan to add one additional process for each farm server connected directly to the Oracle database. For example, if your Oracle server is currently using 100 processes and you want to create a 50-server farm, set your processes value to at least 150 (100 current, plus 50 additional). To do this, set the processes value in the INIT.ORA file on the Oracle server. If necessary, consult your Oracle documentation for more information.


MOVING DATA COLLECTORS TO A NEW ZONE

If you want to move a data collector into a different zone you must first designate another server as a data collector and set its election preference to "Most Preferred." Then, prior to moving the original data collector, set its election preference to "Default Preference" or "Not Preferred." Use the QUERY FARM command to make sure the election preference on the original server has changed. If the election preference has changed, it is safe to move the original data collector to the new zone.


INABILITY TO START IMA SERVICE

If upon rebooting, the IMA service fails to start and you get an "IMA Service Failed" message with error code 2147483649, it may mean that the temp directory is missing for the local system account. To verify that this is the problem, change the IMA Service startup account to the local administrator. If the IMA service starts under the local administrator's account, the missing temp directory is the issue. 

To correct the problem, switch the service back to the local system account and manually create the temp directory %systemroot%\temp. Verify that both the TMP and TEMP environment variables point to this directory. For more information, see Microsoft article Q251254 found at http://support.microsoft.com/support/kb/articles/Q251/2/54.ASP.



LOGON FAILURE AFTER UNINSTALLING NOVELL CLIENT

Logon to a MetaFrame XP server can fail if you uninstall the Novell client from the server after MetaFrame XP is installed. Uninstalling the Novell client might remove the setting for the logon interface (GINA) from the registry. It might be necessary to add the proper settings to the registry after removing the Novell client. The following registry key contains the GINA values:

HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon

The values for MetaFrame logon without the Novell client are:

	GinaDLL	Data: Ctxgina.dll
	CtxGinaDLL	Data: Msgina.dll


LONG NDS DISTINGUISHED NAMES

When NDS distinguished names are longer than 20 characters, logons can fail because NDS does not create a Dynamic Local User (DLU) account under a stress situation. 

A distinguished name is the full path of the user (the context plus the username with a leading period, such as .BobR.FTL.Engineering.Citrix). 

With distinguished names over 20 characters, the Novell Workstation Manager sometimes will not create a Dynamic Local User, causing the logon to fail.

Program Neighborhood, Program Neighborhood Agent, and NFuse ICA Clients use distinguished names to log on users and create DLUs. 

This problem is evident when the Novell Workstation Manager is under stress. This is an open issue with Novell; the Case number is 2633549.

The workaround for this issue is to make an aliased object for all users and place the aliases in a container, and make sure that the username plus the context does not exceed 20 characters. In Program Neighborhood and the Program Neighborhood Agent, users log on as the users in the aliased container. For NFuse, specify the container of the aliased objects in the SearchContext field in the Nfuse.conf file so that it is searched first.

With this setup, users need to remember only one context, such as .BobR.alias.

In addition, logons fail if auto logon credentials received from the ICA Client are longer than 48 characters. You cannot use auto logon with an NDS user name that is longer than 48 characters because the Novell client does not support longer names.

USE A FULL UNC PATH TO PUBLISH NDS APPLICATIONS LOCATED ON NETWARE METAFRAME SERVERS

Citrix Management Console cannot list MetaFrame servers with NetWare Client installed. You can't use the Browse button to access NetWare servers when specifying a command line or icon location within the Application Publishing Wizard. To publish a Novell Directory Service (NDS) application residing on a NetWare server:  

1. Use Citrix Management Console. From the Actions menu, choose New > Published Application. 

2. Follow the instructions in the Application Publishing Wizard up to the Specify What to Publish (Cont.) dialog box. Don't use the browse button. 

3. Type the Universal Naming Convention (UNC) path to an NDS application in the Command Line box. UNC allows computers on a network to be referred to by name. For example: The NDS tree, MYNDSTREE, contains organization object MYORG, which contains NetWare volume NW50_SYS. The executable path on NW50_SYS is \APPS\OFFICE\WINWORD.EXE. The full UNC path to WINWORD.EXE is \\MYNDSTREE\MYORG\NW50_SYS\APPS\OFFICE\WINWORD.EXE. The Working Directory box can be blank.

4. In the Program Neighborhood Settings dialog box, default icons display instead of the executable's icon. The wizard can't access the executable given in the Command Line box. To use the icon from the specified executable, extract the icon from the executable using an icon extraction utility and give it an .ico extension or use the whole executable. Place either on any MetaFrame server without NetWare client. Use the Change Icon button to browse for the .ico file or executable on the MetaFrame server and select it. This icon is associated with the true application path although it comes from another source.

NOVELL LOGON DISPLAY

When the Novell client is installed on a Terminal Server Edition (TSE) system and a user connects to the server, the logon dialog box has graphical anomalies, including labels extending off the tabs. The problem results from a Windows display issue at all color depth and display size settings. The issue also affects the Microsoft RDP client.

The problem does not occur on Windows 2000 systems and it does not affect ICA sessions after the initial logon.


NDS PREFERRED TREE AND FARM AUTHENTICATION

If you designate an NDS Preferred Tree but none of the servers are MetaFrame XP Feature Release 1-enabled, the farm authentication prompts the client for NDS credentials but does not accept them. To correct the problem, set the Feature Release level to Feature Release 1 on at least one sever, remove the NDS tree name in the NDS Preferred Tree field (Farm Properties --> MetaFrame Settings), and reset the Feature Release level to "NONE." 


NDS CREDENTIALS AND SESSION SHARING

The "session sharing" feature is not currently supported for custom ICA connections that are configured with NDS user credentials (under Properties->Login Information). To use the session sharing feature for Custom ICA Connections, do not specify user credentials in the Login Information tab for a connection.


NOVELL AND WINDOWS AUTHENTICATION

If you connect, by dial-up ICA, to a MetaFrame XP Feature Release 1 server that has a Novell Intranetware Client installed, the server returns the Microsoft logon dialog box instead of the Novell logon dialog box. This occurs because the "Use Default NT Authentication" option (under Advanced Connection Settings) is selected, by default, on Windows 2000 servers. 

If you want to use Novell authentication on a server under these circumstances, deselect the "Use Default NT Authentication" option. Refer to the online help for Citrix Connection Configuration for more information.

If a Windows 2000 server without Service Pack 2 is set up to use the default Windows NT authentication (under Advanced Connection Settings in the Citrix Connection Configuration) and you installed a third-party authentication software such as Novell Intranetware Client, the third-party logon dialog box appears instead of the default Windows logon dialog box.

Installing Windows 2000 server with Service Pack 2 resolves the problem.


FAILURE TO LIST DOMAINS AFTER SERVER REMOVAL

If some servers have Feature Release 1 installed and some do not, and you remove a server from the farm by using the Remove Server from Farm command, domains can fail to appear in Citrix Management Console when you try to select users for published applications, Citrix administrators, or allocation of network printers.

This issue occurs only if all of the following are true:
	-- NDS is enabled in the server farm.
	-- The server you remove is the only server that has Feature Release 1 and the Novell Intranetware Client installed.
	-- You use the Remove Server from Farm command with Citrix Management Console connected to a MetaFrame XP server that does not have Feature Release 1 installed.

To avoid this issue, always uninstall MetaFrame XP to remove a server from the server farm; do not try to remove the server using the Remove Server from Farm command.

If you must use the Remove Server from Farm command to remove a server that has Feature Release 1 installed, be sure to connect Citrix Management Console to a server that has Feature Release 1 installed.

If domains fail to appear in Citrix Management Console because of this issue, do the following to fix the problem: 

Delete the text in the NDS Preferred Tree box on the Properties sheet for the server farm. Removing the NDS Preferred Tree name disables NDS in the server farm and restores regular domain enumeration.


SERVER TRAP -- INSTALLATION MANAGER 2.0 AND RESOURCE MANAGER 2.0

If you encounter a server trap at the end of an Installation Manager or Resource Manager install, refer to Knowledge Base article CTX328428 found on www.citrix.com under "Support." This knowledge base document addresses a server trap that can occur while installing  IM 2.0 or  RM 2.0 on an XPe 1.0 server that has not been upgraded to Feature Release 1, but is part of a server farm that has been upgraded to Feature Release 1.




SHADOW TASK BAR

When you view published applications in the Shadow Task Bar, a server name does not appear under a published application if the server name and the application name are the same.

SHADOWING A USER WITH A DIFFERENT KEYBOARD LAYOUT

Shadowing a user with a different keyboard layout can produce unexpected results. It is possible that a character would be echoed within the shadowed session that is different from the key that was pressed. Instances where this could occur include a person with a 101-key keyboard shadowing a person with a 106-key keyboard, or a person in one input locale shadowing a user in a different input locale.

ANONYMOUS USERS

Anonymous users may be able to open another session of a published application even if you have configured the application to allow only one instance per user. An anonymous user can circumvent the "one instance/one user" configuration by starting the application in a new session. This occurs because the new session runs under a different anonymous user account on the server.


JAVA RUNTIME ENVIRONMENT

The installer places essential files for the Java-based Citrix Management Console in a directory with the Java Runtime Environment (JRE). If you upgrade the JRE and then launch the console, the console files are not found and the console fails to start. You can use the following parameter to specify the location of the console files:

-Djava.ext.dirs=<directory>

where <directory> is the correct extensions directory (typically Program Files\JavaSoft\JRE\1.3\lib\ext). You must enclose the path in quotes if it contains spaces. 

Add this parameter to the shortcut for the Citrix Management Console so it is used when you launch the console from the button on the Citrix Administrator Toolbar. For a default installation, the Citrix Management Console shortcut icon is at %systemroot%\program files\citrix\administration. Right-click the icon and choose Properties. On the Shortcut tab, type a space after the text in the Target box and then type the parameter. Click OK to apply the new setting and close the dialog box.

You can also use the directory parameter to launch the console from a command prompt. For example, use the following command to launch the console and specify the default location for the console files. Run this command from \program files\citrix\administration:

java -Djava.ext.dir="c:\Program Files\JavaSoft\JRE\1.3\lib\ext" -jar tool.jar


RUNNING CITRIX MANAGEMENT CONSOLE AFTER NETSCAPE INSTALLATION

The Citrix Management Console does not run if you try to launch it after you install Netscape 6.01 or 6.1 because installing Netscape changes the Java configuration. If this occurs, the console closes and displays the following message:


JAVA VIRTUAL MACHINE LAUNCHER
-Could not find main class. Program will exit.

To resolve this issue, run the utility Nscpfix.exe from Windows Explorer, the command prompt, or the Run dialog box. Nscpfix.exe is on the MetaFrame XP Feature Release 1 CD. The path is \W2K or \TSE (select the appropriate directory for your system) \support\debug\i386\nscpfix.exe.


MATROX MILLENNIUM DUAL HEAD G450 GRAPHICS ADAPTER

Refreshing of the display causes anomalies in Citrix Management Console running on an IBM Intellistation with the Millennium G450 graphics adapter. With this configuration, sections of the console interface can appear blank. For example, when you browse for an application to publish, the scrollable area of the dialog box becomes unreadable.


SESSION INFORMATION WITH SSL ENCRYPTION

When the ICA client uses the Citrix SSL Relay for encryption of an ICA session, Citrix Management Console displays the session encryption level incorrectly as "Basic encryption;" it should be "Basic SSL Secured, 128 bit."


IMA SERVICE AND SERVERS THAT DO NOT HAVE SERVICE PACK 2

If you are using a server that does not have Service Pack 2, install the Microsoft Q273772 hotfix. Not installing this hotfix results in memory leaks by the IMA service. 


ATI RAGE PRO IIC DISPLAY ADAPTER

Performance can be very slow in an ICA session with this adapter using display driver version 4.11.2650 and the ICA Win32 Client on Windows 98. 


NETWORK PRINTER NAMES

Changing the share name of a printer installed on a MetaFrame XP server deletes all user names entered in the auto-creation list for the printer in Citrix Management Console.


EXTENDED CHARACTERS IN ZONE NAMES

If the name of a zone contains extended characters, the IMA service fails to start after installation of Feature Release 1 or Service Pack 1. To avoid this issue, change zone names to remove extended characters before you install the feature release or service pack.


MFCOM SERVICE TIMEOUT

MetaFrame COM Server (MFCOM) is a service that starts when a MetaFrame XP server starts up. The IMA service must be running for MFCOM to start. If a "Service failed to start" message appears when you restart a server, check the Event Log (TSE) or the System Log (Windows 2000 Server). 

If the messages "IMA service hung on starting" and "MFCOM service failed to start" are in the log, IMA service did not start within three minutes, the default timeout period for the MFCOM service.

Timeout of the MFCOM service at startup is not a problem, because MFCOM will start later if it is needed. 

To prevent MFCOM from timing out, edit the following registry key, which sets the amount of time that MFCOM waits for the IMA service to start: 

   HKLM\SYSTEM\CurrentControlSet\Services\MFCom\IMAWaitTimeout

Set the value to 1,200,000 milliseconds (20 minutes) or higher.

The following registry key controls the time MFCOM waits before polling the IMA service for its status:
   
   HKLM\SYSTEM\CurrentControlSet\Services\MFCom\IMAWaitPause 

The default value is 30,000 milliseconds (30 seconds), which works well in most cases.


SHORTCUTS FOR APPLICATIONS WITH LONG PATH NAMES 

If the path name of a published application exceeds 256 characters, shortcuts to the published application do not appear in the Start menu or on the desktop of client devices (if these options are selected when publishing the application). Instead, the shortcuts appear in a folder named "Application Errors." The folder appears in the specified shortcut location. For example, if you select the option to place a shortcut on the desktop, the Application Errors folder appears on the desktop. The folder contains a shortcut icon with the application name truncated.

To avoid this issue, make the application name and path no longer than 256 characters for each published application.


CONCURRENT CONNECTION LIMITS

The MetaFrame XP Feature Release 1 Administrator's Guide contains an incorrect reference to "Citrix administrators" under "Limiting Total Connections in a Server Farm," (Chapter 11). The documentation for the Connection Control feature states that you can exempt Citrix administrators from a connection limit that you set in a server farm. In fact, you can exempt members of the local Administrator's group, not Citrix administrators, from Connection Control limits. The option "Enforce limits on administrators" refers to members of the local Administrators group, not Citrix administrators. This option is on the MetaFrame Settings tab in the server farm's Properties dialog box.

The corrected statement is:

"You can apply the concurrent connections limit to all users including members of the local administrator group," or you can exempt administrators from the limit. By default, members of the local administrator group are exempt from the limit so they can establish as many connections as necessary, including connections for shadowing sessions."


ADDING RE-IMAGED SERVERS TO SERVER FARMS

If a MetaFrame XP server is a member of a server farm, and you do not remove the server from the server farm before you apply a system image to create a new MetaFrame XP server on the same machine, you can experience performance problems and find invalid data displayed in the Citrix Management Console if you then add the server back to the same server farm. This issue arises because the old server's host record in the data store is applied to the newly imaged server.

If you are going to re-image a server, first remove the server from the server farm by uninstalling MetaFrame XP, then apply the system image and add the server to the server farm. 

IMA SERVICE FAILS TO START WHEN A SQL SERVER DATA STORE IS CORRUPTED BY A NON_ENGLISH CODE PAGE

If you use a non-English code page in a SQL Server data store with the English version of MetaFrame XP, a SQL Server data store can become corrupted. The IMA Service can not start if this happens. 

This problem can occur during installation of MetaFrame XP. Installing MetaFrame XP Feature Release 1 prevents new SQL Server data store corruption, but if the SQL Server data store got corrupted prior to installing Feature Release 1, it must be fixed. Use the ctxsqlfix Utility to recreate the data store and the local host caches on all the MetaFrame servers in the server farm. Ctxsqlfix.exe is on the MetaFrame XP Feature Release 1 CD. The path is \W2K or \TSE (select the appropriate directory for your system) \support\debug\i386\ctxsqlfix.exe. Any information in the data store is lost when this database is recreated.

To fix a SQL Server data store corrupted by a non-English code page:

1. Find a MetaFrame XP server in the server farm that has a direct connection to the corrupt data store: 
On a MetaFrame XP server, look in the registry key, HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\Ima. If the PSServer value is empty, the server has a direct database connection. If the value is not empty, the MetaFrame server does not have a direct database connection.

2. On one MetaFrame XP server with a direct connection to the data store, run:

 	ctxsqlfix first_server

from Windows Explorer, the command prompt, or the Run dialog box. Type capital "Y" (without the quotation marks) when asked if you want to continue. Ctxsqlfix recreates the SQL Server data store, the local host cache on the MetaFrame XP server, and starts IMA Service on the first server.   
 
3. On each of the other MetaFrame servers in the server farm run:

	ctxsqlfix non_first_server

from Windows Explorer, the command prompt, or the Run dialog box. Ctxsqlfix recreates the local host cache and starts IMA Service on the server where it is run.

4. Use the Citrix Management Console to add any information lost in the recreation of the data store for the server farm. Examples are licenses, zones setup, administrator accounts, and published applications. 

HOTFIXES INCORPORATED IN SERVICE PACK 1
---------------------------------------

This service pack includes all hotfixes that were previously released separately, and additional patches that have not been previously released. Many hotfix releases are cumulative; that is, they include fixes contained in prior hotfix releases. Issues addressed by hotfixes are listed here once, under the number of the hotfix in which they were first resolved.


HOTFIXES FOR WINDOWS 2000 SERVERS

Hotfix XE100W001
1. An incorrect error code was returned by the WFShadowSession call.

2. The customer virtual channel lost packets when the packets were being received every 0.5 seconds. The problem occurred when WFVirtualChannelRead timeout was INFINITE or 10 ms.

Hotfix XE100W002
Disabling (or deleting) all Citrix ICA client devices caused the server to trap.

Hotfix XE100W003
The Imauserss.dll trapped when the Application Publishing SDK was installed.

Hotfix XE100W004
The IMA service would hang when Resource Manager was installed.

Hotfix XE100W005
1. Invalid data was returned from the IMA_WaitGenericIMAEventQueue. The incorrect data size parameter was returned by the fixed module.

2. MFCOM was not able to receive the "server added to farm" event.

Hotfix XE100W006
The user list became corrupted when a user was removed from an application user list. The problem occurred only when the user was removed while using the MFCOM and Application Publishing SDK.

Hotfix XE100W007
When using a non-English code page in an SQL database, the IMA service failed to start due to corruption in the database. After applying the hotfix, follow the steps below for one of the servers that has a direct database connection in your farm. (If the PSServer value is empty in the registry key, HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\Ima, it is a MetaFrame with a direct database connection. If the value is not empty, it is a MetaFrame server without a direct database connection.)

A. Delete the corrupt SQL database and create a new one. Give the new database the same name as the old one.

B. Go to the following registry key:
   HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\IMA\Data
    Give the logon user name full control permission to the Security key.

C. At a command prompt, type:
    cd %SystemRoot%\System32\Citrix\ima
    From the directory, type:
    init_sql_db.exe 
    Launch the executable from the console. You will get the message:
   "The sql db has been initialized successfully."

D. Recreate the local host cache. Give the new cache the same name as the old one.

E. Go to the following registry key:
   HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\IMA\RunTime\PsRequired
   Change the value to 1.

F. Restart imaservice.

G. When the service starts, from the %SystemRoot%\System32\citrix\ima directory, type "clicense read_db" (without the quotation marks).

H. Return to HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\IMA\Data and remove full control permission for the logon user name from the Security key.

I. Stop and restart imaservice.

Follow the steps below for all other MetaFrame servers in your farm.

A. Make sure the imaservice is stopped. Recreate the local host cache. Give the new cache the same name as the old one.

B. Go to the following registry key:
   HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\IMA\RunTime\PsRequired
   Change the value to 1.

C. Restart imaservice.

D. Stop and restart imaservice.

Hotfix XE100W008
If a new Java Runtime Environment (JRE) (such as Netscape 6) was installed after the Citrix CMC was installed, the new JRE was installed in a new path and the registry was updated to reflect the new path, but the CMC extensions were not copied to the new path. This hotfix copies the CMC extensions from the old JRE install path to the new install path.

See known issues under "CITRIX MANAGEMENT CONSOLE DOES NOT RUN AFTER NETSCAPE IS INSTALLED", for action to take when Netscape is installed.

Hotfix XE100W009
Adds support for Citrix Server SDK 2.0 on MetaFrame XP 1.0.

Hotfix XE100W010
Version 1.0 of German MetaFrame XP had a security vulnerability at %SystemRoot%\SSLRelay\Keystore. Users were able to browse into that directory and view the certificates inside.

Hotfix XE100W011
1. Invalid data was returned from the IMA_WaitGenericIMAEventQueue. The incorrect data size parameter was returned by the fixed module.

2. MFCOM was not able to receive the "server added to farm" event.

3. Incorrect data was sent from the IMARpc client to the IMARpc server when an event queue was created.

Hotfix XE100W012
1. Long CMC passwords crashed Imasrv.exe.
   NOTE: Passwords must not exceed IMA's maximum password length of 63 characters.
 
2. CMC passwords starting with the letter "S" did not work.

Hotfix XE100W013
1. Invalid data was returned from the IMA_WaitGenericIMAEventQueue. The incorrect data size parameter was returned by the fixed module.

2. MFCOM was not able to receive the "server added to farm" event.

3. Incorrect data was sent from the IMARpc client to the IMARpc server when an event queue was created.

4. Events subscribed using MFCOM and Application Publishing SDK event APIs were not removed from the dynamic store when the events were unsubscribed.

Hotfix XE100W014
1. Adds support for Citrix Server SDK 2.0 on MetaFrame XP 1.0.

2. Events generated on remote servers were not received by the MFCOM SDK's events example. Events affected were adding or removing a server from a farm.

3. The AppID key for MFCOM was not removed when MFCOM was unregistered.

Hotfix XE100W015
1. Using a farm connection, published applications could not be launched. The session on the server remained in a "ConQ" state.

2. When tracing was enabled for IMA PN, the IMA Service could not be stopped.

3. When switching to interoperability mode, refreshing Program Neighborhood did not return any apps.

4. The IMA service would hang when Resource Manager was installed.

Hotfix XE100W016
Native print driver replication failed on a MetaFrame XP server if the server drives were remapped.

Hotfix XE100W017
Printer driver replication failed for certain printer drivers; for example, the HP LaserJet 4000 PCL 5e.

Hotfix XE100W019
The Lotus Notes Version 5.06 client could not read or write to a file from an ICA mapped client drive.


HOTFIXES FOR WINDOWS NT 4.0 SERVER, TERMINAL SERVER EDITION

Hotfix XE100T001
1. An incorrect error code was returned by the WFShadowSession call.

2. The customer virtual channel lost packets when the packets were being received every 0.5 seconds. The problem occurred when WFVirtualChannelRead timeout was INFINITE or 10 ms.

Hotfix XE100T002
Disabling (or deleting) all Citrix ICA client devices caused the server to trap.

Hotfix XE100T003
The Imauserss.dll trapped when the Application Publishing SDK was installed.

Hotfix XE100T004
The IMA service would hang when Resource Manager was installed.


Hotfix XE100T005
1. Invalid data was returned from the IMA_WaitGenericIMAEventQueue. The incorrect data size parameter was returned by the fixed module.

2. MFCOM was not able to receive the "server added to farm" event.

Hotfix XE100T006
1. Long CMC passwords would crash Imasrv.exe.


2. CMC passwords beginning with the letter "S" did not work.

Hotfix XE100T007
The user list became corrupted when a user was removed from an application user list. The problem occurred only when the user was removed while using the MFCOM and Application Publishing SDK.

Hotfix XE100T008
When using a non-English code page in an SQL database, the IMA service failed to start due to corruption in the database. After applying the hotfix, follow the steps below for one machine in your farm.

A. Recreate the SQL database. Give the new database the same name as the old one.

B. Go to the following registry key:

   HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\IMA\Data

   Give the logon user name full control permission to the Security key.

C. Put Init_sql_db.exe in the %SystemRoot%\System32\Citrix\ima directory and launch it from the console. You will get the message:

   "The sql db has been initialized successfully."

D. Recreate the local host cache. Give the new cache the same name as the old one.

E. Go to the following registry key:

   HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\IMA\RunTime\PsRequired

   Change the value to 1.

F. Put Imasql.dll in the %SystemRoot%\System32\citrix\ima directory. Restart the IMA service.

G. When the service starts, from the %SystemRoot%\System32\citrix\ima directory, type "clicense read_db" (without the quotation marks).

H. Return to HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\IMA\Data and remove full control permission for the logon user name from the Security key.

Repeat Steps D, E, and F for additional machines.

Hotfix XE100T009
If a new Java Runtime Environment (JRE) (such as Netscape 6) was installed after the Citrix CMC was installed, the new JRE was installed in a new path and the registry was updated to reflect the new path, but the CMC extensions were not copied to the new path. This hotfix copies the CMC extensions from the old JRE install path to the new install path.

See known issues under "CITRIX MANAGEMENT CONSOLE DOES NOT RUN AFTER NETSCAPE IS INSTALLED", for action to take when Netscape is installed.

Hotfix XE100T010
Adds support for Citrix Server SDK 2.0 on MetaFrame XP 1.0.

Hotfix XE100T011
Version 1.0 of German MetaFrame XP had a security vulnerability at %SystemRoot%\SSLRelay\Keystore. Users were able to browse into that directory and view the certificates inside.

Hotfix XE100T012
1. Invalid data was returned from the IMA_WaitGenericIMAEventQueue. The incorrect data size parameter was returned by the fixed module.

2. MFCOM was not able to receive the "server added to farm" event.

3. Incorrect data was sent from the IMARpc client to the IMARpc server when an event queue was created.

Hotfix XE100T013
1. Invalid data was returned from the IMA_WaitGenericIMAEventQueue. The incorrect data size parameter was returned by the fixed module.

2. MFCOM was not able to receive the "server added to farm" event.

3. Incorrect data was sent from the IMARpc client to the IMARpc server when an event queue was created.

4. Events subscribed using MFCOM and Application Publishing SDK event APIs were not removed from the dynamic store when the events were unsubscribed.


Hotfix XE100T014
1. Adds support for Citrix Server SDK 2.0 on MetaFrame XP 1.0.

2. Events generated on remote servers were not received by the MFCOM SDK's events example. Events affected were adding or removing a server from a farm.

3. The AppID key for MFCOM was not removed when MFCOM was unregistered.

Hotfix XE100T016
Native print driver replication failed on a MetaFrame XP server if the server drives were remapped.

Hotfix XE100T017
Printer driver replication failed for certain printer drivers; for example, the HP LaserJet 4000 PCL 5e.

Hotfix XE100T019
The Lotus Notes Version 5.06 client could not read or write to a file from an ICA mapped client drive.

Hotfix XE100T021
1. Using a farm connection, published applications could not be launched. The session on the server remained in a "ConnQ" state.

2. When tracing was enabled for IMA PN, the IMA Service could not be stopped.

3. In a four day connect/disconnect stress test with tracing turning on, the handle count of IMA Service went from 400 to 1400. There were approximately 1000 thread handles but only 50 active threads.

4. When switching to interoperability mode, applications did not appear after a Program Neighborhood refresh.


-------------------
CONTACT INFORMATION

Citrix Systems, Inc.
6400 NW 6th Way
Fort Lauderdale, Florida 33309 USA
954-267-3000
http://www.citrix.com

------------------------
document code: rcd0913dh

