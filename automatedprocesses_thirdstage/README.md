###################################################################################################################################################################
##
##  The report server hosts all processes for automation including but not limited to shell scripts acting as schedulers and python scripts to grab data from api's
##  and all correlating dependicies
##
###################################################################################################################################################################

### OVERVIEW ###


PLATFORM id's
=============

aol main account => dna
digitalconsulting => dc
adsymbiot => adsym
techmate => tm
adtransport => adtrans
springserve => springserve


ssh connection to server(you will need the .pem file on your local machine)

-->ssh -i /location/of/key/<name of key> ec2-user@<address>

ex:  ssh -i /etc/ssh/EpiphanyWinServer.pem ec2-user@34.212.37.5

================
Main directories
================
/etc/crontab
schedules times of execution of scripts

/usr/local/sbin/
contains automated scripts

/home/ec2-user/data-integration/epiphany_ktr/
all pentaho transformations

/home/ec2-user/data-integration/epiphany_kjb/
all pentaho jobs

/home/ec2-user/data-integration/epiphany_reports/xls/
storage for daily reports that are executed

=======
crontab
=======

to edit cron
--> sudo vim /etc/crontab -e
--> type "visual"

=======
CONSOLE
=======

simply run "console" from any window on the server and a complete overview of server/database will be displayed

--PARAMETERS TOP HEADER--
	-todays date
	-current hour --to compare updated hour throughout script
	-current user logged in

--CURRENT REALTIME TOTALS PER ACCOUNT
	-displays current hour updated in table
	-if "UPDATED" then the table is complete with 24 hours of table data
	-if "NOT UPDATED" either empty table or not-complete table
		-->re-run script

--EPIPHANY HOURLY TOTAL TODAY
	-displays hourly total and daily total

--YESTERDAY TOTAL REVENUE TAG LEVEL
	-displays total revenue per platform and daily total

--MONTHLY TOTAL BY DAY
	-display totals per day and by the current month

--YESTERDAY TOTAL REVENUE DOMAIN LEVEL
	-displays total revenue per platform and daily total

--YEARLY TOTAL BY MONTH
	-display total per month and for the year


=================
REAL-TIME SCRIPTS
=================

There are two ways to run scripts for real-time execution

--specific platform
	--> ex:  /usr/local/sbin/oath_core_last60.py <platformid>
		 /usr/local/sbin/oath_core_last60.py dna

--run all scripts for a specific table
	--> ex:  /usr/local/sbin/SCHEDULER_core_last60.sh

===============
DAILY PROCESSES
===============
--> /usr/local/sbin/SCHEDULER_daily_process.sh

DAILY SITE ADDITIONS

--> /usr/local/sbin/SCHEDULER_siteAdditions.sh

=========
REPORTING
=========
--BEFORE SENDING REPORTS, CHECK "console" FOR YESTERDAYS DATA IN THE TABLES UNDER "YESTERDAY TOTAL REVENUE TAG LEVEL"
--> If yesterday is not full,
	--> run /usr/local/sbin/SCHEDULER_daily_process.sh
** NOTE WHEN RUN /usr/local/sbin/SCHEDULER_daily_process.sh management and daily publisher reports should automatically send


=======
PENTAHO
=======

You should never have to run pentaho transformations or jobs on their own.  They are tied in with other process.  If you do however,
you will need to run them from /home/ec2-user/data-integration/

-- spoon for transformations

-- kitchen for jobs

**please ask for help when performing this operation

