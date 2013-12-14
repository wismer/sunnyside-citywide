Citrix Systems, Inc.

READ ME
Service Pack 2 and Feature Release 2
for Citrix MetaFrame XP (tm) 
Application Server for Windows, Version 1.0

May 2002


INTRODUCTION

This document contains last-minute information about Service Pack 2 and Feature 
Release 2 for MetaFrame XP for Windows.  It contains the following sections:

   Viewing or Printing this Document
   Where to Find Documentation   
   Known Issues in this Release
   Hotfixes Incorporated in Service Pack 2
   Hotfixes Incorporated in Service Pack 1 (installed with Service Pack 2)


VIEWING OR PRINTING THIS DOCUMENT

When viewing this document in Notepad, if the text does not wrap in the window, 
choose Edit > Word Wrap on Windows NT or choose Format > Word Wrap on Windows 
2000. 

Before printing from Notepad, you may have to adjust the width of the window to 
fit your printer paper. To print the document, choose File > Print.


WHERE TO FIND DOCUMENTATION

Documentation for MetaFrame XP and advanced management features of MetaFrame XPa 
and MetaFrame XPe is available in Adobe Portable Document Format (PDF) in the 
Docs directory of the MetaFrame Server CD-ROM. 

Use Adobe Acrobat to view PDF files. You can download the free Acrobat Reader 
program from Adobe's Web site at http://www.adobe.com.

Documentation for NFuse Classic, Enterprise Services for NFuse and Citrix Secure 
Gateway is available in PDF format on the MetaFrame XP Components CD-ROM.
 
Documentation for ICA Client software includes a Read Me file in the root 
directory of the Components CD-ROM and an ICA Client Administrator's Guide for 
each ICA Client. These guides are in PDF files in the ICAClientDoc directory on 
the Components CD-ROM.

Information about installing Feature Release 2 or Service Pack 2 using 
Installation Manager (a component of MetaFrame XPe) is in the Citrix 
Installation Manager Application Compatibility Guide. The guide is available in 
English at http://www.citrix.com/support. The Japanese version is available on 
the Citrix Web site at http://www.citrix.com/support or 
http://www.citrix.co.jp/support/pdf/.

Some documentation files are installed on the server with MetaFrame XP. Updates 
to these documents are installed with Feature Release 2 and Service Pack 2. To 
display the installed documentation, click the folder icon on the ICA 
Administrator Toolbar or choose Start > Programs > Citrix > Documentation.

All current documentation is available on the Citrix Web site at 
http://www.citrix.com/support. Select Product Documentation. Updates to 
Citrix technical manuals are posted on the Web site.

CAUTION: Instructions in Known Issues sometimes direct you to use the Registry 
Editor. Using Registry Editor incorrectly can cause serious problems that can 
require you to reinstall the operating system. Citrix cannot guarantee that 
problems resulting from incorrect use of Registry Editor can be solved. Use 
Registry Editor at your own risk. Make sure you back up the registry before you 
edit it. If you are running Windows NT, make sure you also update your Emergency 
Repair Disk.


KNOWN ISSUES IN THIS RELEASE
----------------------------

********************************************************************************
                                   CAUTION
********************************************************************************

Windows 2000 Server operating systems include Version 1.1 of the Windows 
Installer Service by default. Citrix recommends that you install Windows 
Installer Version 2.0 or later on the server before you install MetaFrame XP. 
See the MetaFrame XP Administrator’s Guide for important details.

KNOWN ISSUES WHEN INSTALLING METAFRAME WITH WINDOWS INSTALLER VERSION 1.1

The following issues can occur if you attempt to install MetaFrame XP or upgrade 
to Feature Release 2 on servers running Version 1.1 of Windows Installer:

1.   The installation process can hang the server and require that you reinstall 
     the server's operating system.

2.   If you are able to successfully install MetaFrame or upgrade to Feature 
     Release 2 on a Windows 2000 server running Version 1.1 of Windows 
     Installer, you cannot later uninstall MetaFrame XP or Feature Release 2 in 
     the recommended manner (using Add/Remove Programs in Control Panel). You 
     must force the removal of MetaFrame. To force the removal of MetaFrame XP 
     or Feature Release 2 and create a log file, type the following at a command 
     line:

     msiexec /x MFXP001.msi /l*v %SystemDrive%:\output.log 
     CTX_IGNORE_MSI_CHECK="YES"

3.   If you enable Windows Installer logging in Windows Installer Version 1.1 
     (included by default with the Windows 2000 operating system), passwords are 
     saved in the log file in unencrypted plain text. Check the documentation 
     included with later versions of Windows Installer for support of encrypted 
     passwords in log files. 

4.   If you successfully install MetaFrame XP, Feature Release 2 on a server 
     running Version 1.1 of Windows Installer, you cannot log on to the server 
     as a domain user. If you attempt to log on to the MetaFrame server as a
     domain user, you may repeatedly receive an error message stating that you 
     should be an administrator of the machine to install the product. 

******************************************************************************** 

INSTALLING AND UNINSTALLING METAFRAME XP FEATURE RELEASE 2 ON A MICROSOFT 
DATACENTER SERVER

You must remove the /3GB switch in the boot.ini file and reboot the server 
before you install or uninstall MetaFrame on a Microsoft DataCenter server. 
After you reboot the server you can install or uninstall MetaFrame. When you are 
done installing or uninstalling MetaFrame, you can add the /3GB switch back to 
the boot.ini file.


SETUP PROMPTS FOR METAFRAME CD AFTER RUNNING THE ICA CLIENT DISTRIBUTION WIZARD

If you run the ICA Client Distribution wizard at the end of MetaFrame XP Setup 
and you remove the Component CD from the server's CD-ROM drive, you are prompted 
to reinsert the MetaFrame XP CD. Reinsert the MetaFrame XP CD when prompted.

If you click Continue or Cancel on the message prompting you to reinsert the 
MetaFrame XP CD, an application error may occur. This error can be ignored 
because Setup is successful, but you must manually restart the server.


LIMITATIONS ON CERTIFICATE CHAIN LENGTH FOR SSL RELAY
   
If you are using SSL Relay and have intermediate certificates between your 
server certificate and root certificate, make sure that there are no more than 
seven intermediate certificates in the certificate chain. The Win32 client only 
supports connections that use a certificate chain length of less than nine 
certificates (from server to root). Connections that use a certificate chain 
containing nine or more certificates will fail.


NWGINA PROMPTS FOR USER CREDENTIALS 

NWGINA may prompt you for user credentials while launching a connection to an 
application or a desktop, published for anonymous users on a MetaFrame XP server 
with a Novell client. This occurs if you are not using NDS support provided by 
MetaFrame XP, Feature Release 1 or higher.

To prevent NWGINA from prompting for user credentials, you must edit Registry as 
follows:
Key : HKLM\Software\Novell\Network Provider\Initial Login
Value: Login When NWGina Not Loaded 
Set it to: no

