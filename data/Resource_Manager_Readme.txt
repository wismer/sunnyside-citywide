Citrix Resource Manager for MetaFrame XPe 1.0, Feature Release 2/Service
Pack 2 for Microsoft Windows(TM) Operating Systems
=============================================================

Release Notes
=============
Copyright 2002, Citrix Systems, Inc. All rights reserved.

This file contains the latest information relating to Citrix 
Resource Manager for MetaFrame XPe 1.0,Feature Release 2/
Service Pack 2.

Please read this file fully before using the update. It contains
important information that may be more up to date than other
documentation you have available.

This readme file includes the following information:

     * Notes about this release
     * A description of the documentation provided
     * A list of usage notes, restrictions, and known problems
       (VERY IMPORTANT - PLEASE READ)


Where to Find Documentation
===========================
For a general introduction to installing, configuring, and 
maintaining Resource Manager, see the Administrator's Guide. 
The Administrator's Guide is available in Adobe PDF format 
in the "DOCS" directory of your MetaFrame Server CD-ROM. 

Note: Using the Adobe Acrobat Reader, you can view and search the 
documentation electronically, or print it. To download the Adobe 
Acrobat Reader, go to Adobe's Web site at http://www.adobe.com. 

You can also view online help for Resource Manager.

All documentation files installed with Resource Manager are 
available from the following locations:

* In the "DOCS" directory of your MetaFrame Server CD-ROM.

* Installed into the documentation folder of your
  MetaFrame XPe server. From the Start Menu, choose 
  Start > Programs > Citrix > Documentation.

* On the Citrix Web site at http://www.citrix.com/support,
  select the Product Documentation tab. You can check the
  Product Documentation area of the Web site at any time for the
  latest updates to Citrix technical manuals. Any updates to this
  manual published after the release of this product will be
  posted there.


Usage Notes, Restrictions, and Known Problems
=============================================

Oracle Version 7 support
------------------------
Resource Manager does not currently support Oracle Version 7 DBMS.
Citrix is intending to make a hotfix available that enables Resource 
Manager to support Oracle Version 7. The hotfix will be 
available for download from the Citrix Web site at 
http://www.citrix.com.


Memory used by IMA service
--------------------------
On a MetaFrame XP or XPe server, the amount of memory used by the 
IMA service can become very large, reaching 100 Mbytes or more. 
To check the amount of memory currently being used by the 
IMA service, run Task Manager.
The high memory use is due to a memory leak in the ODBC driver 
for the Microsoft Jet database. 

Resource Manager uses this driver to access the local database of 
detailed metric information that it maintains on a server. You may 
also experience this problem if you use Microsoft Access as a 
MetaFrame XP data store. However, since the amount of data being 
stored is lower, you may not notice the leak. Resource Manager 
accesses the database more frequently so you may be more likely 
to notice the leak on a MetaFrame XPe server that includes 
Resource Manager.

If you find that the memory used by the IMA service is too large, 
stop and restart the IMA service. 

For information about a fix for this memory leak:
1. Go to the Microsoft Product Support Services page at 
http://search.support.microsoft.com/
2. Search for article ID number Q273772.
On a Windows 2000 Server machine, this fix is included in 
Windows 2000 Service Pack 2.


DOS 16-bit applications on Windows 2000
---------------------------------------
For Windows 2000, 16-bit DOS applications running in ntvdm.exe 
are not listed individually in Resource Manager reports.


Umlauts and accented characters in SMS messages
-----------------------------------------------
Umlauts and accented characters are not displayed in SMS 
messages sent by Resource Manager. 
Umlauts and accented characters are converted into other 
characters, e.g. ue is displayed for U Umlaut in the German 
version of Resource Manager.
If you use server names that contain umlauts or accented 
characters, make sure that the names that you use will enable you 
to uniquely identify the server when the server name is displayed 
using this method.


Multiple server farms sharing the same summary database
-------------------------------------------------------
You can configure multiple server farms to share the same summary 
database. When you generate reports, however, you can only for the 
server farm that the Citrix Management Console is connected to. 
When you generate reports, you will be able to select processes and 
users from the other farms in the report generation dialog boxes, 
however, they will not be reported on.

Having farms sharing the same summary database may lessen disk space 
used by the summary database, but may also degrade database performance.


Report filename length
----------------------
If Resource Manager displays error messages when you try to save a 
report,check that the filename, including the full path, is less than 
128 characters in length.


Illegal characters in report file names
---------------------------------------
Do not use illegal characters in a file name when saving a Resource 
Manager report. If you do, you will be able to "save" the file to a 
non-existent server. This may cause you to lose the report.

Illegal characters are:

  \  /  :  *  ?  "  <  >  |


Terminating report generation from Oracle databases
---------------------------------------------------
When you generate Resource Manager reports in conjunction with an Oracle 
summary database, the database requests for the reports are queued. 
For example, if you are generating a report that will take 20 minutes to 
complete, and you cancel it after three minutes, you will not be able to 
generate another report for a further 17 minutes. Note also that the IMA 
service may encounter problems shutting down while there are database 
operations pending. To work around this, you need to terminate the session 
from the DBMS. See your DBMS documentation for details on terminating 
database sessions.


Saving multiple report files
----------------------------
When you save multiple report files from the Report Viewer Save dialog 
box, the files are only actually saved at the end of the operation and
so are not displayed in the file save dialog box browse window.


Citrix Management Console update delay
--------------------------------------
When you make changes to the summary database configuration, 
for example, changing the automatic database update time it 
can take up to 10 minutes for other Citrix Management Consoles 
in the farm to be updated with the new settings.

==============================================================

