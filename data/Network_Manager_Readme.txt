Citrix Network Manager for MetaFrame XP for Windows, Feature Release 2
Read Me
(c) 2002 Citrix Systems, Inc.
May 2002

Contents
========

Where to Find Documentation
System Requirements
Usage Notes, Restrictions, and Known Problems
Finding More Information


Where to Find Documentation
===========================

The Administrator's Guide for Network Manager is in an Adobe(R) 
Portable Document Format (PDF) file named Network_Manager_Guide.pdf 
in the \DOCS directory of this CD-ROM. To view this document, 
use Adobe Acrobat(R) Reader. The Acrobat Reader is available 
for free from Adobe's Web site at http://www.adobe.com. 


System Requirements
===================

The requirements for MetaFrame XPe servers that are to use the 
SNMP agent are the same as MetaFrame XPe with the addition of 
Microsoft SNMP services. Microsoft SNMP services are included 
with Windows but not installed by default. See “Installing the 
Microsoft SNMP Service” in the Network Manager Guide for 
instructions on installing Microsoft SNMP services.

Network Manager supports the following SNMP management consoles:

* Tivoli® NetView® 6.0 for Windows NT (with Service Pack 5 or higher) 
or Windows 2000 (with Service Pack 1 or higher).

* HP OpenView™ Network Node Manager 6.2 for Windows NT (with 
Service Pack 5 or higher) or Windows 2000 (with Service Pack 1 or higher).

* CA Unicenter® TNG 2.4 for Windows NT (with Service Pack 5 or higher) 
or Windows 2000 (with Service Pack 1 or higher), using 
either the 2D or 3D WorldView.
The Agent Common Services and Windows NT Enterprise Manager must be 
installed, and the Security Management (secadmin) and trap 
daemon (catrapd) agents must be active. The Distributed State 
Machine (DSM), Enterprise Manager, and WorldView can be installed 
on separate computers.


Usage Notes, Restrictions, and Known Problems
=============================================

This section includes important last-minute information. 
PLEASE READ THIS INFORMATION CAREFULLY BEFORE INSTALLING 
NETWORK MANAGER.

Object appears in Unplaced Objects (Unicenter TNG 2.4)
------------------------------------------------------
When you install the Unicenter Network Manager plug-in, an object is created in Unplaced Objects. Do not delete this object as doing so will cause TrapDialog to stop working.
If you prefer to move this object rather than leave it in Unplaced Objects, use Design Mode to move the object into the correct place under the Unicenter Server's icon in the WorldView map.

If you need to recreate the icon (for example, if you have deleted the object):
1.  Uninstall the Network Manager Plug-in.
2.  Discover the server and make sure that it appears in the map.
3.  Install the Network Manager plug-in.
4.  If required, move the object to its correct place according to the above instructions.


Network Map Not Updated (Unicenter TNG 2.4)
--------------------------------------------
When a MetaFrame server is discovered the server is not re-classified as 
a Citrix server in the TCP/IP Network map. 

This does not affect the operation of the SNMP management console and 
you can still drill down to the Citrix submaps from the TCP/IP Network map. 

Truncated names for MetaFrame XP server farm and zone names
-----------------------------------------------------------
CA Unicenter may display truncated names when you use long server farm 
names or zone names on MetaFrame XP servers. 
This limitation comes from the inability of the Unicenter API to handle 
data of over 30 bytes.

Upgrading the Unicenter plug-in from MetaFrame Feature Release 1
---------------------------------------------------------------
If you have installed the Unicenter plug-in that was included with 
Feature Release 1 and want to upgrade this to the Unicenter 
plug-in included with Feature Release 2, you must first uninstall 
the Unicenter plug-in for MetaFrame Feature Release 1.

Upgrading the Openview plug-in from Feature Release 1
-----------------------------------------------------
If you are using the Openview Network Manager plug-in included with MetaFrame 
XP, Feature Release 1 and want to upgrade to the plug-in included with MetaFrame 
XP Feature Release 2, you should uninstall the Feature Release 1 plug-in before 
installing the plug-in for Feature Release 2 or both plug-ins will appear under 
Add/Remove Programs.

Using Unicenter plug-in on French/Spanish Operating Systems
-----------------------------------------------------------
The user name "Administrator" is hard coded into the Unicenter Management
console and this can cause problems on a French or Spanish operating system.
If you are using a Unicenter management console with a French or Spanish 
operating system, you can use the English version of the Network Manager plug-in 
for Unicenter. However, to use the plug-in you need to set up an account called 
"Administrator," which has full administrative privileges. 

Enabling/Disabling the SNMP Agent from the Citrix Management Console
--------------------------------------------------------------------
If you change the "Enable SNMP Agent on All Servers" setting in
the Citrix Management Console, make sure the servers are operational. 
If a server is down when you change the setting, the new 
configuration is not used when you restart that server.
If a server is not using the correct configuration, apply the setting 
again in the Citrix Management Console and click OK.


Finding More Information
========================

Citrix provides technical support primarily through the Citrix 
Solutions Network (CSN) channel partners. Please contact your 
supplier for first-line support, or use Citrix Online Technical 
Support to find the nearest CSN partner. 

Citrix offers Online Technical Support Services at 
http://www.citrix.com/support/.

Online Technical Support Services include downloadable ICA 
clients, Frequently Asked Questions, service packs, an Online 
Knowledgebase, and interactive online support forums. 

Network Manager is certified as ca smart. See the ca smart Web site 
at http://www.ca.com/casmart for more information.