Refer to the Novell support documentation for more information:
http://support.novell.com/cgi-bin/search/searchtid.cgi?/10059708.htm


SHADOW TASKBAR DISPLAYS INCORRECT CLIENT MACHINE NAME

If you rename a client machine and then use the shadow taskbar, the shadow 
taskbar may display an incorrect name. To prevent this, delete the wfcname.ini 
file so that the correct name displays the next time you launch an ICA 
connection.


SHADOW TASKBAR STOPS RESPONDING AFTER RESIZE AND CLICK

If you resize the Shadow Taskbar, making it small so that only part of the 
shadow button displays, when you click the button, the Shadow Taskbar stops 
responding and you must end the task from Task Manager.


SHADOW TASK BAR AND IDENTICAL SERVER AND APPLICATION NAMES

When you view published applications in the Shadow Task Bar, a server name does 
not appear under a published application if the server name and the application 
name are the same.


CANNOT INSTALL METAFRAME XP Feature Release 2.2 USING RDP OR ICA

If you are installing an MSI package from a mapped network drive inside of a 
session (ICA or RDP), the MSI fails and error messages appear. To prevent this 
from occurring, use the UNC path instead of drive letters. This is a known 
Microsoft issue; see article Q255591 for more information.


INSTALLING METAFRAME XP 1.0 FOR WINDOWS FEATURE RELEASE 2 FROM AN ICA SESSION 
CAUSES AN INTERNAL ERROR

This problem occurs when Windows Installer is running as a service in the 
console session and is unable to access the network path mapped in a remote 
session. Use the UNC path to correct the problem, for example, C:\>msiexec /I 
<\\server\share\MFXP001.msi>. This is a known Microsoft issue; see article 
Q255591 for more information.


TRAP OCCURS IN EXPLORER.EXE IF SYSTEM PATH ENVIRONMENT VARIABLE IS TOO LONG

Keep the contents of the system path environment variable to less than 128 
characters so that users will not experience problems during sessions.


TRAP OCCURS INSIDE CLIENT'S SESSION DURING LOGON/LOGOFF STRESS TEST

A trap may occur inside a client session during the logon/logoff stress test. 
This is a Known Issue for Microsoft. To prevent this from occurring, delete the 
Keys folder: 
HKLM\System\CurrentControlSet\Control\SessionManager\AppCompatibility\
Explorer.exe 


SPOOLER SERVICE STOPS WHEN CONNECTING FROM ICA CLIENT AFTER LEXMARK Z12 
DRIVERS ARE INSTALLED

You cannot use Lexmark Z12 drivers with MetaFrame XP Feature Release 2.
Installing these drivers causes the client printer auto-creation to fail for all 
printers. 


PRINTER FAILS IF "COM" PREFIX IS USED

Do not use a "COM" prefix such as "com4xxx" to name a printer. Doing so causes 
the printer to fail. 


SERVER DOES NOT RETAIN ITS PRODUCT CODE AFTER A CHFARM COMMAND

A MetaFrame Feature Release 2 server loses its feature release level if you 
run the CHFARM (Change Farm) command. To correct this, reset the  feature  
release level after the server is joined to a new farm. You may also need to 
re-enter the product code. You reset the feature release and the product code on 
the Properties dialog box for a server. Expand the Servers node in the left pane 
of Citrix Management Console and right-click the server you want to work on. 
Select the appropriate option from the short-cut menu that appears. 


HANDLE LEAK OCCURS IN TERMSRV.EXE AND LSASS.EXE 

Terminal Services and LSASS leak resources and memory. This is a known Microsoft 
Issue. Refer to Microsoft support article Q291340. 


CHANGING CITRIX ADMINISTRATOR ACCESS LEVEL MAY NOT WORK IN MIXED SERVER FARMS

If you use a version of the Citrix Management Console released prior to Feature 
Release 2 to connect to a MetaFrame XP server at an earlier feature release 
level, changes you make to the Citrix administrators group may not take affect. 

For example, if you use a Feature Release 1 version of the console to connect to 
a Feature Release 1 MetaFrame XP server in a mixed server farm, custom Citrix 
administrators can be displayed as view-only Citrix administrators.


ISSUES WHEN LOGGING ON TO CITRIX MANAGEMENT CONSOLE USING PASS-THROUGH 
AUTHENTICATION

The following issues may be seen for Citrix administrators who log on to Citrix 
Management Console using the pass-through authentication logon method.
 
1.   "Custom" Citrix administrators can view all Citrix administrator accounts, 
     even if the "View Citrix Administrators" task has not been enabled for     
     them.
 
2.   If Citrix administrators are logged on to Citrix Management Console, and   
     another Citrix administrator changes their permissions, the administrators 
     are not automatically logged off from the console. The administrators must 
     log off and then log back on for the new permissions to take effect.
 
3.   If Citrix administrators are logged on to Citrix Management Console, and   
     another Citrix administrator deletes their accounts, the administrators are 
     not automatically logged off from the console. 


UNINSTALLING METAFRAME FAILS TO REMOVE LOCAL USERS/ADMINISTRATORS IN THE CITRIX 
MANAGEMENT CONSOLE

Citrix Administrators who are local users/administrators of a MetaFrame server 
fail to be removed when you uninstall MetaFrame from that server. Their user IDs 
appear as question marks under the Citrix Administrators node in the Citrix 
Management Console. To correct the problem, remove the users and groups 
manually.


HTML AND ICA FILE LOCATIONS

If you create an HTML file in the Citrix Management Console and point it to an 
ICA file, make sure both files are in the same directory. An error occurs when 
the HTML and ICA files are not placed in the same directory.


USERS UNABLE TO RECONNECT DURING CHANGES TO PUBLISHED APPLICATION AVAILABILITY

Users that disconnect from a session while you are making changes to the 
availability of a published application on a server may be unable to reconnect 
to their sessions. If a user is unable to reconnect, you must log out of the 
user's disconnected session and ask the user to try again.


JOINING SERVER FARMS

A server that has Service Pack 2 installed cannot join a server farm in which 
the direct server (the server that connects directly to the data store) does not 
have Service Pack 2 installed. Do not use the CHFARM command to move a server 
that has Service Pack 2 installed unless the direct server in the target farm 
already has Service Pack 2 installed.


NETSCAPE DOES NOT RECOGNIZE WHEN PLUG-IN IS INSTALLED

If you are using Netscape 6.x, and you download and install the Netscape Plug-in 
Client (wfplug32.exe) from an ICA file or from an HTML page, the Npican.dll file 
installs in the wrong directory of your client device. As a result, Netscape 
does not recognize that the plug-in was installed. To remedy the situation, 
locate and copy the file Npican.dll to the following directory:  Program 
Files\Netscape\Netscape6\Plugins.


