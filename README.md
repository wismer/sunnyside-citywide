sunnyside-citywide
==================

I wrote this gem for a few reasons: 

<ol>
  <li>To be able to make my life as a glorified data entry clerk for a home health care agency and their billing department more tolerable.</li>
  <li>To make it simple enough and easy to use so that my co workers could use it in case that I am not around.</li>
  <li>To learn how to use GitHub.</li>
  <li>To learn more about ruby and programming in general.</li>
</ol>
As of this writing, the gem is incomplete and due to it's incredibly specific purpose, it would only work for this agency that I work for. 

First, some context: 
<ol>
  <li>
    There are two databases that are physically and electronically divorced from each other. One contains the fiscal data for the agency, the other contains everything else (i.e. 23 providers, several thousand clients, several thousand more aides clocking in and out, sometimes daily, etc.). They, unfortunately, do have data that is in both systems but since they do not talk to each other, we have to do a significant amount of data-entry to make sure they reconcile each other.
  </li> 
  <li>
    The fiscal database is run through the program FUND-EZ (Microsoft SQL 2005). It's not suited for this kind of non-profit work so it created problems for me initially. Entering in payments was a slow, onerous process. I had to enter one invoice at a time when there could be hundreds for a single payment. If there was a denial for a claim (or invoice), there was no easy way to record it. 
  </li>
  <li>
    The other database is run by a company called SanData. They use an SCOpen Server UNIX OS and the program that we're forced to use is a text-based GUI. It is not user friendly for numerous reasons. If you want to export any kind of data into an appreciable format, for example, the only one that is available to you is PDF. That is well and good, and their formatting is somewhat understandable, but often (and I mean at least once a week) we have to print off a report that can be in excess of a hundred pages. If we want to put it into an excel format, we either have to convert the pdf to text, then spend a good hour in excel to format it appropriately or purchase a program that would cost several hundred, money which this agency does not have.
  </li>
  <li>  
    Other agencies in this part of the health care industry usually handle financial transactions over health care claims through EDI or <a href="http://en.wikipedia.org/wiki/Electronic_data_interchange">Electronic Data Interchange</a>. Though it predates XML, it was still more useful than receiving an Explanation of Benefits/Payment that could be several hundred pages long. Though my agency was interested in adopting this standard of claim settlement, it was not equipped to do so.
  </li>
</ol>

<p>With these challenges in mind, the most useful thing that could be done was to try to mimic the data that the SanData DB and the FUND-EZ DB were supposed to share. So, by relying on the numerous 100+ page PDF reports, I was able to parse them (after significant trial and error) with the gem pdf-reader. Storing that data was another matter, so I used the gem sequel (again, after much trial and error). Once secured in my own .db file, I could specify data by either manually typing in a parameter, like the date the invoice was posted or the check number, and then have the data be exported into a csv file (which can then be used to import into FUND-EZ).</p>

<p>The most challenging aspect of creating these tools was the EDI interpreter. After some time, the agency I work for adopted the use of these files for a few business partners (providers). Though I was able to create one that inteprets the 835 variant of the file format and get the necessary information, there are still chunks of data that I simply do not know how to parse. There are gems that would handle this for me, but for some reason, the business partners use an older format of EDI (which the gems do not support).</p>

= TO DO
<ul>
  <li>Link the <code>Sequel.connect(DB)</code> to the Sunnyside's network drive and test to see if it works.</li>
  <li>Test and implement the new EDI parser</li>
  <li>Add functionality for Sunnyside HC Project</li>
  <li>Populate FUND-EZ ids in the CLIENT table of the DB</li>
  <li>Custom search function for specific clients, invoices and services</li>
</ul>