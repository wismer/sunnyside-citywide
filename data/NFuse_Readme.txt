Citrix NFuse Classic
Version 1.7
Release Notes
(c) 2000-2002, Citrix Systems, Inc


Introduction
============

Thank you for your interest in Citrix NFuse Classic. Before you 
install NFuse Classic, please read this file for important 
information about the NFuse Classic software and documentation.

This Readme file includes the following information:

     * A description of available documentation
     * Instructions for getting support
     * A list of usage notes, restrictions, and known problems
       (VERY IMPORTANT--PLEASE READ)
       

Where to Find Documentation
===========================
For instructions on installing, configuring, and using NFuse 
Classic Version 1.7, see the NFuse Classic Administrator's Guide.
This manual is for system administrators and Web masters 
responsible for installing, configuring, and maintaining NFuse 
Classic. The manual is in Adobe PDF format, and is available on 
the Components CD-ROM and on the Citrix Web site 
(http://www.citrix.com/support) - select Product Documentation. 

Using the Adobe(R) Acrobat(R) Reader, you can view and
search these manuals electronically or print them for easy 
reference. To download the Adobe Acrobat Reader for free, 
please go to Adobe's Web site at http://www.adobe.com.

The NFuse Classic Administrator's Guide includes:

     * Instructions for installing NFuse Classic 

     * Instructions for configuring NFuse Classic 

     * Instructions for configuring ICA Client devices 
       for use with NFuse Classic 

     * Instructions for configuring NFuse Classic security

NFuse Classic also includes a Customizing NFuse Classic Guide 
for Citrix server administrators and Web masters who want to 
extend and customize the capabilities of NFuse Classic. This 
guide is available in Adobe PDF format (Customizing_NFuse.pdf) 
on the Components CD-ROM, and on the Citrix Web site.


Getting Support for NFuse Classic
=================================

Citrix provides technical support primarily through the Citrix 
Solutions Network (CSN) channel partners. Please contact your 
supplier for first-line support, or use Citrix Online Technical 
Support to find the nearest CSN partner.

Citrix offers Online Technical Support Services at 
http://www.citrix.com/support/. Online Technical Support Services 
include downloadable ICA Clients, Frequently Asked Questions 
pages, service packs, an Online Solution Knowledgebase, and 
interactive online support forums.


Usage Notes, Restrictions, and Known Problems
=============================================

This section includes important last-minute notes and tips.
PLEASE READ IT CAREFULLY BEFORE INSTALLING THE PRODUCT.


1.  If your MetaFrame XP farm is operating in interoperability 
    mode, some of the NFuse Classic features introduced since 
    NFuse 1.51 may be unavailable. 

2.  If you change the IP address or addresses of a MetaFrame 
    server running the Citrix XML Service, ticketing will not 
    function until you reboot the server. After changing a 
    MetaFrame server's IP address or addresses, make sure you 
    reboot the machine.

3.  If your Web server has a statically configured IP address, you 
    must define the Primary DNS suffix or a fully qualified DNS 
    domain name for the server. This can be done on Windows 2000 
    via My Network places -> Local Area Connection Properties -> 
    Internet Protocol properties. On Windows NT4, use Network 
    Neighborhood -> Properties -> Protocols - > TCP/IP protocol -> 
    Properties -> DNS tab. To verify correct configuration, check 
    to see if a valid DNS suffix is present in the following 
    registry key value data: 

    Key: HKLM\System\currentControlset\services\tcpip\parameters
    Value: Domain

4.  The version of NFuseErrorsResource.properties that is 
    installed in %SystemRoot%\Program Files\Citrix\NFuse displays 
    limited information with error messages. If you are having 
    trouble configuring NFuse Classic and would like to see 
    additional data with error messages, rename the existing file 
    and replace it with NFuseErrorsResource.properties.dbg. 
    Note - The additional information displayed can help an 
    attacker gain unauthorized access to your MetaFrame servers. 
    It should not be used in a production environment. 

5.  Users with Microsoft Internet Explorer 5.00.2920 may 
    experience logon problems when connecting to an NFuse Classic 
    Web site hosted on SUN/Netscape iPlanet 4.1 Web server. This 
    problem is caused by IE, which fails to maintain a session 
    field with the Web server. You can solve this problem by 
    upgrading the Internet Explorer to a later version.

6.  If the ICA Win32 Client is uninstalled shortly after using 
    Netscape to connect to a published application using NFuse 
    Classic, the file Npican.dll is not removed from the Netscape 
    Plug-in folder. When this happens, the NFuse Classic Login page 
    does not display the ICA Client download links. To fix this 
    problem, either manually remove the Npican.dll file or 
    re-install the ICA Win32 Client using a method other than the 
    NFuse Classic Login page.
    
7.  NFuse Classic on iPlanet Web Server 4.1 does not support the 
    use of extended characters such as the tilde (~) and accented 
    characters. Use of extended characters in user names, domains, 
    and passwords on these Web servers results in errors. 

8.  By default, iPlanet Web Server Version 4.1 has the "exe" 
    MIME-type associated with CGI scripts. This configuration 
    causes NFuse Classic's Web-based ICA Client installation 
    feature to fail. When a user visits an NFuse Classic page and 
    attempts to install an ICA Client, the Web server tries to 
    execute the ICA Client installation executable as a CGI script 
    instead of downloading the file to the user's Web browser. 
    Instead of receiving the file, the user sees notification of 
    Internal Server Error 500. 

    To allow NFuse Classic's Web-based ICA Client installation 
    feature to function on iPlanet Web servers, you must modify 
    the server's mime.types file. The following change enables 
    HTTP downloads of executables. In the mime.types file, change 
    the lines: 

        type=application/octet-stream exts=bin 
        type=magnus-internal/cgi exts=cgi,exe,bat 

    to the following:

        type=application/octet-stream exts=bin,exe 
        type=magnus-internal/cgi exts=cgi,bat 

9.  NFuse Classic installed on a Solaris 8 machine with 
    JVM 1.2.1.x does not properly execute due to a conflict 
    between the JVM and the NFuse Classic socket pooling feature. 
    With such a system in use, Web browsers display an error 
    during processing of the application list page that states that 
    no data can be displayed.

    To make NFuse Classic function on a Solaris 8 machine with a 
    1.2.1.x JVM, you must add the following entry to the NFuse.conf 
    file: PooledSockets=off. After adding the parameter, restart 
    your Web server.

    To support socket pooling on Solaris 8, you must use JVM 
    Version 1.2.2.x. Citrix has successfully verified execution of 
    NFuse Classic with socket pooling enabled on JVM 1.2.2.05a.

    For information on socket pooling and modifying the NFuse.conf
    file, see the topic "Configuring NFuse Classic Using 
    NFuse.conf" in the NFuse Classic Administrator's Guide.

10. If you install NFuse Classic 1.7 and the installation fails 
    for any reason, the Web server may not automatically restart. 
    Ensure you restart the Web server before you begin a 
    reinstallation.

11. If you install NFuse Classic as part of MetaFrame XP 
    installation and you choose drive remapping, you may need to 
    update the NFuse.properties file to reflect the new drive 
    mappings. If you do not do this, the following error message 
    is displayed when users attempt to log on to NFuse Classic: 
    "ERROR: The .gif cache directory specified by the 
    Nfuse_IconCache session field does not exist or could not be 
    accessed." 
 
    To fix this problem, edit the NFuse.properties file (located 
    in the software directory) with the new drive mappings; for 
    example, to change c:\ to m:\. Drive remapping occurs during 
    installation of MetaFrame. Therefore, make these changes after 
    installing MetaFrame, but before Feature Release 1 is 
    installed. 

12. A security feature has been introduced in NFuse Classic 1.7 
    that may cause existing NFuse Web sites to fail. Should an 
    existing NFuse Web site fail, try updating the NFuse.conf 
    file as follows:
    - Locate the UnrestrictedSessionFields parameter in NFuse.conf
    - Add to this list any session fields your Web site requires.
    For a full list of session fields, see the NFuse Classic 
    Administrator's Guide. 

    Note, however, that adding session fields to the 
    UnrestrictedSessionFields parameter may leave your Web site 
    more vulnerable to attack.

13. If you upgrade to NFuse Classic 1.7 as part of MetaFrame XP 
    installation on a MetaFrame 1.8A server that had drives 
    remapped, the installation of NFuse Classic may fail. This is 
    due to problems with the MetaFrame 1.8A drive mapping utility. 
    To fix this problem, you must update the COM+ Catalog. For 
    information about how to do this, please refer to article 
    CTX240747 on the Citrix Knowledge Base.
 
14. Users of PNAgent may experience problems connecting to an 
    NFuse Classic Web site hosted on an iPlanet Web server on 
    Solaris. A fix for this problem is available from Citrix 
    support.

15. Users of PNAgent may experience problems listing and launching 
    applications if the DNS domain name of the NFuse Classic Web 
    site they are using is not configured in the client's list of 
    search domains. To resolve this, either upgrade to the latest 
    available PNAgent version and add the Web server's DNS domain 
    to the clients search domain, or fully qualify all host names 
    in the config.xml file located on the Web server.

16. The embedded application feature of NFuse Classic does not 
    support the ICA Java Client running in a Netscape 4.7 browser 
    executing on MacOS 9. However, the version of Internet Explorer 
    that comes with MacOS 9 is supported.

17. When using Netscape running on Windows to access the embedded 
    application plugin feature of NFuse Classic, the window 
    containing the application may stay on users' screens even 
    though the application running inside has terminated. Users 
    should close this window if this occurs.

18. If the administrator changes the allowed methods for 
    authenticating to NFuse Classic, error messages may be displayed 
    to existing users. Users must close and restart any browsers 
    used to access NFuse Classic when the permitted authentication 
    methods are changed.

19. When using the Admin tool, some settings may be disabled if
    their value is not relevant to the current configuration. The 
    corresponding NFuse.conf settings are reset to their default 
    values. Citrix recommends that administrators take regular 
    backups of the NFuse.conf file.

20. In this release of NFuse Classic, the Web-Based ICA Client 
    Installation functionality, previously included on the NFuse 
    CD, is not included on the MetaFrame XP Feature Release 2 
    Components CD. The HTML pages that comprise the Web-Based ICA 
    Client Installation are available from the Citrix download 
    site: http://www.citrix.com/download.

21. When installing ICA Clients on UNIX platforms, note that the 
    path specified for the client CD icaweb directory must include 
    the icaweb directory itself (for example: /cdrom/cdrom0/icaweb).
    If this is omitted, the install will complete without errors 
    but client download will not function correctly.

22. On UNIX platforms, if NFuse Classic 1.7 is installed over an 
    existing installation, you are prompted for a directory in 
    which to back up the existing configuration files. If a 
    directory is not supplied, the configuration files are still 
    backed up. By default, a new directory called "backup" is 
    created in which existing configuration files are backed up. 

23. If Oracle 9i is installed on a MetaFrame XP Feature Release 2 
    server, NFuse Classic fails to appear as the default Web page 
    on that server. This is due to the Oracle Web server consuming 
    HTTP requests. To restore NFuse Classic, shut down the 
    OracleOraHome90HTTPServer service.

24. Citrix recommends that if you configure NFuse Classic to allow 
    users to log on using a smart card, you should configure the 
    Login page so it is accessible using HTTPS connections only.

25. If smart card authentication is enabled and IIS is configured 
    to use a port other than 443 for HTTPS traffic, smart card 
    users accessing NFuse Classic over plain HTTP will see an 
    error message. Administrators are advised to publish the full 
    HTTPS URL to all smart card users; for example:
    https://nfuse.company.com:449/Citrix/NFuse17

26. Under some circumstances the NFuse Classic 1.7 uninstaller
    may fail. Possible causes are:
    - Insufficient registry access for the uninstaller
    - The CTX_NFUSE_ADMIN user is no longer present
    - The uninstaller has insufficient permissions to remove the 
      CTX_NFUSE_ADMIN user
    - IIS has been removed from the system after NFuse Classic was 
      installed
    - The Microsoft JVM has been removed from the system

27. When Citrix Secure Gateway is in use, NFuse Classic does not 
    always disable the ICA Client auto-reconnect feature. Users of 
    NFuse Classic with Citrix Secure Gateway may find that a 
    reconnection dialog box is displayed if the ICA connection is
    broken. It is not possible to reconnect in this way when using 
    Citrix Secure Gateway. To configure NFuse Classic to disable 
    the auto-reconnect feature in clients, change the following 
    lines in the template.ica file:

    <[NFuse_IfSessionField sessionfield="NFuse_CSG_Enable" value="On"]>
    TransportReconnectEnabled=Off
    <[/NFuse_IfSessionField]>

    to this:
  
    TransportReconnectEnabled=Off

    This disables the auto-reconnect feature for all NFuse Classic 
    users.

28. Using NFuse Classic, you can configure the enhanced Content Publishing 
    feature to associate published content with a published application on 
    a MetaFrame XP server. 
    To make the published content open correctly in the appropriate 
    application, you need to have an ICA client installed on the local 
    device. If a local client is not available, the ICA Connection will 
    fail. Note that you need a locally installed client even if you 
    configure the application to launch with the application embedded 
    into the HTML page (a method which does not usually require a locally 
    installed client for other published applications).
    See your ICA Client documentation for information about system 
    requirements for ICA Clients and for installation instructions.


Documentation Errata
====================
1.  The NFuse Classic Administrator's Guide states that the 
    IBM HTTP 1.3.12.2 Web server is supported on the Redhat 7.1 
    platform with WebSphere 3.5.2. This is incorrect; WebSphere 3.5.2 
    is not supported on Redhat 7.1. 