COMPONENT DESCRIPTION CONTAINS INNACURATE INFORMATION ABOUT DISK SPACE
 
When installing MetaFrame, you can determine how much disk space the components 
you want to install requires. For the most accurate figures, select a component 
and click Disk Cost.


NDS PREFERRED TREE AND FARM AUTHENTICATION

If you designate an NDS Preferred Tree but none of the servers are MetaFrame XP 
Feature Release 2 enabled, the farm authentication prompts the client for NDS 
credentials but does not accept them. To correct the problem, set the Feature 
Release level to Feature Release 2 on at least one sever, remove the NDS tree 
name in the NDS Preferred Tree field (Farm Properties --> MetaFrame Settings), 
and reset the Feature Release level to “NONE.”


NDS CREDENTIALS AND SESSION SHARING

The session sharing feature is not currently supported for custom ICA 
connections that are configured with NDS user credentials (under 
Properties->Login Information). To use the session sharing feature for Custom 
ICA Connections, do not specify user credentials in the Login Information tab 
for a connection.


FAILURE TO LIST DOMAINS AFTER SERVER REMOVAL

If some servers have Feature Release 2 installed and some do not, and you remove 
a server from the farm by using the Remove Server from Farm command, domains can 
fail to appear in Citrix Management Console when you try to select users for 
published applications, Citrix administrators, or allocation of network 
printers.

This issue occurs only if all of the following are true:

     - NDS is enabled in the server farm.

     - The server you remove is the only server that has Feature Release 2 and 
       the Novell Intranetware Client installed.

     - You use the Remove Server from Farm command with Citrix Management 
       Console connected to a MetaFrame XP server that does not have Feature 
       Release 2 installed.

To avoid this issue, always uninstall MetaFrame XP to remove a server from the 
server farm; do not try to remove the server using the Remove Server from Farm 
command. If you must use the Remove Server from Farm command to remove a server 
that has Feature Release 2 installed, be sure to connect Citrix Management 
Console to a server that has Feature Release 2 installed.

If domains fail to appear in Citrix Management Console because of this issue, do 
the following to fix the problem: 

Delete the text in the NDS Preferred Tree box on the Properties sheet for the 
server farm. Removing the NDS Preferred Tree name disables NDS in the server 
farm and restores regular domain enumeration.


NOVELL AND WINDOWS AUTHENTICATION

If you connect, by dial-up ICA, to a MetaFrame XP Feature Release 2 server that 
has a Novell Intranetware Client installed, the server returns the Microsoft 
logon dialog box instead of the Novell logon dialog box. This occurs because the 
"Use Default NT Authentication" option (under Advanced Connection Settings) is 
selected, by default, on Windows 2000 servers. 

If you want to use Novell authentication on a server under these circumstances, 
deselect the "Use Default NT Authentication" option. Refer to the online help 
for Citrix Connection Configuration for more information.

If a Windows 2000 server without Service Pack 2 is set up to use the default 
Windows NT authentication (under Advanced Connection Settings in the Citrix 
Connection Configuration) and you installed a third-party authentication 
software such as Novell Intranetware Client, the third-party logon dialog box 
appears instead of the default Windows logon dialog box. Installing Windows 2000 
server with Service Pack 2 resolves the problem.


SEARCH DOES NOT CHECK FOR NESTED GROUP MEMBERSHIPS

MetaFrame XP Feature Release 2 allows you to search for published applications, 
autocreated printers. and user policies for users or user groups. However, the 
search feature does not check for nested group memberships.


SERVER MAY NOT BE REMOVED WHEN USING THE REMOVE FROM SERVER FARM OPTION

If you need to remove a server from the farm that is no longer available, make 
sure that you are using a Feature Release 2 Citrix Management Console and are 
connected to a MetaFrame XP Feature Release 2 server before you select the 
"Remove Server from Farm" option. If you are using an earlier Citrix Management 
Console or are connected to a server running an earlier feature release and you 
use this command you may get an error message and the server may not be removed 
from the farm properly.


CHANGING FARMS FROM AN ORACLE DATABASE TO SQL DATABASE CAUSES SOME TABS TO 
DISAPPEAR

If you are changing farms from an Oracle to an SQL database, make sure the 
server's product code, licences, and feature release level are set before you 
run the CHFARM command. Failing to do so may cause the Installation Manager and 
Policies tabs to disappear.


INSTALLATION OF "TURNKEY" NFUSE CLASSIC MAY FAIL IF UPGRADING ON SERVER WITH 
REMAPPED DRIVES

If you are upgrading to MetaFrame XP, Feature Release 2 from MetaFrame 1.8 for 
Windows 2000 and the server has remapped drives, the installation of NFuse 
Classic may fail. To fix the problem, you must update the server’s COM+ catalog. 
See article CTX240747 on the online Citrix Knowledge Base at 
http://www.citrix.com/support for more information.


PENDING CLIENT PRINT JOBS ARE NOT CLEARED FROM QUEUE WHEN SERVER AND CLIENT 
PRINTER SETTINGS CONFLICT

If ICA Clients' printers are set to "keep printed documents" (on a Windows 2000 
Professional computer, for example, on the Advanced tab of the client's printer 
Properties dialog box), printer settings on the MetaFrame XP server may not take 
effect.

This issue occurs when the options "Inherit printer's setting for pending print 
jobs" and "Delete pending print jobs at logout" are both selected on the Printer 
Management Properties dialog box (Printers tab) in Citrix Management Console. If 
these options are both selected and print jobs have not completed printing when 
the user logs out, the client printer will not be removed from the user's 
profile and the print jobs will remain in the queue.


LONG NDS DISTINGUISHED NAMES

When NDS distinguished names are longer than 20 characters, logons can fail 
because NDS does not create a Dynamic Local User (DLU) account under a stress 
situation. 

A distinguished name is the full path of the user (the context plus the username 
with a leading period, such as .BobR.FTL.Engineering.Citrix). 

With distinguished names over 20 characters, the Novell Workstation Manager 
sometimes will not create a Dynamic Local User, causing the logon to fail.

Program Neighborhood, Program Neighborhood Agent, and NFuse ICA Clients use 
distinguished names to log on users and create DLUs. 

This problem is evident when the Novell Workstation Manager is under stress. 
This is an open issue with Novell; the Case number is 2633549.

The workaround for this issue is to create an alias for each user and place the 
aliases in a new container so that the longest alias plus the context does not 
exceed 20 characters. In Program Neighborhood and the Program Neighborhood 
Agent, users log on using their alias in the new container. For NFuse, specify 
the new container in the SearchContextList field in the Nfuse.conf file so that 
it is searched first.

With this setup, the distinguished name used as an example above would become 
.BobR.newcontainer.Citrix.

In addition, logons fail if auto logon credentials received from the ICA Client 
are longer than 48 characters. You cannot use auto logon with an NDS user name 
that is longer than 48 characters because the Novell client does not support 
longer names.


