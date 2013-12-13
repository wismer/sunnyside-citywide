sunnyside-citywide
==================

sunnyside-citywide

Hi folks. I use this program at work and it mostly concerns itself with two things - PDF reports that are generated from the main database of the agency and my own sqlite database (which stores data from parsing the PDF report). There are additional functions, like a rudimentary EDI file parser (x12ANSI file), an ftp automator for a specific ftp site, and a PDF generator that creates a summary of payments/denials. Most files this creates are csv files which is the required format for the accounting program that is used at this agency.

The program uses the following gems:

  sequel
  prawn
  money

and I start it off by typing <pre>ruby menu</pre>.

I don't know how to put this into a gem - but I will need to eventually, as I would have to install it for a co-worker. 

