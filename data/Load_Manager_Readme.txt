Citrix Systems, Inc.
READ ME 
Citrix Load Manager(TM)
May 2002


INTRODUCTION
------------
This document contains last-minute information on Citrix
Load Manager. Load Manager enables you to manage the 
user and application load among the MetaFrame XP servers
in your MetaFrame server farm, ensuring high service levels
for your end users.

SYSTEM REQUIREMENTS
-------------------
See the Citrix MetaFrame XP Administrator's Guide for a
complete description of the system requirements for
MetaFrame XP servers.

WHERE TO FIND DOCUMENTATION
---------------------------
Load Manager includes the following documentation:

* This readme file

* Online help for all Load Manager features, integrated
  into the help system for Citrix Management Console

* The Citrix Load Manager Getting Started guide, in Adobe
  Portable Document format (Load_Manager_Get_Started.pdf)

  Use the Adobe Acrobat Reader program to view
  PDF files. You can download Acrobat Reader for free from
  Adobe's Web site at http://www.adobe.com. 

This file and the Citrix Load Manager Getting Started guide
are available in the following locations:

* In the \Doc directory of your MetaFrame XP Server CD-ROM

* Installed into the documentation folder of your
  MetaFrame XP server. From the Start Menu, choose 
  Start>Programs>Citrix>Documentation.

* On the Citrix Web site at http://www.citrix.com/support,
  select the Product Documentation tab. You can check the
  Product Documentation area of the Web site at any time for the
  latest updates to Citrix technical manuals. Any updates to this
  manual published after the release of this product will be
  posted there.


LIMITATIONS and KNOWN ISSUES
----------------------------

Load Manager Functionality
--------------------------

LOAD BALANCING. Citrix cannot guarantee that 
servers will not overload when using Load Manager. Because
the data store can take a few seconds to update and requests
for published applications to open can also take a few seconds,
connections may continue to be directed to a loaded server
before its status is updated in the data store. Therefore,
the threshold of a rule should never be the absolute maximum
value that a server can handle. For example, if a certain 
threshold of CPU usage makes a server unusable, set the 
threshold to a lower setting.

For a server to become overloaded, all servers in the farm 
need to be close to fully loaded and connections must be 
coming in more quickly than the data store can update. 
In this case, it is possible for the load to exceed the 
threshold of a rule.

LOAD MANAGER AND PUBLISHED APPLICATIONS. You can publish
applications, but you cannot load-balance those published 
applications on servers whose licenses do not enable Load
Manager (such as MetaFrame XPs).
 

ICA CLIENTS USING TCP/IP+HTTP. If the server location for ICA 
Clients using TCP/IP+HTTP is not set to the data collector 
and the server farm receives a high level of ICA connection 
requests, updates to the load balancing data for servers in 
the farm may be delayed. This will affect the optimization 
of load balancing. It is recommended that the server 
location for ICA Clients using TCP/IP+HTTP is set to the 
data collector for the zone.

CITRIX-PROVIDED LOAD EVALUATORS. The Default load evaluator
threshold is 100 sessions per server. If your server is
required to handle 100 or more sessions, Citrix recommends 
that the server be at least a four-processor machine with
2-4GB of RAM and two RAID controllers. If your server does
not provide this configuration, either duplicate the Default
load evaluator and lower the setting or use the Advanced
load evaluator.

The Advanced load evaluator is provided as an example evaluator.
This evaluator is configured to function on a single CPU Pentium
400 MHz machine with 192MB of RAM and a SCSI Ultra Wide 
Controller. If the servers that this evaluator is being applied 
to differ from this configuration, it is recommended that you 
create a new load evaluator and set appropriate values for the included rules. 


Load Manager Rules
------------------

CHANGES TO RULE SCHEDULE. If you make changes to an evaluator schedule, you need to add or remove rules from the evaluator for the schedule change to take effect.
If you make changes to a evaluator schedule, you may find that the schedule does not appear to be used correctly. If so, remove and replace a rule from those in the evaluator to make the schedule changes take effect.

DISK I/O AND DISK OPERATIONS RULES. To use the Disk I/O 
and Disk Operations rules, you must run "diskperf -y" at 
the command line.

LICENSE THRESHOLD. For local (assigned) licenses, a full load 
is returned when the number of "assigned" licenses for a server 
is greater than the set value. For pooled licenses (unassigned
licenses that remain in the licensing pool until a user connects), 
a full load is returned when the number of "pooled" licenses 
on a server (and not the farm) is greater than 
the set value.

IP RANGE. Only IP addresses are recognized by this rule.
All other protocol addresses are ignored.

IP RANGE RULE WITH NFUSE. The IP Range rule will be ignored 
when connections are launched from NFuse. Only if you allow client 
enumerations with NFuse will the IP Range rule be applied.

The following rules have default values that are based on a single
CPU Pentium 400 MHz machine with 192MB of RAM and a SCSI Ultra 
Wide Controller. 

Context Switches
Disk I/O
Disk Operations
Page Faults
Page Swaps

If the servers that these rules are being applied to differ from 
this configuration, Citrix recommends that you change the default 
values.

The CPU and Memory Usage rules calculate the percentage 
load displayed based on a scale of 100, not on the value 
entered in the upper threshold. The Context Switches, 
Disk I/O, Disk Operations, Page Faults, and Page Swap 
rules base the percentage load displayed on the value 
that is entered in the upper threshold value and 0.


Interoperability Mode
---------------------

LICENSES. If licenses are exhausted on one subnet in
interoperability mode, ICA connections may not be directed
to load-managed servers on another subnet that has free
licenses. Add the license threshold rule to the servers
in different subnets for connections to be redirected
correctly.

APPLICATION USER LOAD RULE. If you set up an existing
farm to run both MetaFrame 1.8 for Windows and MetaFrame
XPa or XPe servers, the master browser in MetaFrame 1.8
for Windows is used for load balancing. Loads for the
MetaFrame 1.8 for Windows and MetaFrame XPa or XPe servers
are calculated in the same way, but an evaluator created
with the Application User Load rule is recognized only
in MetaFrame XPa or XPe and cannot be applied to the
MetaFrame 1.8 for Windows product.

APPLICATION LOAD RULE. In interoperability mode, 
server loads are determined by the server load evaluator 
only. If an application load evaluator has been assigned, 
it is ignored in this mode.

DEFAULT LOAD EVALUATOR. Always use the Default load
evaluator when the farm is in interoperability mode.
If you use rules other than Server User Load 
in interoperability mode, configuring the rules 
to load-balance properly between the MetaFrame 1.8 
machines and MetaFrame XP machines will be difficult. 

IP RANGE. In interoperability mode, the IP Range rule allows
published applications to be connected even though the IP
address for an ICA Client is set as "denied." The session
should be denied, but the ICA Client can still connect to
the published application.

COMMAND LINE. In interoperability mode, do not use 
the "qfarm /load" command; use "qserver /load" instead. 
Because "qfarm" and "qserver" pull their information 
from different sources, these commands will not show 
identical values.


CONTACT INFORMATION
-------------------
Citrix Systems, Inc.
6400 NW 6th Way
Fort Lauderdale, Florida 33309 USA
954-267-3000
http://www.citrix.com