MIGRATING APPLICATIONS FROM METAFRAME 1.8

If you have a MetaFrame 1.8 server farm and you want to use  mixed mode to 
migrate to MetaFrame XP, you must follow the instructions in the MetaFrame XP 
Administrator's Guide about using the identical farm name when you install 
MetaFrame XP.

If you install MetaFrame XP in mixed mode and create a new server farm, but you 
enter a farm name that is different from the name of the MetaFrame 1.8 server 
farm, and then you migrate published applications from the MetaFrame 1.8 server 
farm to the new server farm, users cannot launch the published applications in 
the MetaFrame 1.8 server farm. If you try to connect to a published application, 
a message tells you that the application set data is out of date, and when you 
click OK, you are connected to the published application in the new server farm.


CLIENT BROWSING FAILS AFTER CHANGE TO NATIVE MODE

ICA Clients might fail to locate published applications in a MetaFrame XP server 
farm after the farm is in mixed mode (for interoperability with MetaFrame 1.8) 
and is changed to native mode. This issue occurs only if the Citrix XML Service 
shares the HTTP port with Internet Information Server (IIS) on MetaFrame XP 
servers.

If this problem occurs, you can correct it by restarting the IIS Admin Service 
(IISADMIN) on the MetaFrame XP servers.


USING THE UNIVERSAL PRINT DRIVER WITH POSTSCRIPT PRINTERS

PostScript client printers with constrained memory (typically 2-4 MB of printer 
memory) can run out of memory when printing full-page graphics. If this happens, 
the print job spools completely but does not print correctly. The printer may 
output a diagnostic page or error code.

The Citrix Universal Print Driver renders print jobs as full-page graphics. It 
sends bitmap data to a client printer driver for printing. PostScript drivers 
for client printers typically consume more memory than PCL drivers, so 
out-of-memory errors are more likely on a client printer with a PostScript 
driver.

The Citrix Universal Print Driver feature minimizes the memory required for 
printing by sending 300-dpi output to client printers. However, some printer 
drivers always use a higher resolution, which consumes more memory.

The following workarounds can be used to avoid client printer memory problems 
with the Citrix Universal driver:

     - Add more physical memory to the client printer.

     - Use PCL or other emulations instead of PostScript for the client 
       printer.

     - Install and use a native printer driver on the MetaFrame server for 
       client printing.


EXTENDED CHARACTERS WITH MULTI-BYTE SQL SERVER

Problems with some data not being written to the server farm's data store can 
arise with the following configuration:

   --The MetaFrame XP server environment contains extended characters in 
     the domain name, server name, or zone name

   --A multi-byte version of Microsoft SQL Server (such as Japanese, 
     Korean, or Chinese language) is used for the server farm's data store.

With this configuration, it is important to deselect the option "Perform 
translation for character data" when you configure the DSN for SQL Server. If 
you are not sure if the environment contains extended characters, Citrix 
recommends that you deselect the option.

If you use the Japanese version of MetaFrame XP with a multi-byte SQL Server, 
the farm operates correctly when the "Perform translation for character data" 
option is selected.


USING CITRIX WEB CONSOLE

Citrix Web Console uses an authentication method that is different than the 
method that Citrix Management Console uses. Citrix administrators can access the 
Citrix Web Console only if the console can authenticate their user credentials.

The Web console can authenticate local users of the server that hosts the Web 
console. After authenticating a local user account, the console uses the MFCom 
service to verify Citrix administrator privileges. Citrix administrators cannot 
log on to the Web console by using local user accounts on other servers, NDS 
user accounts, or Windows domain accounts in domains other than the Web 
console's domain and domains trusted by the domain of the Web console server. 

When you click Logoff for the first time in the Web console, a message asks for 
permission to download and install an ActiveX control from Citrix Systems. This 
control clears the authentication cache on the system, so that choosing Refresh 
does not log on to the Web console again with cached user credentials. The 
ActiveX control needs to be downloaded only once on a client system that you use 
to connect to Citrix Web Console.

If you click "No" when the download message appears, an error message states 
"The object does not support the property or method."


ALTERNATIVE USER INPUT AND METAFRAME SERVERS

To avoid getting errors, disable the Alternative User Input when you install 
Microsoft Office XP on a MetaFrame server. Alternative User Input provides 
handwriting recognition and microphone dictation functions. The MetaFrame 
environment does not currently support these functions.


CPU PRIORITY

Even though you are able to set a CPU priority for a published desktop, 
MetaFrame XP Feature Release 2 does not adhere to your settings; therefore, the 
published desktop and all processes that start in the session run at their 
default CPU priority status. 


SERVER AND DATA STORE CONNECTIVITY

If a MetaFrame XP 1.0 server and the data store lose connectivity before at 
least one ICA session is connected to the MetaFrame XP 1.0 server, the server 
cannot process any ICA connection requests and returns a "system has reached its 
licensed logon limit" error. To correct this problem, restore connectivity 
between the MetaFrame XP 1.0 server and the data store. To prevent this problem 
from occurring, make sure that at least one ICA connection has been made to each 
MetaFrame XP 1.0 server when data store connectivity is available.


MIGRATION TO ORACLE VERSION 8.1.7

If you use DSMAINT to migrate from an Access database to Oracle 8.1.7 for the 
server farm's data store, the IMA service fails to start because the Oracle 
8.1.7.0 driver alters the logon authentication method.

The Oracle 8.1.7.0 driver installs a security feature named NTS, which uses 
Windows NT credentials to authenticate to the Oracle server. The IMA service is 
configured to use the System account to access the data store and IMA fails to 
connect to the Oracle server with the NTS feature. If this happens, IMA reports 
error code 2147483649.

To avoid this problem if you migrate from Access to Oracle 8.1.7, disable the 
Oracle NTS feature using the Net8 Assistant.

1.   Run the Net8 Assistant, navigate to Net8 Configuration\Local\Profile and 
     select Oracle Advanced Security.

2.   Select the Authentication tab.

3.   Remove NTS from the Selected Methods list.


ADDITIONAL PROCESSES FOR FARM SERVERS CONNECTED TO THE ORACLE DATABASE

If you are using an Oracle server in dedicated mode, plan to add one additional 
process for each farm server connected directly to the Oracle database. For 
example, if your Oracle server is currently using 100 processes and you want to 
create a 50-server farm, set your processes value to at least 150 (100 current, 
plus 50 additional). To do this, set the processes value in the INIT.ORA file on 
the Oracle server. If necessary, consult your Oracle documentation for more 
information.


MOVING DATA COLLECTORS TO A NEW ZONE

If you want to move a data collector into a different zone you must first 
designate another server as a data collector and set its election preference to 
"Most Preferred." Then, prior to moving the original data collector, set its 
election preference to "Default Preference" or "Not Preferred." Use the QUERY 
FARM command to make sure the election preference on the original server has 
changed. If the election preference has changed, it is safe to move the original 
data collector to the new zone.


