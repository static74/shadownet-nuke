#!/usr/bin/perl
use IO::File;
use File::Copy;
use File::Glob;
use Cwd qw(cwd);

use warnings;
use strict;

my $cwd = cwd;

print "$cwd\n";
my $backupDir = "$cwd/backup_SP_before_convert";



print "$backupDir\n";

#######################################
#create a backup directory
#######################################
 if ( ! -d $backupDir ) 
 { 
   mkdir( $backupDir ) or die "Couldn't create $backupDir directory, $!";
   print "Directory created successfully\n";
 }


#######################################
#set up variables for find and replace
#######################################
my $find = "<useNodeLocation>true</useNodeLocation>";
my $replace = "<useNodeLocation>false</useNodeLocation>";

my $targetReplace = "true";
my $replacement = "false";

my $filename;
my $line;

#########################################################################
#read all the files in the directory starting with plan.xml into an array
#########################################################################

my @allfilesDir = glob("plan.xml*");


############################################################################################
# 1. loop through each file
# 2. copy a backup of the file into the backup directory
# 3. open each file and replace any line matching "<useNodeLocation>true</useNodeLocation>";
#    with "<useNodeLocation>false</useNodeLocation>";
#    and save to a new file with the same name but ending in _new
# 4. delete the orginal file
# 5. rename the modified file with the _new suffix to the original file name.
#
############################################################################################

foreach my $f (@allfilesDir) {
  if( -f "$cwd/$f"){
	  
	  print "$cwd/$f\n";
	  print "$backupDir/$f\n";
	  	    
	  ####################################
	  #create a backup of all the sp files
	  #####################################
	  if(!copy "$cwd/$f", "$backupDir/$f"){
		  print "Some error: $!";
	  } 	 
	  
	  ######################################
	  # open sp file for reading
	  ########################################
	  open(my $fh, "<", "$f") or die "Can't open $f: $!\n";
	  
	  ########################################
	  # open a new file for writing
	  #########################################
	  my $fileout =  $f . _new;
	  
	  open(my $fhout, ">", $fileout) or die "Can't open newfile : $!\n";
	  
	  #########################################
	  #read all the sp file lines into an array
	  #########################################
	  my @lines = <$fh>;
	  my $array_length = @lines;
	  print $array_length;
	  #close the file
	  close($fh);
	  
	  ######################################################################################
	  #check each line and replace any with UseNodeLocation<true> with UseNodeLocation<false>
	  ######################################################################################
	 foreach my $element (@lines) {
		if($element =~ /$find/){
			$element =~ s/$targetReplace/$replacement/;
		}#end if
	 
		print $fhout "$element";
	 
	}#end for each @lines
	
	###############################
	#end the file with a new line
	#############################
	print $fhout "\n";

    #################################
	#close the outfile and delete the original
	###################################
	close($fhout);
	print "unlinking $f";
	unlink($f) or die "Could not delete $f!\n";
	
	
  }
} # end for each file


    #################################################
	# rename the _new files to the original file names
	#################################################
	my @arr;
	my $fileName;
	my @allPlansDir = glob("plan.xml*_new");
	foreach my $sp (@allPlansDir){
		print "$sp\n";
		my $loc = index($sp, "_new");
		$fileName = substr($sp, 0, $loc);
		print "$sp\n";
	    rename("$sp", "$fileName");
		print "change $sp to $fileName";
    }
	
		
		

	

	
	
	
  