INABILITY TO START IMA SERVICE

If upon rebooting, the IMA service fails to start and you get an "IMA Service 
Failed" message with error code 2147483649, it may mean that the temp directory 
is missing for the local system account. To verify that this is the problem, 
change the IMA Service startup account to the local administrator. If the IMA 
service starts under the local administrator's account, the missing temp 
directory is the issue. 

To correct the problem, switch the service back to the local system account and 
manually create the temp directory %systemroot%\temp. Verify that both the TMP 
and TEMP environment variables point to this directory. For more information, 
see Microsoft article Q251254 found at 
http://support.microsoft.com/support/kb/articles/Q251/2/54.ASP.


LOGON FAILURE AFTER UNINSTALLING NOVELL CLIENT

Logon to a MetaFrame XP server can fail if you uninstall the Novell client from 
the server after MetaFrame XP is installed. Uninstalling the Novell client might 
remove the setting for the logon interface (GINA) from the registry. It might be 
necessary to add the proper settings to the registry after removing the Novell 
client. The following registry key contains the GINA values:

HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon

The values for MetaFrame logon without the Novell client are:

   GinaDLL  Data: Ctxgina.dll
   CtxGinaDLL  Data: Msgina.dll


USE A FULL UNC PATH TO PUBLISH NDS APPLICATIONS LOCATED ON NETWARE METAFRAME 
SERVERS

Citrix Management Console cannot list MetaFrame servers with NetWare Client 
installed. You can't use the Browse button to access NetWare servers when 
specifying a command line or icon location within the Application Publishing 
Wizard. To publish a Novell Directory Service (NDS) application residing on a 
NetWare server:  

1.   Use Citrix Management Console. From the Actions menu, choose New > 
     Published Application. 

2.   Follow the instructions in the Application Publishing Wizard up to the 
     Specify What to Publish (Cont.) dialog box. Don't use the browse button. 

3.   Type the Universal Naming Convention (UNC) path to an NDS application in 
     the Command Line box. UNC allows computers on a network to be referred to 
     by name. 

     For example: The NDS tree, MYNDSTREE, contains organization object MYORG, 
     which contains NetWare volume NW50_SYS. The executable path on NW50_SYS is 
     \APPS\OFFICE\WINWORD.EXE. The full UNC path to WINWORD.EXE is 
     \\MYNDSTREE\MYORG\NW50_SYS\APPS\OFFICE\WINWORD.EXE. The Working Directory 
     box can be blank.

4.   In the Program Neighborhood Settings dialog box, default icons display 
     instead of the executable's icon. The wizard can't access the executable 
     given in the Command Line box. To use the icon from the specified 
     executable, extract the icon from the executable using an icon extraction 
     utility and give it an .ico extension or use the whole executable. Place 
     either on any MetaFrame server without the Novell Client. Use the Change
     Icon button to browse for the .ico file or executable on the MetaFrame 
     server and select it. This icon is associated with the true application 
     path, although it comes from another source.


SHADOW TASK BAR

When you view published applications in the Shadow Task Bar, a server name does 
not appear under a published application if the server name and the application 
name are the same.


SHADOWING A USER WITH A DIFFERENT KEYBOARD LAYOUT

Shadowing a user with a different keyboard layout can produce unexpected 
results. It is possible that a character would be echoed within the shadowed 
session that is different from the key that was pressed. Instances where this 
could occur include a person with a 101-key keyboard shadowing a person with a 
106-key keyboard, or a person in one input locale shadowing a user in a 
different input locale.


UPGRADING FROM METAFRAME 1.8 ON A SERVER WITH MAPPED DRIVES DOES NOT UPDATE ICA 
WIN32 PASS-THROUGH CLIENT

If you upgrade from MetaFrame 1.8 to MetaFrame XP on a server with changed 
server drive letters, the ICA Win32 pass-through Client. To avoid this issue, be 
sure the server is operating in install mode before running Setup. To update the 
pass-through client, install the "stand-alone" version of the pass-through 
client.


ANONYMOUS USERS

Anonymous users may be able to open another session of a published application 
even if you have configured the application to allow only one instance per user. 
An anonymous user can circumvent the "one instance/one user" configuration by 
starting the application in a new session. This occurs because the new session 
runs under a different anonymous user account on the server.


JAVA RUNTIME ENVIRONMENT

The installer places essential files for the Java-based Citrix Management 
Console in a directory with the Java Runtime Environment (JRE). If you upgrade 
the JRE and then launch the console, the console files are not found and the 
console fails to start. You can use the following parameter to specify the 
location of the console files:

-Djava.ext.dirs=<directory>

where <directory> is the correct extensions directory (typically Program 
Files\JavaSoft\JRE\1.3\lib\ext). You must enclose the path in quotes if it 
contains spaces. 

Add this parameter to the shortcut for the Citrix Management Console so it is 
used when you launch the console from the button on the Citrix Administrator 
Toolbar. For a default installation, the Citrix Management Console shortcut icon 
is at %systemroot%\program files\citrix\administration. Right-click the icon and 
choose Properties. On the Shortcut tab, type a space after the text in the 
Target box and then type the parameter. Click OK to apply the new setting and 
close the dialog box.

You can also use the directory parameter to launch the console from a command 
prompt. For example, use the following command to launch the console and specify 
the default location for the console files. Run this command from \program 
files\citrix\administration:

java -Djava.ext.dir="c:\Program Files\JavaSoft\JRE\1.3\lib\ext" -jar tool.jar


MATROX MILLENNIUM DUAL HEAD G450 GRAPHICS ADAPTER

Refreshing of the display causes anomalies in Citrix Management Console running 
on an IBM Intellistation with the Millennium G450 graphics adapter. With this 
configuration, sections of the console interface can appear blank. For example, 
when you browse for an application to publish, the scrollable area of the dialog 
box becomes unreadable.


SESSION INFORMATION WITH SSL ENCRYPTION

When the ICA client uses the Citrix SSL Relay for encryption of an ICA session, 
Citrix Management Console displays the session encryption level incorrectly as 
"Basic encryption;" it should be "Basic SSL Secured, 128 bit."


IMA SERVICE AND SERVERS THAT DO NOT HAVE WINDOWS 2000 SERVICE PACK 2

If you are using a server that does not have Windows 2000 Service Pack 2, 
install the Microsoft Q273772 hotfix. Not installing this hotfix results in 
memory leaks by the IMA service. 


ATI RAGE PRO IIC DISPLAY ADAPTER

Performance can be very slow in an ICA session with this adapter using display 
driver version 4.11.2650 and the ICA Win32 Client on Windows 98. 


NETWORK PRINTER NAMES

Changing the share name of a printer installed on a MetaFrame XP server deletes 
all user names entered in the auto-creation list for the printer in Citrix 
Management Console.


EXTENDED CHARACTERS IN ZONE NAMES

If the name of a zone contains extended characters, the IMA service fails to 
start after installation of Feature Release 2 or Service Pack 2. To avoid this 
issue, change zone names to remove extended characters before you install the 
feature release or service pack.


MFCOM SERVICE TIMEOUT

MetaFrame COM Server (MFCOM) is a service that starts when a MetaFrame XP server 
starts up. The IMA service must be running for MFCOM to start. If a "Service 
failed to start" message appears when you restart a server, check the Event Log 
(TSE) or the System Log (Windows 2000 Server). 

If the messages "IMA service hung on starting" and "MFCOM service failed to 
start" are in the log, IMA service did not start within three minutes, the 
default timeout period for the MFCOM service.

Timeout of the MFCOM service at startup is not a problem, because MFCOM will 
start later if it is needed. 

To prevent MFCOM from timing out, edit the following registry key, which sets 
the amount of time that MFCOM waits for the IMA service to start: 

   HKLM\SYSTEM\CurrentControlSet\Services\MFCom\IMAWaitTimeout

Set the value to 1,200,000 milliseconds (20 minutes) or higher.

The following registry key controls the time MFCOM waits before polling the IMA 
service for its status:
   
   HKLM\SYSTEM\CurrentControlSet\Services\MFCom\IMAWaitPause 

The default value is 30,000 milliseconds (30 seconds), which works well in most 
cases.


SHORTCUTS FOR APPLICATIONS WITH LONG PATH NAMES 

If the path name of a published application exceeds 256 characters, shortcuts to 
the published application do not appear in the Start menu or on the desktop of 
client devices (if these options are selected when publishing the application). 
Instead, the shortcuts appear in a folder named "Application Errors." The folder 
appears in the specified shortcut location. For example, if you select the 
option to place a shortcut on the desktop, the Application Errors folder appears 
on the desktop. The folder contains a shortcut icon with the application name 
truncated.

To avoid this issue, make the application name and path no longer than 256 
characters for each published application.

ADDING RE-IMAGED SERVERS TO SERVER FARMS

If a MetaFrame XP server is a member of a server farm, and you do not remove the 
server from the server farm before you apply a system image to create a new 
MetaFrame XP server on the same machine, you can experience performance problems 
and find invalid data displayed in the Citrix Management Console if you then add 
the server back to the same server farm. This issue arises because the old 
server's host record in the data store is applied to the newly imaged server.

If you are going to re-image a server, first remove the server from the server 
farm by uninstalling MetaFrame XP, then apply the system image and add the 
server to the server farm. 


USING UNICENTER 3.1 TO INSTALL METAFRAME IS SUCCESSFULL BUT GIVES MISSING DLL
ERROR

When MetaFrame XP FR2 is installed with Unicenter 3.1 you may see an error that 
ImaSystem.dll could not be found. The installation is successful but the path to 
imaSystem.dll is unavailable to aminstn.exe, a Unicenter file, when it executes. 
This is a third party bug which does not affect the installation. Click OK to 
clear the error message. The system reboots and MetaFrame XP Feature Release 2 
becomes available.


SESSION MANAGEMENT IS RESTRICTED IN CITRIX MANAGEMENT CONSOLE BUT SESSIONS CAN 
BE MANAGED USING OTHER TOOLS

Citrix administrators with customized access that excludes some or all of the 
session management tasks may be able to manage ICA sessions outside of Citrix
Management Console. 

Terminal services management tools can be used to manage ICA sessions in a 
server farm. Local administrators have access to reset, connect, disconnect, 
reconnect, and log off sessions by default. They can manage ICA sessions
in a server farm after connecting their local administrator accounts to 
MetaFrame servers. 

An administrator's rights to manage sessions using terminal services management 
tools can be changed using Citrix Connection Configuration and Terminal Services 
Configuration. Local administrators given access to any session tasks on Citrix 
Management Console can manage the combination of session tasks assigned on the 
console and session tasks assigned in Citrix Connection Configuration or 
Terminal Services Configuration when they use terminal services management tools 
from an ICA session.

When session management settings are turned off on the console,in Citrix 
Connection Configuration, and Terminal Services Configuration, users can still 
use Send Message using terminal services management tools. 


*******************************************************************************

HOTFIXES INCORPORATED IN SERVICE PACK 2
---------------------------------------

This service pack includes all hotfixes that were previously released 
separately, and additional patches that have not been previously released. 

MetaFrame XP, Service Pack 2 includes all of the hotfixes packaged into 
MetaFrame XP, Service Pack 1.

Many hotfix releases are cumulative; that is, they include fixes contained in 
prior hotfix releases. Issues addressed by hotfixes are listed here once, under 
the number of the hotfix in which they were first resolved.

HOTFIXES FOR WINDOWS 2000 SERVERS

Hotfix XE101W001
A denial of service attack causes a MetaFrame server's CPU utilization to go to 
100% and result in a "blue screen."

Hotfix XE101W002
The copy and paste functions for cell formatting does not work when using 
Microsoft Excel in an ICA session.

This hotfix allows users to add custom clipboard formatting from the registry. 
Add the following registry value to add a custom clipboard format called 
"MyCustomFormat" to a supported ICA clipboard format.

Hotfix XE101W003
The Citrix Management Console does not enumerate NDS users. You cannot log 
into farm using the Citrix Management Console, Program Neighborhood, or NFuse 
with NDS credentials.

The Novell registry settings for NDS Tree name/Save On Exit/DefaultUserName is 
not being set appropriately.

If a user attempts to enumerate accounts in the Citrix Administrators wizard, 
the NDS tree does not appear in the list of domains.

If a user attempts to enumerate accounts in the Published Application wizard, 
the NDS tree appeared in the list of domains but the user cannot enumerate 
accounts from the NDS tree.

Hotfix XE101W005
With certain applications that are unique in loading system Dlls, an access 
violation occurs when calling Advapi.dll functions (Reg**) from Tzhook.dll.

Hotfix XE101W006
Printer driver replication fails for certain drivers after installing Feature 
Release 1.

Hotfix XE101W007
An error occurs when a non-administrator attempts to open the shadow taskbar.

Hotfix XE101W008
The IMA service fails to start after installing Feature Release 2. This failure 
is caused by an invalid entry in the database.

Hotfix XE101W009
1.   Shadowing from the Citrix Management Console failed when the server is set 
     to "Only Run Published Applications." The following error message appears:
     "The system cannot log you on (52e). Please try again or consult your 
     system administrator."

2.   If a session disconnects while printing, the print spooler hangs.

3.   Logon to published applications is slow when a number of printers needs to 
     be autocreated.

4.   Single sign-on authentication does not function for published applications 
     on a server. 

5.   If users launch the Program Neighborhood Client and then change their 
     passwords, the client displays all the published applications in the farm,
     not just the ones for which the users have permission.

6.   Autocreated client printers are causing a server spooler trap.

7.   If Independent Management Architecture (IMA) service was down on a
     MetaFrame server but  XML service was running on one or more servers, the 
     client sometimes failed to connect to a MetaFrame server/farm using 
     TCP/HTTP even when other servers were available in the farm.

Hotfix XE101W010
When expanding a server node in the Citrix Managment Console the following error 
appeared: "Error expanding the tree, please refresh the parent node" 
Note: This hotfix need to be applied to every server in the farm.

Hotfix XE101W011
When expanding an application folder in the Citrix Managment Console the 
following error appeared: "Error The node is obsolete, please refresh the parent 
node"  Note: This hotfix need to be applied to every server in the farm.

Hotfix XE101W012
When publishing applications that contains spaces in their names, there is no 
output using qfarm /app appname

Hotfix XE101W013
The left bracket ({) key did not work on Linux Clients configured with 
Portuguese (Brazilian ABNT2) keyboard layouts.

Hotfix XE101W014
The Citrix Management Console may display only a partial list of groups and 
users when enumerating 
domain accounts.

From a Win2K member server running MFXP1.0 FR1 enumeration of an Active 
Directory domain will fail of the domain contains a large number of distribution 
groups. This  enumeration failure is due to a memory leak in IMA.

A server in an NT4 domain cannot enumerate groups and users in a NT5 domain even 
though the domains have trust relationships.

Hotfix XE101W015
Extended Parameter passing does not work with files which have spaces in the 
filename.  

When passing large command line parameters to a published application heap 
corruption could occur resulting in random read and/or write memory errors and 
unexpected termination of the published application.

If a user launched an application from Program Neighborhood in window mode (as 
opposed to seamless mode) and then closed it, the Citrix Management Console 
continued to display session information about the application.


Hotfix XE101W016
Provides a method to install and activate a serial number without contacting 
Citrix for activation codes. An auto-activation flag was added to the serial 
number. When installed, MetaFrame XP generates the activation code 
automatically.


Hotfix XE101W017
1.   Fatal system errors (Stop 50 and Stop C2) occurred when sending large 
     amounts of data from the server to mapped drives on an ICA Macintosh Client
     device.

2.   Incorrect volume size was reported by ICA Client mapped drives.

Hotfix XE101W018
A scheduled reboot of a server did not work properly because an administrator 
was logged on to the console during the reboot sequence.

Hotfix XE101W019
Wdica.sys was causing a blue screen.

Hotfix XE101W020
An incorrect message appeared when the auto update is 
unsuccessful due to the write permission error.

Hotfix XE101W021
IME dictionary path in user profiles can point to client drive if MetaFrame 
server’s local drive was remapped. If that happened, text input gets very slow 
because of the frequent data query in the dictionary located in client drive by 
IME2002.

******************************************************************************

HOTFIXES INCORPORATED IN SERVICE PACK 1
---------------------------------------
These hotfixes are also included when you install MetaFrame XP 
Feature Release 2.


Hotfix XE100W001
1.   An incorrect error code was returned by the WFShadowSession call.

2.   The customer virtual channel lost packets when the packets were being 
     received every 0.5 seconds. The problem occurred when WFVirtualChannelRead 
     timeout was INFINITE or 10 ms.

Hotfix XE100W002
Disabling (or deleting) all Citrix ICA client devices caused the server to trap.

Hotfix XE100W003
The Imauserss.dll trapped when the Application Publishing SDK was installed.

Hotfix XE100W004
The IMA service would hang when Resource Manager was installed.

Hotfix XE100W005
1.   Invalid data was returned from the IMA_WaitGenericIMAEventQueue. The 
     incorrect data size parameter was returned by the fixed module.

2.   MFCOM was not able to receive the "server added to farm" event.

Hotfix XE100W006
The user list became corrupted when a user was removed from an application user 
list. The problem occurred only when the user was removed while using the MFCOM 
and Application Publishing SDK.

Hotfix XE100W007
When using a non-English code page in an SQL database, the IMA service failed to 
start due to corruption in the database. After applying the hotfix, follow the 
steps below for one of the servers that has a direct database connection in your 
farm. (If the PSServer value is empty in the registry key, 
HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\Ima, it is a MetaFrame with a direct database 
connection. If the value is not empty, it is a MetaFrame server without a direct 
database connection.)

A.   Delete the corrupt SQL database and create a new one. Give the new database 
     the same name as the old one.

B.   Go to the following registry key:
     HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\IMA\Data
     Give the logon user name full control permission to the Security key.

C.   At a command prompt, type:
     cd %SystemRoot%\System32\Citrix\ima
     From the directory, type:
     init_sql_db.exe 
     Launch the executable from the console. You will get the message:
     "The sql db has been initialized successfully."

D.   Recreate the local host cache. Give the new cache the same name as the old 
     one.

E.   Go to the following registry key:
     HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\IMA\RunTime\PsRequired
     Change the value to 1.

F.   Restart imaservice.

G.   When the service starts, from the %SystemRoot%\System32\citrix\ima
     directory, type "clicense read_db" (without the quotation marks).

H.   Return to HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\IMA\Data and remove full
     control permission for the logon user name from the Security key.

I.   Stop and restart imaservice.

Follow the steps below for all other MetaFrame servers in your farm.

A.   Make sure the imaservice is stopped. Recreate the local host cache. Give
     the new cache the same name as the old one.

B.   Go to the following registry key:
     HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\IMA\RunTime\PsRequired
     Change the value to 1.

C.   Restart imaservice.

D.   Stop and restart imaservice.

Hotfix XE100W008
If a new Java Runtime Environment (JRE) (such as Netscape 6) was installed after 
the Citrix Citrix Management Console was installed, the new JRE was installed in 
a new path and the registry was updated to reflect the new path, but the Citrix 
Management Console extensions were not copied to the new path. This hotfix 
copies the Citrix Management Console extensions from the old JRE install path to 
the new install path.

Hotfix XE100W009
Adds support for Citrix Server SDK 2.0 on MetaFrame XP 1.0.

Hotfix XE100W010
Version 1.0 of German MetaFrame XP had a security vulnerability at 
%SystemRoot%\SSLRelay\Keystore. Users were able to browse into that directory 
and view the certificates inside.

Hotfix XE100W011
1.   Invalid data was returned from the IMA_WaitGenericIMAEventQueue. The 
     incorrect data size parameter was returned by the fixed module.

2.   MFCOM was not able to receive the "server added to farm" event.

3.   Incorrect data was sent from the IMARpc client to the IMARpc server when an 
     event queue was created.

Hotfix XE100W012
1.   Long Citrix Management Console passwords crashed Imasrv.exe.
     NOTE: Passwords must not exceed IMA's maximum password length of 63 
     characters.
 
2.   Citrix Management Console passwords starting with the letter "S" did not 
     work.

Hotfix XE100W013
1.   Invalid data was returned from the IMA_WaitGenericIMAEventQueue. The 
     incorrect data size parameter was returned by the fixed module.

2.   MFCOM was not able to receive the "server added to farm" event.

3.   Incorrect data was sent from the IMARpc client to the IMARpc server when an 
     event queue was created.

4.   Events subscribed using MFCOM and Application Publishing SDK event APIs 
     were not removed from the dynamic store when the events were unsubscribed.

Hotfix XE100W014
1.   Adds support for Citrix Server SDK 2.0 on MetaFrame XP 1.0.

2.   Events generated on remote servers were not received by the MFCOM SDK's 
     events example. Events affected were adding or removing a server from a
     farm.

3.   The AppID key for MFCOM was not removed when MFCOM was unregistered.

Hotfix XE100W015
1.   Using a farm connection, published applications could not be launched. The 
     session on the server remained in a "ConQ" state.

2.   When tracing was enabled for IMA PN, the IMA Service could not be stopped.

3.   When switching to interoperability mode, refreshing Program Neighborhood
     did not return any apps.

4.   The IMA service would hang when Resource Manager was installed.

Hotfix XE100W016
Native print driver replication failed on a MetaFrame XP server if the server 
drives were remapped.

Hotfix XE100W017
Printer driver replication failed for certain printer drivers; for example, the 
HP LaserJet 4000 PCL 5e.

Hotfix XE100W019
The Lotus Notes Version 5.06 client could not read or write to a file from an 
ICA mapped client drive.


HOTFIXES FOR WINDOWS NT 4.0 SERVER, TERMINAL SERVER EDITION

Hotfix XE100T001
1.   An incorrect error code was returned by the WFShadowSession call.

2.   The customer virtual channel lost packets when the packets were being 
     received every 0.5 seconds. The problem occurred when WFVirtualChannelRead 
     timeout was INFINITE or 10 ms.

Hotfix XE100T002
Disabling (or deleting) all Citrix ICA client devices caused the server to trap.

Hotfix XE100T003
The Imauserss.dll trapped when the Application Publishing SDK was installed.

Hotfix XE100T004
The IMA service would hang when Resource Manager was installed.


Hotfix XE100T005
1.   Invalid data was returned from the IMA_WaitGenericIMAEventQueue. The 
     incorrect data size parameter was returned by the fixed module.

2.   MFCOM was not able to receive the "server added to farm" event.

Hotfix XE100T006
1.   Long Citrix Management Console passwords would crash Imasrv.exe.


2.   Citrix Management Console passwords beginning with the letter "S" did not 
     work.

Hotfix XE100T007
The user list became corrupted when a user was removed from an application user 
list. The problem occurred only when the user was removed while using the MFCOM 
and Application Publishing SDK.

Hotfix XE100T008
When using a non-English code page in an SQL database, the IMA service failed to 
start due to corruption in the database. After applying the hotfix, follow the 
steps below for one machine in your farm.

A.   Recreate the SQL database. Give the new database the same name as the old 
     one.

B.   Go to the following registry key:

     HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\IMA\Data

     Give the logon user name full control permission to the Security key.

C.   Put Init_sql_db.exe in the %SystemRoot%\System32\Citrix\ima directory and 
     launch it from the console. You will get the message:

     "The sql db has been initialized successfully."

D.   Recreate the local host cache. Give the new cache the same name as the old 
     one.

E.   Go to the following registry key:

     HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\IMA\RunTime\PsRequired

     Change the value to 1.

F.  Put Imasql.dll in the %SystemRoot%\System32\citrix\ima directory. Restart   
    the IMA service.

G.   When the service starts, from the %SystemRoot%\System32\citrix\ima         
     directory, type "clicense read_db" (without the quotation marks).

H.   Return to HKEY_LOCAL_MACHINE\SOFTWARE\Citrix\IMA\Data and remove full      
     control permission for the logon user name from the Security key.

Repeat Steps D, E, and F for additional machines.

Hotfix XE100T009
If a new Java Runtime Environment (JRE) (such as Netscape 6) was installed after 
the Citrix Citrix Management Console was installed, the new JRE was installed in 
a new path and the registry was updated to reflect the new path, but the Citrix 
Management Console extensions were not copied to the new path. This hotfix 
copies the Citrix Management Console extensions from the old JRE install path to 
the new install path.

Hotfix XE100T010
Adds support for Citrix Server SDK 2.0 on MetaFrame XP 1.0.

Hotfix XE100T011
Version 1.0 of German MetaFrame XP had a security vulnerability at 
%SystemRoot%\SSLRelay\Keystore. Users were able to browse into that directory 
and view the certificates inside.

Hotfix XE100T012
1.   Invalid data was returned from the IMA_WaitGenericIMAEventQueue. The 
     incorrect data size parameter was returned by the fixed module.

2.   MFCOM was not able to receive the "server added to farm" event.

3.   Incorrect data was sent from the IMARpc client to the IMARpc server when an 
     event queue was created.

Hotfix XE100T013
1.   Invalid data was returned from the IMA_WaitGenericIMAEventQueue. The 
     incorrect data size parameter was returned by the fixed module.

2.   MFCOM was not able to receive the "server added to farm" event.

3.   Incorrect data was sent from the IMARpc client to the IMARpc server when an 
     event queue was created.

4.   Events subscribed using MFCOM and Application Publishing SDK event APIs    
     were not removed from the dynamic store when the events were unsubscribed.

Hotfix XE100T014
1.   Adds support for Citrix Server SDK 2.0 on MetaFrame XP 1.0.

2.   Events generated on remote servers were not received by the MFCOM SDK's 
     events example. Events affected were adding or removing a server from a    
     farm.

3.   The AppID key for MFCOM was not removed when MFCOM was unregistered.

Hotfix XE100T016
Native print driver replication failed on a MetaFrame XP server if the server 
drives were remapped.

Hotfix XE100T017
Printer driver replication failed for certain printer drivers; for example, the 
HP LaserJet 4000 PCL 5e.

Hotfix XE100T019
The Lotus Notes Version 5.06 client could not read or write to a file from an 
ICA mapped client drive.

Hotfix XE100T021
1.   Using a farm connection, published applications could not be launched. The 
     session on the server remained in a "ConnQ" state.

2.   When tracing was enabled for IMA PN, the IMA Service could not be stopped.

3.   In a four day connect/disconnect stress test with tracing turning on, the 
     handle count of IMA Service went from 400 to 1400. There were approximately 
     1000 thread handles but only 50 active threads.

4.   When switching to interoperability mode, applications did not appear after 
     a Program Neighborhood refresh.


-------------------
CONTACT INFORMATION

Citrix Systems, Inc.
6400 NW 6th Way
Fort Lauderdale, Florida 33309 USA
954-267-3000
http://www.citrix.com

------------------------
document code: Tuesday, April 16, 2002 (MP)

