#!/usr/bin/perl -w

#********************************************************************************************************************************************
# Programmed by: Ozgur M. Polat
# E-mail: ozgurpolat@msn.com
# Licence: GNU General Public Licence (www.gnu.org)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#********************************************************************************************************************************************
# MAINLOOP START ****************************************************************************************************************************
#********************************************************************************************************************************************

use strict;
use warnings;
use Tk;								# Allows you to use Perl/Tk
use Tk::ErrorDialog;						# Allows you to use ErrorDialog widget
use Tk::NoteBook;   						# Allows you to use NoteBook widget
use Tk::ROText;							# Allows you to use ROText widget
use Tk::Menu;          						# Allows you to create menus
use Tk::BrowseEntry;   						# Allows you to use BrowseEntry widget
use Tk::Balloon;       						# Allows you to use balloon widgets
use Tk::TextUndo;						# Allows you to use TextUndo widget
use Tk::ProgressBar;						# Allows you to use ProgressBar widget
use Tk::DirTree;						# Allows you to use DirTree widget
use subs qw/edit_menuitems file_menuitems help_menuitems/;	# Tels program to use sub functions for creating menus
use Time::Local;						# Allows you to use functions for date and time
use File::stat;        						# Allows you to use functions for date and time
use POSIX 'strftime';  						# Allows you to use functions for date and time and some maths functions
use Cwd; 							# Cwd gets the current working directory,			
use Math::Trig;							# Allows you to use trigonometric functions

#if ($^O eq 'MSWin32') {
	#use Win32::Clipboard;					# Allows you to get and modify the contents of the clipboard in windows systems
#}
				
#********************************************************************************************************************************************
# VARIABLES  ********************************************************************************************************************************
#********************************************************************************************************************************************

my $Dir_Tree;
my $Dir_Tree_Popup;
use vars qw/$Dir_Tree_popanchor $Dir_Tree_popover $Dir_Tree_overanchor/;

my $btn_readbdf;			# Button to read bdf file
my $btn_selectbdf;			# Button to select bdf files
my $btn_selectf06;			# Button to select f06 files
my $btnInterface;		# Button to start extracting Interface loads
my $btnFasteners;		# Button to start extracting Fastener loads
my $btnGamahCoupling;		# Button to extract freebody loads
my $BUTTON_EXIT;			# Button to exit the program


my $l_time = localtime;	
my $gm_time = gmtime;

my $FileDir = "";			# This is the selected directory for sorted files
my $CurrentDir = cwd;

my $ProgrammingLog_dat = "$CurrentDir/ProgrammingLog.dat";

my $filename_select = "";		# Name of the f06 file to select (to be sorted)

my $Drtree;				# This is the directory tree for selecting multiple files

my $mw = MainWindow->new(-title => "Interface 2.1 Pre-realease");		# Opens up the main window and gives it a title 

my $MainText;

my @popup_opts;

my @f06FileArray = ();		# This is the array that contains f06 file names and their location
my $f06FileArray_i = 0;		# This is a counter for @f06FileArray = ()
my @f06files = ();		# This is the array for selecting multiple files
my $Listbox_select_f06;		# This is the listbox for selecting multiple files

my @bdfFileArray = ();		# This is the array that contains bdf file names and their location
my $bdfFileArray_i = 0;		# This is a counter for @bdfFileArray = ()
my @bdffiles = ();		# This is the array for selecting multiple files
my $Listbox_select_bdf;		# This is the listbox for selecting multiple files

my @txtFileArray = ();		# This is the array that contains txt file names and their location
my $txtFileArray_i = 0;		# This is a counter for @txtFileArray = ()
my @txtfiles = ();		# This is the array for selecting multiple files
my $Listbox_select_txt;		# This is the listbox for selecting multiple files

my $yesno_f06;
my $db_f06;

my $labelf06_1;
my $labelf06_2;

my $yesno_bdf;
my $db_bdf;

my $labelbdf_1;
my $labelbdf_2;

my $yesno_txt;
my $db_txt;

my $labeltxt_1;
my $labeltxt_2;


my @datFileArray = ();			# This is the array that contains file names with dat extension and their location
my @gpfbFileArray = ();			# This is the array that contains file names with gpfb extension and their location

my @mpcforcesFileArray = ();		# This is the array that contains file names with mpc extension and their location
my @mpcsummedFileArray = ();			# This is the array that contains file names with mpc extension and their location
my @mpcdatFileArray = ();		# This is the array that contains file names with dat extension and their location

my @interfaceallFileArray = ();		# This is the array that contains file names with interfaceall extension and their location
my @interfaceresultsFileArray = ();	# This is the array that contains file names with interfaceall extension and their location
my @interfacesummedFileArray = (); 	# This is the array that contains file names with interfacesummed extension and their location
my @interfacedataFileArray = ();	# This is the array that contains file names with interfacedata extension and their location

my @freebodydatFileArray = ();		# This is the array that contains file names with freebodydat extension and their location

my @freebodyloadsFileArray = ();	# This is the array that contains file names with freebodydat extension and their location
my $freebodyloadsFileArray_i = 0;	# This is a counter for @freebodyloadsFileArray = ()

my @freebodytransformedFileArray = ();	# This is the array that contains file names with freebodydat extension and their location

my @freebodytempFileArray = ();		# This is the array that contains file names with freebodydat extension and their location

my @freebodytemp2FileArray = ();	# This is the array that contains file names with freebodydat extension and their location
	
my @freebodymaxminsFileArray = ();	# This is the array that contains file names with freebodydat extension and their location

my @cbardatFileArray = ();
my @cbeamdatFileArray = ();
my @cbushdatFileArray = ();
my @croddatFileArray = ();


my $NewCoordFlag = 0;			# If the user has entered new coordinate definitions, This value is 1, 
					# if @NodeIDArray is empty cannot read bdf file unless this value is turned on.

my $InterfaceFlag = 0;			# If the user has entered interface points definitions, This value is 1, 
					# Size of @NodeIDArray > 0

my $MPCFlag = 0;			# If the user has entered MPC node definitions, This value is 1, 
					# Size of @MPCNodeIDArray > 0

my $GamahFlag = 0;			# If the user has entered interface points definitions, This value is 1, 
					# Size of @NodeIDArray > 0

my $FastenerFlag = 0;			# If the user has entered CBAR, CBEAM .. element ids, This value is 1, 
					# if @NodeIDArray is empty cannot read bdf file unless this value is turned on.

my @ElmIDArray = ();
my $EIDCnt = 0;

my @NodeIDArray = ();			# Contains the selected node ids
my $NIACnt = 0;				# Counter for @NodeIDArray

my @MPCNodeIDArray = ();		# Contains the selected node ids
my $MPCNIDCnt = 0;			# Counter for @MPCNodeIDArray

my @DispNodeIDArray = ();		# Contains the selected node ids
my $DNIDCnt = 0;			# Counter for @MPCNodeIDArray

my @ElmRangeInfoArray = ();		
my $ERIACnt = 0;

my @NodeRangeInfoArray = ();		
my $NRIACnt = 0;

my @InterfaceInfoArray = ();		# An array of all summation point ids and node ids and summation point coordinate
my $IIACnt = 0;

my @InterfaceErrorArray = ();		# An array of errors occured while reading the text file
my $IEACnt = 0;

my @MPCInfoArray = ();			# An array of all MPC and node ids and summation point coordinate
my $MPCIACnt = 0;

my @MPCErrorArray = ();			# An array of errors occured while reading the text file
my $MPCEACnt = 0;

my @GamahErrorArray = ();		# An array of all summation point ids and node ids and summation point coordinate
my $GEACnt = 0;

my @RefCoordErrorArray = ();
my $RCEACnt = 0;


my @readBdfFileReturnArray = ();	# @ReturnArray = (@NodeXYZCoordArray,@MPCNodeXYZCoordArray,@FreebodyNodeXYZCoordArray);
my $SizeRBFRA = @readBdfFileReturnArray;

my @NodeXYZCoordArray = ();
my @MPCNodeXYZCoordArray = ();
my @FreebodyNodeXYZCoordArray = ();
my @DispNodeXYZCoordArray = ();


my @CoordIDArray = ();		# Array that contains all coordinate ids found in the bdf file
my $CIDACnt = 0;		# Counter for @CoordIDArray

my @CoordInfoArray = ();	# Array that contains coordinate id information from the bdf file
my $CIACnt = 0;			# Counter for @CoordInfoArray

my @CoordInfoArrayTmp = ();	# Array that contains coordinate id information (vectors) entered by the user
my $CIATCnt = 0;		# Counter for @CoordIDArrayTmp

my @CoordA1Array = ();	my @CoordA2Array = ();	my @CoordA3Array = ();		# Arrays to record A1, A2, A3 points of each coordinate found in the bdf file
my @CoordB1Array = ();	my @CoordB2Array = ();	my @CoordB3Array = ();		# Arrays to record B1, B2, B3 points of each coordinate found in the bdf file
my @CoordC1Array = ();	my @CoordC2Array = ();	my @CoordC3Array = ();		# Arrays to record C1, C2, C3 points of each coordinate found in the bdf file

my $A1 = 0; my $A2 = 0; my $A3 = 0;		# Current values of A1, A2, A3
my $B1 = 0, my $B2 = 0; my $B3 = 0;		# Current values of B1, B2, B3
my $C1 = 0; my $C2 = 0; my $C3 = 0;		# Current values of C1, C2, C3

# Global variables for extracting freebody loads

my @FreebodyAnalysisCoordArray = ();
my $BACACnt = 0;

my @FreebodyEntryLineArray = ();	# Contains the selected node ids for freebody loads

my @FreebodyNodeIDArray = ();		# Contains the selected node ids for freebody loads
my $FBNIACnt = 0;			# Counter for @FreebodyNodeIDArray

my @FreebodyElmIDArray = ();		# Contains the connecting element ids for freebody loads
my $FBEIACnt = 0;			# Counter for @FreebodyElmIDArray

my @FreebodyCoordIDArray = ();		# Contains the connecting coord. ids for freebody loads
my $FBCIACnt = 0;			# Counter for @FreebodyCoordIDArray

my @FreebodyMaxMinArray = ();		# Contains 
my $FBMMACnt = 0;			# Counter for @FreebodyMaxMinArray

# ************* Gamah Coupling Displacement Variables ********************************************************************************

# ************* Creating Example Text Files in the Current Directorx *****************************************************************

&createExampleTxt($CurrentDir);
		    
# ************************************************************************************************************************************

print ("Please wait while Interface.pl is starting up...\nLocal time:$l_time GMT:$gm_time\n");

# *********** SETTING UP MENU ITEMS **************************************************************************************************
# *********** BINDING ACCELERATORS TO $mw ********************************************************************************************
# *********** Binding accelerators mean being able to use ctrl-(Key)******************************************************************

# file_menuitems:

$mw->bind('<Control-l>', \&select_bdf);		# Ctrl-l to select multiple files
$mw->bind('<Control-m>', \&select_f06);		# Ctrl-l to select multiple files
$mw->bind('<Control-b>', \&remove_bdf);  	# Ctrl-b to remove a file
$mw->bind('<Control-u>', \&remove_f06);  	# Ctrl-u to remove a file
$mw->bind('<Control-q>', \&exit_program);  	# Ctrl-w to exit from the software

# ****** IMPORTANT ****  WHEN BINDING Control-v DO NOT CALL paste_text because IT PRINTS THE CLIPBOARD TWICE  

# help_menuitems

$mw ->bind('<F1>', 	 \&help);		# F1 for help
$mw ->bind('<F10>',	 \&html_help);		# F10 for Html Help

# *********** SETTING UP MAIN WINDOW *************************************************************************************************
# ************************************************************************************************************************************

$mw -> withdraw;
$mw -> deiconify;		# Show Interface.pl
$mw -> focus;

#if ($^O eq 'MSWin32') {
	#my $icon_image = $mw->Photo(-file=>'images/interface.bmp');# Tells the program where the icon image for the main window is 
	#$mw->Icon(-image => $icon_image); # Sets the icon 
#}

my $height;$height = $mw -> screenheight;
my $width; $width = $mw -> screenwidth;

if ($height < 768){

	my $ans_to_screen_size = $mw -> messageBox(-title => 'Screen resolution is too small!',
   		-message => 'The screen resolution of your monitor must be at least 1024 by 768 pixels. Please adjust your screen resolution!',
   		-type => 'Ok', -icon => 'question');
    	if($ans_to_screen_size eq 'ok') {
    	   exit;
    	}

}

my $minheight = ($height*(97/100));	# Start of setting the window size
my $minwidth = ($width*(99/100));

$mw -> minsize($minwidth,$minheight);
$mw -> geometry('+0+0');			# End of setting the window size

# ************************************************************************************************************************************
# MAIN TEXT, ENTRY AND LISTBOXES AND BUTTONS *****************************************************************************************
# ************************************************************************************************************************************

$MainText = $mw -> Scrolled("TextUndo", 
			    -wrap => 'none', 
			    -scrollbars => 'se', 
			    #-font => 'Courier -12'
			    ) -> place(-relx => 0.0, -rely => 0.72,-relwidth => 1.0, -relheight => 0.28); 


$mw -> Label(	-text => "1. Select bdf filepath/name by using the button below:"
		#-font => 'Courier -12'
						) -> place(-relx => 0.01, -rely => 0.01);


$btn_selectbdf = $mw -> Button(-text =>"Select single or multiple bdf files",
			       -font=> 'Helvetica -15 bold', 
			       -state => 'normal', 
			       -height => 1, 
			       -width => 35, 
			       -command => \&select_bdf) -> place(-relx=> 0.02, -rely => 0.04);
			    
$mw -> Label( 	-text => "(2*). Create Ref. Coords by using two vectors. Enter the origin (X Y Z) and the"
		#-font => 'Courier -12'
						) -> place(-relx => 0.01, -rely => 0.09);

$mw -> Label(	-text => "directions of 2 vectors: X Axis (X1 Y1 Z1), XY Plane (X2 Y2 Z2) in Coord 0."
		#-font => 'Courier -12'
						) -> place(-relx => 0.02, -rely => 0.11);

$mw -> Label(	-text => "Enter values or right-click to load from a text. Enter \"del\" to clear. Example\:"
		#-font => 'Courier -12'
						)-> place(-relx => 0.02, -rely => 0.13);

$mw -> Label(	-text => "Coord 1,(0.0 0.0 0.0),(0.57735 0.57735 -0.57735),(0.57735 0.57735 0.57735)"
		#-font => 'Courier -12'
						)-> place(-relx => 0.02, -rely => 0.15);

my $EntryRefCoordTxt = "Enter Coord ID, Origin, Vector Direction 1 (X axis), Vector Direction 2 (XY plane)";

my $EntryRefCoord = $mw -> Entry( -relief => 'groove',
			          -background => 'white',
				  -width => 80,  
 			          -state => 'normal',
				  #-font => 'Courier -12',
			          -textvariable => \$EntryRefCoordTxt) -> place(-relx => 0.02, -rely => 0.18);

$EntryRefCoord -> bind('<Control-v>' => sub{

	$EntryRefCoord -> delete('sel.first', 'sel.last')
		if $EntryRefCoord -> selectionPresent();

});

my $EntryRefCoordMessageCnt = 0;

$EntryRefCoord -> bind('<Button-1>', sub{
	
	$EntryRefCoordMessageCnt++;

	if($EntryRefCoordMessageCnt <= 1){
		
		$MainText -> delete("0.0", "end");
		$MainText -> insert("end", "\nExample\: Coord 1,(0.0 0.0 0.0),(0.57735 0.57735 -0.57735),(0.57735 0.57735 0.57735)\n");
		
		$mw->update;
	}
});

$EntryRefCoord -> bind('<Button-3>'=> \&EntryRefCoord_Popup); 

my $EntryRefCoord_Popup;
my $EntryRefCoord_popanchor  = 'nw';
my $EntryRefCoord_popover = $EntryRefCoord;
my $EntryRefCoord_overanchor  = 'c';

sub EntryRefCoord_Popup{
    $EntryRefCoord_Popup -> Popup(-popanchor  => $EntryRefCoord_popanchor,
				  -overanchor => $EntryRefCoord_overanchor,
				  -popover    => $EntryRefCoord_popover,
				 );
}

$EntryRefCoord_Popup = $mw -> Menu(-tearoff => 0, -menuitems => 
[
 					
	[Button  => 'Load from a text file', 
	 -command => sub {

		my $SizeBFA = @bdfFileArray;
		my $errorflag = 0;

		my @CoordIDCheckArray = ();
		my $CICACnt = 0;
		
		my $InfoLine = "";		

		@CoordInfoArrayTmp = ();
		$CIATCnt = 0;

		if($SizeBFA == 0){

			$MainText-> delete("1.0", "end");
			$MainText->insert("end", "\nPlease select a bdf file to read!\n\n");
			$mw->update;	

		}else{

			&select_txt;

			my $RefCoordFilename = $txtFileArray[0];

			@RefCoordErrorArray = ();
			$RCEACnt = 0;

			$RefCoordErrorArray[$RCEACnt] = "Following errors occured:";
			$RCEACnt++;
						
			my $linecnt = 1;

			if( (defined $RefCoordFilename) && ($RefCoordFilename ne "") ){

				open (FH, "<$RefCoordFilename") or die "Could not open $RefCoordFilename";
				
				while(<FH>) {
					
					my @LineSummaryArray = split(",", $_);
					my $SizeETA = @LineSummaryArray;
					
					if($SizeETA == 4){
					
						if($LineSummaryArray[0] =~ /^Coord(\s+)(\d+)/   || $LineSummaryArray[0] =~ /^coord(\s+)(\d+)/ ||
						   $LineSummaryArray[0] =~ /\s+Coord(\s+)(\d+)/ || $LineSummaryArray[0] =~ /\s+coord(\s+)(\d+)/){
						   
						   	#print "$linecnt: $2 ";
							
							$CoordIDCheckArray[$CICACnt] = $2;
							$CICACnt++;
							
							$InfoLine = "$2" . ",";
						}else{
						
							$errorflag = 1;
							$RefCoordErrorArray[$RCEACnt] = "Line $linecnt: Please check the coord id format!";
							$RCEACnt++;						
						}
						
						if($LineSummaryArray[1] =~ /\((\d+\.\d+||-\d+\.\d+)\s+(\d+\.\d+||-\d+\.\d+)\s+(\d+\.\d+||-\d+\.\d+)\)/){
						
							#print "$1 $2 $3 ";
							$InfoLine = $InfoLine . "$1" . "," . "$2" . "," . "$3" . ",";
						
						}else{
						
							$errorflag = 1;
							$RefCoordErrorArray[$RCEACnt] = "Line $linecnt: Please check origin of the coordinate!";
							$RCEACnt++;						
						}

						if($LineSummaryArray[2] =~ /\((\d+\.\d+||-\d+\.\d+)\s+(\d+\.\d+||-\d+\.\d+)\s+(\d+\.\d+||-\d+\.\d+)\)/){
						
							#print "$1 $2 $3 ";
							$InfoLine = $InfoLine . "$1" . "," . "$2" . "," . "$3" . ",";
						   
						}else{
						
							$errorflag = 1;
							$RefCoordErrorArray[$RCEACnt] = "Line $linecnt: Please check Vector 1 (X Axis)!";
							$RCEACnt++;						
						}

						if($LineSummaryArray[3] =~ /\((\d+\.\d+||-\d+\.\d+)\s+(\d+\.\d+||-\d+\.\d+)\s+(\d+\.\d+||-\d+\.\d+)\)/){
						
							#print "$1 $2 $3\n";
							$InfoLine = $InfoLine . "$1" . "," . "$2" . "," . "$3" . ",";
						   
						}else{
						
							$errorflag = 1;
							$RefCoordErrorArray[$RCEACnt] = "Line $linecnt: Please check Vector 2 (Y Axis)!";
							$RCEACnt++;						
						}
						
						if($errorflag == 0){
							
							$CoordInfoArrayTmp[$CIATCnt] = $InfoLine;
							$CIATCnt++;
						}
					}else{
					
						$errorflag = 1;
						$RefCoordErrorArray[$RCEACnt] = "Line $linecnt: Please check the format of line $linecnt!";
						$RCEACnt++;
						
					} # End of if($SizeETA == 3){
					
					$linecnt++;
					
				} # End of while(<FH>) {
				
				close FH;
				
	 		} # End of if( (defined $RefCoordFilename) && ($RefCoordFilename ne "") ){

			#print "CoordIDCheckArray: @CoordIDCheckArray\n";
			
			my @CoorIDFlagArray = @{checkCoordIds(@CoordIDCheckArray);};
			my $SizeCIFA = @CoorIDFlagArray;
			my $SizeCICA = @CoordIDCheckArray;
			
			#print "CoorIDFlagArray: @CoorIDFlagArray\n";
			
			if($CoorIDFlagArray[0] > 0 && ($SizeCICA == ($SizeCIFA-1))){

				$NewCoordFlag = 1;
				
				$MainText-> delete("1.0", "end");
				$MainText->insert("end", "\n");
				$MainText->insert("end", "You have entered:\n");
				$MainText->insert("end", "[Coord ID, Origin, Vector 1 Direction (X Axis),Vector 2 Direction (Y Axis), Vector Product (Z Axis)]:\n");

				
				$CIATCnt = 0;	# Make it zero to recreate @CoordInfoArrayTmp
				
				foreach(@CoordInfoArrayTmp){
					
					#$MainText->insert("end", "$_\n");
					#$mw->update;
								
					my @Line = split ",",$_;

					my $O1 = $Line[1]; my $O2 = $Line[2]; my $O3 = $Line[3]; # Origin
					my $C1 = $Line[4]; my $C2 = $Line[5]; my $C3 = $Line[6]; # Vector in X axis direction
					my $D1 = $Line[7]; my $D2 = $Line[8]; my $D3 = $Line[9]; # Vector in Y axis direction

					my @CoordVectorDefinitionInput = ($O1,$O2,$O3,$C1,$C2,$C3,$D1,$D2,$D3);

					my @CrossProductArray = @{directionalcrossPruduct(@CoordVectorDefinitionInput);};
				
					my $SizeCPA = @CrossProductArray;
				
								
					if($SizeCPA == 1 && $CrossProductArray[0] == 1){
				
						$MainText->insert("end", "\nSpecified vectors are in the same direction. Cross product is zero. Please check your values!\n");
				
					}elsif($SizeCPA == 1 && $CrossProductArray[0] == -1){

						$MainText->insert("end", "\nSpecified vectors are in the opposite direction. Cross product is zero. Please check your values!\n");
				
					}elsif($SizeCPA == 3){
					
						my $B1 = $CrossProductArray[0]; my $B2 = $CrossProductArray[1]; my $B3 = $CrossProductArray[2]; # Vector in Z axis direction
					
						$B1 = sprintf("%.9f", $B1);     $B2 = sprintf("%.9f", $B2); 	$B3 = sprintf("%.9f", $B3);
						
						# Note: "$D1,$D2,$D3" are origin of the coordinate
						#       "$B1,$B2,$B3" and "$C1,$C2,$C3" are vectors;

						@CrossProductArray = (); # Reset @CrossProductArray
					
						@CoordVectorDefinitionInput = ($O1,$O2,$O3,$B1,$B2,$B3,$C1,$C2,$C3);
					
						@CrossProductArray = @{directionalcrossPruduct(@CoordVectorDefinitionInput);};
				
						$SizeCPA = @CrossProductArray;
					
						if($SizeCPA == 3){
						
							# Entered $A1, $A2, $A3 may not be 90 deg. to X axis. By using the crosproduct we make sure that X, Y, and Z axis
							# are 90 deg. to each other
						
							$D1 = $CrossProductArray[0]; $D2 = $CrossProductArray[1]; $D3 = $CrossProductArray[2]; # Vector in Y axis direction

							$D1 = sprintf("%.9f", $D1);  $D2 = sprintf("%.9f", $D2);  $D3 = sprintf("%.9f", $D3);

						}else{
							$MainText->insert("end", "\nError occored while creating Y axis (cross product). Please check entered values!\n");
						}
					
						$CoordInfoArrayTmp[$CIATCnt] = "$Line[0],$O1,$O2,$O3,$C1,$C2,$C3,$D1,$D2,$D3,$B1,$B2,$B3";
						$CIATCnt++;
						
						$MainText->insert("end", "[Coord $Line[0],($O1,$O2,$O3),($C1,$C2,$C3),($D1,$D2,$D3),($B1,$B2,$B3)]\n");	
					}
				
				} # End of foreach(@CoordInfoArrayTmp){

			
			}elsif($CoorIDFlagArray[0] > 0 && ($SizeCICA > ($SizeCIFA-1))){
						
				splice(@CoorIDFlagArray,0,1);
				
				$errorflag = 1;
				$RefCoordErrorArray[$RCEACnt] = "Entered Coord ids are: @CoordIDCheckArray. Some of these coordinates already exist in the bdf file. The Coord. id(s): @CoorIDFlagArray can be used. Please renumber the other coordinates!";
				$RCEACnt++;
				
			}elsif($CoorIDFlagArray[0] == 0){
				
				$errorflag = 1;
				$RefCoordErrorArray[$RCEACnt] = "The Coord. id(s): @CoordIDCheckArray already exist in the bdf file. Please renumber these coordinates!";
				$RCEACnt++;		
			}

			if($errorflag == 1){
			
				$MainText-> delete("1.0", "end");
				$MainText->insert("end", "\n");
			
				foreach(@RefCoordErrorArray){
					$MainText->insert("end", "$_\n");
				}

				$mw->update;
				
				@CoordInfoArrayTmp = ();
				$CIATCnt = 0;
		
				$RefCoordFilename = "";
			
				@RefCoordErrorArray = ();
				$RCEACnt = 0;

				@txtFileArray = ();	# This is the array that contains txt file names and their location
				$txtFileArray_i = 0;	# This is a counter for @txtFileArray = ()
				
			}				
			
		} # End of if($SizeBFA == 0){ 
	 }]
]);

$EntryRefCoord -> bind('<Return>' => sub{

	my $SizeBFA = @bdfFileArray;

	@CoordInfoArrayTmp = ();
	$CIATCnt = 0;
	
	if($EntryRefCoordTxt =~ /^del$/){
		
		@CoordInfoArrayTmp = ();
		$CIATCnt = 0;
		
		$MainText->insert("end", "\nInterface point information is deleted!\n");
		
	}elsif($SizeBFA == 0){

		$MainText-> delete("1.0", "end");
		$MainText->insert("end", "\nPlease select a bdf file to read!\n\n");
		$mw->update;	
	}else{

		my $O1 = 0; my $O2 = 0;  my $O3 = 0;
		my $D1 = 0; my $D2 = 0;  my $D3 = 0;
		my $B1 = 0; my $B2 = 0;  my $B3 = 0;
		my $C1 = 0; my $C2 = 0;  my $C3 = 0;
		
		if($EntryRefCoordTxt =~ /^Coord(\s+)(\d+)\,\((\d+\.\d+||-\d+\.\d+)\s+(\d+\.\d+||-\d+\.\d+)\s+(\d+\.\d+||-\d+\.\d+)\)\,\((\d+\.\d+||-\d+\.\d+)\s+(\d+\.\d+||-\d+\.\d+)\s+(\d+\.\d+||-\d+\.\d+)\)\,\((\d+\.\d+||-\d+\.\d+)\s+(\d+\.\d+||-\d+\.\d+)\s+(\d+\.\d+||-\d+\.\d+)\)/){
		

			$O1 = $3; $O2 = $4;  $O3 = $5;  # Origin
			$D1 = $9; $D2 = $10; $D3 = $11; # Vector in Y axis direction
			$C1 = $6; $C2 = $7;  $C3 = $8;  # Vector in X axis direction
			
			my $CoordID = $2;
			
			my @CoordVectorDefinitionInput = ($3,$4,$5,$6,$7,$8,$9,$10,$11);
			
			$MainText -> delete("0.0", "end");
			$MainText->insert("end", "\nPlease wait while checking the coordinate frame id in the bdf file...\n");
			$mw->update;
		
			my @CoordIDCheckArray = ($CoordID);

			my @CoorIDFlag = @{checkCoordIds(@CoordIDCheckArray);};
					
			if($CoorIDFlag[0] > 0){

				my @CrossProductArray = @{directionalcrossPruduct(@CoordVectorDefinitionInput);};
				
				my $SizeCPA = @CrossProductArray;
				
								
				if($SizeCPA == 1 && $CrossProductArray[0] == 1){
				
					$MainText->insert("end", "\nSpecified vectors are in the same direction. Cross product is zero. Please check your values!\n");
				
				}elsif($SizeCPA == 1 && $CrossProductArray[0] == -1){

					$MainText->insert("end", "\nSpecified vectors are in the opposite direction. Cross product is zero. Please check your values!\n");
				
				}elsif($SizeCPA == 3){
					
					$B1 = $CrossProductArray[0]; $B2 = $CrossProductArray[1]; $B3 = $CrossProductArray[2]; # Vector in Z axis direction
					
					$B1 = sprintf("%.9f", $B1);  $B2 = sprintf("%.9f", $B2);  $B3 = sprintf("%.9f", $B3);

					# Note: "$D1,$D2,$D3" are origin of the coordinate
					#       "$B1,$B2,$B3" and "$C1,$C2,$C3" are vectors;

					@CrossProductArray = (); # Reset @CrossProductArray
					
					@CoordVectorDefinitionInput = ($O1,$O2,$O3,$B1,$B2,$B3,$C1,$C2,$C3);
					
					@CrossProductArray = @{directionalcrossPruduct(@CoordVectorDefinitionInput);};
				
					$SizeCPA = @CrossProductArray;
					
					if($SizeCPA == 3){
						
						# Entered $D1, $D2, $D3 may not be 90 deg. to X axis. By using the crosproduct we make sure that X, Y, and Z axis
						# are 90 deg. to each other
						
						$D1 = $CrossProductArray[0]; $D2 = $CrossProductArray[1]; $D3 = $CrossProductArray[2]; # Vector in Y axis direction
					
						$D1 = sprintf("%.9f", $D1);  $D2 = sprintf("%.9f", $D2);  $D3 = sprintf("%.9f", $D3);
					
					}else{
						$MainText->insert("end", "\nAn error occored while creating Y axis (cross product). Please check entered values!\n");
					}
					
					$CoordInfoArrayTmp[$CIATCnt] = "$CoordID,$O1,$O2,$O3,$C1,$C2,$C3,$D1,$D2,$D3,$B1,$B2,$B3";
					$CIATCnt++;
					
					$NewCoordFlag = 1;
					
					$MainText->insert("end", "\nYou have entered:\n");
					$MainText->insert("end", "[Coord ID, Origin, Vector 1 Direction (X Axis),Vector 2 Direction (Y Axis), Vector Product (Z Axis)]:\n");
					$MainText->insert("end", "[Coord $CoordID,($O1,$O2,$O3),($C1,$C2,$C3),($D1,$D2,$D3),($B1,$B2,$B3)]\n");	
				}
							
			}elsif($CoorIDFlag[0] == 0){

				$MainText -> insert("end", "Coord id already exists in the bdf file! Please enter another Coord id!\n");
				$mw->update;
		
			}
			
			#my @CoordVectorDefinitionArray = @{checkCoordVectorDefinition(@CoordVectorDefinitionInput);};
			

		}else{
		
			$MainText -> delete("0.0", "end");
			$MainText -> insert("end", "\nPlease enter the values as shown in the example, don't forget the decimal point even if your value is an exact integer \n");
			$MainText -> insert("end", "for example: 14504, you have to enter it like 14504.0.\n");
			$MainText -> insert("end", "\nNo spaces before \"Coord...\" and after \")\".\n");
	
		}
		
	} #End of if($EntryRefCoordTxt =~ /^del$/){
	
});

$mw -> Label(	-text => "3(a). For interface loads, enter Summation Point Id, Identification Text, Nodes,"
		#-font => 'Courier -12'
					) -> place(-relx => 0.01, -rely => 0.21); 

$mw -> Label(	-text => "Connecting Elements (Or the List of All Elements for All Nodes), Ref.Coord Id,"
		#-font => 'Courier -12'
					) -> place(-relx => 0.02, -rely => 0.23); 

$mw -> Label(	-text => "Summ. Point Coordinates: or right-click to load from a text file. Enter \"del\""
		#-font => 'Courier -12'
					) -> place(-relx => 0.02, -rely => 0.25); 

$mw -> Label(	-text => "to clear. Example:"
		#-font => 'Courier -12'
					) -> place(-relx => 0.02, -rely => 0.27); 

$mw -> Label(	-text => "Point 1, POSITION_1, Node 8 10:12, Element 1001:1004, Coord 0, [0 0 0] or Node 20"
		#-font => 'Courier -12'
					) -> place(-relx => 0.02, -rely => 0.29); 

my $EntrySumPointTxt = "Enter Summation Point Id, Identification Text, Nodes, Connecting (Or All) Elements, Ref. Coord, Summ. Point Coordinates";

my $EntrySumPoint = $mw -> Entry( -relief => 'groove',
			          -background => 'white',
				  -width => 80,  
 			          -state => 'normal',
				  #-font => 'Courier -12',
			          -textvariable => \$EntrySumPointTxt) -> place(-relx => 0.02, -rely => 0.32);			      

my $EntrySumPointMessageCnt = 0;

$EntrySumPoint -> bind('<Button-1>', sub{
	
	$EntrySumPointMessageCnt++;

	if($EntrySumPointMessageCnt <= 1){
		
		$MainText -> delete("0.0", "end");
		$MainText -> insert("end", "\nExample: Point 1, POS_1, Node 8 10:12, Element 1001:1004, Coord 0, [0 0 0] or Node 20\n");
		$mw->update;
	}
});

$EntrySumPoint -> bind('<Control-v>' => sub{

	$EntrySumPoint -> delete('sel.first', 'sel.last')
		if $EntrySumPoint -> selectionPresent();

});

$EntrySumPoint -> bind('<Button-3>'=> \&EntrySumPoint_Popup); 

my $EntrySumPoint_Popup;
my $EntrySumPoint_popanchor  = 'nw';
my $EntrySumPoint_popover = $EntrySumPoint;
my $EntrySumPoint_overanchor  = 'c';

sub EntrySumPoint_Popup{
    $EntrySumPoint_Popup -> Popup(-popanchor  => $EntrySumPoint_popanchor,
				  -overanchor => $EntrySumPoint_overanchor,
				  -popover    => $EntrySumPoint_popover,
				 );
}

$EntrySumPoint_Popup = $mw -> Menu(-tearoff => 0, -menuitems => 
[
 					
	[Button  => 'Load from a text file', 
	 -command => sub {
		
		my $SizeBFA = @bdfFileArray;
		my $errorflag = 0;
		my $summnodeerrorflag = 0;


		#$SizeBFA = 0;
		
		#&createAllGridsArray;
		

		if($SizeBFA == 0){

			$MainText-> delete("1.0", "end");
			$MainText->insert("end", "\nPlease select a bdf file to read!\n\n");
			$mw->update;	
		}else{

			&select_txt;

			my $InterfaceNodesFilename = $txtFileArray[0];

			@InterfaceErrorArray = ();
			$IEACnt = 0;

			$InterfaceErrorArray[$IEACnt] = "Following errors occured:";
			$IEACnt++;
			
			my @SummationNodeList = ();
			my $SNLCnt = 0;
			
			my $linecnt = 1;

			if( (defined $InterfaceNodesFilename) && ($InterfaceNodesFilename ne "") ){


				open (FH, "<$InterfaceNodesFilename") or die "Could not open $InterfaceNodesFilename";
				
				while(<FH>) {
					
					my @LineSummaryArray = split(",", $_);
					my $SizeLSA = @LineSummaryArray;
					
					if($SizeLSA == 6){
					
						if($LineSummaryArray[5] =~ /^Node(\s+)(\d+)/   || $LineSummaryArray[5] =~ /^node(\s+)(\d+)/ ||
						   $LineSummaryArray[5] =~ /\s+Node(\s+)(\d+)/ || $LineSummaryArray[5] =~ /\s+node(\s+)(\d+)/){
							
							$SummationNodeList[$SNLCnt] = $2;
							$SNLCnt++;
						}
					}	
				}
				
				close FH;

				# We need to filter the repeated number of nodes and then sort the array
					
				my %FilterHash = ();
				my $key = 0;
			
				# We are filtering the repeated number of node ids.
				# First create the hash, then clear the @SummationNodeList
			
				foreach(@SummationNodeList){
				
					$FilterHash{$_} = $_;
				}

				@SummationNodeList = ();
				$SNLCnt = 0;

				# Then recreate the SummationNodeList array
			
				foreach $key (sort {$a <=> $b} keys %FilterHash){
						
					# Recreating ElmIDArray with filtered elements 		
					$SummationNodeList[$SNLCnt] = $key;	
					$SNLCnt++;
				}

				%FilterHash = ();
				$key = 0;						

				# Checking Summation node ids (NOT INTERFACE NODES: These will be checked later.)
				
				my @NodeCheckArray = @{checkNodeIds(@SummationNodeList);};

				my @FoundNodesArray = ();
				my $FNACnt = 0;
				
				for(my $i = 2; $i < ($NodeCheckArray[0]+2); $i++){
				
					$FoundNodesArray[$FNACnt] = $NodeCheckArray[$i];
					$FNACnt++;
				}

				my $SizeFNA = @FoundNodesArray;
												
				my @NotFoundNodesArray = ();
				my $NFNACnt = 0;
				
				for(my $i = ($NodeCheckArray[0]+2); $i < (2+$NodeCheckArray[0]+$NodeCheckArray[1]); $i++){
				
					$NotFoundNodesArray[$NFNACnt] = $NodeCheckArray[$i];
					$NFNACnt++;
				}					

				my $SizeNFNA = @NotFoundNodesArray;
							
				open (FH, "<$InterfaceNodesFilename") or die "Could not open $InterfaceNodesFilename";

				while(<FH>) {
				
					my @LineSummaryArray = split(",", $_);

					my $SizeLSA = @LineSummaryArray;

					my $line = "";

					my @NodeRangeArray = ();
					my $NRACnt = 0;

					my @ElementRangeArray = ();
					my $ERACnt = 0;

					my $PointIdRepeatedFlag = 0;
					
					#print "Line $linecnt:\n";

						if($SizeLSA == 6){

							if( $LineSummaryArray[0] =~ /^Point(\s+)(\d+)/ || $LineSummaryArray[0] =~ /^point(\s+)(\d+)/ ||
							    $LineSummaryArray[0] =~ /\s+Point(\s+)(\d+)/ || $LineSummaryArray[0] =~ /\s+point(\s+)(\d+)/){

								my $PointId = $2;

								for(my $i = 0; $i <= $#InterfaceInfoArray; $i++){

									my @PointIdArray = split (",", $InterfaceInfoArray[$i]);

									if($PointIdArray[0] == $PointId){

										$errorflag = 1;
										$PointIdRepeatedFlag = 1;
									}	
								}

								$line = "$PointId" . "," . " ";

							}else{
								$errorflag = 1;

								if($PointIdRepeatedFlag == 0){

									$InterfaceErrorArray[$IEACnt] = "Line $linecnt: Check point id format";
									$IEACnt++;														
								}
							}

							if($LineSummaryArray[1] =~ /^(\w+)/   || $LineSummaryArray[1] =~ /^(\w+)/ || 
				   			   $LineSummaryArray[1] =~ /\s+(\w+)/ || $LineSummaryArray[1] =~ /\s+(\w+)/){
				
								$line = $line . "$1" . "," . " ";

							}else{
								$errorflag = 1;

								if($PointIdRepeatedFlag == 0){

									$MainText->insert("end", "Line $linecnt: Check identification text format\n");
									$mw->update;				
								}
							}

							if($LineSummaryArray[2] =~ /^Node(.*)/   || $LineSummaryArray[2] =~ /^node(.*)/ || 
							   $LineSummaryArray[2] =~ /\s+Node(.*)/ || $LineSummaryArray[2] =~ /\s+node(.*)/){

								#print "LineSummaryArray[1] $LineSummaryArray[1], D1 $1\n";
								my $noderange = $1;
								my @NodeLineArray = split (" ", $noderange);

								foreach(@NodeLineArray){

									if($_ =~ /(\d+)\:(\d+)\:(\d+)/ || $_ =~ /(\d+)\:(\d+)\:(\-\d+)/){

										my @field = ();
										my $ID_1 = 0; my $ID_2 = 0; my $Range = 0; 

										@field = split(":",$_);

										$ID_1 = $1 * 1; $ID_2 = $2 * 1; $Range = $3 * 1;

										if(($ID_1 > 0) && ($ID_2 > 0) && ($ID_1 < $ID_2) && ($Range > 0)){

											for(my $i = 0; $i <= (($ID_2 - $ID_1)/$Range); $i++){

												$NodeRangeArray[$NRACnt] = $ID_1 + ($Range * $i);
												$NRACnt++;	
											}

										}elsif(($ID_1 > 0) && ($ID_2 > 0) && ($ID_1 > $ID_2) && ($Range < 0)){

											for(my $i = 0; $i <= (($ID_2 - $ID_1)/$Range); $i++){

												print "ID_2 $ID_2 ID_1 $ID_1 Range $Range\n";
												$NodeRangeArray[$NRACnt] = $ID_1 + ($Range * $i);
												$NRACnt++;
											}

										}else{												
											$errorflag = 1;

											if($PointIdRepeatedFlag == 0){

												$InterfaceErrorArray[$IEACnt] = "Line $linecnt: Please check if $ID_1:$ID_2:$Range is correct.";	# An array of all summation point ids and node ids and summation point coordinate
												$IEACnt++;																				
											}
										}

									}elsif($_ =~ /(\d+)\:(\d+)/){

										my @field = ();
										my $ID_1 = 0; my $ID_2 = 0; 

										@field = split(":",$_);

										$ID_1 = $1 * 1; $ID_2 = $2 * 1; 

										if(($ID_1 > 0) && ($ID_2 > 0) && ($ID_1 < $ID_2)){

											for(my $i = 0; $i <= ($ID_2 - $ID_1); $i++){

												$NodeRangeArray[$NRACnt] = $ID_1 + $i;
												$NRACnt++;						 
											}

										}else{												
											$errorflag = 1;

											if($PointIdRepeatedFlag == 0){

												$InterfaceErrorArray[$IEACnt] = "Line $linecnt: Please check if $ID_1:$ID_2 is correct.";
												$IEACnt++;
											}
										}				

									}elsif($_ =~ /(\d+)/){

										my $ID = $1 * 1;

										if($ID > 0){

											$NodeRangeArray[$NRACnt] = $ID;
											$NRACnt++;

										}else{

											$errorflag = 1;

											if($PointIdRepeatedFlag == 0){

												$InterfaceErrorArray[$IEACnt] = "Line $linecnt: Please check node id $ID";
												$IEACnt++;							
											}
										}
									}		
								}

								# We need to filter the repeated number of elements or grids and then sort the array
					
								my %FilterHash = ();
								my $key = 0;


								# We are filtering the repeated number of element or node ids.
								# First create the hash, then clear the NodeRangeArray
			
								foreach(@NodeRangeArray){

									$FilterHash{$_} = $_;
								}		

								@NodeRangeArray = ();
								$NRACnt = 0;
			
								# Then recreate the NodeRangeArray
			
								foreach $key(sort {$a <=> $b} keys %FilterHash){
					
									# Recreating NodeRangArray with filtered elements 		
									$NodeRangeArray[$NRACnt] = $key;	
									$NRACnt++;
								}
			
								%FilterHash = ();
								$key = 0;

								foreach(@NodeRangeArray){

									$NodeIDArray[$NIACnt] = $_;
									$NIACnt++;
									
									$line = $line . "$_" . " ";
								}

								$line = $line . ",";
								

								# We are filtering the repeated number of element or node ids.
								# First create the hash, then clear the NodeIDArray
			
								foreach(@NodeIDArray){

									$FilterHash{$_} = $_;
								}

								@NodeIDArray = ();
								$NIACnt = 0;

								# Then recreate the ElmIDArray
			
								foreach $key (sort {$a <=> $b} keys %FilterHash){
					
									# Recreating ElmIDArray with filtered elements 		
									$NodeIDArray[$NIACnt] = $key;	
									$NIACnt++;
								}

								%FilterHash = ();
								$key = 0;
									
							}

                                                       	if( $LineSummaryArray[3] =~ /^Element(.*)/   || $LineSummaryArray[3] =~ /^element(.*)/ ||
                                                            $LineSummaryArray[3] =~ /\s+Element(.*)/ || $LineSummaryArray[3] =~ /\s+element(.*)/ ||
                                                            $LineSummaryArray[3] =~ /^Elm(.*)/       || $LineSummaryArray[3] =~ /^elm(.*)/ ||
                                                            $LineSummaryArray[3] =~ /\s+Elm(.*)/     || $LineSummaryArray[3] =~ /\s+elm(.*)/){

								#print "LineSummaryArray[1] $LineSummaryArray[1], D1 $1\n";
								my $elementrange = $1;
								my @ElementLineArray = split (" ", $elementrange);

								foreach(@ElementLineArray){

									if($_ =~ /(\d+)\:(\d+)\:(\d+)/ || $_ =~ /(\d+)\:(\d+)\:(\-\d+)/){

										my @field = ();
										my $ID_1 = 0; my $ID_2 = 0; my $Range = 0; 

										@field = split(":",$_);

										$ID_1 = $1 * 1; $ID_2 = $2 * 1; $Range = $3 * 1;

										if(($ID_1 > 0) && ($ID_2 > 0) && ($ID_1 < $ID_2) && ($Range > 0)){

											for(my $i = 0; $i <= (($ID_2 - $ID_1)/$Range); $i++){

												$ElementRangeArray[$ERACnt] = $ID_1 + ($Range * $i);
												$ERACnt++;	
											}

										}elsif(($ID_1 > 0) && ($ID_2 > 0) && ($ID_1 > $ID_2) && ($Range < 0)){

											for(my $i = 0; $i <= (($ID_2 - $ID_1)/$Range); $i++){

												#print "ID_2 $ID_2 ID_1 $ID_1 Range $Range\n";
												
												$ElementRangeArray[$ERACnt] = $ID_1 + ($Range * $i);
												$ERACnt++;
											}

										}else{												
											$errorflag = 1;

											if($PointIdRepeatedFlag == 0){

												$InterfaceErrorArray[$IEACnt] = "Line $linecnt: Please check if $ID_1:$ID_2:$Range is correct.";	# An array of all summation point ids and element ids and summation point coordinate
												$IEACnt++;																				
											}
										}

									}elsif($_ =~ /(\d+)\:(\d+)/){

										my @field = ();
										my $ID_1 = 0; my $ID_2 = 0; 

										@field = split(":",$_);

										$ID_1 = $1 * 1; $ID_2 = $2 * 1; 

										if(($ID_1 > 0) && ($ID_2 > 0) && ($ID_1 < $ID_2)){

											for(my $i = 0; $i <= ($ID_2 - $ID_1); $i++){

												$ElementRangeArray[$ERACnt] = $ID_1 + $i;
												$ERACnt++;						 
											}

										}else{												
											$errorflag = 1;

											if($PointIdRepeatedFlag == 0){

												$InterfaceErrorArray[$IEACnt] = "Line $linecnt: Please check if $ID_1:$ID_2 is correct.";
												$IEACnt++;
											}
										}				

									}elsif($_ =~ /(\d+)/){

										my $ID = $1 * 1;

										if($ID > 0){

											$ElementRangeArray[$ERACnt] = $ID;
											$ERACnt++;

										}else{

											$errorflag = 1;

											if($PointIdRepeatedFlag == 0){

												$InterfaceErrorArray[$IEACnt] = "Line $linecnt: Please check element id $ID";
												$IEACnt++;							
											}
										}
									}		
								}

								# We need to filter the repeated number of elements or grids and then sort the array
					
								my %FilterHash = ();
								my $key = 0;


								# We are filtering the repeated number of element or element ids.
								# First create the hash, then clear the ElementRangeArray
			
								foreach(@ElementRangeArray){

									$FilterHash{$_} = $_;
								}		

								@ElementRangeArray = ();
								$ERACnt = 0;
			
								# Then recreate the ElementIDArray
			
								foreach $key(sort {$a <=> $b} keys %FilterHash){
					
									# Recreating ElementRangeArray with filtered elements 		
									$ElementRangeArray[$ERACnt] = $key;	
									$ERACnt++;
								}
			
								%FilterHash = ();
								$key = 0;

								$line = $line . "$elementrange" . ",";
								
								foreach(@ElementRangeArray){

									$ElmIDArray[$EIDCnt] = $_;
									$EIDCnt++;
								}		
								
								# We are filtering the repeated number of element or node ids.
								# First create the hash, then clear the ElmIDArray
			
								foreach(@ElmIDArray){

									$FilterHash{$_} = $_;
								}

								@ElmIDArray = ();
								$EIDCnt = 0;

								# Then recreate the ElmIDArray
			
								foreach $key (sort {$a <=> $b} keys %FilterHash){
						
									# Recreating ElmIDArray with filtered elements 		
									$ElmIDArray[$EIDCnt] = $key;	
									$EIDCnt++;
								}

								%FilterHash = ();
								$key = 0;
								
								#foreach(@ElmIDArray){

									#print "ElmIDArray: $_\n";
								#}								
																								
							}
                                                        
							if( $LineSummaryArray[4] =~ /^Coord(\s+)(\d+)/   || $LineSummaryArray[4] =~ /^coord(\s+)(\d+)/ ||
							    $LineSummaryArray[4] =~ /\s+Coord(\s+)(\d+)/ || $LineSummaryArray[4] =~ /\s+coord(\s+)(\d+)/){

								my $RefCoord = $2;
								$line = $line . "$RefCoord" . ",";

							}else{
								$errorflag = 1;

								if($PointIdRepeatedFlag == 0){

									$InterfaceErrorArray[$IEACnt] = "Line $linecnt: Check coord id format";
									$IEACnt++;				
								}
							}

							if( $LineSummaryArray[5] =~ /^Node(\s+)(\d+)/   || $LineSummaryArray[5] =~ /^node(\s+)(\d+)/ ||
							    $LineSummaryArray[5] =~ /\s+Node(\s+)(\d+)/ || $LineSummaryArray[5] =~ /\s+node(\s+)(\d+)/){     

								#print "LineSummaryArray[3] $LineSummaryArray[3]\n";
								#print "D2 $2\n";
								
								if($2 > 0){

									if($PointIdRepeatedFlag == 0 && $errorflag == 0){

										my $SummNodeID = $2;
										
										#print "SummNodeID $SummNodeID\n";
										my $nodeflag = 0;

										foreach(@FoundNodesArray){
										
											#print "SummNodeID $SummNodeID, FoundNodesArray $_\n";
											my @LineArray = split (" ", $_);
																						
											if(defined $LineArray[0] && $SummNodeID == $LineArray[0]){
											
												#print "SummNodeID $SummNodeID LineArray[0] $LineArray[0]\n";
												$nodeflag = 1;
												$line = $line . "$LineArray[1] $LineArray[2] $LineArray[3]";
												
											}
										}
										
										if($nodeflag == 0){
										
											$summnodeerrorflag = 1;
											$InterfaceErrorArray[$IEACnt] = "Line $linecnt: Summation nodes: @NotFoundNodesArray could not be found in the bdf file!";
											$IEACnt++;
										}
									}
								}		

							}elsif( $LineSummaryArray[5] =~ /\[(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)\]/ ||      
								$LineSummaryArray[5] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ || 

								$LineSummaryArray[5] =~ /\[(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||
								$LineSummaryArray[5] =~ /\[(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)\]/ ||           
								$LineSummaryArray[5] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)\]/ ||

								$LineSummaryArray[5] =~ /\[(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||		   
								$LineSummaryArray[5] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)\]/ ||
								$LineSummaryArray[5] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||


								$LineSummaryArray[5] =~ /\[(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||
								$LineSummaryArray[5] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ || 

								$LineSummaryArray[5] =~ /\[(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||
								$LineSummaryArray[5] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||
								$LineSummaryArray[5] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||

								$LineSummaryArray[5] =~ /\[(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||             
								$LineSummaryArray[5] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||      
								$LineSummaryArray[5] =~ /\[(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)\]/){

								if($PointIdRepeatedFlag == 0){

									$line = $line . "$1 $3 $5";				
								}

							}elsif(

								$LineSummaryArray[5] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)\]/ ||
								$LineSummaryArray[5] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ || 

								$LineSummaryArray[5] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||
								$LineSummaryArray[5] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)\]/ ||
								$LineSummaryArray[5] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||

								$LineSummaryArray[5] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||             
								$LineSummaryArray[5] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)\]/ ||      
								$LineSummaryArray[5] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)\]/ ||


								$LineSummaryArray[5] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||
								$LineSummaryArray[5] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ || 

								$LineSummaryArray[5] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||
								$LineSummaryArray[5] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||
								$LineSummaryArray[5] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||

								$LineSummaryArray[5] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||             
								$LineSummaryArray[5] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||      
								$LineSummaryArray[5] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)\]/){

								if($PointIdRepeatedFlag == 0){

									$line = $line . "$2 $4 $6";				
								}

							}else{

								$errorflag = 1;

								if($PointIdRepeatedFlag == 0){

									$InterfaceErrorArray[$IEACnt] = "Line $linecnt: Please enter summation point correctly!";
									$IEACnt++;
									
									$InterfaceErrorArray[$IEACnt] = "When you are entering the coordinates for the summation point, do not forget to put \"0\" after \".\"";
									$IEACnt++;
							
									$InterfaceErrorArray[$IEACnt] = "For example: Instead of using \"14504.\" use \"14504.0\"";
									$IEACnt++;

									$InterfaceErrorArray[$IEACnt] = "Example:[(14504.0,-102.868,2719.95),(14504.0,-102.868,17477.1),(14504.0,-14860.1,2719.95)]";
									$IEACnt++;							
								}
							}

							if($errorflag == 0 && $PointIdRepeatedFlag == 0){

								$InterfaceInfoArray[$IIACnt] = $line; # An array of all summation point ids and node ids and summation point coordinate	
								$IIACnt++;

							}elsif($PointIdRepeatedFlag == 1){

								$InterfaceErrorArray[$IEACnt] = "Line $linecnt: Point Id is already entered, please check point id number!";
								$IEACnt++;
							}

						}else{

							$errorflag = 1;
							$InterfaceErrorArray[$IEACnt] = "Line $linecnt: Please check the format! Use the example format for interface point information!";
							$IEACnt++;

							$InterfaceErrorArray[$IEACnt] = "Make sure that thare are no empty lines or lines with only \"End of line\" character. Program will not recognise these lines and will give an error message!";
							$IEACnt++;
																					
						} # End of if($SizeETA == 4){

					$linecnt++;
						
				} # End of while(<FH>)

				close FH;

				@txtFileArray = ();	# This is the array that contains txt file names and their location
				$txtFileArray_i = 0;	# This is a counter for @txtFileArray = ()
			}


			#foreach(@NodeIDArray){
			
				#print "NodeIDArray: $_\n";
			#}
			
			my @NodeCheckArray = @{checkNodeIds(@NodeIDArray);};

			my @FoundNodesArray = ();
			my $FNACnt = 0;
			
			for(my $i = 2; $i < ($NodeCheckArray[0]+2); $i++){
			
				$FoundNodesArray[$FNACnt] = $NodeCheckArray[$i];
				$FNACnt++;
			}

			#foreach(@FoundNodesArray){
			
				#print "FoundNodesArray: $_\n";
			#}

			my $SizeFNA = @FoundNodesArray;
							
			my @NotFoundNodesArray = ();
			my $NFNACnt = 0;
			
			for(my $i = ($NodeCheckArray[0]+2); $i < (2+$NodeCheckArray[0]+$NodeCheckArray[1]); $i++){
			
				$NotFoundNodesArray[$NFNACnt] = $NodeCheckArray[$i];
				$NFNACnt++;
			}					

			#foreach(@NotFoundNodesArray){
			
				#print "NotFoundNodesArray: $_\n";
			#}

			my $SizeNFNA = @NotFoundNodesArray;

			if($NodeCheckArray[1] > 0){			
				
				$errorflag = 1;

				$InterfaceErrorArray[$IEACnt] = "Please check interface node ids! Node id(s): @NotFoundNodesArray could not be found in the bdf file!";
				$IEACnt++;
			}
				
			if($errorflag == 0 && $summnodeerrorflag == 0){

				$MainText -> delete("0.0", "end");
				$MainText->insert("end", "\nThe following interface point information is entered:\n");
				$MainText->insert("end", "Interface Points, Identification Text, Nodes, Elements, Reference Coord Ids and the Summation Nodes:\n\n");	

				foreach(@InterfaceInfoArray){

					my @InfoArray = split (",", $_);
					$MainText->insert("end", "Point Id: $InfoArray[0], $InfoArray[1], Node(s): $InfoArray[2], Element(s): $InfoArray[3], Coord Id: $InfoArray[4], Summation Point: $InfoArray[5]\n");	
				}

			}elsif($errorflag == 1 || $summnodeerrorflag == 1){

				@InterfaceInfoArray = (); # An array of all summation point ids and node ids and summation point coordinate	
				$IIACnt = 0;

				$MainText -> delete("0.0", "end");
				$MainText->insert("end", "\n");

				foreach(@InterfaceErrorArray){

			        	$MainText->insert("end", "$_\n");       
				}							       
			}						
		} # End of if($SizeBFA == 0){		
 	}]
]);

$EntrySumPoint -> bind('<Return>' => sub{

	$MainText-> delete("1.0", "end");

	if($EntrySumPointTxt =~ /^del$/){
		
		@InterfaceInfoArray = ();
		$IIACnt = 0;
		
		$MainText->insert("end", "\nInterface point information is deleted!\n");
		
	}else{
	
		my @EntryTextArray = split(",", $EntrySumPointTxt);

		my $SizeETA = @EntryTextArray;

		my $line = "";
		my $errorflag = 0;

		my @NodeRangeArray = ();
		my $NRACnt = 0;

		my @ElementRangeArray = ();
		my $ERACnt = 0;

		my $PointIdRepeatedFlag = 0;

		my $SizeBFA = @bdfFileArray;
		
		if($SizeBFA == 0){

			$errorflag = 1;

			if($PointIdRepeatedFlag == 0){

				$MainText->insert("end", "\nPlease select a bdf file to read!\n\n");
				$mw->update;						
			}
		}else{

			if($SizeETA == 6){
				
				if( $EntryTextArray[0] =~ /^Point(\s+)(\d+)/ || $EntryTextArray[0] =~ /^point(\s+)(\d+)/ ||
				    $EntryTextArray[0] =~ /\s+Point(\s+)(\d+)/ || $EntryTextArray[0] =~ /\s+point(\s+)(\d+)/){

					my $PointId = $2;

					for(my $i = 0; $i <= $#InterfaceInfoArray; $i++){

						my @PointIdArray = split (",", $InterfaceInfoArray[$i]);

						if($PointIdArray[0] == $PointId){

							$errorflag = 1;
							$PointIdRepeatedFlag = 1;
						}	
					}

					$line = "$PointId" . "," . " ";

				}else{
					$errorflag = 1;

					if($PointIdRepeatedFlag == 0){

						$MainText->insert("end", "Check point id format\n");
						$mw->update;				
					}
				}
				
				if($EntryTextArray[1] =~ /^(\w+)/   || $EntryTextArray[1] =~ /^(\w+)/ || 
				   $EntryTextArray[1] =~ /\s+(\w+)/ || $EntryTextArray[1] =~ /\s+(\w+)/){
				
					$line = $line . "$1" . "," . " ";

				}else{
					$errorflag = 1;

					if($PointIdRepeatedFlag == 0){

						$MainText->insert("end", "Check identification text format\n");
						$mw->update;				
					}
				}
				

				if($EntryTextArray[2] =~ /^Node(.*)/   || $EntryTextArray[2] =~ /^node(.*)/ || 
				   $EntryTextArray[2] =~ /\s+Node(.*)/ || $EntryTextArray[2] =~ /\s+node(.*)/){

					#print "EntryTextArray[1] $EntryTextArray[1], D1 $1\n";
					my $noderange = $1;
					my @NodeLineArray = split (" ", $noderange);

					foreach(@NodeLineArray){

						if($_ =~ /(\d+)\:(\d+)\:(\d+)/ || $_ =~ /(\d+)\:(\d+)\:(\-\d+)/){

							my @field = ();
							my $ID_1 = 0; my $ID_2 = 0; my $Range = 0; 

							@field = split(":",$_);

							$ID_1 = $1 * 1; $ID_2 = $2 * 1; $Range = $3 * 1;

							if(($ID_1 > 0) && ($ID_2 > 0) && ($ID_1 < $ID_2) && ($Range > 0)){

								for(my $i = 0; $i <= (($ID_2 - $ID_1)/$Range); $i++){

									$NodeRangeArray[$NRACnt] = $ID_1 + ($Range * $i);
									$NRACnt++;	
								}

							}elsif(($ID_1 > 0) && ($ID_2 > 0) && ($ID_1 > $ID_2) && ($Range < 0)){

								for(my $i = 0; $i <= (($ID_2 - $ID_1)/$Range); $i++){

									$NodeRangeArray[$NRACnt] = $ID_1 + ($Range * $i);
									$NRACnt++;
								}

							}else{												
								$errorflag = 1;

								if($PointIdRepeatedFlag == 0){

									$MainText->insert("end", "Please check if $ID_1:$ID_2:$Range is correct.\n");
									$mw->update;							
								}
							}

						}elsif($_ =~ /(\d+)\:(\d+)/){

							my @field = ();
							my $ID_1 = 0; my $ID_2 = 0; 

							@field = split(":",$_);

							$ID_1 = $1 * 1; $ID_2 = $2 * 1; 

							if(($ID_1 > 0) && ($ID_2 > 0) && ($ID_1 < $ID_2)){

								for(my $i = 0; $i <= ($ID_2 - $ID_1); $i++){

									$NodeRangeArray[$NRACnt] = $ID_1 + $i;
									$NRACnt++;						 
								}

							}else{												
								$errorflag = 1;

								if($PointIdRepeatedFlag == 0){

									$MainText->insert("end", "Please check if $ID_1:$ID_2 is correct.\n");
									$mw->update;
								}
							}				

						}elsif($_ =~ /(\d+)/){

							my $ID = $1 * 1;

							if($ID > 0){

								$NodeRangeArray[$NRACnt] = $ID;
								$NRACnt++;

							}else{

								$errorflag = 1;

								if($PointIdRepeatedFlag == 0){

									$MainText->insert("end", "Please check elm id $ID\n");
									$mw->update;							
								}
							}
						}
					}

					# We need to filter the repeated number of elements or grids and then sort the array

					my %FilterHash = ();
					my $key = 0;


					# We are filtering the repeated number of element or node ids.
					# First create the hash, then clear the ElementIDArray

					foreach(@NodeRangeArray){

						$FilterHash{$_} = $_;
					}		

					@NodeRangeArray = ();
					$NRACnt = 0;

					# Then recreate the NodeIDArray

					foreach $key(sort {$a <=> $b} keys %FilterHash){

						# Recreating NodeIDArray with filtered elements 		
						$NodeRangeArray[$NRACnt] = $key;	
						$NRACnt++;
					}

					%FilterHash = ();
					$key = 0;
													
					foreach(@NodeRangeArray){

						$NodeIDArray[$NIACnt] = $_;
						$NIACnt++;

						$line = $line . "$_" . " ";
					}

					$line = $line . ",";
					
					# We are filtering the repeated number of element or node ids.
					# First create the hash, then clear the NodeIDArray
			
					foreach(@NodeIDArray){
					
						$FilterHash{$_} = $_;
					}

					@NodeIDArray = ();
					$NIACnt = 0;

					# Then recreate the NodeIDArray
			
					foreach $key (sort {$a <=> $b} keys %FilterHash){
					
						# Recreating NodeIDArray with filtered elements 		
						$NodeIDArray[$NIACnt] = $key;	
						$NIACnt++;
					}

					%FilterHash = ();
					$key = 0;

					foreach(@NodeIDArray){

						#$MainText->insert("end", "NodeIDArray: $_\n");
						print "$_\n";

					}
				}

				if($EntryTextArray[3] =~ /^Element(.*)/   || $EntryTextArray[3] =~ /^element(.*)/ || 
				   $EntryTextArray[3] =~ /\s+Element(.*)/ || $EntryTextArray[3] =~ /\s+element(.*)/ ||
				   $EntryTextArray[3] =~ /^Elm(.*)/   || $EntryTextArray[3] =~ /^elm(.*)/ || 
				   $EntryTextArray[3] =~ /\s+Elm(.*)/ || $EntryTextArray[3] =~ /\s+elm(.*)/){

					#print "EntryTextArray[1] $EntryTextArray[1], D1 $1\n";
					my $elementrange = $1;
					my @ElementLineArray = split (" ", $elementrange);

					foreach(@ElementLineArray){

						if($_ =~ /(\d+)\:(\d+)\:(\d+)/ || $_ =~ /(\d+)\:(\d+)\:(\-\d+)/){

							my @field = ();
							my $ID_1 = 0; my $ID_2 = 0; my $Range = 0; 

							@field = split(":",$_);

							$ID_1 = $1 * 1; $ID_2 = $2 * 1; $Range = $3 * 1;

							if(($ID_1 > 0) && ($ID_2 > 0) && ($ID_1 < $ID_2) && ($Range > 0)){

								for(my $i = 0; $i <= (($ID_2 - $ID_1)/$Range); $i++){

									$ElementRangeArray[$ERACnt] = $ID_1 + ($Range * $i);
									$ERACnt++;	
								}

							}elsif(($ID_1 > 0) && ($ID_2 > 0) && ($ID_1 > $ID_2) && ($Range < 0)){

								for(my $i = 0; $i <= (($ID_2 - $ID_1)/$Range); $i++){

									$ElementRangeArray[$ERACnt] = $ID_1 + ($Range * $i);
									$ERACnt++;
								}

							}else{												
								$errorflag = 1;

								if($PointIdRepeatedFlag == 0){

									$MainText->insert("end", "Please check if $ID_1:$ID_2:$Range is correct.\n");
									$mw->update;							
								}
							}

						}elsif($_ =~ /(\d+)\:(\d+)/){

							my @field = ();
							my $ID_1 = 0; my $ID_2 = 0; 

							@field = split(":",$_);

							$ID_1 = $1 * 1; $ID_2 = $2 * 1; 

							if(($ID_1 > 0) && ($ID_2 > 0) && ($ID_1 < $ID_2)){

								for(my $i = 0; $i <= ($ID_2 - $ID_1); $i++){

									$ElementRangeArray[$ERACnt] = $ID_1 + $i;
									$ERACnt++;						 
								}

							}else{												
								$errorflag = 1;

								if($PointIdRepeatedFlag == 0){

									$MainText->insert("end", "Please check if $ID_1:$ID_2 is correct.\n");
									$mw->update;
								}
							}				

						}elsif($_ =~ /(\d+)/){

							my $ID = $1 * 1;

							if($ID > 0){

								$ElementRangeArray[$ERACnt] = $ID;
								$ERACnt++;

							}else{

								$errorflag = 1;

								if($PointIdRepeatedFlag == 0){

									$MainText->insert("end", "Please check elm id $ID\n");
									$mw->update;							
								}
							}

						}		

					}

					# We need to filter the repeated number of elements or grids and then sort the array

					my %FilterHash = ();
					my $key = 0;


					# We are filtering the repeated number of element or node ids.
					# First create the hash, then clear the ElementIDArray

					foreach(@ElementRangeArray){

						$FilterHash{$_} = $_;
					}		

					@ElementRangeArray = ();
					$ERACnt = 0;

					# Then recreate the NodeIDArray

					foreach $key(sort {$a <=> $b} keys %FilterHash){

						# Recreating ElementIDArray with filtered elements 		
						$ElementRangeArray[$ERACnt] = $key;	
						$ERACnt++;
					}

					%FilterHash = ();
					$key = 0;

					$line = $line . "$elementrange" . ",";
								
					foreach(@ElementRangeArray){

						$ElmIDArray[$EIDCnt] = $_;
						$EIDCnt++;
					}		
					
					# We are filtering the repeated number of element or node ids.
					# First create the hash, then clear the ElmIDArray
			
					foreach(@ElmIDArray){

						$FilterHash{$_} = $_;
					}

					@ElmIDArray = ();
					$EIDCnt = 0;

					# Then recreate the ElmIDArray
			
					foreach $key (sort {$a <=> $b} keys %FilterHash){
					
						# Recreating ElmIDArray with filtered elements 		
						$ElmIDArray[$EIDCnt] = $key;	
						$EIDCnt++;
					}

					%FilterHash = ();
					$key = 0;

					#foreach(@ElmIDArray){

						#$MainText->insert("end", "ElmIDArray: $_\n");
					#}			
				}

				if( $EntryTextArray[4] =~ /^Coord(\s+)(\d+)/ || $EntryTextArray[4] =~ /^coord(\s+)(\d+)/ ||
				    $EntryTextArray[4] =~ /\s+Coord(\s+)(\d+)/ || $EntryTextArray[4] =~ /\s+coord(\s+)(\d+)/){

					my $RefCoord = $2;
					$line = $line . "$RefCoord" . ",";

				}else{
					$errorflag = 1;

					if($PointIdRepeatedFlag == 0){

						$MainText->insert("end", "Check coord id format\n");
						$mw->update;				
					}
				}

				if( $EntryTextArray[5] =~ /^Node(\s+)(\d+)/ || $EntryTextArray[5] =~ /^node(\s+)(\d+)/ ||
				    $EntryTextArray[5] =~ /\s+Node(\s+)(\d+)/ || $EntryTextArray[5] =~ /\s+node(\s+)(\d+)/){     

					if($2 > 0){

						if($PointIdRepeatedFlag == 0 && $errorflag == 0){

							$MainText->insert("end", "\nPlease wait while checking the selected summation node id in the bdf file...\n");
							$mw->update;
							
							my @SummNodeIDArray = ($2);
							my $SizeSNIA = @SummNodeIDArray;

							my @NodeCheckArray = @{checkNodeIds(@SummNodeIDArray);};
							# @ReturnArray = ($SizeNRA, $SizeNFNA, @NodeReturnArray, @NotFoundNodeArray);
							
							print "NodeCheckArray[0] $NodeCheckArray[0], SizeSNIA $SizeSNIA";

							if(defined $NodeCheckArray[0] && $NodeCheckArray[0] == $SizeSNIA){

								my @LineArray = split " ", $NodeCheckArray[2];

								$line = $line . "$LineArray[1] $LineArray[2] $LineArray[3]";

								$MainText->insert("end", "\nSummation node is obtained from the bdf file!\n");		
								$MainText->insert("end", "\nSelected summation node: Node $2\n");
								$MainText->insert("end", "\nSummation point coordinates for the current interface point are set to:\n\n");
								$MainText->insert("end", "X = $LineArray[1] Y = $LineArray[2] Z = $LineArray[3]\n");
								$mw->update;

							}elsif(defined $NodeCheckArray[1] && $NodeCheckArray[1] > 0){

								$errorflag = 1;
								$MainText->insert("end", "\nSummation node could not be found in the bdf file!\n");
								$mw->update;
							}
						}
					}		

				}elsif( $EntryTextArray[5] =~ /\[(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)\]/ ||      
					$EntryTextArray[5] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ || 

					$EntryTextArray[5] =~ /\[(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||
					$EntryTextArray[5] =~ /\[(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)\]/ ||           
					$EntryTextArray[5] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)\]/ ||

					$EntryTextArray[5] =~ /\[(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||		   
					$EntryTextArray[5] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)\]/ ||
					$EntryTextArray[5] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||


					$EntryTextArray[5] =~ /\[(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||
					$EntryTextArray[5] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ || 

					$EntryTextArray[5] =~ /\[(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||
					$EntryTextArray[5] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||
					$EntryTextArray[5] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||

					$EntryTextArray[5] =~ /\[(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||             
					$EntryTextArray[5] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||      
					$EntryTextArray[5] =~ /\[(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)\]/){

					if($PointIdRepeatedFlag == 0){

						$line = $line . "$1 $3 $5";
			
						$MainText->insert("end", "\nSummation point coordinates:\n\n");
						$MainText->insert("end", "X = $1 Y = $3 Z = $5\n");
						
						$mw->update;				
					}

				}elsif(

					$EntryTextArray[5] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)\]/ ||
					$EntryTextArray[5] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ || 

					$EntryTextArray[5] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||
					$EntryTextArray[5] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)\]/ ||
					$EntryTextArray[5] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||

					$EntryTextArray[5] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||             
					$EntryTextArray[5] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)\]/ ||      
					$EntryTextArray[5] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)\]/ ||


					$EntryTextArray[5] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||
					$EntryTextArray[5] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ || 

					$EntryTextArray[5] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||
					$EntryTextArray[5] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||
					$EntryTextArray[5] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||

					$EntryTextArray[5] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||             
					$EntryTextArray[5] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||      
					$EntryTextArray[5] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)\]/){

					if($PointIdRepeatedFlag == 0){

						$line = $line . "$2 $4 $6";

						$MainText->insert("end", "\nSummation point coordinates:\n\n");
						$MainText->insert("end", "X = $2 Y = $4 Z = $6\n");

						$mw->update;				
					}

				}else{

					$errorflag = 1;

					if($PointIdRepeatedFlag == 0){

						$MainText->insert("end", "\nPlease enter summation point correctly!\n\n");
						$MainText->insert("end", "When you are entering the coordinates for the summation point, do not forget to put \"0\" after \".\"");
						$MainText->insert("end", "For example: Instead of using \"14504.\" use \"14504.0\"\n");
						$MainText->insert("end", "Example:[(14504.0,-102.868,2719.95),(14504.0,-102.868,17477.1),(14504.0,-14860.1,2719.95)]\n");

						$mw->update;
					}
				}

				if($errorflag == 0 && $PointIdRepeatedFlag == 0){

					$InterfaceInfoArray[$IIACnt] = $line; # An array of all summation point ids and node ids and summation point coordinate	
					$IIACnt++;

					$MainText->insert("end", "\nInterface Points:\n\n");

					foreach(@InterfaceInfoArray){

						my @InfoArray = split (",", $_);

						$MainText->insert("end", "Point Id: $InfoArray[0], $InfoArray[1], Node(s): $InfoArray[2], Elements: $InfoArray[3], Coord Id: $InfoArray[4], Summation Point: $InfoArray[5]\n");	
					}

				}elsif($PointIdRepeatedFlag == 1){

					$MainText->insert("end", "\nPoint Id is already entered, please check point id number!\n\n");
				}

			}else{

				$MainText->insert("end", "\nPlease check the format! Use the example format for interface point information!\n\n");
			
			} # End of if($SizeETA == 5){

		} # if($SizeBFA == 0){
	}
});


$mw -> Label(	-text => "3(b). For MPC loads enter node ids, ref.coord id and Summ. node/point"
		#-font => 'Courier -12'
				) -> place(-relx => 0.01, -rely => 0.35);
				 
$mw -> Label(	-text => "for each node where MPC is connected. Enter \"del\" to clear."
		#-font => 'Courier -12'
				) -> place(-relx => 0.02, -rely => 0.37);
				
$mw -> Label(	-text => "Example: Node 1125, Coord 2, [0 0 0] or Node 1125"
		#-font => 'Courier -12'
				) -> place(-relx => 0.02, -rely => 0.39);
				
my $EntryMPCLoadTxt = "Enter Node ID, Coord ID, Summation Point/Node";

my $EntryMPCLoad = $mw -> Entry( -relief => 'groove',
			          -background => 'white',
				  -width => 80,  
 			          -state => 'normal',
				  #-font => 'Courier -12',
			          -textvariable => \$EntryMPCLoadTxt) -> place(-relx => 0.02, -rely => 0.42);


$EntryMPCLoad -> bind('<Control-v>' => sub{

	$EntryMPCLoad -> delete('sel.first', 'sel.last')
		if $EntryMPCLoad -> selectionPresent();

});

$EntryMPCLoad -> bind('<Button-3>'=> \&EntryMPCLoad_Popup); 

my $EntryMPCLoad_Popup;
my $EntryMPCLoad_popanchor  = 'nw';
my $EntryMPCLoad_popover = $EntryMPCLoad;
my $EntryMPCLoad_overanchor  = 'c';

sub EntryMPCLoad_Popup{
    $EntryMPCLoad_Popup -> Popup(-popanchor  => $EntryMPCLoad_popanchor,
				  -overanchor => $EntryMPCLoad_overanchor,
				  -popover    => $EntryMPCLoad_popover,
				 );
}

$EntryMPCLoad_Popup = $mw -> Menu(-tearoff => 0, -menuitems => 
[
 					
	[Button  => 'Load from a text file', 
	 -command => sub {

		my $SizeBFA = @bdfFileArray;
		my $errorflag = 0;
		my $summnodeerrorflag = 0;

		if($SizeBFA == 0){

			$MainText-> delete("1.0", "end");
			$MainText->insert("end", "\nPlease select a bdf file to read!\n\n");
			$mw->update;	
		}else{

			&select_txt;

			my $MPCFilename = $txtFileArray[0];

			@MPCErrorArray = ();
			$MPCEACnt = 0;

			$MPCErrorArray[$MPCEACnt] = "Following errors occured:";
			$MPCEACnt++;
			
			my @SummationNodeList = ();
			my $SNLCnt = 0;
			
			my $linecnt = 1;

			if( (defined $MPCFilename) && ($MPCFilename ne "") ){

				open (FH, "<$MPCFilename") or die "Could not open $MPCFilename";
				
				while(<FH>) {
					
					my @LineSummaryArray = split(",", $_);
					my $SizeETA = @LineSummaryArray;
					
					if($SizeETA == 3){
					
						if($LineSummaryArray[2] =~ /^Node(\s+)(\d+)/   || $LineSummaryArray[2] =~ /^node(\s+)(\d+)/ ||
						   $LineSummaryArray[2] =~ /\s+Node(\s+)(\d+)/ || $LineSummaryArray[2] =~ /\s+node(\s+)(\d+)/){
							
							$SummationNodeList[$SNLCnt] = $2;
							$SNLCnt++;
						}
					}	
				}
				
				close FH;

				# We need to filter the repeated number of nodes and then sort the array
					
				my %FilterHash = ();
				my $key = 0;
			
				# We are filtering the repeated number of node ids.
				# First create the hash, then clear the @MPCNodeList
			
				foreach(@SummationNodeList){

					$FilterHash{$_} = $_;
				}

				@SummationNodeList = ();
				$SNLCnt = 0;

				# Then recreate the MPCNodeList array
			
				foreach $key (sort {$a <=> $b} keys %FilterHash){
						
					# Recreating ElmIDArray with filtered elements 		
					$SummationNodeList[$SNLCnt] = $key;	
					$SNLCnt++;
				}

				%FilterHash = ();
				$key = 0;						


				# Checking Summation node ids (NOT INTERFACE NODES: These will be checked later.)
				
				my @NodeCheckArray = @{checkNodeIds(@SummationNodeList);};

				my @FoundNodesArray = ();
				my $FNACnt = 0;
				
				for(my $i = 2; $i < ($NodeCheckArray[0]+2); $i++){
				
					$FoundNodesArray[$FNACnt] = $NodeCheckArray[$i];
					$FNACnt++;
				}

				my $SizeFNA = @FoundNodesArray;
												
				my @NotFoundNodesArray = ();
				my $NFNACnt = 0;
				
				for(my $i = ($NodeCheckArray[0]+2); $i < (2+$NodeCheckArray[0]+$NodeCheckArray[1]); $i++){
				
					$NotFoundNodesArray[$NFNACnt] = $NodeCheckArray[$i];
					$NFNACnt++;
				}					

				my $SizeNFNA = @NotFoundNodesArray;
				
				open (FH, "<$MPCFilename") or die "Could not open $MPCFilename";

				while(<FH>) {

					
					#print "D_ $_\n";
					
					my @LineSummaryArray = split(",", $_);

					my $SizeETA = @LineSummaryArray;

					my $line = "";

					my @NodeRangeArray = ();
					my $NRACnt = 0;

					my @ElementRangeArray = ();
					my $ERACnt = 0;

					my $NodeIdRepeatedFlag = 0;
					
					#print "Line $linecnt:\n";

						if($SizeETA == 3){

							if( $LineSummaryArray[0] =~ /^Node(\s+)(\d+)/   || $LineSummaryArray[0] =~ /^node(\s+)(\d+)/ ||
							    $LineSummaryArray[0] =~ /\s+Node(\s+)(\d+)/ || $LineSummaryArray[0] =~ /\s+node(\s+)(\d+)/){     


								my $NodeId = $2;

								for(my $i = 0; $i <= $#MPCInfoArray; $i++){

									my @MPCAllNodes = split (",", $MPCInfoArray[$i]);

									if($MPCAllNodes[0] == $NodeId){

										$errorflag = 1;
										$NodeIdRepeatedFlag = 1;
									}	
								}

								$line = "$NodeId" . "," . " ";


								# We need to filter the repeated number of nodes and then sort the array
					
								my %FilterHash = ();
								my $key = 0;


								$MPCNodeIDArray[$MPCNIDCnt] = $2;	# Contains the selected node ids
								$MPCNIDCnt++;				# Counter for @MPCNodeIDArray

								# We are filtering the repeated number of element or node ids.
								# First create the hash, then clear the NodeIDArray
			
								foreach(@MPCNodeIDArray){

									$FilterHash{$_} = $_;
								}

								@MPCNodeIDArray = ();
								$MPCNIDCnt = 0;

								# Then recreate the ElmIDArray
			
								foreach $key (sort {$a <=> $b} keys %FilterHash){
					
									# Recreating ElmIDArray with filtered elements 		
									$MPCNodeIDArray[$MPCNIDCnt] = $key;	
									$MPCNIDCnt++;
								}

								%FilterHash = ();
								$key = 0;
							}
                                                        
							if( $LineSummaryArray[1] =~ /^Coord(\s+)(\d+)/   || $LineSummaryArray[1] =~ /^coord(\s+)(\d+)/ ||
							    $LineSummaryArray[1] =~ /\s+Coord(\s+)(\d+)/ || $LineSummaryArray[1] =~ /\s+coord(\s+)(\d+)/){

								my $RefCoord = $2;
								$line = $line . "$RefCoord" . ",";

							}else{
								$errorflag = 1;

								if($NodeIdRepeatedFlag == 0){

									$MPCErrorArray[$MPCEACnt] = "Line $linecnt: Check coord id format";
									$MPCEACnt++;				
								}
							}

							if( $LineSummaryArray[2] =~ /^Node(\s+)(\d+)/   || $LineSummaryArray[2] =~ /^node(\s+)(\d+)/ ||
							    $LineSummaryArray[2] =~ /\s+Node(\s+)(\d+)/ || $LineSummaryArray[2] =~ /\s+node(\s+)(\d+)/){     
								
								if($2 > 0){

									if($NodeIdRepeatedFlag == 0 && $errorflag == 0){

										my $SummNodeID = $2;
										
										#print "SummNodeID $SummNodeID\n";
										my $nodeflag = 0;

										foreach(@FoundNodesArray){
										
											#print "SummNodeID $SummNodeID, FoundNodesArray $_\n";
											my @LineArray = split (" ", $_);
																						
											if(defined $LineArray[0] && $SummNodeID == $LineArray[0]){
											
												#print "SummNodeID $SummNodeID LineArray[0] $LineArray[0]\n";
												$nodeflag = 1;
												$line = $line . "$LineArray[1] $LineArray[2] $LineArray[3]";
												
											}
										}
										
										if($nodeflag == 0){
										
											$summnodeerrorflag = 1;
											$MPCErrorArray[$MPCEACnt] = "Line $linecnt: Summation nodes: @NotFoundNodesArray could not be found in the bdf file!";
											$MPCEACnt++;
										}
									}
								}		

							}elsif( $LineSummaryArray[2] =~ /\[(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)\]/ ||      
								$LineSummaryArray[2] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ || 

								$LineSummaryArray[2] =~ /\[(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||
								$LineSummaryArray[2] =~ /\[(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)\]/ ||           
								$LineSummaryArray[2] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)\]/ ||

								$LineSummaryArray[2] =~ /\[(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||		   
								$LineSummaryArray[2] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)\]/ ||
								$LineSummaryArray[2] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||


								$LineSummaryArray[2] =~ /\[(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||
								$LineSummaryArray[2] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ || 

								$LineSummaryArray[2] =~ /\[(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||
								$LineSummaryArray[2] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||
								$LineSummaryArray[2] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||

								$LineSummaryArray[2] =~ /\[(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||             
								$LineSummaryArray[2] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||      
								$LineSummaryArray[2] =~ /\[(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)\]/){

								if($NodeIdRepeatedFlag == 0){

									$line = $line . "$1 $3 $5";				
								}

							}elsif(

								$LineSummaryArray[2] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)\]/ ||
								$LineSummaryArray[2] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ || 

								$LineSummaryArray[2] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||
								$LineSummaryArray[2] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)\]/ ||
								$LineSummaryArray[2] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||

								$LineSummaryArray[2] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||             
								$LineSummaryArray[2] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)\]/ ||      
								$LineSummaryArray[2] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)\]/ ||


								$LineSummaryArray[2] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||
								$LineSummaryArray[2] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ || 

								$LineSummaryArray[2] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||
								$LineSummaryArray[2] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||
								$LineSummaryArray[2] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||

								$LineSummaryArray[2] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||             
								$LineSummaryArray[2] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||      
								$LineSummaryArray[2] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)\]/){

								if($NodeIdRepeatedFlag == 0){

									$line = $line . "$2 $4 $6";				
								}

							}else{

								$errorflag = 1;

								if($NodeIdRepeatedFlag == 0){

									$InterfaceErrorArray[$IEACnt] = "Line $linecnt: Please enter summation point correctly!";
									$IEACnt++;
									
									$InterfaceErrorArray[$IEACnt] = "When you are entering the coordinates for the summation point, do not forget to put \"0\" after \".\"";
									$IEACnt++;
							
									$InterfaceErrorArray[$IEACnt] = "For example: Instead of using \"14504.\" use \"14504.0\"";
									$IEACnt++;

									$InterfaceErrorArray[$IEACnt] = "Example:[(14504.0,-102.868,2719.95),(14504.0,-102.868,17477.1),(14504.0,-14860.1,2719.95)]";
									$IEACnt++;							
								}
							}

							if($errorflag == 0 && $NodeIdRepeatedFlag == 0){

								$MPCInfoArray[$MPCIACnt] = $line; # An array of all summation point ids and node ids and summation point coordinate	
								$MPCIACnt++;

							}elsif($NodeIdRepeatedFlag == 1){

								$MPCErrorArray[$MPCEACnt] = "Line $linecnt: MPC Node Id is already entered, please check the node id number!";
								$MPCEACnt++;
							}

						}else{

							$errorflag = 1;
							$MPCErrorArray[$MPCEACnt] = "Line $linecnt: Please check the format! Use the example format for interface point information!";
							$MPCEACnt++;

							$MPCErrorArray[$MPCEACnt] = "Make sure that thare are no empty lines or lines with only \"End of line\" character. Program will not recognise these lines and will give an error message!";
							$MPCEACnt++;
																					
						} # End of if($SizeETA == 4){

					$linecnt++;
						
				} # End of while(<FH>)

				close FH;

				@txtFileArray = ();	# This is the array that contains txt file names and their location
				$txtFileArray_i = 0;	# This is a counter for @txtFileArray = ()
			}

				my @NodeCheckArray = @{checkNodeIds(@MPCNodeIDArray);};

				my @FoundNodesArray = ();
				my $FNACnt = 0;
			
			        for(my $i = 2; $i < ($NodeCheckArray[0]+2); $i++){
				
					$FoundNodesArray[$FNACnt] = $NodeCheckArray[$i];
			 		$FNACnt++;
				}

				my $SizeFNA = @FoundNodesArray;
			        				
			 	my @NotFoundNodesArray = ();
			 	my $NFNACnt = 0;
			
				for(my $i = ($NodeCheckArray[0]+2); $i < (2+$NodeCheckArray[0]+$NodeCheckArray[1]); $i++){
			
			        	$NotFoundNodesArray[$NFNACnt] = $NodeCheckArray[$i];
			        	$NFNACnt++;
			 	}					

				my $SizeNFNA = @NotFoundNodesArray;

			        if($NodeCheckArray[1] > 0){			
			        	
			        	$errorflag = 1;

			        	$MPCErrorArray[$MPCEACnt] = "Please check MPC node ids! Node id(s): @NotFoundNodesArray could not be found in the bdf file!";
			        	$MPCEACnt++;
				}


			if($errorflag == 0 && $summnodeerrorflag == 0){

				$MainText -> delete("0.0", "end");
				$MainText->insert("end", "\nThe following MPC information is entered:\n\n");
				$MainText->insert("end", "MPC Node Id, Reference Coord Id, and the Summation Node/Point:\n");	

				foreach(@MPCInfoArray){

					my @InfoArray = split (",", $_);
					$MainText->insert("end", "Node Id: $InfoArray[0], Coord Id: $InfoArray[1], Summation Point: $InfoArray[2]\n");	
				}

			}elsif($errorflag == 1 || $summnodeerrorflag == 1){
                            
				@MPCInfoArray = (); # An array of all summation point ids and node ids and summation point coordinate	
				$MPCIACnt = 0;

				$MainText -> delete("0.0", "end");
				$MainText->insert("end", "\n");

				foreach(@MPCErrorArray){

					$MainText->insert("end", "$_\n");	
				}
											
			} # End of elsif($errorflag == 1 || $summnodeerrorflag == 1){					
		} # End of if($SizeBFA == 0){	 
	 }]
]);


$mw -> Label(	-text => "3(c). For max/min freebody loads, Enter node id, connecting element ids,"
		#-font => 'Courier -12'
				) -> place(-relx => 0.01, -rely => 0.45);
				 
$mw -> Label(	-text => "ref.coord id, number of max/min values and Summ. node/point"
		#-font => 'Courier -12'
				) -> place(-relx => 0.02, -rely => 0.47);
				
$mw -> Label(	-text => "for each freebody seperately. Enter \"del\" to clear. Example (for 2 max/min"
		#-font => 'Courier -12'
				) -> place(-relx => 0.02, -rely => 0.49);
				
$mw -> Label(	-text => "Cases): Node 1125, Element 10019, Coord 2, 2, [0 0 0] or Node 1125"
		#-font => 'Courier -12'
				) -> place(-relx => 0.02, -rely => 0.51);

my $EntryNodeElmCoordTxt = "Enter Node ID, Element IDs, Coord ID, N.of Max/Min, Summation Point/Node";

my $EntryNodeElmCoord = $mw -> Entry( -relief => 'groove',
			          -background => 'white',
				  -width => 80,  
 			          -state => 'normal',
				  #-font => 'Courier -12',
			          -textvariable => \$EntryNodeElmCoordTxt) -> place(-relx => 0.02, -rely => 0.54);

$EntryNodeElmCoord -> bind('<Control-v>' => sub{

	$EntryNodeElmCoord -> delete('sel.first', 'sel.last')
		if $EntryNodeElmCoord -> selectionPresent();

});

my $EntryNodeElmCoordMessageCnt = 0;

$EntryNodeElmCoord -> bind('<Button-1>', sub{
	
	$EntryNodeElmCoordMessageCnt++;

	if($EntryNodeElmCoordMessageCnt <= 1){
		
		$MainText -> delete("0.0", "end"); 
		$MainText -> insert("end", "\nExample: Node 1125, Element 10019, Coord 2, 2, [0 0 0]\n");
	}

});

$EntryNodeElmCoord -> bind('<Button-3>'=> \&EntryNodeElmCoord_Popup); 

my $EntryNodeElmCoord_Popup;
my $EntryNodeElmCoord_popanchor  = 'nw';
my $EntryNodeElmCoord_popover = $EntryNodeElmCoord;
my $EntryNodeElmCoord_overanchor  = 'c';

sub EntryNodeElmCoord_Popup{
    $EntryNodeElmCoord_Popup -> Popup(-popanchor  => $EntryNodeElmCoord_popanchor,
				  -overanchor => $EntryNodeElmCoord_overanchor,
				  -popover    => $EntryNodeElmCoord_popover,
				 );
}

$EntryNodeElmCoord_Popup = $mw -> Menu(-tearoff => 0, -menuitems => 
[
 					
	[Button  => 'Load from a text file', 
	 -command => sub {}]
]);


$EntryNodeElmCoord -> bind('<Return>' => sub{		

	$MainText-> delete("1.0", "end");
	$mw->update;
		
	my $NodeID = 0;
	my $ElmID = 0;
	my $CoordID = -1;	# Coord Id can be zero (global coordinate frame)
	my $NofMaxMin = 0;
		
	my @EntryArray = split ',', $EntryNodeElmCoordTxt;
	my $SizeEA = @EntryArray;
	
	if($EntryNodeElmCoordTxt =~ /^del$/){
	
			@FreebodyEntryLineArray = ();
			
			@FreebodyNodeIDArray = ();	@FreebodyElmIDArray = ();	@FreebodyCoordIDArray = ();	@FreebodyMaxMinArray = ();
			$FBNIACnt = 0;			$FBEIACnt = 0;			$FBCIACnt = 0;			$FBMMACnt = 0;

			$MainText-> delete("1.0", "end");
			$MainText->insert("end", "\nAll Node ID, Element ID, Coord ID and Number of Max/Mins information are deleted!\n");
			$mw->update;
	
	}else{
	
		my $SizeBFA = @bdfFileArray;
		
		if($SizeBFA == 0){

			#$errorflag = 1;

			#if($PointIdRepeatedFlag == 0){

				$MainText->insert("end", "\nPlease select a bdf file to read!\n\n");
				$mw->update;						
			#}
		}else{
	
			if($SizeEA == 5){
			
				if( ($EntryArray[0] =~ /Node\s+(\d+)$/ || $EntryArray[0] =~ /node\s+(\d+)$/ || 
	     		     	     $EntryArray[0] =~ /Node\s+(\d+)\s+$/ || $EntryArray[0] =~ /node\s+(\d+)\s+$/) 
	     
	     			&& 
	    
	    		    	    ($EntryArray[1] =~ /Element\s+(\d+)$/ || $EntryArray[1] =~ /Elm\s+(\d+)$/ || 
	     		     	     $EntryArray[1] =~ /elm\s+(\d+)$/ || $EntryArray[1] =~ /element\s+(\d+)$/ ||
	     		     	     $EntryArray[1] =~ /Element\s+(\d+)\s+$/ || $EntryArray[1] =~ /Elm\s+(\d+)\s+$/ || 
	     		     	     $EntryArray[1] =~ /elm\s+(\d+)\s+$/ || $EntryArray[1] =~ /element\s+(\d+)\s+$/) 
	     
	    			&& 
	    
	    		    	    ($EntryArray[2] =~ /Coord\s+(\d+)$/ || $EntryArray[2] =~ /coord\s+(\d+)$/ ||
	     		     	     $EntryArray[2] =~ /Coord\s+(\d+)\s+$/ || $EntryArray[2] =~ /coord\s+(\d+)\s+$/)
	     
	     			&& 
	     	    
	    		    	    ($EntryArray[3] =~ /^(\d+)$/ || $EntryArray[3] =~ /^(\d+)\s+$/ ||
	     		     	     $EntryArray[3] =~ /^\s+(\d+)$/ || $EntryArray[3] =~ /^\s+(\d+)\s+$/)
	     
	     			&&
	     
	    		   	   (($EntryArray[4] =~ /^Node(\s+)(\d+)/ || $EntryArray[4] =~ /^node(\s+)(\d+)/ ||
	      		     	     $EntryArray[4] =~ /\s+Node(\s+)(\d+)/ || $EntryArray[4] =~ /\s+node(\s+)(\d+)/)
	      
	      			||
	      
	     		    	    ($EntryArray[4] =~ /\[(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)\]/ ||      
	      		     	     $EntryArray[4] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ || 

	      		     	     $EntryArray[4] =~ /\[(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||
	      		     	     $EntryArray[4] =~ /\[(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)\]/ ||           
	      		     	     $EntryArray[4] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)\]/ ||

	      		     	     $EntryArray[4] =~ /\[(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||		   
	      		     	     $EntryArray[4] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)\]/ ||
	      		     	     $EntryArray[4] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||


	      		     	     $EntryArray[4] =~ /\[(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||
	      		     	     $EntryArray[4] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ || 

	      		     	     $EntryArray[4] =~ /\[(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||
	      		     	     $EntryArray[4] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||
	      		     	     $EntryArray[4] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||

	      		     	     $EntryArray[4] =~ /\[(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||             
	      		     	     $EntryArray[4] =~ /\[(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||      
	      		     	     $EntryArray[4] =~ /\[(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)\]/) 
	      
	      			||
	      
	     		    	    ($EntryArray[4] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)\]/ ||
	      		     	     $EntryArray[4] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ || 

	      		     	     $EntryArray[4] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||
	      		     	     $EntryArray[4] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)\]/ ||
	      		     	     $EntryArray[4] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||

	      		     	     $EntryArray[4] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)\]/ ||             
	      		     	     $EntryArray[4] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)\]/ ||      
	      		     	     $EntryArray[4] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)\]/ ||


	      		     	     $EntryArray[4] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||
	      		     	     $EntryArray[4] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ || 

	      		     	     $EntryArray[4] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||
	      		     	     $EntryArray[4] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||
	      		     	     $EntryArray[4] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||

	      		     	     $EntryArray[4] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)\]/ ||             
	      		     	     $EntryArray[4] =~ /\[(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)(\d+||-\d+)(\s+)\]/ ||      
	      		     	     $EntryArray[4] =~ /\[(\s+)(\d+||-\d+)(\s+)(\d+\.\d+||-\d+\.\d+)(\s+)(\d+||-\d+)(\s+)\]/))	      
								
				){
		

					my @NodeID =  split ' ', $EntryArray[0]; $NodeID = $NodeID[1]; 
					my @ElmID =   split ' ', $EntryArray[1]; $ElmID = $ElmID[1]; 
					my @CoordID = split ' ', $EntryArray[2]; $CoordID = $CoordID[1];
		
					if($EntryArray[3] =~ /(\d+)$/ || $EntryArray[3] =~ /(\d+)\s+$/){
		
						$NofMaxMin = $1;
					}
				
					#$MainText->insert("end", "\n$NodeID = $NodeID[1]; $ElmID = $ElmID[1]; $CoordID = $CoordID[1]; NofMaxMin = $NofMaxMin EntryArray[3] $EntryArray[3]\n");

					my $NodeRepeatFlag = 0;

					for(my $i = 0; $i <= $#FreebodyNodeIDArray; $i++){

						if($FreebodyNodeIDArray[$i] == $NodeID){
				
							$NodeRepeatFlag = 1;
						}	
					}
		
					if(defined $NodeID && defined $ElmID && defined $CoordID && defined $NofMaxMin &&
		   				$NodeID > 0 && $ElmID > 0 && $CoordID > -1 && $NofMaxMin > 0 &&
		   				$NodeRepeatFlag == 0){
			
						#print ("before push: $NodeID $EntryNodeElmCoordTxt\n");
			
						push (@FreebodyEntryLineArray, [$EntryNodeElmCoordTxt, $NodeID]);
			
						#print ("freebodylinearray:\n @FreebodyEntryLineArray\n");
			
						my @tmparray = ();
			
						@tmparray = @FreebodyEntryLineArray;
			
						@tmparray = map {$_->[0]}
				    	    		sort {$a->[1] <=> $b->[1]}
				    	    		@tmparray;
			
						#print ("temparray:\n @tmparray\n");
			
						#$MainText-> delete("1.0", "end");
						#$MainText->insert("end", "array:\n");
			
						@FreebodyNodeIDArray = ();	@FreebodyElmIDArray = ();	@FreebodyCoordIDArray = ();	@FreebodyMaxMinArray = ();
						$FBNIACnt = 0;			$FBEIACnt = 0;			$FBCIACnt = 0;			$FBMMACnt = 0;
			
						foreach(@tmparray){
			
							#$MainText->insert("end", "$_\n");
				
							my @EntryArray = split ',', $_;
				
							my @NodeID =  split ' ', $EntryArray[0]; $NodeID = $NodeID[1]; 
							my @ElmID =   split ' ', $EntryArray[1]; $ElmID = $ElmID[1]; 
							my @CoordID = split ' ', $EntryArray[2]; $CoordID = $CoordID[1];
				            			$NofMaxMin = $EntryArray[3];
				
							$FreebodyNodeIDArray[$FBNIACnt] = $NodeID;	# Contains the selected node ids for freebody loads
							$FBNIACnt++;				# Counter for @FreebodyNodeIDArray

							$FreebodyElmIDArray[$FBEIACnt] = $ElmID;	# Contains the connecting element ids for freebody loads
							$FBEIACnt++;				# Counter for @FreebodyElmIDArray

							$FreebodyCoordIDArray[$FBCIACnt] = $CoordID;	# Contains the connecting coord. ids for freebody loads
							$FBCIACnt++;				# Counter for @FreebodyCoordIDArray

							$FreebodyMaxMinArray[$FBMMACnt] = $NofMaxMin;# Contains the connecting requested number of max/min (max/min load case) for each freebody loads (each node)
							$FBMMACnt++;				# Counter for @FreebodyMaxMinArray
						}
						
					} # End of if(defined $NodeID && defined $ElmID && defined $CoordID && defined $NofMaxMin &&
		
					my $SizeNodeIDArray = @FreebodyNodeIDArray;
		
					#$MainText->insert("end", "\nSizeNodeIDArray $SizeNodeIDArray\n");
	
					if($SizeNodeIDArray > 0){
				
						if($NodeRepeatFlag == 1){
				
							$MainText->insert("end", "The node id $NodeID is already entered!\n");
						}
			
						$MainText->insert("end", "\nSelected Node ID, Element ID, Coord ID and Number of Max/Mins:\n");
	
						for(my $i = 0; $i <= $#FreebodyNodeIDArray; $i++){
							$MainText->insert("end", "Node $FreebodyNodeIDArray[$i], Element $FreebodyElmIDArray[$i], Coord $FreebodyCoordIDArray[$i], $FreebodyMaxMinArray[$i]\n");
						}
	
						$mw->update;
			
					}
		
				} # End of if( ($EntryArray[0] =~ /Node\s+(\d+)$/ || $EntryArray[0] =~ /node\s+(\d+)$/ || 
			
			} #End of if($SizeEA == 5){
			
		} # End of if($SizeBFA == 0){
		
	} # End of if($EntryNodeElmCoordTxt =~ /^del$/){
	
		#$MainText-> delete("1.0", "end");
		#$MainText->insert("end", "\n\"$EntryNodeElmCoordTxt\" does not seem to be in correct format\n");
		#$MainText->insert("end", "\nPlease enter Node ID, Element ID and Coord ID using following format!\n");
		#$MainText->insert("end", "\nExample: Node 1125, Element 10019, Coord 2\n\n");
		#$mw->update;		
});


$mw -> Label(	-text => "3(d). For gamah coupling displacements, Enter six or three node ids and the ref."
		#-font => 'Courier -12'
				) -> place(-relx => 0.01, -rely => 0.57);
				 
$mw -> Label(	-text => "coord id for coordinate transformation, do not enter information more than 4 gamah"
		#-font => 'Courier -12'
				) -> place(-relx => 0.02, -rely => 0.59);

$mw -> Label(	-text => "coupling. Program can extract results up to 2 twin & 2 single gamah couplings."
		#-font => 'Courier -12'
				) -> place(-relx => 0.02, -rely => 0.61);				

$mw -> Label(	-text => "Example: 1125,1130,1135,1145,1150,1155,Coord 248"
		#-font => 'Courier -12'
				) -> place(-relx => 0.02, -rely => 0.63);
				
$mw -> Label(	-text => "Example: 2180,2185,2190,Coord 300"
		#-font => 'Courier -12'
				) -> place(-relx => 0.02, -rely => 0.65);

my $EntryGamahTxt = "Enter ID1, ID2, ID3, ID4, ID5, ID6, Coord ID or ID1, ID2, ID3, Coord ID";

my $EntryGamah = $mw -> Entry( -relief => 'groove',
			          -background => 'white',
				  -width => 80,  
 			          -state => 'normal',
				  #-font => 'Courier -12',
			          -textvariable => \$EntryGamahTxt) -> place(-relx => 0.02, -rely => 0.68);

$EntryGamah -> bind('<Control-v>' => sub{

	$EntryGamah -> delete('sel.first', 'sel.last')
		if $EntryGamah -> selectionPresent();

});

$EntryGamah -> bind('<Button-3>'=> \&EntryGamah_Popup); 

my $EntryGamah_Popup;
my $EntryGamah_popanchor  = 'nw';
my $EntryGamah_popover = $EntryGamah;
my $EntryGamah_overanchor  = 'c';

sub EntryGamah_Popup{
    $EntryGamah_Popup -> Popup(-popanchor  => $EntryGamah_popanchor,
				  -overanchor => $EntryGamah_overanchor,
				  -popover    => $EntryGamah_popover,
				 );
}

$EntryGamah_Popup = $mw -> Menu(-tearoff => 0, -menuitems => 
[
 					
	[Button  => 'Load from a text file', 
	 -command => sub {

		my $SizeBFA = @bdfFileArray;
		
		if($SizeBFA == 0){

			#$errorflag = 1;

			#if($PointIdRepeatedFlag == 0){

				$MainText->insert("end", "\nPlease select a bdf file to read!\n\n");
				$mw->update;						
			#}
		}else{
	 
			&select_txt;

			my $GamahFilename = $txtFileArray[0];

			@GamahErrorArray = ();
			$GEACnt = 0;

			$GamahErrorArray[$GEACnt] = "Following errors occured:";
			$GEACnt++;
			
			my @GamahNodeList = ();
			my $GNLCnt = 0;
			
			my $CoorIDFlag = 0;
			my $errorflag1 = 0;
			my $errorflag2 = 0;
			
			my $linecnt = 1;

			my @CoordIDCheckArray = ();
			my $CICACnt = 0;

			if( (defined $GamahFilename) && ($GamahFilename ne "") ){

				open (FH, "<$GamahFilename") or die "Could not open $GamahFilename";
				
				while(<FH>) {
					
					my @LineArray = split(",", $_);
					my $SizeETA = @LineArray;
					
					if($SizeETA == 7){
					
						if($LineArray[0] =~ /\d+/ && $LineArray[1] =~ /\d+/ &&
						   $LineArray[2] =~ /\d+/ && $LineArray[3] =~ /\d+/ &&
						   $LineArray[4] =~ /\d+/ && $LineArray[5] =~ /\d+/ ){
							
							$GamahNodeList[$GNLCnt] = $LineArray[0];$GNLCnt++;
							$GamahNodeList[$GNLCnt] = $LineArray[1];$GNLCnt++;
							$GamahNodeList[$GNLCnt] = $LineArray[2];$GNLCnt++;
							$GamahNodeList[$GNLCnt] = $LineArray[3];$GNLCnt++;
							$GamahNodeList[$GNLCnt] = $LineArray[4];$GNLCnt++;
							$GamahNodeList[$GNLCnt] = $LineArray[5];$GNLCnt++;	
						}else{
							$errorflag2 = 1;

							$GamahErrorArray[$GEACnt] = "Check node id format";
							$GEACnt++;														
						}

						if($LineArray[6] =~ /^Coord(\s+)(\d+)/ || $LineArray[6] =~ /^coord(\s+)(\d+)/ ||
						   $LineArray[6] =~ /\s+Coord(\s+)(\d+)/ || $LineArray[6] =~ /\s+coord(\s+)(\d+)/){

							$CoordIDCheckArray[$CICACnt] = $2;
							$CICACnt++;
						}else{
							$errorflag2 = 1;

							$GamahErrorArray[$GEACnt] = "Check node id format";
							$GEACnt++;														
						}											
						
					}elsif($SizeETA == 4){

						if($LineArray[0] =~ /\d+/ && 
						   $LineArray[1] =~ /\d+/ &&
						   $LineArray[2] =~ /\d+/ ){
							
							$GamahNodeList[$GNLCnt] = $LineArray[0];$GNLCnt++;
							$GamahNodeList[$GNLCnt] = $LineArray[1];$GNLCnt++;
							$GamahNodeList[$GNLCnt] = $LineArray[2];$GNLCnt++;
						}else{
							$errorflag2 = 1;

							$GamahErrorArray[$GEACnt] = "Check node id format";
							$GEACnt++;														
						}

						if($LineArray[3] =~ /^Coord(\s+)(\d+)/ || $LineArray[3] =~ /^coord(\s+)(\d+)/ ||
						   $LineArray[3] =~ /\s+Coord(\s+)(\d+)/ || $LineArray[3] =~ /\s+coord(\s+)(\d+)/){

							$CoordIDCheckArray[$CICACnt] = $2;
							$CICACnt++;
						}else{
							$errorflag2 = 1;

							$GamahErrorArray[$GEACnt] = "Check node id format";
							$GEACnt++;														
						}
					}
					
					$linecnt++;	
				}
				
				close FH;

				# We need to filter the repeated number of nodes and then sort the array
					
				my %FilterHash = ();
				my $key = 0;
			
				# We are filtering the repeated number of node ids.
				# First create the hash, then clear the @GamahNodeList
			
				foreach(@GamahNodeList){

					$FilterHash{$_} = $_;
				}

				@GamahNodeList = ();
				$GNLCnt = 0;

				# Then recreate the GamahNodeList array
			
				foreach $key (sort {$a <=> $b} keys %FilterHash){
						
					# Recreating GamahNodeList with filtered elements 		
					$GamahNodeList[$GNLCnt] = $key;	
					$GNLCnt++;
				}

				%FilterHash = ();
				$key = 0;						

				#foreach(@GamahNodeList){
				
					#print "1: $_\n";
				#}

				my @NodeCheckArray = ();
		
				@NodeCheckArray = @{checkGamahNodeIds(@GamahNodeList);};
			
				#my @ReturnArray = ($SizeNPA, $SizeNIA, $SizeLNRA, $SizeNLNIA, @NodeIDArray, @LocalNodesReturnArray, @NoLocalNodeIDArray);

				if(defined $NodeCheckArray[0] && $NodeCheckArray[0] > 0){
		
					$errorflag1 = 1;
					
					$GamahErrorArray[$GEACnt] = "The following node ids could not be found in the bdf file:";
					$GEACnt++;
									
					# If there are missing nodes, empty the list and tell the user to enter node ids again
				
					@GamahNodeList = (); 
					$GNLCnt = 0;
					
					for(my $i = (4+$NodeCheckArray[1]+$NodeCheckArray[2]); $i <=$#NodeCheckArray; $i++){
					
						$GamahErrorArray[$GEACnt] = "$NodeCheckArray[$i],";
						$GEACnt++;		
					}
				}


				# We need to filter the repeated number of nodes and then sort the array
					
				%FilterHash = ();
				$key = 0;
			
				# We are filtering the repeated number of coord ids.
				# First create the hash, then clear the @CoordIDCheckArray
			
				foreach(@CoordIDCheckArray){

					$FilterHash{$_} = $_;
				}

				@CoordIDCheckArray = ();
				$CICACnt = 0;

				# Then recreate the CoordIDCheckArray array
			
				foreach $key (sort {$a <=> $b} keys %FilterHash){
						
					# Recreating ElmIDArray with filtered elements 		
					$CoordIDCheckArray[$CICACnt] = $key;	
					$CICACnt++;
				}

				%FilterHash = ();
				$key = 0;						

				my @CoorIDFlagArray =  @{checkCoordIds(@CoordIDCheckArray);};
		
				$CoorIDFlag = $CoorIDFlagArray[0];
			
				if($CoorIDFlag > 0){
			
					$errorflag1 = 1;
					
					@CoordIDCheckArray = (); $CICACnt = 0;

					$GamahErrorArray[$GEACnt] = "The following coordinate ids could not be found in the bdf file:";
					$GEACnt++;

					for(my $i = 1; $i <=$#CoorIDFlagArray; $i++){
				
						$GamahErrorArray[$GEACnt] = $CoorIDFlagArray[$i];
						$GEACnt++;								
					}
				}
				
				@txtFileArray = ();	# This is the array that contains txt file names and their location
				$txtFileArray_i = 0;	# This is a counter for @txtFileArray = ()
				
			}# End of if( (defined $GamahFilename) && ($GamahFilename ne "") ){
		} # End of if($SizeBFA == 0){
	 }]
]);


$mw -> Label(	-text => "3(e). For CBAR, CBEAM, CBUSH and CROD element forces (Fastener Loads)"
		#-font => 'Courier -12'
				) -> place(-relx => 0.52, -rely => 0.01);
				 
$mw -> Label(	-text => "simply enter element ids. Enter \"del\" to clear. Example:"
		#-font => 'Courier -12'
				) -> place(-relx => 0.53, -rely => 0.03);
				
$mw -> Label(	-text => "Element 900:1001 1005 1006 1010:1020:2 2026:2010:-4"
		#-font => 'Courier -12'
				) -> place(-relx => 0.53, -rely => 0.05);
				
$mw -> Label(	-text => "Enter number of max/min values in the next entry box."
		#-font => 'Courier -12'
				) -> place(-relx => 0.53, -rely => 0.07);

my $EntryNumberMaxMinTxtVar = "Enter No.Max/Min";

my $EntryNumberMaxMin = $mw -> Entry(-width => 20,
				-relief => 'groove',
			        -background => 'white',
			        -state => 'normal',
				#-font => 'Courier -12',
			        -textvariable => \$EntryNumberMaxMinTxtVar
			      	) -> place(-relx => 0.83, -rely => 0.10);

$EntryNumberMaxMin->bind('<Control-v>' => sub{

	$EntryNumberMaxMin -> delete('sel.first', 'sel.last')
		if $EntryNumberMaxMin -> selectionPresent();

});


				
my $ElmNodeROText;

#my $ElemNodeTxtvar = "Enter elm or node ids";
my $ElemNodeTxtvar = "Enter elm ids";

my $EntryElmNode = $mw -> Entry(-width => 50,
				-relief => 'groove',
			        -background => 'white',
			        -state => 'normal',
				#-font => 'Courier -12',
			        -textvariable => \$ElemNodeTxtvar
			      	) -> place(-relx => 0.53, -rely => 0.10);

$EntryElmNode->bind('<Control-v>' => sub{

	$EntryElmNode -> delete('sel.first', 'sel.last')
		if $EntryElmNode -> selectionPresent();

});

$EntryElmNode -> bind('<KeyPress>' => \&callback_Key_EntryRange);

sub callback_Key_EntryRange {

	if($ElemNodeTxtvar =~ /^\d+/ || $ElemNodeTxtvar =~ /^\s+\d+/){
	
		$ElmNodeROText -> delete("1.0", "end");
		#$ElmNodeROText -> insert("end", "Please type \"Node\" or \"Element\" first!\n");
		$ElmNodeROText -> insert("end", "Please type \"Element\" first!\n");
		$ElmNodeROText -> insert("end", "before entering the id numbers\n");
		$ElemNodeTxtvar = "";
	
	}elsif($ElemNodeTxtvar =~ /[a-zA-z]/){
	
		if($ElemNodeTxtvar =~ /E/   || $ElemNodeTxtvar =~ /e/){
		
		}elsif($ElemNodeTxtvar =~ /N/    || $ElemNodeTxtvar =~ /n/){
		
		}else{

			$ElmNodeROText -> delete("1.0", "end");
			#$ElmNodeROText -> insert("end", "Please type \"Node\" or \"Element\" first!\n");
			$ElmNodeROText -> insert("end", "Please type \"Element\" first!\n");
			$ElemNodeTxtvar = "";
		}
		
	}elsif($ElemNodeTxtvar =~ /\:/){
		
	}elsif($ElemNodeTxtvar =~ /[\W_]/){

		$ElmNodeROText -> delete("1.0", "end");
		#$ElmNodeROText -> insert("end", "Please type \"Node\" or \"Element\" first!\n");
		$ElmNodeROText -> insert("end", "Please type \"Element\" first!\n");
		$ElemNodeTxtvar = "";
	}
};
	    
$EntryElmNode -> bind('<Return>' => sub{		

		my @RangeInfoArray = ();		
		my $RIACnt = 0;
				
		chomp($ElemNodeTxtvar);
		
		my $EntryText = "";
		my $ElmFlag = 0;
		my $NodeFlag = 0;
		
		if($ElemNodeTxtvar =~ /Element(.*)Node/ || $ElemNodeTxtvar =~ /Node(.*)Element/){
		
			$RangeInfoArray[$RIACnt] = "Please enter Node or Elmement ids.\nDo not enter both at the same time!";
			$RIACnt++;
						
		}elsif($ElemNodeTxtvar =~ /^Elm(.*)/   || $ElemNodeTxtvar =~ /^elm(.*)/ || 
		   $ElemNodeTxtvar =~ /\s+Elm(.*)/ || $ElemNodeTxtvar =~ /\s+elm(.*)/ ||
		   $ElemNodeTxtvar =~ /^Element(.*)/   || $ElemNodeTxtvar =~ /^element(.*)/ ||
		   $ElemNodeTxtvar =~ /\s+Element(.*)/ || $ElemNodeTxtvar =~ /\s+element(.*)/){

			@ElmIDArray = ();
			$EIDCnt = 0;
			$ERIACnt = 0;			

			@ElmRangeInfoArray = ();
			$ERIACnt = 0;
			
			$EntryText = $1;			
			
			if($EntryText =~ /[a-zA-z]/){
			
				$EntryText = "";	
			}
			
			$ElmFlag = 1;
			
		}elsif($ElemNodeTxtvar =~ /^Node(.*)/   || $ElemNodeTxtvar =~ /^node(.*)/ || 
		       $ElemNodeTxtvar =~ /\s+Node(.*)/ || $ElemNodeTxtvar =~ /\s+node(.*)/){
			
			@NodeIDArray = ();
			$NIACnt = 0;
			$NRIACnt = 0;	

			@NodeRangeInfoArray = ();
			$NRIACnt = 0;
			
			$EntryText = $1;

			if($EntryText =~ /[a-zA-z]/){
			
				$EntryText = "";	
			}

			$NodeFlag = 1;
					
		}else{												
			$RangeInfoArray[$RIACnt] = "Please type in Node or Elm \nbefore entering the id numbers";
			$RIACnt++;
		}
		
		my @EntryTextArray = split(" ", $EntryText);
		
		foreach(@EntryTextArray){
				
			if($ElmFlag == 1){
				$ElmRangeInfoArray[$ERIACnt] = $_;		
				$ERIACnt++;
			}elsif($NodeFlag == 1){
				$NodeRangeInfoArray[$NRIACnt] = $_;		
				$NRIACnt++;				
			}
			
			if($_ =~ /(\d+)\:(\d+)\:(\d+)/ || $_ =~ /(\d+)\:(\d+)\:(\-\d+)/){
			
				my @field = ();
				my $ID_1 = 0; my $ID_2 = 0; my $Range = 0; 

				@field = split(":",$_);

				$ID_1 = $1 * 1; $ID_2 = $2 * 1; $Range = $3 * 1;
			  		
			  	if(($ID_1 > 0) && ($ID_2 > 0) && ($ID_1 < $ID_2) && ($Range > 0)){
			  			
					for(my $i = 0; $i <= (($ID_2 - $ID_1)/$Range); $i++){
						 
					 	if($ElmFlag == 1){
							$ElmIDArray[$EIDCnt] = $ID_1 + ($Range * $i);
							$EIDCnt++;
						}elsif($NodeFlag == 1){
							$NodeIDArray[$NIACnt] = $ID_1 + ($Range * $i);
							$NIACnt++;							
						}
					}

				}elsif(($ID_1 > 0) && ($ID_2 > 0) && ($ID_1 > $ID_2) && ($Range < 0)){
			  			
					for(my $i = 0; $i <= (($ID_2 - $ID_1)/$Range); $i++){
						 
					 	if($ElmFlag == 1){
							$ElmIDArray[$EIDCnt] = $ID_1 + ($Range * $i);
							$EIDCnt++;
						}elsif($NodeFlag == 1){
							$NodeIDArray[$NIACnt] = $ID_1 + ($Range * $i);
							$NIACnt++;							
						}
					}

				}else{												
					$RangeInfoArray[$RIACnt] = "Please check if $ID_1:$ID_2:$Range is correct.";
					$RIACnt++;
				}
			  	
			}elsif($_ =~ /(\d+)\:(\d+)/){
					
				my @field = ();
				my $ID_1 = 0; my $ID_2 = 0; 

				@field = split(":",$_);

				$ID_1 = $1 * 1; $ID_2 = $2 * 1; 
			  		
				if(($ID_1 > 0) && ($ID_2 > 0) && ($ID_1 < $ID_2)){
			  			
					for(my $i = 0; $i <= ($ID_2 - $ID_1); $i++){

					 	if($ElmFlag == 1){
							$ElmIDArray[$EIDCnt] = $ID_1 + $i;
							$EIDCnt++;
						}elsif($NodeFlag == 1){
							$NodeIDArray[$NIACnt] = $ID_1 + $i;
							$NIACnt++;						
						}						 
					}
						
				}else{												
					$RangeInfoArray[$RIACnt] = "Please check if $ID_1:$ID_2 is correct.";
					$RIACnt++;
				}				
				
			}elsif($_ =~ /(\d+)/){
			  		
				my $ID = $1 * 1;
					
				if($ID > 0){

					if($ElmFlag == 1){
						$ElmIDArray[$EIDCnt] = $ID;
						$EIDCnt++;
					}elsif($NodeFlag == 1){
						$NodeIDArray[$NIACnt] = $ID;
						$NIACnt++;						
					}
						
				}else{
					$RangeInfoArray[$RIACnt] = "Please check elm id $ID";
					$RIACnt++;					
				}
			  	      
			}
				
			 	
		} # End of foreach

		# **** PLEASE NOTE ***************************************************************************
					
		# We need to filter the repeated number of elements or grids and then sort the array
					
		my %FilterHash = ();
		my $key = 0;

		my $FirstSizeNIA = @NodeIDArray;
		my $FirstSizeEIA = @ElmIDArray;

		#print "Before filtering:\nFirstSizeNRIA: $FirstSizeNIA \n";
		#print "FirstSizeEIA: $FirstSizeEIA \n";
		#print "ElmFlag: $ElmFlag\n";
		#print "NodeFlag: $NodeFlag\n";
		
		if($ElmFlag == 1){
			
			# We are filtering the repeated number of element or node ids.
			# First create the hash, then clear the ElmIDArray
			
			foreach(@ElmIDArray){

				$FilterHash{$_} = $_;
			}

			@ElmIDArray = ();
			$EIDCnt = 0;

			# Then recreate the ElmIDArray
			
			foreach $key (sort {$a <=> $b} keys %FilterHash){
						
				# Recreating ElmIDArray with filtered elements 		
				$ElmIDArray[$EIDCnt] = $key;	
				$EIDCnt++;
			}

			%FilterHash = ();
			$key = 0;						
		
			#$ElmFlag  = 0;
		
		}elsif($NodeFlag == 1){

			# We are filtering the repeated number of element or node ids.
			# First create the hash, then clear the NodeIDArray
			
			foreach(@NodeIDArray){

				$FilterHash{$_} = $_;
			}		

			@NodeIDArray = ();
			$NIACnt = 0;
			
			# Then recreate the NodeIDArray
			
			foreach $key(sort {$a <=> $b} keys %FilterHash){
						
				# Recreating NodeIDArray with filtered elements 		
				$NodeIDArray[$NIACnt] = $key;	
				$NIACnt++;
			}
			
			%FilterHash = ();
			$key = 0;
			
			#$NodeFlag = 0;

		}

		# ********************************************************************************************
			
		$ElmNodeROText -> delete("1.0", "end");
		$MainText -> delete("1.0", "end");
			
		my $SizeNIA = @NodeIDArray;
		my $SizeEIA = @ElmIDArray;
		my $SizeRIA = @RangeInfoArray;
		my $SizeNRIA = @NodeRangeInfoArray;
		my $SizeERIA = @ElmRangeInfoArray;

		#print "After filtering:\nSizeNIA: $SizeNIA \n";
		#print "SizeEIA: $SizeEIA \n";	
		#print "SizeNRIA $SizeNRIA SizeERIA $SizeERIA\n";
		
		if($SizeNIA > 0){
		
			#$ElmNodeROText -> insert("end", "Node ");
			$MainText    -> insert("end", "\nSelected Node IDs: \n");
			
			my $i = 1;
			
			foreach(@NodeIDArray){
				
				#$ElmNodeROText -> insert("end", "$_\n");
				$MainText -> insert("end", "$_,");
				
				if($i % 10 == 0){$MainText -> insert("end", "\n");}
				
				$i++;
				
				$mw->update;
			}
			
			$MainText -> insert("end", "\n\n");
		}
			
		if($SizeEIA > 0){
			
			$FastenerFlag = 1;
			
			#$ElmNodeROText -> insert("end", "Elm ");	
			$MainText    -> insert("end", "\nSelected Elm IDs:\n");
			
			my $i = 1;
			
			foreach(@ElmIDArray){
				
				#$ElmNodeROText -> insert("end", "$_\n");
				$MainText -> insert("end", "$_,");
				
				if($i % 10 == 0){$MainText -> insert("end", "\n");}
				
				$i++;
				
				$mw->update;
			}
			
			$MainText    -> insert("end", "\n\n");
		}
		
		if($SizeNRIA > 0 && $NodeFlag == 1){
		
			$ElmNodeROText -> delete("1.0", "end");
			$ElmNodeROText -> insert("end", "Node ");
			#$MainText  -> insert("end", "Node range summary:\n");	
			
			my $i = 1;
			
			foreach(@NodeRangeInfoArray){
							
				$ElmNodeROText -> insert("end", "$_, ");
				
				if($i % 3 == 0){$ElmNodeROText -> insert("end", "\n");}	
				#$MainText -> insert("end", "$_\n");
				$i++;
				$mw->update;
			}
			
			#$MainText    -> insert("end", "\n");
			
			if($FirstSizeNIA > $SizeNIA){
				$ElmNodeROText -> insert("end", "Please note some node ids are repeated\nand they are removed from the list.\n");
				$MainText -> insert("end", "Please note some node ids are repeated\nand they are removed from the list.\n");			
			}
			
		}
	
		if($SizeERIA > 0 && $ElmFlag == 1){
			
			$ElmNodeROText -> delete("1.0", "end");
			$ElmNodeROText -> insert("end", "Elm ");	
			#$MainText  -> insert("end", "Elm range summary:\n");
			
			my $i = 1;
			
			foreach(@ElmRangeInfoArray){
							
				$ElmNodeROText -> insert("end", "$_, ");
				if($i % 3 == 0){$ElmNodeROText -> insert("end", "\n");}
				$i++;
				#$MainText -> insert("end", "$_\n");
				$mw->update;
			}
			
			#$MainText    -> insert("end", "\n");
			
			if($FirstSizeEIA > $SizeEIA){
				$ElmNodeROText -> insert("end", "Please note some elment ids are repeated\nand they are removed from the list.\n");
				$MainText -> insert("end", "Please note some elment ids are repeated\nand they are removed from the list.\n");			
			}
			
		}
				
		if($SizeRIA > 0){	

			$ElmNodeROText -> delete("1.0", "end");
			$MainText -> delete("1.0", "end");
						
			foreach(@RangeInfoArray){
				$ElmNodeROText -> insert("end", "$_\n");
				$MainText -> insert("end", "$_\n");
				$mw->update;
			}
		}		

		$NodeFlag = 0;
		$ElmFlag = 0;
});


$ElmNodeROText = $mw -> Scrolled("ROText", 
				  -wrap => 'none', 
				  -scrollbars => 'se', 
				  -width => 47, 
				  -height => 8, 
				  -relief => 'groove',
				  -state => 'normal'
				) -> place(-relx => 0.53, -rely => 0.13);

$ElmNodeROText -> delete("1.0", "end");
#$ElmNodeROText -> insert("end", "Example:\nNode 10:12 21 31 40:48:2\n1026:1010:-4\n\nOr");
#$ElmNodeROText -> insert("end", "\n\nElement 900:1001 1005 1006\n1010:1020:2 2026:2010:-4\n");
$ElmNodeROText -> insert("end", "Example:\nElement 900:1001 1005 1006\n1010:1020:2 2026:2010:-4\n");


$mw -> Label(	-text => "4. Start reading the bdf file:"
		#-font => 'Courier -12'
					) -> place(-relx => 0.52, -rely => 0.32); 

$btn_readbdf = $mw -> Button( -text => "Read single or multiple bdf file(s)",
			         -font => 'Helvetica -15 bold', 
			         -state => 'normal', 
			         -height => 1, 
			         -width => 35, 
			         -command => 
	sub{
	
		$btn_selectbdf -> configure(-state => 'disable');
		$btn_selectf06 -> configure(-state => 'disable');
		$btnGamahCoupling -> configure(-state => 'disable');
		$btnInterface -> configure(-state => 'disable');
		$BUTTON_EXIT -> configure(-state => 'disable');
                $btnFasteners -> configure(-state => 'disable');
		$mw->update;
				
		my $SizeSNBLA = 0;
		my $SizeBFA = @bdfFileArray;
		my $SizeEIA = @ElmIDArray;
		my $SizeNIA = @NodeIDArray;
		my $SizeMPCNIA = @MPCNodeIDArray;
		my $SizeFBNIA = @FreebodyNodeIDArray;
		my $SizeDNIA = @MPCNodeIDArray;
		my $AfterSizeNIA = @NodeIDArray;
		
		$SizeRBFRA = 0; # @readBdfFileReturnArray
		
		if($SizeNIA == 0 && $SizeFBNIA == 0 && $SizeMPCNIA == 0 && $FastenerFlag == 0 && $NewCoordFlag == 0){
	
			$MainText-> delete("1.0", "end");
			$MainText->insert("end", "\nPlease enter node ids first!\n\n");
			$mw->update;
			
		}elsif($SizeBFA == 0){

			$MainText-> delete("1.0", "end");
			$MainText->insert("end", "\nPlease select a bdf file to read!\n\n");
			$mw->update;
			
		}else{
			
			$MainText-> delete("1.0", "end");
			$btn_readbdf -> configure(-state => 'disable');
			
			$MainText->insert("end", "\nStarted reading the bdf file...\n");
			$mw->update;
			
			
			# @ReturnArray = (@NodeXYZCoordArray,@MPCNodeXYZCoordArray,@FreebodyNodeXYZCoordArray,@DispNodeXYZCoordArray);
			
			@readBdfFileReturnArray =  @{readBdfFile($SizeNIA,
								 $SizeMPCNIA, 
								 $SizeFBNIA,
								 $SizeDNIA,
								 @NodeIDArray, 
								 @MPCNodeIDArray, 
								 @FreebodyNodeIDArray, 
								 @DispNodeIDArray);};
			

			# my @ReturnArray = ($SizeNXYZCA, $SizeMPCNXYZCA, $SizeFBNXYZCA, $SizeDNXYZCA, @NodeXYZCoordArray, @MPCNodeXYZCoordArray, @FreebodyNodeXYZCoordArray, @DispNodeXYZCoordArray);

			# Locally rebuilding @NodeIDArray
			
			my $SizeNXYZCA = $readBdfFileReturnArray[0];
			my $NXYZCACnt = 0;
			
			for(my $i = 4; $i < ($SizeNXYZCA + 4) ; $i++){	

			   $NodeXYZCoordArray[$NXYZCACnt] = $readBdfFileReturnArray[$i];
			   $NXYZCACnt++;
			}

			# Locally rebuilding @MPCNodeIDArray
			
			my $SizeMPCNXYZCA = $readBdfFileReturnArray[1];
			my $MPCNXYZCACnt = 0;
	
			for(my $i = (4 + $SizeNXYZCA); $i < (4 + $SizeNXYZCA + $SizeMPCNXYZCA); $i++){ 

			   $MPCNodeXYZCoordArray[$MPCNXYZCACnt] = $readBdfFileReturnArray[$i];
			   $MPCNXYZCACnt++;
			}

			# Locally rebuilding @FreebodyNodeIDArray

			my $SizeFBNXYZCA = $readBdfFileReturnArray[2];
			my $FBNXYZCACnt = 0;
	
			for(my $i = (4 + $SizeNXYZCA + $SizeMPCNXYZCA); $i < (4 + $SizeNXYZCA + $SizeMPCNXYZCA + $SizeFBNXYZCA); $i++){ # starting from $i = $SizeNIA, because 

			   $FreebodyNodeXYZCoordArray[$FBNXYZCACnt] = $readBdfFileReturnArray[$i];
			   $FBNXYZCACnt++;
			}
			# Locally rebuilding @DispNodeXYZCoordArray

			my $SizeDNXYZCA = $readBdfFileReturnArray[3];
			my $DNXYZCACnt = 0;
	
			for(my $i = (4 + $SizeNXYZCA + $SizeMPCNXYZCA + $SizeFBNXYZCA); $i < (4 + $SizeNXYZCA + $SizeMPCNXYZCA + $SizeFBNXYZCA + $SizeDNXYZCA); $i++){ # starting from $i = $SizeNIA, because 

			   $DispNodeXYZCoordArray[$DNXYZCACnt] = $readBdfFileReturnArray[$i];
			   $DNXYZCACnt++;
			}

			#print "SizeNXYZCA $SizeNXYZCA\n";

			#foreach(@NodeXYZCoordArray){
			   
			   #print "NodeXYZCoordArray: $_\n";
			#}

			#print "SizeMPCNXYZCA $SizeMPCNXYZCA\n";

			#foreach(@MPCNodeXYZCoordArray){
			   
			   #print "MPCNodeXYZCoordArray: $_\n";
			#}

			#print "SizeFBNXYZCA $SizeFBNXYZCA\n";

			#foreach(@FreebodyNodeXYZCoordArray){
			   
			   #print "FreebodyNodeXYZCoordArray: $_\n";
			#}

			#print "SizeDNXYZCA $SizeDNXYZCA\n";

			#foreach(@DispNodeXYZCoordArray){
			   
			   #print "DispNodeXYZCoordArray: $_\n";
			#}

			$SizeRBFRA = @readBdfFileReturnArray;
			
			$MainText->insert("end", "\nStarted checking the coordinates...\n");
			$mw->update;
			
			&checkCoordDefinition;		

			$MainText->insert("end", "\nFinished reading the bdf file!\n");
			$mw->update;		
		}
				 
		$btn_selectbdf -> configure(-state => 'normal');
		$btn_readbdf -> configure(-state => 'normal');		
		$btn_selectf06 -> configure(-state => 'normal');
		$btnGamahCoupling -> configure(-state => 'normal');
		$btnInterface -> configure(-state => 'normal');
		$BUTTON_EXIT -> configure(-state => 'normal');
                $btnFasteners -> configure(-state => 'normal');
		$mw->update;		
				 
	}) -> place(-relx=> 0.53, -rely => 0.35);

$mw -> Label(	-text => "5. Select Single or Multiple f06 File(s) Path/Filename "
		#-font => 'Courier -12' 
					) -> place(-relx => 0.52, -rely => 0.40); 

$btn_selectf06 = $mw -> Button( -text =>"Select single or multiple f06 file(s)",
			        -font => 'Helvetica -15 bold', 
			        -state => 'normal', 
			        -height => 1, 
			        -width => 35, 
			        -command => \&select_f06) -> place(-relx=> 0.53, -rely => 0.43);

# **********  BUTTON_START ******************  
# BUTTON_START is the botton[Start Initial Sort] that starts the intial sorting when clicked 

$mw -> Label(	-text => "6. Start extracting interface, fastener (CBEAM, CBAR, CBUSH, CROD) or freebody loads:"
		#-font => 'Courier -12'
				) -> place(-relx => 0.52, -rely => 0.48);


$btnInterface = $mw -> Button( -text =>"Extract Interface, MPC or Freebody Loads",
                               -font=> 'Helvetica -15 bold', 
			       -state => 'normal', 
			       -height => 1, 
			       -width => 35, -command => sub{ 

	$MainText -> delete("1.0", "end"); # The main text window information is deleted when the program starts extracting

	$btnInterface -> configure(-state => 'disable');
	$BUTTON_EXIT  -> configure(-state => 'disable');
	$btn_selectbdf -> configure(-state => 'disable');
	$btn_readbdf -> configure(-state => 'disable');		
	$btn_selectf06 -> configure(-state => 'disable');
	$btnGamahCoupling -> configure(-state => 'disable');
        $btnFasteners -> configure(-state => 'disable');
	$mw -> update;

	my $Sizef06FA = @f06FileArray;
	my $SizeEIA = @ElmIDArray;
	my $SizeNIA = @NodeIDArray;		# To pass the size of @NodeIDArray to subroutines
	my $SizeFBNIA = @FreebodyNodeIDArray;	# To pass the size of @FreebodyNodeIDArray to subroutines
	my $SizeMPCNIA = @MPCNodeIDArray;	# To pass the size of @MPCNodeIDArray to subroutines
	my $SizeIIA = @InterfaceInfoArray;	# To pass the size of @InterfaceInfoArray to subroutines
	my $SizeMPCIA = @MPCInfoArray;		# To pass the size of @MPCInfoArray to subroutines
	
	if($SizeNIA == 0 && $SizeFBNIA == 0 && $SizeMPCNIA == 0){
	
		$MainText-> delete("1.0", "end");
		$MainText->insert("end", "\nPlease enter node ids first!\n\n");
		$mw->update;
			
	}elsif($SizeRBFRA == 0){

		$MainText-> delete("1.0", "end");
		$MainText->insert("end", "\nPlease load and read a bdf file!\n\n");
		$mw->update;

	}elsif($Sizef06FA == 0){

		$MainText-> delete("1.0", "end");
		$MainText->insert("end", "\nPlease load an f06 file!\n\n");
		$mw->update;

	}else{
		$MainText-> delete("1.0", "end");
		
		$l_time = localtime;	$gm_time = gmtime;
		
		$MainText->insert("end", "\nStarted extracting at LOCAL TIME:$l_time	GMT:$gm_time\n\n");
		print "\nStarted extracting at LOCAL TIME:$l_time	GMT:$gm_time\n";
		$mw->update;
		

		# If they exist delete files from a previous extraction
		
		&deleteFiles();
		
		# Start Initial extraction
		
		&gpfbInitialSort($SizeNIA, $SizeMPCNIA, $SizeFBNIA, @NodeIDArray, @MPCNodeIDArray, @FreebodyNodeIDArray);
		
		if($SizeNIA > 0){
		
			my $SizeIIA = @InterfaceInfoArray;
			my $SizeNXYZCA = @NodeXYZCoordArray;

			&extractInterfaceLoads($SizeIIA, $SizeNXYZCA, @InterfaceInfoArray, @NodeXYZCoordArray);
		}		
	
		if($SizeMPCNIA > 0){

			my $SizeMPCIA = @MPCInfoArray;
			my $SizeMPCNXYZCA = @MPCNodeXYZCoordArray;		
		
			&extractMPCLoads($SizeMPCIA, $SizeMPCNXYZCA, @MPCInfoArray, @MPCNodeXYZCoordArray);
		}
				
		if($SizeFBNIA > 0){	

			my $SizeFNXYZCA = @FreebodyNodeXYZCoordArray;
		
			# Start extracting freebody loads. Following subroutine reads .freebodydat file and creates number of
			# extracted data.
		
			&extractFreebodyLoads($SizeFNXYZCA, @FreebodyNodeXYZCoordArray);
		
			# Start reading .freebodytemp data file and sort the data based on the first column which is node id
			# then create .freebodytemp2 file for the maximum and minimum load cases, temporary files will be deleted.
		
			&sortNodeIds();

			# Start reading .freebodytemp2 data file and sort the data based on the Fx, Fy, Fz, Mx, My, Mz columns
			# then create .freebodymaxmins file for the maximum and minimum load cases, temporary files will be deleted.
		
			&extractMaxMins();
		}		
		
		$l_time = localtime;	$gm_time = gmtime;

		print "\nFinished extracting at LOCAL TIME:$l_time	GMT:$gm_time\n";
	
		$MainText->insert("end", "\nFinished extracting at LOCAL TIME:$l_time	GMT:$gm_time\n");
		$mw->update;
	}

	$btnInterface -> configure(-state => 'normal');
	$BUTTON_EXIT  -> configure(-state => 'normal');
	$btn_selectbdf -> configure(-state => 'normal');
	$btn_readbdf -> configure(-state => 'normal');		
	$btn_selectf06 -> configure(-state => 'normal');
	$btnGamahCoupling -> configure(-state => 'normal');
        $btnFasteners -> configure(-state => 'normal');
	$mw->update;	
		
}) ->place(-relx=> 0.53, -rely => 0.51);

$btnGamahCoupling = $mw -> Button( -text =>"Extract Gamah Coupling Displacements",
			        -font => 'Helvetica -15 bold', 
			        -state => 'normal', 
			        -height => 1, 
			        -width => 35, 
			        -command => sub{ 

	$MainText -> delete("1.0", "end"); # The main text window information is deleted when the program starts extracting

	$btnInterface -> configure(-state => 'disable');
	$BUTTON_EXIT  -> configure(-state => 'disable');
	$btn_selectbdf -> configure(-state => 'disable');
	$btn_readbdf -> configure(-state => 'disable');		
	$btn_selectf06 -> configure(-state => 'disable');
	$btnGamahCoupling -> configure(-state => 'disable');
        $btnFasteners -> configure(-state => 'disable');
	$mw -> update;

	my $Sizef06FA = @f06FileArray;
	my $SizeEIA = @ElmIDArray;
	my $SizeNIA = @NodeIDArray;		# Will be also used to pass the size of @NodeIDArray to subroutines
	my $SizeFBNIA = @FreebodyNodeIDArray;	# Will be also used to pass the size of @FreebodyNodeIDArray to subroutines
	
	if($SizeNIA == 0 && $SizeFBNIA == 0){
	
		$MainText-> delete("1.0", "end");
		$MainText->insert("end", "\nPlease enter node ids for the freebodys first!\n\n");
		$mw->update;
			
	}elsif($SizeNIA > 0 && $SizeFBNIA == 0){

		$MainText-> delete("1.0", "end");
		$MainText->insert("end", "\nPlease use \"Extract interface loads\" button for the interface loads!\n\n");
		$mw->update;

	}elsif($SizeRBFRA == 0){

		$MainText-> delete("1.0", "end");
		$MainText->insert("end", "\nPlease load and read a bdf file!\n\n");
		$mw->update;

	}elsif($Sizef06FA == 0){

		$MainText-> delete("1.0", "end");
		$MainText->insert("end", "\nPlease load an f06 file!\n\n");
		$mw->update;

	}else{

		$MainText-> delete("1.0", "end");
		
		$l_time = localtime;	$gm_time = gmtime;
		
		$MainText->insert("end", "\nStarted extracting freebody loads at LOCAL TIME:$l_time	GMT:$gm_time\n\n");
		print "\nStarted extracting at LOCAL TIME:$l_time	GMT:$gm_time\n";
		$mw->update;
	
		
		$l_time = localtime;	$gm_time = gmtime;

		print "\nFinished extracting at LOCAL TIME:$l_time	GMT:$gm_time\n";
	
		$MainText->insert("end", "\nFinished extracting freebody loads at LOCAL TIME:$l_time	GMT:$gm_time\n");
		$mw->update;
	
	}

	$btnInterface -> configure(-state => 'normal');
	$BUTTON_EXIT  -> configure(-state => 'normal');
	$btn_selectbdf -> configure(-state => 'normal');
	$btn_readbdf -> configure(-state => 'normal');		
	$btn_selectf06 -> configure(-state => 'normal');
	$btnGamahCoupling -> configure(-state => 'normal');
        $btnFasteners -> configure(-state => 'normal');
	$mw->update;	
		
}) -> place(-relx=> 0.53, -rely => 0.56);

$btnFasteners = $mw -> Button( -text =>"Extract Fastener Loads",
			        -font => 'Helvetica -15 bold', 
			        -state => 'normal', 
			        -height => 1, 
			        -width => 35, 
			        -command => sub{ 

	$MainText -> delete("1.0", "end"); # The main text window information is deleted when the program starts extracting

	$btnInterface -> configure(-state => 'disable');
	$BUTTON_EXIT  -> configure(-state => 'disable');
	$btn_selectbdf -> configure(-state => 'disable');
	$btn_readbdf -> configure(-state => 'disable');		
	$btn_selectf06 -> configure(-state => 'disable');
	$btnGamahCoupling -> configure(-state => 'disable');
	$mw -> update;

	my $Sizef06FA = @f06FileArray;
	my $SizeEIA = @ElmIDArray;	# Will be also used to pass the size of @NodeIDArray to subroutines
	
	if($SizeEIA == 0){
	
		$MainText-> delete("1.0", "end");
		$MainText->insert("end", "\nPlease enter element ids first!\n\n");
		$mw->update;
			
	}elsif($SizeEIA > 0 && ($EntryNumberMaxMinTxtVar =~ /^$/)){

		$MainText-> delete("1.0", "end");
		$MainText->insert("end", "\nPlease enter number of Max/Mins!\n\n");
		$mw->update;

	}elsif($SizeEIA > 0 && ($EntryNumberMaxMinTxtVar =~ /\D/ || $EntryNumberMaxMinTxtVar =~ /^-\d/ || $EntryNumberMaxMinTxtVar =~ /[\W_]/)){

		$MainText-> delete("1.0", "end");
		$MainText->insert("end", "\nPlease enter number positive integer value in the Max/Mins entry box!\n\n");
		$mw->update;

	}elsif($SizeRBFRA == 0){

		$MainText-> delete("1.0", "end");
		$MainText->insert("end", "\nPlease load and read a bdf file!\n\n");
		$mw->update;

	}elsif($Sizef06FA == 0){

		$MainText-> delete("1.0", "end");
		$MainText->insert("end", "\nPlease load an f06 file!\n\n");
		$mw->update;

	}else{

		$MainText-> delete("1.0", "end");
		
		$l_time = localtime;	$gm_time = gmtime;
		
		$MainText->insert("end", "\nStarted extracting fastener loads at LOCAL TIME:$l_time	GMT:$gm_time\n\n");
		print "\nStarted extracting at LOCAL TIME:$l_time	GMT:$gm_time\n";
		$mw->update;
		
		&InitialSort($SizeEIA, @ElmIDArray);	
	}

	$btnInterface -> configure(-state => 'normal');
	$BUTTON_EXIT  -> configure(-state => 'normal');
	$btn_selectbdf -> configure(-state => 'normal');
	$btn_readbdf -> configure(-state => 'normal');		
	$btn_selectf06 -> configure(-state => 'normal');
	$btnGamahCoupling -> configure(-state => 'normal');
	$mw->update;	
		
}) -> place(-relx=> 0.77, -rely => 0.51);


# **********  BUTTON_EXIT ******************  
# BUTTON_EXIT is the botton[Start Initial Sort] that starts the intial sorting when clicked 

$BUTTON_EXIT = $mw->Button(-text =>"Exit",
			   -font=> 'Helvetica -15 bold', 
			   -state => 'normal', -height => 1, 
			   -width => 35, -command => sub{ exit;}) ->place(-relx=> 0.77, -rely => 0.56);
			  

$mw->configure(-menu => my $menubar = $mw->Menu);
# Create the menubar's menubuttons.

map {$menubar->cascade( -label => '~' . $_->[0], -menuitems => $_->[1] )}
     ['File', file_menuitems],
     ['Help', help_menuitems];

#my $file = $menubar->cascade(
#    -label => '~File',   -menuitems => file_menuitems);
#
#my $edit = $menubar->cascade(
#    -label => '~Edit',   -menuitems => edit_menuitems); 
#
#my $help = $menubar->cascade(
#    -label => '~Help',   -menuitems => help_menuitems);

if ($^O eq 'MSWin32') {
    my $syst = $menubar->cascade(-label => '~System');
    my $dir = 'dir | sort | more';
    $syst->command(
        -label   => $dir,
        -command => sub {system $dir},
    );
}

my $file_menu = $menubar->entrycget('File', -menu);
#print "File=$file_menu\n";

# ***************************  IMPORTANT ********************************************

$MainText -> menu (undef);	# Default menu on the MainText is canceled
$MainText -> menu ($menubar);	# New menu on the MainText is $menubar

# ***********************************************************************************

$mw->focus;

&BindMouseWheel($MainText);


MainLoop;

#********************************************************************************************************************************************
# MAINLOOP END ******************************************************************************************************************************
#********************************************************************************************************************************************

#********************************************************************************************************************************************
# SUB FUNCTIONS THAT ARE CALLED FROM THE MENUBAR ********************************************************************************************
#********************************************************************************************************************************************

# Menu Subs Start ---------------------------------------------------------------------------------------------------------------------------

sub file_menuitems {

    # Create the menu items for the File menu.
    [
      [qw/command/, 'Select bdf Files', 	qw/ -accelerator Ctrl-l -command/ => \&select_bdf],
      [qw/command/, 'Select f06 Files', 	qw/ -accelerator Ctrl-m -command/ => \&select_f06],
      [qw/command/, 'Remove bdf Files', 	qw/ -accelerator Ctrl-u -command/ => \&remove_bdf],
      [qw/command/, 'Remove f06 Files', 	qw/ -accelerator Ctrl-v -command/ => \&remove_f06],
      [qw/command ~Quit 			    -accelerator Ctrl-q -command/ => \&exit_program],
    ];

} # end file_menuitems

sub help_menuitems {
    [
      ['command', 'Version', -command => sub {
	my $db = $mw -> DialogBox(-title => 'Version',
	    			-buttons => ['Ok'],
	    			-default_button => 'Ok');

	$db -> add('Label', -text => 'Interface 2.1 Pre-release')->pack();
	$db -> add('Label', -text => 'Release Date: 05 November 2009')->pack();
	my $ans = $db -> Show();
	     if($ans eq 'Ok') {
	     }    
      }],
      '',
      ['command', 'About',   -command => sub {
	my $db = $mw -> DialogBox(-title => 'About',
	    			-buttons => ['Ok'],
	    			-default_button => 'Ok');
	if ($^O eq 'MSWin32') {
		#my $icon = $db -> Photo(-file=>'images/icon.bmp');
		#my $c1 = $db -> Canvas(-background => 'white',
		#		  qw/-width 300 -height 150/,
		#	);
		#$c1-> pack(-side => 'left');
		#$c1 -> createImage(150, 75, -image => $icon);
	}
	
	$db -> add('Label', -text => 'Licence: GNU General Public Licence (http://www.gnu.org/licenses/licenses.html)')->pack();
	$db -> add('Label', -text => 'Support Free Software: (http://www.gnu.org/)')->pack();
	$db -> add('Label', -text => 'Programmed by: Ozgur M Polat, email: ozgurpolat@msn.com') ->pack();
	$db -> add('Label', -text => '', -font => 'Helvetica 10')->pack();
	$db -> add('Label', -text => 'This program is free software: you can redistribute it and/or modify', -font => 'Helvetica 10')->pack();
	$db -> add('Label', -text => 'it under the terms of the GNU General Public License as published by', -font => 'Helvetica 10')->pack();
	$db -> add('Label', -text => 'the Free Software Foundation, either version 3 of the License, or', -font => 'Helvetica 10')->pack();
	$db -> add('Label', -text => '(at your option) any later version.', -font => 'Helvetica 10')->pack();
	$db -> add('Label', -text => '', -font => 'Helvetica 10')->pack();
	$db -> add('Label', -text => 'This program is distributed in the hope that it will be useful,', -font => 'Helvetica 10')->pack();
	$db -> add('Label', -text => 'but WITHOUT ANY WARRANTY; without even the implied warranty of', -font => 'Helvetica 10')->pack();
	$db -> add('Label', -text => 'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the', -font => 'Helvetica 10')->pack();
	$db -> add('Label', -text => 'GNU General Public License for more details.', -font => 'Helvetica 10')->pack();
	$db -> add('Label', -text => '', -font => 'Helvetica 10')->pack();
	$db -> add('Label', -text => 'You should have received a copy of the GNU General Public License', -font => 'Helvetica 10')->pack();
	$db -> add('Label', -text => 'along with this program.  If not, see <http://www.gnu.org/licenses/>.', -font => 'Helvetica 10')->pack();
	$db -> add('Label', -text => '', -font => 'Helvetica 10')->pack();
	
	my $ans = $db -> Show();
	     if($ans eq 'Ok') {
	     }
	}
      ],
       '',
      [qw/command 	~Help			 	-accelerator F1 	-command/ => \&html_help],
      [qw/command/, 	'H~tml Help',		qw/  	-accelerator F10 	-command/ => \&html_help],      
    ];
}

# Menu subs end __________________________________________________________________________________________________________


# Sub select_f06 start -----------------------------------------------------------------------------------------------------

sub select_f06 {

	#use Cwd;				# *** VERY IMPORTANT ***
	$CurrentDir = cwd;			# Cwd gets the current working directory,
						# which is where interface.pl is runing
						# Because later on we will use "chdir" 
						# function to select files, we need to return to
						# our original working directory.
						# later we will do this: chdir($CurrentDir);

	#print("$CurrentDir\n");
		
	&call_dialog_f06;
	
	if ($^O eq 'MSWin32') {
		
		#$Drtree->delete('all');
		
		#use Win32API::File;
		
		#my @drv = Win32API::File::getLogicalDrives();
		
		#for (my $i=1; $i<=$#drv; $i++){
		#	$Drtree->add_to_tree($drv[$i], $drv[$i]);
		#}
	}

  	# Call &f06_files:
	
	$Drtree -> bind('<Button-1>'=> \&f06_files);
	
	&call_select_f06;
	
}
# Sub select_f06 file end ________________________________________________________________________________________________

# Sub select_bdf start -----------------------------------------------------------------------------------------------------

sub select_bdf {

	#use Cwd;				# *** VERY IMPORTANT ***
	$CurrentDir = cwd;			# Cwd gets the current working directory,
						# which is where interface.pl is runing
						# Because later on we will use "chdir" 
						# function to select files, we need to return to
						# our original working directory.
						# later we will do this: chdir($CurrentDir);

	#print("select_bdf: $CurrentDir\n");
		
	&call_dialog_bdf;
	
	if ($^O eq 'MSWin32') {
		
		#$Drtree->delete('all');
		
		#use Win32API::File;
		
		#my @drv = Win32API::File::getLogicalDrives();
		
		#for (my $i=1; $i<=$#drv; $i++){
		#	$Drtree->add_to_tree($drv[$i], $drv[$i]);
		#}
	}

  	# Call &bdf_files
	
	$Drtree -> bind('<Button-1>'=> \&bdf_files);
	
	&call_select_bdf;
	
}
# Sub select_bdf file end ________________________________________________________________________________________________

# Sub select_txt start -----------------------------------------------------------------------------------------------------

sub select_txt {

	#use Cwd;				# *** VERY IMPORTANT ***
	$CurrentDir = cwd;			# Cwd gets the current working directory,
						# which is where interface.pl is runing
						# Because later on we will use "chdir" 
						# function to select files, we need to return to
						# our original working directory.
						# later we will do this: chdir($CurrentDir);

	#print("select_txt: $CurrentDir\n");
		
	&call_dialog_txt;
	
	if ($^O eq 'MSWin32') {
		
		#$Drtree->delete('all');
		
		#use Win32API::File;
		
		#my @drv = Win32API::File::getLogicalDrives();
		
		#for (my $i=1; $i<=$#drv; $i++){
		#	$Drtree->add_to_tree($drv[$i], $drv[$i]);
		#}
	}

  	# Call &txt_files
	
	$Drtree -> bind('<Button-1>'=> \&txt_files);
	
	&call_select_txt;
	
}
# Sub select_txt file end ________________________________________________________________________________________________

sub call_dialog_f06 {

	(@popup_opts) = (-popover => undef, qw/-overanchor nw -popanchor nw/);
	
	$db_f06 = $mw -> Dialog(@popup_opts , -title => 'Select f06 files to read',
						    -anchor => 'nw',
						    -buttons => ['Ok', 'Cencel'],
						    -default_button => 'Ok',);


	$height = $mw -> screenheight;
	$width = $mw -> screenwidth;
	
	my $minheight = ($height*(55/100));	# Start of setting the window size
	my $minwidth = ($width*(51/100));
	
	$db_f06 -> minsize($minwidth,$minheight);
	$db_f06 -> maxsize($minwidth,$minheight);
	$db_f06 -> geometry('-100-100');			# End of setting the window size

	$labelf06_1 = $db_f06 -> Label (-text => 'Select a directory') -> place(-relx => 0.04, -rely => 0.00);

	$Drtree = $db_f06 -> Scrolled("DirTree",
					-directory => "$CurrentDir",
					-showhidden => 1,				
					-scrollbars => "se", 
					-height=> 12, 
					-width => 80,
					-highlightthickness => 0,
					-selectbackground => '#1E90FF', 
					-selectforeground => 'white',
					-background 	  => '#FFFFFF',
					-relief 	  => 'groove',
				   ) -> place(-relx => 0.04, -rely => 0.06);		   

	$labelf06_2 = $db_f06 -> Label (-text => 'Select f06 Result Files') -> place(-relx => 0.04, -rely => 0.52);

	$Listbox_select_f06 = $db_f06 -> Scrolled("Listbox", 
						-scrollbars => "se", 
						-relief => 'groove', 
						-selectmode => "extended",
						-height => 8, -width => 80)->place(-relx => 0.04, -rely => 0.58);

}


sub call_dialog_bdf {

	(@popup_opts) = (-popover => undef, qw/-overanchor nw -popanchor nw/);
	
	$db_bdf = $mw -> Dialog(@popup_opts ,   -title => 'Select bdf files to read',
						-anchor => 'nw',
						-buttons => ['Ok', 'Cencel'],
						-default_button => 'Ok',);						

	$height = $mw -> screenheight;
	$width = $mw -> screenwidth;
	
	my $minheight = ($height*(55/100));	# Start of setting the window size
	my $minwidth = ($width*(51/100));
	
	$db_bdf -> minsize($minwidth,$minheight);
	$db_bdf -> maxsize($minwidth,$minheight);
	$db_bdf -> geometry('-100-100');			# End of setting the window size

	$labelbdf_1 = $db_bdf -> Label (-text => 'Select a directory') -> place(-relx => 0.04, -rely => 0.00);

	$Drtree = $db_bdf -> Scrolled("DirTree",
					-directory => "$CurrentDir",
					-showhidden => 1,				
					-scrollbars => "se", 
					-height=> 12, 
					-width => 80,
					-highlightthickness => 0,
					-selectbackground => '#1E90FF', 
					-selectforeground => 'white',
					-background 	  => '#FFFFFF',
					-relief 	  => 'groove',
				   ) -> place(-relx => 0.04, -rely => 0.06);		   

	$labelbdf_2 = $db_bdf -> Label (-text => 'Select bdf Files') -> place(-relx => 0.04, -rely => 0.52);

	$Listbox_select_bdf = $db_bdf -> Scrolled("Listbox", 
						-scrollbars => "se", 
						-relief => 'groove', 
						-selectmode => "extended",
						-height => 8, -width => 80)->place(-relx => 0.04, -rely => 0.58);
}

sub call_dialog_txt {

	(@popup_opts) = (-popover => undef, qw/-overanchor nw -popanchor nw/);
	
	$db_txt = $mw -> Dialog(@popup_opts ,   -title => 'Select txt files to read',
						-anchor => 'nw',
						-buttons => ['Ok', 'Cencel'],
						-default_button => 'Ok',);						

	$height = $mw -> screenheight;
	$width = $mw -> screenwidth;
	
	my $minheight = ($height*(55/100));	# Start of setting the window size
	my $minwidth = ($width*(51/100));
	
	$db_txt -> minsize($minwidth,$minheight);
	$db_txt -> maxsize($minwidth,$minheight);
	$db_txt -> geometry('-100-100');			# End of setting the window size

	$labeltxt_1 = $db_txt -> Label (-text => 'Select a directory') -> place(-relx => 0.04, -rely => 0.00);

	$Drtree = $db_txt -> Scrolled("DirTree",
					-directory => "$CurrentDir",
					-showhidden => 1,				
					-scrollbars => "se", 
					-height=> 12, 
					-width => 80,
					-highlightthickness => 0,
					-selectbackground => '#1E90FF', 
					-selectforeground => 'white',
					-background 	  => '#FFFFFF',
					-relief 	  => 'groove',
				   ) -> place(-relx => 0.04, -rely => 0.06);		   

	$labeltxt_2 = $db_txt -> Label (-text => 'Select txt Files') -> place(-relx => 0.04, -rely => 0.52);

	$Listbox_select_txt = $db_txt -> Scrolled("Listbox", 
						-scrollbars => "se", 
						-relief => 'groove', 
						-selectmode => "extended",
						-height => 8, -width => 80)->place(-relx => 0.04, -rely => 0.58);
}

sub call_select_f06 {

	$yesno_f06 = $db_f06 -> Show();

	if($yesno_f06 eq 'Ok') {
		
		my @SFArray = $Listbox_select_f06 -> curselection;
		
		my $SizeSFA = @SFArray;
		
		if($SizeSFA > 0) {
			
			#$FileDir = $Drtree -> selectionGet; #Note: This statement does't work with the latest edition of Perl changed to following code:
			
			my @FileDirArray = $Drtree -> selectionGet;
			$FileDir = $FileDirArray[0];
			
			if($FileDir =~ m/(.+?)\\(.*)/){
				$FileDir = "$1$2";
			}
			
			# ***** Calling sub function to create Results Folder *********
			
			#&createDataFolder($FileDir);
			
			# **************************************************************
			
			my @SFA_Tmp = ();
			my $FA_counter = 0;
			
			foreach(@SFArray){
				
				my $i = $_;
				$SFA_Tmp[$FA_counter] = "$FileDir/$f06files[$_]";
				$FA_counter++;
			}

			#foreach(@SFA_Tmp){print("FATemp: $_\n");}

			#foreach(@f06FileArray){print("FArr: $_\n");}

			my @Location_Array = ();
			my $LA_Counter = 0;
			
			for(my $i = 0; $i <= $#SFA_Tmp; $i++){
			
				for(my $j = 0; $j <= $#f06FileArray; $j++){

					if($SFA_Tmp[$i] eq $f06FileArray[$j]){
					
						$Location_Array[$LA_Counter] = $i;
						$LA_Counter++;
					}
				}	
			}
			
			my $minus = 0;

			my $Files_Already_Selected = 0;
			my @Report_Array = ();
			my $RA_Counter = 0;
			
			foreach(@Location_Array){
				$Report_Array[$RA_Counter] = $SFA_Tmp[$_];
				$RA_Counter++;
			}
						
			foreach(@Location_Array){

			    my $j = $_;

			    $j = $j - $minus;
			    $minus++;
			    splice(@SFA_Tmp,$j,1);
			    $LA_Counter = $LA_Counter - 1;

			}
				
			my $SizeLA = @Location_Array;
			
			#print("SizeLA: $SizeLA\n");
			
			if($SizeLA == 0){
				
				foreach(@SFA_Tmp){

					$f06FileArray[$f06FileArray_i] = "$_";
					$f06FileArray_i++;
				}
			
			}elsif($SizeLA > 0){
			
				for(my $i = 0; $i <= $#SFA_Tmp; $i++){
					#print("FA:$SFA_Tmp[$i]\n");
					$f06FileArray[$f06FileArray_i] = $SFA_Tmp[$i];
					$f06FileArray_i++;						
				}
			
				$Files_Already_Selected = 1;
			}
			
			#print("Location_Array: @Location_Array\n");
			
			$MainText -> delete("1.0", "end");
			$MainText->insert("end", "\n");
			
			for (my $j = 0; $j <= $#f06FileArray; $j++) { 
				$MainText -> insert("end", "File $f06FileArray[$j] selected\n");
			}
			
			if($Files_Already_Selected == 1){
				
				#print("Report_Array: @Report_Array\n");

				my $ans_already_selected;

				my(@popup_opts) = (-popover => undef, qw/-overanchor n -popanchor n/);
				
				my $db = $mw -> Dialog(@popup_opts , -title => 'Select files',
								     -anchor => 'nw',
								     -buttons => ['Ok', 'Cencel'],
								     -default_button => 'Ok',);


				my $height;$height = $mw -> screenheight;
				my $width; $width = $mw -> screenwidth;
				my $minheight = ($height*(35/100));	# Start of setting the window size
				my $minwidth = ($width*(55/100));
				$db -> minsize($minwidth,$minheight);
				$db -> maxsize($minwidth,$minheight);
				$db -> geometry('-100-100');			# End of setting the window size

				my $label_1 = $db -> Label (-text => 'Following files are already selected!') -> place(-relx => 0.04, -rely => 0.00);

				my $Listbox_Already_Selected_Files = $db -> Scrolled("Listbox", 
										-scrollbars => "se", 
										-relief => 'groove', 
										-selectmode => "extended",
										-height => 10, -width => 80)->place(-relx => 0.04, -rely => 0.08);

				
				$Listbox_Already_Selected_Files -> insert('end', @Report_Array);
				
				$ans_already_selected = $db -> Show();

				if($ans_already_selected eq 'Ok') {
				
				}
			}
		}else{
			my $ans_to_please_select = $mw -> messageBox(-title => 'Please select f06 files!',
					    -message => 'You have not selected any f06 files for sorting!',
					    -type => 'Ok', -icon => 'error');
			if($ans_to_please_select   eq 'ok') {
			}
		
		}
		
			#chdir ("$CurrentDir"); 	# *** VERY IMPORTANT ***
			#				# We do not need to return to our original working directory.
			#				# Previously If we did not do this program could not find the							
			#				# other executable files.
	}


}

sub call_select_bdf {

	$yesno_bdf = $db_bdf -> Show();

	if($yesno_bdf eq 'Ok') {
		
		my @SFArray = $Listbox_select_bdf -> curselection;
		
		my $SizeSFA = @SFArray;
		
		if($SizeSFA > 0) {
			
			#$FileDir = $Drtree -> selectionGet; #Note: This statement does't work with the latest edition of Perl changed to following code:
	
			my @FileDirArray = $Drtree -> selectionGet;
			$FileDir = $FileDirArray[0];
			
			
			if($FileDir =~ m/(.+?)\\(.*)/){
				$FileDir = "$1$2";
			}
			
		
			my @SFA_Tmp = ();
			my $FA_counter = 0;
			
			foreach(@SFArray){
				
				my $i = $_;
				$SFA_Tmp[$FA_counter] = "$FileDir/$bdffiles[$_]";
				$FA_counter++;
			}

			#foreach(@SFA_Tmp){print("FATemp: $_\n");}

			#foreach(@bdfFileArray){print("FArr: $_\n");}

			my @Location_Array = ();
			my $LA_Counter = 0;
			
			for(my $i = 0; $i <= $#SFA_Tmp; $i++){
			
				for(my $j = 0; $j <= $#bdfFileArray; $j++){

					if($SFA_Tmp[$i] eq $bdfFileArray[$j]){
					
						$Location_Array[$LA_Counter] = $i;
						$LA_Counter++;
					}
				}	
			}
			
			my $minus = 0;

			my $Files_Already_Selected = 0;
			my @Report_Array = ();
			my $RA_Counter = 0;
			
			foreach(@Location_Array){
				$Report_Array[$RA_Counter] = $SFA_Tmp[$_];
				$RA_Counter++;
			}
						
			foreach(@Location_Array){

			    my $j = $_;

			    $j = $j - $minus;
			    $minus++;
			    splice(@SFA_Tmp,$j,1);
			    $LA_Counter = $LA_Counter - 1;

			}
				
			my $SizeLA = @Location_Array;
			
			#print("SizeLA: $SizeLA\n");
			
			if($SizeLA == 0){
				
				foreach(@SFA_Tmp){

					$bdfFileArray[$bdfFileArray_i] = "$_";
					$bdfFileArray_i++;
				}
			
			}elsif($SizeLA > 0){
			
				for(my $i = 0; $i <= $#SFA_Tmp; $i++){
					#print("FA:$SFA_Tmp[$i]\n");
					$bdfFileArray[$bdfFileArray_i] = $SFA_Tmp[$i];
					$bdfFileArray_i++;						
				}
			
				$Files_Already_Selected = 1;
			}
			
			#print("Location_Array: @Location_Array\n");
			
			$MainText->delete("1.0", "end");
			$MainText->insert("end", "\n");
			
			for (my $j = 0; $j <= $#bdfFileArray; $j++) { 
				$MainText->insert("end", "File $bdfFileArray[$j] selected\n");
			}
			
			if($Files_Already_Selected == 1){
				
				#print("Report_Array: @Report_Array\n");

				my $ans_already_selected;

				my(@popup_opts) = (-popover => undef, qw/-overanchor n -popanchor n/);
				my $db = $mw->Dialog(@popup_opts , -title => 'Select files',
									    -anchor => 'nw',
									    -buttons => ['Ok', 'Cencel'],
									    -default_button => 'Ok',
						    );


				my $height;$height = $mw->screenheight;
				my $width; $width = $mw->screenwidth;
				my $minheight = ($height*(35/100));	# Start of setting the window size
				my $minwidth = ($width*(55/100));
				$db->minsize($minwidth,$minheight);
				$db->maxsize($minwidth,$minheight);
				$db->geometry('-100-100');			# End of setting the window size

				my $label_1 = $db -> Label (-text => 'Following files are already selected!') -> place(-relx => 0.04, -rely => 0.00);

				my $Listbox_Already_Selected_Files = $db -> Scrolled("Listbox", 
										-scrollbars => "se", 
										-relief => 'groove', 
										-selectmode => "extended",
										-height => 10, -width => 80) -> place(-relx => 0.04, -rely => 0.08);

				
				$Listbox_Already_Selected_Files -> insert('end', @Report_Array);
				
				$ans_already_selected = $db -> Show();

				if($ans_already_selected eq 'Ok') {
				
				}
			}
		}else{
			my $ans_to_please_select = $mw -> messageBox(-title => 'Please select bdf files!',
					    -message => 'You have not selected any bdf files for reading!',
					    -type => 'Ok', -icon => 'error');
			if($ans_to_please_select   eq 'ok') {
			}
		
		}
		
			#chdir ("$CurrentDir"); 	# *** VERY IMPORTANT ***
			#				# We do not need to return to our original working directory.
			#				# Previously If we did not do this program could not find the							
			#				# other executable files.
	}


}

sub call_select_txt {

	$yesno_txt = $db_txt -> Show();

	if($yesno_txt eq 'Ok') {
		
		my @SFArray = $Listbox_select_txt -> curselection;
		
		my $SizeSFA = @SFArray;
		
		if($SizeSFA > 0) {
			
			#$FileDir = $Drtree -> selectionGet; #Note: This statement does't work with the latest edition of Perl changed to following code:
	
			my @FileDirArray = $Drtree -> selectionGet;
			$FileDir = $FileDirArray[0];

			
			if($FileDir =~ m/(.+?)\\(.*)/){
				$FileDir = "$1$2";
			}
			
		
			my @SFA_Tmp = ();
			my $FA_counter = 0;
			
			foreach(@SFArray){
				
				my $i = $_;
				$SFA_Tmp[$FA_counter] = "$FileDir/$txtfiles[$_]";
				$FA_counter++;
			}

			#foreach(@SFA_Tmp){print("FATemp: $_\n");}

			#foreach(@txtFileArray){print("FArr: $_\n");}

			my @Location_Array = ();
			my $LA_Counter = 0;
			
			for(my $i = 0; $i <= $#SFA_Tmp; $i++){
			
				for(my $j = 0; $j <= $#txtFileArray; $j++){

					if($SFA_Tmp[$i] eq $txtFileArray[$j]){
					
						$Location_Array[$LA_Counter] = $i;
						$LA_Counter++;
					}
				}	
			}
			
			my $minus = 0;

			my $Files_Already_Selected = 0;
			my @Report_Array = ();
			my $RA_Counter = 0;
			
			foreach(@Location_Array){
				$Report_Array[$RA_Counter] = $SFA_Tmp[$_];
				$RA_Counter++;
			}
						
			foreach(@Location_Array){

			    my $j = $_;

			    $j = $j - $minus;
			    $minus++;
			    splice(@SFA_Tmp,$j,1);
			    $LA_Counter = $LA_Counter - 1;

			}
				
			my $SizeLA = @Location_Array;
			
			#print("SizeLA: $SizeLA\n");
			
			if($SizeLA == 0){
				
				foreach(@SFA_Tmp){

					$txtFileArray[$txtFileArray_i] = "$_";
					$txtFileArray_i++;
				}
			
			}elsif($SizeLA > 0){
			
				for(my $i = 0; $i <= $#SFA_Tmp; $i++){
					#print("FA:$SFA_Tmp[$i]\n");
					$txtFileArray[$txtFileArray_i] = $SFA_Tmp[$i];
					$txtFileArray_i++;						
				}
			
				$Files_Already_Selected = 1;
			}
			
			#print("Location_Array: @Location_Array\n");
			
			$MainText->delete("1.0", "end");
			$MainText->insert("end", "\n");
			
			for (my $j = 0; $j <= $#txtFileArray; $j++) { 
				$MainText->insert("end", "File $txtFileArray[$j] selected\n");
			}
			
			if($Files_Already_Selected == 1){
				
				#print("Report_Array: @Report_Array\n");

				my $ans_already_selected;

				my(@popup_opts) = (-popover => undef, qw/-overanchor n -popanchor n/);
				my $db = $mw->Dialog(@popup_opts , -title => 'Select files',
									    -anchor => 'nw',
									    -buttons => ['Ok', 'Cencel'],
									    -default_button => 'Ok',
						    );


				my $height;$height = $mw->screenheight;
				my $width; $width = $mw->screenwidth;
				my $minheight = ($height*(35/100));	# Start of setting the window size
				my $minwidth = ($width*(55/100));
				$db->minsize($minwidth,$minheight);
				$db->maxsize($minwidth,$minheight);
				$db->geometry('-100-100');			# End of setting the window size

				my $label_1 = $db -> Label (-text => 'Following files are already selected!') -> place(-relx => 0.04, -rely => 0.00);

				my $Listbox_Already_Selected_Files = $db -> Scrolled("Listbox", 
										-scrollbars => "se", 
										-relief => 'groove', 
										-selectmode => "extended",
										-height => 10, -width => 80) -> place(-relx => 0.04, -rely => 0.08);

				
				$Listbox_Already_Selected_Files -> insert('end', @Report_Array);
				
				$ans_already_selected = $db -> Show();

				if($ans_already_selected eq 'Ok') {
				
				}
			}
		}else{
			my $ans_to_please_select = $mw -> messageBox(-title => 'Please select txt files!',
					    -message => 'You have not selected any txt files for reading!',
					    -type => 'Ok', -icon => 'error');
			if($ans_to_please_select   eq 'ok') {
			}
		
		}
		
			#chdir ("$CurrentDir"); 	# *** VERY IMPORTANT ***
			#				# We do not need to return to our original working directory.
			#				# Previously If we did not do this program could not find the							
			#				# other executable files.
	}


}

sub f06_files {
		
	#$FileDir = $Drtree -> selectionGet; #Note: This statement does't work with the latest edition of Perl changed to following code:
	
	# This is to get the selection 
	
	my @FileDirArray = $Drtree -> selectionGet;
	$FileDir = $FileDirArray[0];
	
	if( (defined $FileDir) && ($FileDir ne "") ) {

		if (defined $FileDir) {chdir ("$FileDir");}

		@f06files = ();
		@f06files = <*.f06>;

		my $Size_Of_f06files = @f06files;

		if($Size_Of_f06files > 0) {
		
			$Listbox_select_f06 -> delete(0, 'end');
			$Listbox_select_f06 -> insert('end', @f06files);
			
		}elsif($Size_Of_f06files == 0){
	
			$Listbox_select_f06 -> delete(0, 'end');
			
		}
	
	}
}


sub bdf_files {
		
	#$FileDir = $Drtree -> selectionGet; #Note: This statement does't work with the latest edition of Perl changed to following code:
	
	# This is to get the selection

	my @FileDirArray = $Drtree -> selectionGet;
	$FileDir = $FileDirArray[0];
		
	if( (defined $FileDir) && ($FileDir ne "") ) {

		if (defined $FileDir) {chdir ("$FileDir");}

		@bdffiles = ();
		@bdffiles = <*.bdf>;

		my $Size_Of_bdffiles = @bdffiles;

		if($Size_Of_bdffiles > 0) {
		
			$Listbox_select_bdf -> delete(0, 'end');
			$Listbox_select_bdf -> insert('end', @bdffiles);
			
		}elsif($Size_Of_bdffiles == 0){
	
			$Listbox_select_bdf -> delete(0, 'end');
			
		}
	
	}
}

sub txt_files {
		
	#$FileDir = $Drtree -> selectionGet; #Note: This statement does't work with the latest edition of Perl changed to following code:
	
	# This is to get the selection

	my @FileDirArray = $Drtree -> selectionGet;
	$FileDir = $FileDirArray[0];
		
	if( (defined $FileDir) && ($FileDir ne "") ) {

		if (defined $FileDir) {chdir ("$FileDir");}

		@txtfiles = ();
		@txtfiles = <*.txt>;

		my $Size_Of_txtfiles = @txtfiles;

		if($Size_Of_txtfiles > 0) {
		
			$Listbox_select_txt -> delete(0, 'end');
			$Listbox_select_txt -> insert('end', @txtfiles);
			
		}elsif($Size_Of_txtfiles == 0){
	
			$Listbox_select_txt -> delete(0, 'end');
			
		}
	
	}
}

# Sub remove file -----------------------------------------------------------------------------------------------------------

sub remove_f06 {

    if(defined $f06FileArray[0]){

	my $ans_to_rm_file;
	my $db = $mw -> DialogBox(-title => 'Select files to remove',
						    -buttons => ['Ok', 'Cencel'],
						    -default_button => 'Ok');

		   my $Listbox_remove = $db -> Scrolled("Listbox", 
		   					-scrollbars => "se", 
		   					-relief => 'groove', 
		   					-height => 7, 
		   					-width => 60,
		   					-selectmode => 'extended')-> pack(-side =>'left');
		   
			$Listbox_remove -> insert('end', @f06FileArray);
			$ans_to_rm_file = $db -> Show();
			if($ans_to_rm_file eq 'Ok') {

			my @selected_files = $Listbox_remove -> curselection;

				my $minus = 0;

				foreach(@selected_files){

				    my $j = $_;

				    $j = $j - $minus;
				    $minus++;
				    splice(@f06FileArray,$j,1);
				    $f06FileArray_i = $f06FileArray_i - 1;

				}

				$MainText->delete("1.0", "end");
				my $size_of_f06FileArray = @f06FileArray;

				if((defined $f06FileArray[0]) && ($size_of_f06FileArray > 0) ){	#Preventing the print if f06FileArray is empty
				    for (my $k = 0; $k <= $#f06FileArray; $k++) { 
					$MainText->insert("end", "File $f06FileArray[$k] selected\n");
				    }
				}

				# my $size = @f06FileArray; print ("size after removeing = $size\n"); print ("FAi: $f06FileArray_i\n");
			}
		   
    }else{

     my $ans_to_rm_file => $mw -> messageBox(	-title		 => 'Nothing to remove',
						 	-message	 => 'There is nothing to remove !',
						 	-type 		 => 'Ok',
						 	-icon		 => 'warning',
						 	-default 	 => 'ok');

    }     	 
} # End of sub remove_f06 {

# Sub remove file end --------------------------------------------------------------------------------------------------------

sub remove_bdf {

    if(defined $bdfFileArray[0]){

	my $ans_to_rm_file;
	my $db = $mw -> DialogBox(-title => 'Select files to remove',
						    -buttons => ['Ok', 'Cencel'],
						    -default_button => 'Ok');

		   my $Listbox_remove = $db -> Scrolled("Listbox", 
		   					-scrollbars => "se", 
		   					-relief => 'groove', 
		   					-height => 7, 
		   					-width => 60,
		   					-selectmode => 'extended')->pack(-side =>'left');
		   
			$Listbox_remove -> insert('end', @bdfFileArray);
			$ans_to_rm_file = $db -> Show();
			if($ans_to_rm_file eq 'Ok') {

			my @selected_files = $Listbox_remove -> curselection;

				my $minus = 0;

				foreach(@selected_files){

				    my $j = $_;

				    $j = $j - $minus;
				    $minus++;
				    splice(@bdfFileArray,$j,1);
				    $bdfFileArray_i = $bdfFileArray_i - 1;

				}

				$MainText->delete("1.0", "end");
				my $size_of_bdfFileArray = @bdfFileArray;

				if((defined $bdfFileArray[0]) && ($size_of_bdfFileArray > 0) ){	#Preventing the print if bdfFileArray is empty
				    for (my $k = 0; $k <= $#bdfFileArray; $k++) { 
					$MainText -> insert("end", "File $bdfFileArray[$k] selected\n");
				    }
				}

				# my $size = @bdfFileArray; print ("size after removeing = $size\n"); print ("FAi: $bdfFileArray_i\n");
			}
		   
    }else{

     my $ans_to_rm_file => $mw -> messageBox(	-title		 => 'Nothing to remove',
						-message	 => 'There is nothing to remove !',
						-type 		 => 'Ok',
						-icon		 => 'warning',
						-default 	 => 'ok');

    }
} # End of sub remove_bdf {

# Sub remove file end --------------------------------------------------------------------------------------------------------


# Start sub exit_program ____________________________________________________________________________________________________

sub exit_program{
	exit;
}
# End sub exit_program ____________________________________________________________________________________________________


# Start of Help Menuitems subs -------------------------------------------------------------------------------------------------------------------------------------

sub html_help {
	
	if ($^O eq 'MSWin32') {
		
		my $command =  "C:\\Program Files\\Internet Explorer\\IEXPLORE.EXE";
		my $iexplorer_c = "C:/Program Files/Internet Explorer/IEXPLORE.EXE";
		my $iexplorer_d = "D:/Program Files/Internet Explorer/IEXPLORE.EXE";
		my $iexplorer_e = "E:/Program Files/Internet Explorer/IEXPLORE.EXE";
		my $iexplorer_f = "F:/Program Files/Internet Explorer/IEXPLORE.EXE";
		my $iexplorer_g = "G:/Program Files/Internet Explorer/IEXPLORE.EXE";
		if (-e "$iexplorer_c"){
			$command = "C:\\Program Files\\Internet Explorer\\IEXPLORE.EXE";
		}elsif(-e "$iexplorer_d"){
			$command = "D:\\Program Files\\Internet Explorer\\IEXPLORE.EXE";
		}elsif(-e "$iexplorer_e"){
			$command = "E:\\Program Files\\Internet Explorer\\IEXPLORE.EXE";
		}elsif(-e "$iexplorer_f"){
			$command = "F:\\Program Files\\Internet Explorer\\IEXPLORE.EXE";
		}elsif(-e "$iexplorer_g"){
			$command = "G:\\Program Files\\Internet Explorer\\IEXPLORE.EXE";
		}else{
			my $ans_to_cannot_find_iexplorer = $mw->messageBox(-title => 'Directory already exists',
					    -message => 'Cannot find Internet Explorer!',
					    -type => 'Ok', -icon => 'error');
			if($ans_to_cannot_find_iexplorer  eq 'ok') {

			}
		}
		#use Win32::Process;
		#my $args = "IEXPLORE.EXE \\Program Files\\f06digest\\help\\html\\welcome.htm";
		#my $process;
		#Win32::Process::Create(
			#$process,
			#$command,
			#$args,
			#0,
			#CREATE_NEW_CONSOLE,
			#'.') || & error();
	}
}

sub help {
	print "Help\n";
}

# End of Help menuitems subs -------------------------------------------------------------------------------------------------------------------------------------


# Start sub BindMouseWheel ---------------------------------------------------------------------------------------------------------------------------------------
sub BindMouseWheel {

    my($w) = @_;

    if ($^O eq 'MSWin32') {
        $w->bind('<MouseWheel>' =>
            [ sub { $_[0]->yview('scroll', -($_[1] / 120) * 3, 'units') },
                Ev('D') ]
        );
    } else {

        # Support for mousewheels on Linux commonly comes through
        # mapping the wheel to buttons 4 and 5.  If you have a
	# mousewheel ensure that the mouse protocol is set to
	# "IMPS/2" in your /etc/X11/XF86Config (or XF86Config-4)
        # file:
	#
        # Section "InputDevice"
	#     Identifier  "Mouse0"
	#     Driver      "mouse"
	#     Option      "Device" "/dev/mouse"
	#     Option      "Protocol" "IMPS/2"
	#     Option      "Emulate3Buttons" "off"
	#     Option      "ZAxisMapping" "4 5"
	# EndSection

        $w->bind('<4>' => sub {
            $_[0]->yview('scroll', -3, 'units') unless $Tk::strictMotif;
        });

        $w->bind('<5>' => sub {
	    $_[0]->yview('scroll', +3, 'units') unless $Tk::strictMotif;
        });
    }

} 
# end BindMouseWheel ____________________________________________________________________________________________________________________________________

# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : setSummationPoint				                  *
# INTERNAL SUB FUNCTION PURPOSE : This function reads the summation point and assigns variables   *
#												  *
# *************************************************************************************************

sub setSummationPoint {

	my $XSummed = $_[0];
	my $YSummed = $_[1];
	my $ZSummed = $_[2];
	
	my @ReturnArray = ($XSummed, $YSummed, $ZSummed);
	
	return \@ReturnArray;
	
}

# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : checkNodeIds					                  *
# INTERNAL SUB FUNCTION PURPOSE : This function checks entered node ids and deletes them from the *
#                                 list if they are not in the bdf file 				  *
#												  *
# *************************************************************************************************

sub checkNodeIds {

	#open(TEST, ">checkNodeIds.dat") or die "Unable to open input file checkNodeIds.dat\n";
	
	my @NodeInputArray = @_;
	my $NIACnt = 0;

	my @NodeReturnArray = ();
	my $NRACnt = 0;

	my @AllGridsArray = ();
	my $AGACnt = 0;

	my @AllNodesIDArray = ();
	my $ANIACnt = 0;

	for (my $i =0; $i<= $#bdfFileArray; $i++) {

		open(FILE, $bdfFileArray[$i]) or die "Unable to open input file $bdfFileArray[$i]\n";

		while (<FILE>) { # **************** IMPORTANT ********** This is the main while loop that goes through the bdf Files.


			if ($_ =~m/^GRID....(.{8})/) {

				chomp($_);
				
				$AllGridsArray[$AGACnt] = $_;
				$AGACnt++;
				
				my @GridArray = unpack '(a8)*', $_;
				
				$AllNodesIDArray[$ANIACnt] = $GridArray[1]; 
				$ANIACnt++;
			}
		}
	
		close FILE;
	}

	# We need to filter the repeated number of nodes and then sort the array
		
	my %FilterHash = ();
	my $key = 0;
	
	# We are filtering the repeated number of node ids.
	# First create the hash, then clear the @AllNodesIDArray
	
	foreach(@AllNodesIDArray){

		$FilterHash{$_} = $_;
	}

	@AllNodesIDArray = ();
	$ANIACnt = 0;

	#print "Satage1: OK\n";
	
	# Then recreate the AllNodesIDArray array
	
	foreach $key (sort {$a <=> $b} keys %FilterHash){
			
		# Recreating AllNodesIDArray with filtered elements 		
		$AllNodesIDArray[$ANIACnt] = $key;	
		$ANIACnt++;
	}

	%FilterHash = ();
	$key = 0;						

	#print "Satage2: OK\n";

	# This section of the code looks for the selected node ids in the @NodeIDArray
	# If the node does not exist in the bdf file
			
	my $flag = 0;
	my @NodePositionArray = ();
	my $NPACnt = 0;
	
	foreach(@NodeInputArray){
		
		my $node = $_;
		
		foreach(@AllNodesIDArray){
			
			if($node == $_){
				$flag = 1; # If the node exists then turn on the flag
			}	
		}
		
		if($flag == 0){ 
			
			# Code finds out the position of the node (that does not exist in the bdf file) 
			
			$NodePositionArray[$NPACnt] = $NIACnt;
			$NPACnt++;
		}
		
		$flag = 0;
		$NIACnt++;
		
	}

	my @NotFoundNodesArray = ();
	my $NFNACnt = 0;
	
	foreach(@NodePositionArray){

		$NotFoundNodesArray[$NFNACnt] = $NodeInputArray[$_];
		#print TEST ("NoSummationNodeInputArray[$NSNIACnt]: $NotFoundNodesArray[$NFNACnt]\n");
		$NFNACnt++;
	
	}
	
	my $SizeNFNA = @NotFoundNodesArray;
	
	# This section of the code removes the node id from the @SummationNodeInputArray
	# If the node does not exist in the bdf file

	my $SizeNPA = @NodePositionArray;
	
	if($SizeNPA > 0){ 
	
		my $minus = 0;

		foreach(@NodePositionArray){

			my $j = $_;

			$j = $j - $minus;
			$minus++;
			splice(@NodeInputArray,$j,1);

		}
	}


	my $SizeNIA = @NodeInputArray;
	$NIACnt = 0; # Counter for @NodeInputArray

	#foreach(@SummationNodeInputArray){
		
		#print TEST ("SummationNodeInputArray: $_\n");
		
	#}
	
	foreach(@AllGridsArray){
				
		my @GridArray = unpack '(a8)*', $_;
		
		#print TEST ("AllGridsArray: $_\n");
		
		#print TEST "GridArray[1] $GridArray[1] SummationNodeInputArray[$SNIACnt] $SummationNodeInputArray[$SNIACnt]\n";	

		if(defined $GridArray[1] && defined $NodeInputArray[$NIACnt] && $GridArray[1] == $NodeInputArray[$NIACnt]){
				
			$NodeReturnArray[$NRACnt] = "$NodeInputArray[$NIACnt] $GridArray[3] $GridArray[4] $GridArray[5]";
			
			#print TEST ("SummationNodeReturnArray: $SummationNodeReturnArray[$SNRACnt] SNRACnt $SNRACnt SNIACnt $SNIACnt\n");
			$NRACnt++;
			$NIACnt++;		
		}
		
		if($NIACnt >= $SizeNIA){
			
			#print TEST ("last SNIACnt $SNIACnt SizeSNIA $SizeSNIA\n");
			last;
		}
	}

	#print TEST "AllGridsArray:\n";
	
	#foreach(@AllGridsArray){
		#print TEST "AllGridsArray: $_\n";
	#}

	#print TEST "NodeReturnArray:\n";
	
	#foreach(@NodeReturnArray){
		#print TEST "NodeReturnArray: $_\n";
	#}
	
	#close TEST;

	my $SizeNRA = @NodeReturnArray;
	
	my @ReturnArray = ($SizeNRA, $SizeNFNA, @NodeReturnArray, @NotFoundNodesArray);
	
	return \@ReturnArray;	# If $SizeNRA > 0 then program could not find some selected nodes in the bdf file	
}


# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : checkCoordIds					                  *
# INTERNAL SUB FUNCTION PURPOSE : This function checks entered Coord ids if they are not in 	  *
#                                 the bdf file, sets the reference coord to zero.		  *
#												  *
# *************************************************************************************************

sub checkCoordIds {

	#open(TEST, ">checkNodeIds.dat") or die "Unable to open input file checkNodeIds.dat\n";
        
        my @CoordIDCheckArray = (); # Local Summation node id value
	my $CICACnt = 0;
	
	my $CoordFlag = 1; # Flag for checking coord ids
	
	@CoordIDCheckArray = @_;
	
	my @AllCoordIDArray = ();
	my $ACIACnt = 0;
	
	for (my $i =0; $i<= $#bdfFileArray; $i++) {

		open(FILE, $bdfFileArray[$i]) or die "Unable to open input file $bdfFileArray[$i]\n";

		while (<FILE>) { # **************** IMPORTANT ********** This is the main while loop that goes through the bdf Files.

			if ($_ =~ /^CORD2R..(.{8})/) {

				chomp;
				my $FirstLine = $_; 

				my $mod = length($_) % 8;
				my $add = " ";
								
				if ($mod > 0){# if the first line is shorter than 8 digits than add space so that mod 8 is zero for each line
					for (my $i = 0; $i < 8 - $mod; $i++) { 
						$FirstLine = $FirstLine . $add;
					}
				}
				
				my $SecondLine = <FILE>; 
				chomp($SecondLine);
				
				my $CoordLine = $FirstLine . $SecondLine;
						
				my @CoordArray = unpack '(a8)*', $CoordLine;

				$AllCoordIDArray[$ACIACnt] = $CoordArray[1]; 
				$ACIACnt++;				
			}
			
		}
	
		close FILE;
	}
	
	# This section of the code looks for the selected coord ids in the @AllCoordIDArray
	# If the coordinate frame id does not exist in the bdf file
	
	my $Flag = 0;
	
	my @CoordPositionArray = ();
	my $CPACnt = 0;
		
	foreach(@CoordIDCheckArray){
		
		my $coord = $_;
		
		foreach(@AllCoordIDArray){
			
			if($coord == $_){
			
				$Flag = 1; # If the coord id exists then turn on the flag
			}	
		}
		
		if($Flag == 0){
								
			$CoordPositionArray[$CPACnt] = $CICACnt;
			$CPACnt++;
		}
		
		$Flag = 0;
		$CICACnt++;
		
	}
	
	my @NoCoordIDArray = ();
	my $NCIACnt = 0;
	
	foreach(@CoordPositionArray){

		$NoCoordIDArray[$NCIACnt] = $CoordIDCheckArray[$_];
		$NCIACnt++;
	
	}
	
	
	# This section of the code removes the node id from the @NodeIDArray
	# If the node does not exist in the bdf file

	my $SizeCPA = @CoordPositionArray;
	
	if($SizeCPA > 0){ 
	
		my $minus = 0;

		foreach(@CoordPositionArray){

			my $j = $_;

			$j = $j - $minus;
			$minus++;
			splice(@CoordIDCheckArray,$j,1);

		}
	}

	my $SizeNCIA = @NoCoordIDArray;
			
	my @ReturnArray = ($SizeNCIA, @NoCoordIDArray);
	
	return \@ReturnArray;	# If the value of $SizeNCIA is bigger than 0 then some Coord id/ids could not be found in the bdf file, if
				# $SizeNCIA is 0, then all coord ids are found in the bdf file		
}


# ***************************************************************************************************************
#											      	  		*
# INTERNAL SUB FUNCTION NAME    : checkCoordVectorDefinition			                  		*
# INTERNAL SUB FUNCTION PURPOSE : This function checks (X0,Y0,Z0) point, and the two defined vector directions	*
#                                 (X1,Y1,Z1) & (X2,Y2,Z2)							*
#												  		*
# ***************************************************************************************************************

sub checkCoordVectorDefinition {

	#&unitcrossPruduct();

}

# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : readBdfFile					                  *
# INTERNAL SUB FUNCTION PURPOSE : This function reads bdf files and finds GRID INFO               *
#												  *
# *************************************************************************************************

sub readBdfFile {

	#open (CODE, ">>$CurrentDir/ProgrammingLog.dat") or die "Unable to write input file ProgrammingLog.dat\n";

	#print CODE ("********* Inside readBdfFile ************\n");
	#print CODE ("_[0]: $_[0], _[1]: $_[1], _[2]: $_[2]\n");

        #open(READTEST, ">readBdfFile.dat") or die "Unable to open input file readBdfFile.dat\n";

	my $SizeNIA = 0;		# Local size of @NodeIDArray
	my $SizeMPCNIA = 0;		# Local size of @MPCNodeIDArray
	my $SizeFBNIA = 0;		# Local size of @FreebodyNodeIDArray
	my $SizeDNIA = 0;		# Local size of @FreebodyNodeIDArray

	my @NodeIDArray = ();		# print CODE ("NodeIDArray[$NIACnt] $NodeIDArray[$NIACnt];\n");
	my $NIACnt = 0; 		# Local counter for @NodeIDArray

	my @MPCNodeIDArray = (); 	#print ("MPCNodeIDArray[$MPCNIDCnt] $MPCNodeIDArray[$MPCNIDCnt];\n");
	my $MPCNIACnt = 0; 		# Local counter for @MPCNodeIDArray

	my @FreebodyNodeIDArray = (); 	#print ("FreebodyNodeIDArray[$FBNIACnt] $FreebodyNodeIDArray[$FBNIACnt];\n");
	my $FBNIACnt = 0; 		# Local counter for @FreebodyNodeIDArray

	my @DispNodeIDArray = (); 	#print ("FreebodyNodeIDArray[$FBNIACnt] $FreebodyNodeIDArray[$FBNIACnt];\n");
	my $DNIACnt = 0; 		# Local counter for @DispNodeIDArray


	if(defined $_[0]){ 
	
		$SizeNIA = $_[0];		# Local size of @NodeIDArray
		
		#print READTEST  "SizeNIA $SizeNIA\n";
	}

	if(defined $_[1]){ 
	
		$SizeMPCNIA = $_[1];		# Local size of @NodeIDArray
		
		#print READTEST  "SizeMPCNIA $SizeMPCNIA\n";
	}

	if(defined $_[2]){ 
	
		$SizeFBNIA = $_[2];		# Local size of @FreebodyNodeIDArray
		
		#print READTEST  "SizeFBNIA $SizeFBNIA\n";	
	}

	if(defined $_[3]){ 
	
		$SizeDNIA = $_[3];		# Local size of @DispNodeIDArray
		
		#print READTEST  "SizeDNIA $SizeDNIA\n";	
	}

	# Locally rebuilding @NodeIDArray
	
	for(my $i = 4; $i < ($SizeNIA + 4) ; $i++){	

		# passed variables &gpfbInitialSort($SizeNIA, $SizeMPCNIA, $SizeFBNIA, $SizeDNIA, @NodeIDArray , @MPCNodeIDArray, @FreebodyNodeIDArray, @DispNodeIDArray)
	
		$NodeIDArray[$NIACnt] = $_[$i];	#print CODE ("NodeIDArray[$NIACnt] $NodeIDArray[$NIACnt];\n");
		$NIACnt++;
	}

	# Locally rebuilding @MPCNodeIDArray
	
	for(my $i = (4 + $SizeNIA); $i < (4 + $SizeNIA + $SizeMPCNIA); $i++){ 
		
		# passed variables &gpfbInitialSort($SizeNIA, $SizeMPCNIA, $SizeFBNIA, $SizeDNIA, @NodeIDArray , @MPCNodeIDArray, @FreebodyNodeIDArray, @DispNodeIDArray)
		
		$MPCNodeIDArray[$MPCNIDCnt] = $_[$i]; #print ("MPCNodeIDArray[$MPCNIDCnt] $MPCNodeIDArray[$MPCNIDCnt];\n");
		$MPCNIDCnt++;
	}

	# Locally rebuilding @FreebodyNodeIDArray
	
	for(my $i = (4 + $SizeNIA + $SizeMPCNIA); $i < (4 + $SizeNIA + $SizeMPCNIA + $SizeFBNIA); $i++){ 
		
		# passed variables &gpfbInitialSort($SizeNIA, $SizeMPCNIA, $SizeFBNIA, $SizeDNIA, @NodeIDArray , @MPCNodeIDArray, @FreebodyNodeIDArray, @DispNodeIDArray)
			
		$FreebodyNodeIDArray[$FBNIACnt] = $_[$i]; #print ("FreebodyNodeIDArray[$FBNIACnt] $FreebodyNodeIDArray[$FBNIACnt];\n");
		$FBNIACnt++;
	}

	# Locally rebuilding @DispNodeIDArray
	
	for(my $i = (4 + $SizeNIA + $SizeMPCNIA + $SizeFBNIA); $i < (4 + $SizeNIA + $SizeMPCNIA + $SizeFBNIA + $SizeDNIA); $i++){ 
		
		# passed variables &gpfbInitialSort($SizeNIA, $SizeMPCNIA, $SizeFBNIA, $SizeDNIA, @NodeIDArray , @MPCNodeIDArray, @FreebodyNodeIDArray, @DispNodeIDArray)
			
		$DispNodeIDArray[$DNIACnt] = $_[$i]; #print ("FreebodyNodeIDArray[$FBNIACnt] $FreebodyNodeIDArray[$FBNIACnt];\n");
		$DNIACnt++;
	}

	#foreach(@NodeIDArray){
	
		#print READTEST  "NodeIDArray: $_\n";
	
	#}


	#foreach(@_){
	
		#print READTEST  "At_: $_\n";
	
	#}

	# ********** Create a Directory called DATA in the working directory where some data files will be saved ***************
	
	my $WorkingDir = cwd;	
	my $DataDir = "$WorkingDir\/DATA";
		
	mkdir "$DataDir";

	# **********************************************************************************************************************

	my @CoordBdfLineArray =();
	my $CBLACnt = 0;


	my @NodeXYZCoordArray = ();
	my @MPCNodeXYZCoordArray = ();
	my @FreebodyNodeXYZCoordArray = ();

	@CoordIDArray = ();		# Array that contains all coordinate ids found in the bdf file
	$CIDACnt = 0;			# Counter for @CoordIDArray

	$NIACnt = 0; # Local counter for @NodeIDArray
	$MPCNIACnt = 0; # Local counter for @MPCNodeIDArray
	$FBNIACnt = 0; # Local counter for @FreebodyNodeIDArray
	$DNIACnt = 0; # Local counter for @DispNodeIDArray
		
	#open(WRTFILE, ">$CurrentDir/coordgrid.dat") or die "Unable to write input file coordgrid.dat\n";
		
	#print ("$CurrentDir\n");
		
	for (my $i =0; $i<= $#bdfFileArray; $i++) {

		open(FILE, $bdfFileArray[$i]) or die "Unable to open input file $bdfFileArray[$i]\n";

		while (<FILE>) { # **************** IMPORTANT ********** This is the main while loop that goes through the bdf Files.


			if ($_ =~m/^GRID....(.{8})/) {

				chomp;
				
				my @GridArray = unpack '(a8)*', $_;

				if (defined $NodeIDArray[$NIACnt] && $GridArray[1] == $NodeIDArray[$NIACnt] && $SizeNIA > 0){
					
					if( defined $GridArray[6] && $GridArray[6] > 0){
						
						$NodeXYZCoordArray[$NIACnt] = "$GridArray[1],$GridArray[3],$GridArray[4],$GridArray[5],$GridArray[6]";
						
						print "1: $GridArray[1],$GridArray[3],$GridArray[4],$GridArray[5],$GridArray[6]\n";
						
					}elsif(!defined $GridArray[6] || $GridArray[6] == 0){
						
						$NodeXYZCoordArray[$NIACnt] = "$GridArray[1],$GridArray[3],$GridArray[4],$GridArray[5],0";
						
						#print "2: $GridArray[1],$GridArray[3],$GridArray[4],$GridArray[5],0\n";
					}
					
					$NIACnt++;
				}

				if (defined $MPCNodeIDArray[$MPCNIACnt] && $GridArray[1] == $MPCNodeIDArray[$MPCNIACnt] && $SizeMPCNIA > 0){
					
					if( defined $GridArray[6] && $GridArray[6] > 0){
						
						$MPCNodeXYZCoordArray[$MPCNIACnt] = "$GridArray[1],$GridArray[3],$GridArray[4],$GridArray[5],$GridArray[6]";

						
					}elsif(!defined $GridArray[6] || $GridArray[6] == 0){
						
						$MPCNodeXYZCoordArray[$MPCNIACnt] = "$GridArray[1],$GridArray[3],$GridArray[4],$GridArray[5],0";	
					}
					
					$MPCNIACnt++;
				}

				if (defined $FreebodyNodeIDArray[$FBNIACnt] && $GridArray[1] == $FreebodyNodeIDArray[$FBNIACnt] && $SizeFBNIA >0){
					
					if(defined $GridArray[6] && $GridArray[6] > 0){
						
						$FreebodyNodeXYZCoordArray[$FBNIACnt] = "$GridArray[1],$GridArray[3],$GridArray[4],$GridArray[5],$GridArray[6]";
						
					}elsif(!defined $GridArray[6] || $GridArray[6] == 0){
						
						$FreebodyNodeXYZCoordArray[$FBNIACnt] = "$GridArray[1],$GridArray[3],$GridArray[4],$GridArray[5],0";
					}
					
					$FBNIACnt++;
				}

				if (defined $DispNodeIDArray[$DNIACnt] && $GridArray[1] == $DispNodeIDArray[$DNIACnt] && $SizeDNIA >0){
					
					if(defined $GridArray[6] && $GridArray[6] > 0){
						
						$DispNodeXYZCoordArray[$DNIACnt] = "$GridArray[1],$GridArray[3],$GridArray[4],$GridArray[5],$GridArray[6]";
						
					}elsif(!defined $GridArray[6] || $GridArray[6] == 0){
						
						$DispNodeXYZCoordArray[$DNIACnt] = "$GridArray[1],$GridArray[3],$GridArray[4],$GridArray[5],0";
					}
					
					$DNIACnt++;
				}
				
				chomp;

				#if ($_ =~m/^GRID....(.{8})(.{8})/){
								
				#foreach(@GridArray){
					#$line = "$line" . "$_ ";
					#print WRTFILE ("$line\n");
				#}
			}
				
			if ($_ =~ /^CORD2R..(.{8})/) {

				chomp;
				my $FirstLine = $_; 
				
				#my @CoordArray = unpack '(a8)*', $_;
				#my $SizeCA = @CoordArray;							
				#my $l = length($_);

				my $mod = length($_) % 8;
				my $add = " ";
				
				#print WRTFILE ("$mod\n");
				
				if ($mod > 0){# if the first line is shorter than 8 digits than add space so that mod 8 is zero for each line
					for (my $i = 0; $i < 8 - $mod; $i++) { 
						$FirstLine = $FirstLine . $add;
					}
				}
				
				#foreach(@CoordArray){
					#print WRTFILE ("first Line$_\n");
				#}
				
				my $SecondLine = <FILE>; 
				chomp($SecondLine);
				
				my $CoordLine = $FirstLine . $SecondLine;
				
				$CoordBdfLineArray[$CBLACnt] = $CoordLine;
				$CBLACnt++;
						
				my @CoordArray = unpack '(a8)*', $CoordLine;

				$CoordIDArray[$CIDACnt] = $CoordArray[1]; $CIDACnt++;	# Array that contains all coordinate ids found in the bdf file
                                
				#@CoordArray = unpack '(a8)*', $NextLine;
				
				#foreach(@CoordArray){
					#print WRTFILE ("second Line$_\n");
				#}			
			}		
		}
	}

	# We need to filter the repeated number of nodes and then sort the array
	
	my %FilterHash = ();
	my $key = 0;
	
	# We are filtering the repeated number of node ids.
	# First create the hash, then clear the @SummationNodeList
	
	my @CoordIDArrayTmp = @CoordIDArray;
           
        foreach(@CoordIDArrayTmp){
				
	    $FilterHash{$_} = $_;
	}

	@CoordIDArrayTmp = ();
	my $CIATCnt = 0;

	# Then recreate the SummationNodeList array
			
	foreach $key (sort {$a <=> $b} keys %FilterHash){
	
	    # Recreating ElmIDArray with filtered elements 		
            $CoordIDArrayTmp[$CIATCnt] = $key;	
            $CIATCnt++;
	}

	%FilterHash = ();
	$key = 0;						
	
        my @CoordBdfLineArrayTmp = ();
	my $CBLATCnt = 0;
	
        $CIATCnt = 0;
        
        for(my $i = 0; $i <= $#CoordBdfLineArray; $i++){
  
             my @CoordArray = unpack '(a8)*', $CoordBdfLineArray[$i];
		
	    if(defined $CoordArray[1] && defined $CoordIDArrayTmp[$CIATCnt] && $CoordArray[1] == $CoordIDArrayTmp[$CIATCnt]){
			
                $CoordBdfLineArrayTmp[$CBLATCnt] = $CoordBdfLineArray[$i];
                $CBLATCnt++;  
 	    }
                    
            $CIATCnt++;
	}	

        @CoordBdfLineArray = @CoordBdfLineArrayTmp; # Resetting @CoordBdfLineArray
 
	@CoordIDArray = ();		# Array that contains all coordinate ids found in the bdf file
	$CIDACnt = 0;			# Counter for @CoordIDArray

	@CoordA1Array = ();	@CoordA2Array = ();	@CoordA3Array = ();	# Arrays to record A1, A2, A3 points of each coordinate found in the bdf file
	@CoordB1Array = ();	@CoordB2Array = ();	@CoordB3Array = ();	# Arrays to record B1, B2, B3 points of each coordinate found in the bdf file
	@CoordC1Array = ();	@CoordC2Array = ();	@CoordC3Array = ();	# Arrays to record C1, C2, C3 points of each coordinate found in the bdf file
	
        foreach(@CoordBdfLineArray){
	
	    my @CoordArray = unpack '(a8)*', $_;
            
 	    $CoordIDArray[$CIDACnt] = $CoordArray[1]; 	# Array that contains all coordinate ids found in the bdf file
            $CoordA1Array[$CIDACnt] = $CoordArray[3];  $CoordA2Array[$CIDACnt] = $CoordArray[4];  $CoordA3Array[$CIDACnt] = $CoordArray[5]; 	# Arrays to record A1, A2, A3 points of each coordinate found in the bdf file
            $CoordB1Array[$CIDACnt] = $CoordArray[6];  $CoordB2Array[$CIDACnt] = $CoordArray[7];  $CoordB3Array[$CIDACnt] = $CoordArray[8]; 	# Arrays to record B1, B2, B3 points of each coordinate found in the bdf file
	    $CoordC1Array[$CIDACnt] = $CoordArray[10]; $CoordC2Array[$CIDACnt] = $CoordArray[11]; $CoordC3Array[$CIDACnt] = $CoordArray[12]; 	# Arrays to record C1, C2, C3 points of each coordinate found in the bdf file
            
            #print  READTEST "$CoordIDArray[$CIDACnt] $CoordA1Array[$CIDACnt] $CoordA2Array[$CIDACnt] $CoordA3Array[$CIDACnt] $CoordB1Array[$CIDACnt] $CoordB2Array[$CIDACnt] $CoordB3Array[$CIDACnt] $CoordC1Array[$CIDACnt] $CoordC2Array[$CIDACnt] $CoordC3Array[$CIDACnt]\n";
 
            $CIDACnt++;
	}

        #foreach(@CoordIDArray){

            #print READTEST "1. CoordIDArray: $_\n";

	#}

        #foreach(@CoordBdfLineArray){

            #print READTEST "2. CoordBdfLineArray: $_\n";

	#}

        #close READTEST;
        
	my $SizeNXYZCA = @NodeXYZCoordArray;
	my $SizeMPCNXYZCA = @MPCNodeXYZCoordArray;
	my $SizeFBNXYZCA = @FreebodyNodeXYZCoordArray;
	my $SizeDNXYZCA = @DispNodeXYZCoordArray;
	
	my @ReturnArray = ($SizeNXYZCA, $SizeMPCNXYZCA, $SizeFBNXYZCA , $SizeDNXYZCA, @NodeXYZCoordArray, @MPCNodeXYZCoordArray, @FreebodyNodeXYZCoordArray, @DispNodeXYZCoordArray);
	
	return \@ReturnArray;

}

# end ReadBdfFile --------------------------------------------------------------------------------------------------------------------------



# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : checkCoordDefinition				                  *
# INTERNAL SUB FUNCTION PURPOSE : This function checks (A1,A2,A3),(B1,B2,B3) & (C1,C2,C3) points  *
#				  for each coord id in the bdf file. Point C can be on X axis or  *
#				  can be anywhere in the X-Z plane. For this reason we need to    *
#				  check the angle between AB and AC vectors, if this angle is not * 
#				  90 deg. then we need to find a point on the X axis and redifine *
#				  Point C.							  *
#												  *
# *************************************************************************************************

sub checkCoordDefinition {

	# Global Variables:
	
	@CoordInfoArray = ();
	$CIACnt = 0;

	# Private Variables:
	my $SizeCIA = @CoordIDArray;
	
	my $A1 = 0; my $A2 = 0; my $A3 = 0;
	my $B1 = 0; my $B2 = 0; my $B3 = 0;
	my $C1 = 0; my $C2 = 0; my $C3 = 0;
	
	my $ANGLEDEG = 0;	# Angle between $AB and $AC vectors in degrees

	#for (my $i = 0; $i < $SizeCIA; $i++) {
    		#print  "$CoordIDArray[$i] $CoordC1Array[$i] $CoordC2Array[$i] $CoordC3Array[$i]\n";
	#}
		
	for(my $i = 0; $i < $SizeCIA ; $i++){

		#$DEGTHETA = rad2deg($RADTHETA);
		#$DEGTHETA = sprintf("%.3E", $DEGTHETA);

		$A1 = $CoordA1Array[$i]; $A2 = $CoordA2Array[$i]; $A3 = $CoordA3Array[$i];
		$B1 = $CoordB1Array[$i]; $B2 = $CoordB2Array[$i]; $B3 = $CoordB3Array[$i];
		$C1 = $CoordC1Array[$i]; $C2 = $CoordC2Array[$i]; $C3 = $CoordC3Array[$i];		
		
		my @AngleArray = @{calculateCosineFormulaAngle( $A1, $A2, $A3, 
			      			     	 	$B1, $B2, $B3,
			      			    	 	$C1, $C2, $C3);}; # Make a copy of the return array
				
		$ANGLEDEG = round(rad2deg($AngleArray[0]));
				
		if($ANGLEDEG != 90){
		
			# Look up coordinate definition in NASTRAN, Point C can be defined in XZ plane and it
			# does not nacesarrily defined on X axis, this subroutine checks this.
			# If the point C is not on X axis it redefines the coordinate and puts the point C
			# on X axis.
		
			my @CroosProductArray = @{crossPruduct($A1, $A2, $A3, 
			      			     	       $B1, $B2, $B3,
			      			    	       $C1, $C2, $C3);}; # Make a copy of the return array		
			
			# Point D on Y axis
			
			my $D1 = $CroosProductArray[3]; my $D2 = $CroosProductArray[4]; my $D3 = $CroosProductArray[5];
			
			#print("D1 $D1 D2 $D2 D3 $D3\n");
			
			@CroosProductArray = @{crossPruduct($A1, $A2, $A3,
							    $D1, $D2, $D3, 	# Note it is important which point is on u vector
							    $B1, $B2, $B3	# Note it is important which point is on v vector    
			      			     	    );}; # Make a copy of the return array		
			
			#$rounded = sprintf("%.3E", $DEGTHETA);
			
			$CoordC1Array[$i] = $CroosProductArray[3];	# Code changes the location of point C and puts it on X axis
			$CoordC2Array[$i] = $CroosProductArray[4];	# This is necessary for the coordinate transformation 
			$CoordC3Array[$i] = $CroosProductArray[5];
			
			#print ("CoordIDArray: $CoordIDArray[$i], CoordC1Array[$i] $CoordC1Array[$i]\nCoordC2Array[$i] $CoordC2Array[$i]\nCoordC3Array[$i] $CoordC3Array[$i]\nANGLERAD $ANGLERAD, ANGLEDEG $ANGLEDEG\n");
		}
		
		$CoordInfoArray[$CIACnt] = "$CoordIDArray[$i],$A1,$A2,$A3,$B1,$B2,$B3,$C1,$C2,$C3";
		$CIACnt++;
						
	}

	# Coordinate 0 does not have point A, B and C definition, Therefore it needs to be created.
	# We use the last reference coordinate axis to create A, B, C points for Coord 0
	# This is just one way of doing this. We will add this definition to @CoordIDArray and @CoordA1Array, ... etc

	$CoordIDArray[$SizeCIA] = 0;

	my $AB = calculatePointsDistance($A1, $A2, $A3, $B1, $B2, $B3); # Using the last coordinate to define a Coord 0				
	my $AC = calculatePointsDistance($A1, $A2, $A3, $C1, $C2, $C3); # in terms of point A, B & C			   		

	$AB = sprintf("%.4f", $AB);
	$AC = sprintf("%.4f", $AC);
	
	$CoordA1Array[$SizeCIA] = 0;   $CoordA2Array[$SizeCIA] = 0; $CoordA3Array[$SizeCIA] = 0;
	$CoordB1Array[$SizeCIA] = 0;   $CoordB2Array[$SizeCIA] = 0; $CoordB3Array[$SizeCIA] = $AB;
	$CoordC1Array[$SizeCIA] = $AC; $CoordC2Array[$SizeCIA] = 0; $CoordC3Array[$SizeCIA] = 0;		

	$A1 = $CoordA1Array[$SizeCIA]; $A2 = $CoordA2Array[$SizeCIA]; $A3 = $CoordA3Array[$SizeCIA];
	$B1 = $CoordB1Array[$SizeCIA]; $B2 = $CoordB2Array[$SizeCIA]; $B3 = $CoordB3Array[$SizeCIA];
	$C1 = $CoordC1Array[$SizeCIA]; $C2 = $CoordC2Array[$SizeCIA]; $C3 = $CoordC3Array[$SizeCIA];		

	$CoordInfoArray[$CIACnt] = "$CoordIDArray[$SizeCIA],$A1,$A2,$A3,$B1,$B2,$B3,$C1,$C2,$C3";
	$CIACnt++;

	$SizeCIA = @CoordIDArray;
	
	#$CoordInfoArrayTmp[$CIATCnt] = "$CoordID,$O1,$O2,$O3,$C1,$C2,$C3,$A1,$A2,$A3,$B1,$B2,$B3";
	
	my @CoordInfoArrayTmp2 = ();
	my $CIAT2Cnt = 0;
	
	foreach(@CoordInfoArrayTmp){
	
		my @Line = split(",",$_);
		
		#print "Line: $_\n";
				
		my $O1 = $Line[1];  my $O2 = $Line[2];  my $O3 = $Line[3];
		my $A1 = $O1;       my $A2 = $O2;       my $A3 = $O3;
		my $B1 = $Line[10]; my $B2 = $Line[11]; my $B3 = $Line[12];
		my $C1 = $Line[4];  my $C2 = $Line[5];  my $C3 = $Line[6];

		my $MAGNITUDE_B = sqrt($B1**2+$B2**2+$B3**2);
		
		my $X2 = $B1*$AB/$MAGNITUDE_B; my $Y2 = $B2*$AB/$MAGNITUDE_B; my $Z2 = $B3*$AB/$MAGNITUDE_B;

		my $MAGNITUDE_C = sqrt($C1**2+$C2**2+$C3**2);
		
		my $X3 = $C1*$AC/$MAGNITUDE_C; my $Y3 = $C2*$AC/$MAGNITUDE_C; my $Z3 = $C3*$AC/$MAGNITUDE_C;

		# Redefining A, B and C points (as in bdf entry)
		
		$B1 = $X2; $B2 = $Y2; $B3 = $Z2;
		$C1 = $X3; $C2 = $Y3; $C3 = $Z3;
		
		$A1 = sprintf("%.6f", $A1); $A2 = sprintf("%.6f", $A2); $A3 = sprintf("%.6f", $A3);
		$B1 = sprintf("%.6f", $B1); $B2 = sprintf("%.6f", $B2); $B3 = sprintf("%.6f", $B3);
		$C1 = sprintf("%.6f", $C1); $C2 = sprintf("%.6f", $C2); $C3 = sprintf("%.6f", $C3);
		
		$CoordInfoArrayTmp2[$CIAT2Cnt] = "$Line[0],$A1,$A2,$A3,$B1,$B2,$B3,$C1,$C2,$C3";
		$CIAT2Cnt++;
	}
		
	@CoordInfoArray = (@CoordInfoArray,@CoordInfoArrayTmp2); # Adding new coordinates defined by the user to the list
	
	#$CoordInfoArrayTmp[$CIATCnt] = "$Line[0],$O1,$O2,$O3,$C1,$C2,$C3,$A1,$A2,$A3,$B1,$B2,$B3";
	
	my @array = ();
	
	foreach(@CoordInfoArray){
		
		my $line = $_;
		my @LineArray = split ",", $line;
		
		push @array, [$line, $LineArray[0]];
	}

	@array = map {$_->[0]}
		 sort {$a->[1] <=> $b->[1]}
		 @array;
	
	@CoordInfoArray = @array;	# Sorted @CoordInfoArray
	
	for(my $i = 0; $i <= $#CoordInfoArray; $i++){
	
		my @Line = split ",", $CoordInfoArray[$i];

		$CoordIDArray[$i] = $Line[0];
		$CoordA1Array[$i] = $Line[1]; $CoordA2Array[$i] = $Line[2]; $CoordA3Array[$i] = $Line[3];
		$CoordB1Array[$i] = $Line[4]; $CoordB2Array[$i] = $Line[5]; $CoordB3Array[$i] = $Line[6];
		$CoordC1Array[$i] = $Line[7]; $CoordC2Array[$i] = $Line[8]; $CoordC3Array[$i] = $Line[9];
	}
	
	#for (my $i = 0; $i <= $#CoordInfoArray; $i++) {
        
                #print "CoordInfoArray: $CoordInfoArray[$i]\n";
                #print  "$CoordIDArray[$i] $CoordA1Array[$i] $CoordA2Array[$i] $CoordA3Array[$i] $CoordB1Array[$i] $CoordB2Array[$i] $CoordB3Array[$i] $CoordC1Array[$i] $CoordC2Array[$i] $CoordC3Array[$i]\n";
	
        #}						
}

# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : calculatePointsDistance	                  		  *
# INTERNAL SUB FUNCTION PURPOSE : This function calculates the distance between two points.	  *
#				  it receives X, Y and Zs of two points and returns the distance  *
#				  between them.						    	  *
#												  *
# *************************************************************************************************

sub calculatePointsDistance {

	# Private Variables:	 
	my $DISTANCE = 0;
		
	$DISTANCE = sqrt(($_[3] - $_[0])**2 + 
		   	 ($_[4] - $_[1])**2 + 
		   	 ($_[5] - $_[2])**2);			
	
	return $DISTANCE;
}


# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : calculateCosineFormulaAngle	                  		  *
# INTERNAL SUB FUNCTION PURPOSE : This function calculates the angle between two vectors.	  *
#				  it receives X, Y and Zs of three points and returns the angle	  *
#				  between them in radian and the magnitude of the vectors    	  *
#												  *
# *************************************************************************************************

sub calculateCosineFormulaAngle {

	# Private Variables:	 
	my $AB = 0;
	my $AC = 0;
	my $BC = 0;

	my $A1 = $_[0]; my $A2 = $_[1]; my $A3 = $_[2];
	my $B1 = $_[3]; my $B2 = $_[4]; my $B3 = $_[5];
	my $C1 = $_[6]; my $C2 = $_[7]; my $C3 = $_[8];
	
	my $COSTHETA = 0;
	my $RADTHETA = 0;	   
	
	$AB = calculatePointsDistance($A1, $A2, $A3, $B1, $B2, $B3);				
	$AC = calculatePointsDistance($A1, $A2, $A3, $C1, $C2, $C3); 			   		
	$BC = calculatePointsDistance($B1, $B2, $B3, $C1, $C2, $C3);
	
	#print ("2. AB $AB AC $AC BC $BC\n");
	
	if($AB == 0 || $AC == 0){
	
		print ("Division by zero not allowed in calculateVectorsAngle subroutine\n");	
	}else{
		$COSTHETA = ($AB**2 + $AC**2 - $BC**2) / (2 * $AB * $AC);
	}
	
	$RADTHETA = acos($COSTHETA);
	
	my @ReturnArray = ($RADTHETA, $AB, $AC, $BC);
	
	return \@ReturnArray;
}


# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : calculateVectorsAngle		                  		  *
# INTERNAL SUB FUNCTION PURPOSE : This function calculates the angle between two vectors.	  *
#				  it receives X, Y and Zs of the origin $A1, $A2, $A3 a point     *
#				  defining u vector $B1, $B2, $B3 and a point defining v vector   *
#				  $C1, $C2, $C3							  *
#				  and it returns the angle between the two vectors 		  *
#				  in radian and degrees						  *
#												  *
# *************************************************************************************************

sub calculateVectorsAngle {

	# Private Variables:	 
	#print CODE "********** Inside calculateVectorsAngle\n";
	my $A1 = $_[0]; my $A2 = $_[1];  my $A3 = $_[2];
	my $B1 = $_[3]; my $B2 = $_[4];  my $B3 = $_[5];
	my $C1 = $_[6]; my $C2 = $_[7];  my $C3 = $_[8];
	my $N1 = $_[9]; my $N2 = $_[10]; my $N3 = $_[11];
	
	#print CODE "N1 $N1 N2 $N2 N3 $N3\n";
	
	my @CroosProductArray = ();
	
	my $uSqrt = 0;
	my $vSqrt = 0;
	
	my $signed_angle = 0;
	my $x = 0; # input values for atan2 function
	my $y = 0;

	my $dotProduct = 0;	
	my $degAngle = 0;
	my $radAngle = 0;
	my $angleSign = 0;
		
	my @ReturnArray = ();
	
	my $a1 = $B1 - $A1; my $a2 = $B2 - $A2; my $a3 = $B3 - $A3;
	my $b1 = $C1 - $A1; my $b2 = $C2 - $A2; my $b3 = $C3 - $A3;

	#print CODE "u =" . "$a1" . "i +" . "$a2" . "j +" . "$a3" . "k\n";
	#print CODE "v =" . "$b1" . "i +" . "$b2" . "j +" . "$b3" . "k\n";

	# $u = $a1*i + $a2*j + $a3*k;
	# $v = $b1*i + $b2*j + $b3*k;
	
	# sqrt(|u|^2) = sqrt($a1^2 + $a2^2 + $a3^2);
	# sqrt(|v|^2) = sqrt($b1^2 + $b2^2 + $b3^2);
	
	$uSqrt = sqrt($a1**2 + $a2**2 + $a3**2);
	$vSqrt = sqrt($b1**2 + $b2**2 + $b3**2);
	
	#print CODE "uSqrt $uSqrt vSqrt $vSqrt\n";
	
	# Normalising u and v vectors using $uSqrt and $vSqrt:
	
	if($uSqrt > 0 && $vSqrt > 0){
		
		@CroosProductArray = @{crossPruduct( $A1, $A2, $A3, 
			      			     $a1, $a2, $a3,
			      			     $b1, $b2, $b3 );}; # Make a copy of the return array		

		
		my $SizeCPA = @CroosProductArray;
		
		#foreach(@CroosProductArray){
			#print CODE "CVA: Cross product $_\n";
		#}
		
		if($SizeCPA == 1 && ($CroosProductArray[0] == 1 || $CroosProductArray[0] == -1)){
			
			# if the two vectors are in the same or opposite direction crossProduct subroutine returns 1 or -1
			
			if($CroosProductArray[0] == 1){
			
				@ReturnArray = (0, 0);
				
			}elsif($CroosProductArray[0] == -1){
			
				@ReturnArray = (deg2rad(180), 180);
			}	
		
		}else{
		
			# signed_angle = atan2(  N * ( V1 x V2 ), V1 * V2  );
			# where * is dot product and x is cross product
			# N is the normal to the polygon
			# N, V1, V2 are normalized

			# signed_angle = atan2(  N * ( u x v ), u * v  );
			# where * is dot product and x is cross product
			# N is the normal vector to the u and v vectors
			# If the cross product of u and v vectors is in the same direction as the
			# normal vector, $signed_angle will be zero, if the cross product is
			# in the opposite direction of the normal vector then the $signed_angle will be
			# 180 degrees. Thus we can determine the sign of the angle. If the $signed_angle
			# is zero then the sign is positive, if $signed_angle is 180 degrees then the sign
			# will be negative.
		
			# DO NOT NORMALISE N vector
	
			# 1. N * (u x v)
		
			# dot Product of cross product vector and N vector
			
			
		
			$x = $N1 * $CroosProductArray[0] + $N2 * $CroosProductArray[1] + $N3 * $CroosProductArray[2];
		
			#print CODE "CVA: x = $x\n";
			#print CODE "CVA: CPArray-> $CroosProductArray[0], $CroosProductArray[1], $CroosProductArray[2]\n";
			#print CODE "CVA: NArray(N1,N2,N3)-> $N1, $N2, $N3]\n";
			
			# 2. u * v

			# dot Pruduct of normalised u and v vectors
			# u * v

			$dotProduct = dotPruduct( $A1, $A2, $A3, 
					      	  $B1, $B2, $B3,
					      	  $C1, $C2, $C3 );		      	  		

			$dotProduct = $dotProduct / ($uSqrt * $vSqrt);
			
			#print CODE "CVA: dotProduct $dotProduct\n";
			
			# acos($dotProduct) gives the angle between two vectors where
			# dot product of two vectors is used for this calculation
		
			$radAngle = acos($dotProduct);
			$degAngle = rad2deg($radAngle);
						
			$y = $dotProduct;
		
			# The range for atan2 in Perl is in the range -pi +pi, whereas in C++ it is +pi -pi
		
			$signed_angle = atan2($y, $x);

			# Converting radians to degrees
		
			$signed_angle = rad2deg($signed_angle);
		
			# Rounding the signed angle to make sure that the following if..else condition works
			
			$signed_angle = round($signed_angle);
			
			#print CODE "CVA: signed_angle $signed_angle\n";
		
			if($signed_angle == 0){
		
				$angleSign = 1;
			
			}elsif($signed_angle == -0){
		
		 		$angleSign = 1;
				
			}elsif($signed_angle == 180){
		
		 		$angleSign = -1;
				
			}elsif($signed_angle == -180){
		
		 		$angleSign = -1;
			}
		
			# Calculated angle between u and v vectors in radian
		
			$radAngle = $angleSign * $radAngle;
		
			# Calculated angle between u and v vectors in degrees
		
			$degAngle = $angleSign * $degAngle;
			
			#print CODE "CVA: radAngle $radAngle degAngle $degAngle\n";
		
			@ReturnArray = ($radAngle, $degAngle);
		}
		
	}else{
		 # Division by zero is not allowed. subroutine returns zero.
		 
		 @ReturnArray = (0);
	}	
			
	return \@ReturnArray;
}

# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : directionalcrossPruduct	                  		  *
# INTERNAL SUB FUNCTION PURPOSE : This function finds the cross product of two vectors (u and v)  *
#				  and returns the magnitude (unit) and the direction of the unit  *
#				  cross product (u x v) - $x, $y & $z input and output is 	  *
#				  directional. This cross product algorithm is used for creating  *
#				  reference axis systems					  *
#												  *
# *************************************************************************************************

sub directionalcrossPruduct {
	
	#print CODE ("\n************ sub crossPruduct *************\n");

	# Private Variables: 

	my $X = $_[0];  my $Y = $_[1];  my $Z = $_[2];
	
	my $A1 = 0;     my $A2 = 0;     my $A3 = 0;
	my $B1 = $_[3]; my $B2 = $_[4]; my $B3 = $_[5];
	my $C1 = $_[6]; my $C2 = $_[7]; my $C3 = $_[8];
	
	my $DET1 = 0;
	my $DET2 = 0;
	my $DET3 = 0;
	
	my @CrossProduct = ();
	my @ReturnArray = ();
	
	#print CODE ("\ncross product three points\n");
	#print CODE ("A1 $A1 A2 $A2 A3 $A3\n");
	#print CODE ("B1 $B1 B2 $B2 B3 $B3\n");
	#print CODE ("C1 $C1 C2 $C2 C3 $C3\n");
		
	my $a1 = $B1 - $A1; my $a2 = $B2 - $A2; my $a3 = $B3 - $A3;
	my $b1 = $C1 - $A1; my $b2 = $C2 - $A2; my $b3 = $C3 - $A3;

	#print "u =" . "$a1" . "i + " . "$a2" . "j + " . "$a3" . "k\n";
	#print "v =" . "$b1" . "i + " . "$b2" . "j + " . "$b3" . "k\n";

	# $u = $a1*i + $a2*j + $a3*k;
	# $v = $b1*i + $b2*j + $b3*k;

	$DET1 = ($a2 * $b3) - ($a3 * $b2);
	$DET2 = ($a3 * $b1) - ($a1 * $b3);
	$DET3 = ($a1 * $b2) - ($a2 * $b1);	
		
	if( ( (($a1 > 0  && $b1 > 0) || ($a1 < 0  && $b1 < 0)) && $DET1 == 0 && $DET2 == 0 && $DET3 == 0 ) ||   
	    ( (($a2 > 0  && $b2 > 0) || ($a2 < 0  && $b2 < 0)) && $DET1 == 0 && $DET2 == 0 && $DET3 == 0 ) ||
	    ( (($a3 > 0  && $b3 > 0) || ($a3 < 0  && $b3 < 0)) && $DET1 == 0 && $DET2 == 0 && $DET3 == 0 ) ){
		
		# This means that two vectors are in the same direction.
		# If this is the case then program returns 1
		
		@ReturnArray = (1);
		
		#foreach(@ReturnArray){
		
			#print "$_\n";
		
		#}
		
	}elsif( ( (($a1 > 0  && $b1 < 0) || ($a1 < 0  && $b1 > 0)) && $DET1 == 0 && $DET2 == 0 && $DET3 == 0 ) ||   
	        ( (($a2 > 0  && $b2 < 0) || ($a2 < 0  && $b2 > 0)) && $DET1 == 0 && $DET2 == 0 && $DET3 == 0 ) ||
	        ( (($a3 > 0  && $b3 < 0) || ($a3 < 0  && $b3 > 0)) && $DET1 == 0 && $DET2 == 0 && $DET3 == 0 ) ){
	
		# This means that two vectors are in the opposite direction.
		# If this is the case then program returns -1
		
		@ReturnArray = (-1);
		
		#foreach(@ReturnArray){
		
			#print "$_\n";
		#} 
	
	}else{
	
		$DET1 = sprintf("%.9f", $DET1);
		$DET2 = sprintf("%.9f", $DET2);
		$DET3 = sprintf("%.9f", $DET3);
		
		@CrossProduct = ($DET1, $DET2, $DET3);
		 
		#print CODE ("crossPr: DET1 $DET1 DET2 $DET2 DET3 $DET3 A1 $A1 A2 $A2 A2 $A2\n");
	
		@ReturnArray = ($DET1, $DET2, $DET3);
		
		#foreach(@ReturnArray){
		
			#print "$_\n";
		
		#}
	}
	
	return \@ReturnArray;
}


# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : dotPruduct			                  		  *
# INTERNAL SUB FUNCTION PURPOSE : This function finds the cross product of two vectors (u and v)  *
#				  and returns the magnitude and the direction of the cross	  *
#				  product (u x v) - $x, $y & $z					  *
#												  *
# *************************************************************************************************

sub dotPruduct {
	
	#print CODE ("\n************ sub dotPruduct *************\n");
	
	# Private Variables:
	
	my $A1 = $_[0]; my $A2 = $_[1]; my $A3 = $_[2];
	my $B1 = $_[3]; my $B2 = $_[4]; my $B3 = $_[5];
	my $C1 = $_[6]; my $C2 = $_[7]; my $C3 = $_[8];
							   
	#print CODE ("\n\nInside dot product subroutine\n\n");
	#print CODE ("A1 $A1 A2 $A2 A3 $A3\n");
	#print CODE ("B1 $B1 B2 $B2 B3 $B3\n");
	#print CODE ("C1 $C1 C2 $C2 C3 $C3\n");
		
	my $a1 = $B1 - $A1; my $a2 = $B2 - $A2; my $a3 = $B3 - $A3;
	my $b1 = $C1 - $A1; my $b2 = $C2 - $A2; my $b3 = $C3 - $A3;

	my $dotProduct = 0;
	
	# u * v = $a1 * $b1 + $a2 * $b2 + $a3 * $b3;
	
	$dotProduct = $a1 * $b1 + $a2 * $b2 + $a3 * $b3;
	
	#print CODE "dP: dotProduct $dotProduct\n";
	
	return $dotProduct;
}



# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : crossPruduct			                  		  *
# INTERNAL SUB FUNCTION PURPOSE : This function finds the cross product of two vectors (u and v)  *
#				  and returns the magnitude and the direction of the cross	  *
#				  product (u x v) - $x, $y & $z					  *
#												  *
# *************************************************************************************************

sub crossPruduct {
	
	#print CODE ("\n************ sub crossPruduct *************\n");

	# Private Variables: 

	my $A1 = $_[0]; my $A2 = $_[1]; my $A3 = $_[2];
	my $B1 = $_[3]; my $B2 = $_[4]; my $B3 = $_[5];
	my $C1 = $_[6]; my $C2 = $_[7]; my $C3 = $_[8];

	my $uSqrt = 0;
	my $vSqrt = 0;
	
	my $DET1 = 0;
	my $DET2 = 0;
	my $DET3 = 0;

	my $uv1 = 0;	# Cross Product Vector
	my $uv2 = 0;
	my $uv3 = 0;
	
	my @CrossProduct = ();
	my @ReturnArray = ();
	
	#print CODE ("\ncross product three points\n");
	#print CODE ("A1 $A1 A2 $A2 A3 $A3\n");
	#print CODE ("B1 $B1 B2 $B2 B3 $B3\n");
	#print CODE ("C1 $C1 C2 $C2 C3 $C3\n");
		
	my $a1 = $B1 - $A1; my $a2 = $B2 - $A2; my $a3 = $B3 - $A3;
	my $b1 = $C1 - $A1; my $b2 = $C2 - $A2; my $b3 = $C3 - $A3;

	#print CODE "u =" . "$a1" . "i +" . "$a2" . "j +" . "$a3" . "k\n";
	#print CODE "v =" . "$b1" . "i +" . "$b2" . "j +" . "$b3" . "k\n";

	# $u = $a1*i + $a2*j + $a3*k;
	# $v = $b1*i + $b2*j + $b3*k;
	
	# sqrt(|u|^2) = sqrt($a1^2 + $a2^2 + $a3^2);
	# sqrt(|v|^2) = sqrt($b1^2 + $b2^2 + $b3^2);
	
	$uSqrt = sqrt($a1**2 + $a2**2 + $a3**2);
	$vSqrt = sqrt($b1**2 + $b2**2 + $b3**2);
	
	#print CODE ("crossPr: uSqrt $uSqrt vSqrt $vSqrt\n");
	
	# Normalised u and v vectors:
	
	if($uSqrt > 0 && $vSqrt > 0){
		
		$a1 = $a1/$uSqrt; $a2 = $a2/$uSqrt; $a3 = $a3/$uSqrt;
		$b1 = $b1/$vSqrt; $b2 = $b2/$vSqrt; $b3 = $b3/$vSqrt;

		#print CODE ("crossPr: a1 $a1 a2 $a2 a3 $a3\nb1 $b1 b2 $b2 b3 $b3\n");
		
		$DET1 = ($a2 * $b3) - ($a3 * $b2);
		$DET2 = ($a3 * $b1) - ($a1 * $b3);
		$DET3 = ($a1 * $b2) - ($a2 * $b1);
		
		if( ( (($a1 > 0  && $b1 > 0) || ($a1 < 0  && $b1 < 0)) && $DET1 == 0 && $DET2 == 0 && $DET3 == 0 ) ||   
		    ( (($a2 > 0  && $b2 > 0) || ($a2 < 0  && $b2 < 0)) && $DET1 == 0 && $DET2 == 0 && $DET3 == 0 ) ||
		    ( (($a3 > 0  && $b3 > 0) || ($a3 < 0  && $b3 < 0)) && $DET1 == 0 && $DET2 == 0 && $DET3 == 0 ) ){
			
			# This means that two vectors are in the same direction.
			# If this is the case then program returns 1
			
			@ReturnArray = (1);
			
		}elsif( ( (($a1 > 0  && $b1 < 0) || ($a1 < 0  && $b1 > 0)) && $DET1 == 0 && $DET2 == 0 && $DET3 == 0 ) ||   
		        ( (($a2 > 0  && $b2 < 0) || ($a2 < 0  && $b2 > 0)) && $DET1 == 0 && $DET2 == 0 && $DET3 == 0 ) ||
		        ( (($a3 > 0  && $b3 < 0) || ($a3 < 0  && $b3 > 0)) && $DET1 == 0 && $DET2 == 0 && $DET3 == 0 ) ){
		
			# This means that two vectors are in the opposite direction.
			# If this is the case then program returns -1
			
			@ReturnArray = (-1);
		
		}else{
		
			# Normalised Cross Pruduct
			# u x v
		
			#print CODE ("crossPr: DET1 $DET1 DET2 $DET2 DET3 $DET3 A1 $A1 A2 $A2 A2 $A2\n");

			$uv1 = $DET1 + $A1;
			$uv2 = $DET2 + $A2;
			$uv3 = $DET3 + $A3;
		
			$uv1 = sprintf("%.9f", $uv1);
			$uv2 = sprintf("%.9f", $uv2);
			$uv3 = sprintf("%.9f", $uv3);
			
			@CrossProduct = ($uv1, $uv2, $uv3);

			# a Point on the Cross Pruduct Vector u x v at Coord 0

			$DET1 = $DET1 * ($uSqrt + $vSqrt);
			$DET2 = $DET2 * ($uSqrt + $vSqrt);
			$DET3 = $DET3 * ($uSqrt + $vSqrt);

			$DET1 = sprintf("%.9f", $DET1);
			$DET2 = sprintf("%.9f", $DET2);
			$DET3 = sprintf("%.9f", $DET3);

			# a Point on the Cross Pruduct Vector u x v at Reference Coord Frame
	
			$uv1 = $DET1 + $A1;
			$uv2 = $DET2 + $A2;
			$uv3 = $DET3 + $A3;

			#print CODE ("crossPr: DET1 $DET1 DET2 $DET2 DET3 $DET3 A1 $A1 A2 $A2 A2 $A2\n");
		
			@ReturnArray = (@CrossProduct, $uv1, $uv2, $uv3);
		
		}
		
	}else{
		# Division by zero is not allowed. subroutine returns zero.
		
		@ReturnArray = (0);
	}		

	return \@ReturnArray;
}


# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : moveCoordToCoord0		                  		  *
# INTERNAL SUB FUNCTION PURPOSE : This function moves X, Y, Z of the given coord to Coord 0	  *
#				  this is necassary for the coord transformation. After moving	  *
#				  coordinate is redifined in Coord 0. It receives 		  *
#				  (Coord id, A1, A2, A3, B1, B2, B3, C1, C2, C3) and it returns	  *
#				  (Coord id, A1, A2, A3, B1, B2, B3, C1, C2, C3) moved to Coord 0 * 
#												  *
# *************************************************************************************************

sub moveCoordToCoord0 {
	
	# Private Variables: 
	my $CoordID = $_[0];

	my $A1 = 0; my $A2 = 0; my $A3 = 0;
	my $B1 = 0; my $B2 = 0; my $B3 = 0;
	my $C1 = 0; my $C2 = 0; my $C3 = 0;

	my $COORD0A1 = 0; my $COORD0A2 = 0; my $COORD0A3 = 0;
	my $COORD0B1 = 0; my $COORD0B2 = 0; my $COORD0B3 = 0;
	my $COORD0C1 = 0; my $COORD0C2 = 0; my $COORD0C3 = 0;
	
	$A1 = $_[1]; $A2 = $_[2]; $A3 = $_[3];
	$B1 = $_[4]; $B2 = $_[5]; $B3 = $_[6];
	$C1 = $_[7]; $C2 = $_[8]; $C3 = $_[9];
	
	#print CODE ("******** Inside moveCoordToCoord0 *********\n");
	#print CODE ("******** Before the substraction *********\n");
	
	#print CODE ("A1 $A1 A2 $A2 A3 $A3\n");
	#print CODE ("B1 $B1 B2 $B2 B3 $B3\n");
	#print CODE ("C1 $C1 C2 $C2 C3 $C3\n");
	
	# u = a1i + a2j + a3k;
	# v = b1i + b2j + b3k;
	
	$COORD0A1 = $A1 - $A1; $COORD0A2 = $A2 - $A2; $COORD0A3 = $A3 - $A3;
	$COORD0B1 = $B1 - $A1; $COORD0B2 = $B2 - $A2; $COORD0B3 = $B3 - $A3;
	$COORD0C1 = $C1 - $A1; $COORD0C2 = $C2 - $A2; $COORD0C3 = $C3 - $A3;

	#print CODE ("******** After the substraction *********\n");
	
	#print CODE ("A1 $A1 A2 $A2 A3 $A3\n");
	#print CODE ("B1 $B1 B2 $B2 B3 $B3\n");
	#print CODE ("C1 $C1 C2 $C2 C3 $C3\n");

	#print ("a1 $a1 a2 $a2 a3 $a3\n");
	#print ("b1 $b1 b2 $b2 b3 $b3\n");
			
	my @ReturnArray = ($CoordID, $COORD0A1, $COORD0A2, $COORD0A3, $COORD0B1, $COORD0B2, $COORD0B3, $COORD0C1, $COORD0C2, $COORD0C3);

	return \@ReturnArray;
}

# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : checkTransCoord				                  *
# INTERNAL SUB FUNCTION PURPOSE : This function is a checkup function to see if the program is    *
#				  working properly. It is intended only for the programmer, not   *
#				  the user.							  *
#												  *
# *************************************************************************************************

sub checkTransCoord {

	my @TransMatrixA = (1, 0, 0, 0,	# Local transformation matrix A
		            0, 1, 0, 0,	
		    	    0, 0, 1, 0,
		    	    0, 0, 0, 1);

	my @TransMatrixB = (1, 0, 0, 0,	# Local transformation matrix B
		            0, 1, 0, 0,	
		    	    0, 0, 1, 0,
		    	    0, 0, 0, 1);

	my $ux = $_[2];  # Vector values defined in grid analysis coordinate and will be transferred to
	my $uy = $_[3];  # reference coordinate frame
	my $uz = $_[4];
	my $scale = $_[5];

	my @TransVectorInputArray = ($ux, $uy, $uz, $scale);
	my @TransVectorOutputArray = (0, 0, 0, 0);
	
	my @VectorArrayInCoord0 = (0, 0, 0, 0);
			
		# lets say you are transferring results based on coordinate 1 to reference coordinate 2
		# first we need to calculate the transformation matrix for the transformation from Coord 0
		# to Coord 1, then solve the vector using gaussianEliminationMethod() and then get the vector
		# values in Coordinate 0, this means that we transferred the vector from coord. 1 to coord 0.
		# Now we need to transfer from Coord 0 to Coord 2, for this we need to create a transformation
		# matrix for this transformation.
		
		# 1. First we need to calculate the transformation matrix for the transformation from Coord 0
		# to Coord 1 
			
		@TransMatrixA = @{createTransMatrix(0, $_[1]);}; # Make a copy of the return array			

		# 2. Then solve the vector using gaussianEliminationMethod() and then get the vector
		# values in Coordinate 0
		
		@VectorArrayInCoord0 = @{gaussianEliminationMethod(@TransMatrixA,@TransVectorInputArray);}; # Make a copy of the return array
		
		# 3. Now we need to transfer from Coord 0 to Coord 2, for this we need to create a transformation
		# matrix for this transformation.
		
		#@TransMatrixB = @{createTransMatrix(0, $_[1]);}; # Make a copy of the return array	
		
		#@TransVectorOutputArray = @{calculateTransVector(@TransMatrixB,@VectorArrayInCoord0);};
		
		# 4. Return vector values in Coord. 2
				
		#foreach(@TransMatrixA){
		
			#print CODE ("TransMatrixA: $_\n");
		#}

		#foreach(@TransMatrixB){
		
			#print CODE ("TransMatrixB: $_\n");
		#}
				
		#print CODE ("************ TransVectorOutputArray:\n");
		
		#foreach(@VectorArrayInCoord0){
		
			#print CODE ("VectorArrayInCoord0: $_\n");
		#}

	
	return \@TransVectorOutputArray;		
}

# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : transCoord					                  *
# INTERNAL SUB FUNCTION PURPOSE : This function transfers a vector from one coordinate to another *
#				  it receives (From Coord id, To Coord id, ux, uy, uz, scale)	  *
#				  uy, uy and uz are vectors defined in From Coord id and will be  *
#				  transferred to To Coord id. It returns ux, uy, uz in the 	  *
#				  coordinate system						  *
#												  *
# *************************************************************************************************

sub transCoord {

	my @TransMatrixA = (1, 0, 0, 0,	# Local transformation matrix A
		            0, 1, 0, 0,	
		    	    0, 0, 1, 0,
		    	    0, 0, 0, 1);

	my @TransMatrixB = (1, 0, 0, 0,	# Local transformation matrix B
		            0, 1, 0, 0,	
		    	    0, 0, 1, 0,
		    	    0, 0, 0, 1);

	my $ux = $_[2];  # Vector values defined in grid analysis coordinate and will be transferred to
	my $uy = $_[3];  # reference coordinate frame
	my $uz = $_[4];
	my $scale = $_[5];

	my @TransVectorInputArray = ($ux, $uy, $uz, $scale);
	my @TransVectorOutputArray = (0, 0, 0, 0);
	
	my @VectorArrayInCoord0 = (0, 0, 0, 0);
	
	if($_[0] > 0 && $_[1] > 0){ # If both coordinates are bigger than zero do the following transformation,
		
		# lets say you are transferring results based on coordinate 1 to reference coordinate 2
		# first we need to calculate the transformation matrix for the transformation from Coord 0
		# to Coord 1, then solve the vector using gaussianEliminationMethod() and then get the vector
		# values in Coordinate 0, this means that we transferred the vector from coord. 1 to coord 0.
		# Now we need to transfer from Coord 0 to Coord 2, for this we need to create a transformation
		# matrix for this transformation.
		
		# 1. First we need to calculate the transformation matrix for the transformation from Coord 0
		# to Coord 1 
			
		@TransMatrixA = @{createTransMatrix(0, $_[0]);}; # Make a copy of the return array			

		# 2. Then solve the vector using gaussianEliminationMethod() and then get the vector
		# values in Coordinate 0
		
		@VectorArrayInCoord0 = @{gaussianEliminationMethod(@TransMatrixA,@TransVectorInputArray);}; # Make a copy of the return array
		
		# 3. Now we need to transfer from Coord 0 to Coord 2, for this we need to create a transformation
		# matrix for this transformation.
		
		@TransMatrixB = @{createTransMatrix(0, $_[1]);}; # Make a copy of the return array	
		
		@TransVectorOutputArray = @{calculateTransVector(@TransMatrixB,@VectorArrayInCoord0);};
		
		# 4. Return vector values in Coord. 2
				
		#foreach(@TransMatrixA){
		
			#print CODE ("TransMatrixA: $_\n");
		#}

		#foreach(@TransMatrixB){
		
			#print CODE ("TransMatrixB: $_\n");
		#}
				
		#print CODE ("************ TransVectorOutputArray:\n");
		
		#foreach(@TransVectorOutputArray){
		
			#print CODE ("TransVectorOutputArray: $_\n");
		#}
						
	}elsif($_[0] > 0 && $_[1] == 0){ # If "To coord id = Coord 0"
		
		# lets say you are transferring results based on coordinate 1 to reference coordinate 0
		# first we need to calculate the transformation matrix for the transformation from Coord 0
		# to Coord 1, then solve the vector using gaussianEliminationMethod() and then get the vector
		# values in Coordinate 0, this means that we transferred the vector from coord. 1 to coord 0.
		
		# 1. First we need to calculate the transformation matrix for the transformation from Coord 0
		# to Coord 1
			
		@TransMatrixA = @{createTransMatrix(0, $_[0]);}; # Make a copy of the return array			

		# 2. Then solve the vector using gaussianEliminationMethod() and then get the vector
		# values in Coordinate 0
		
		@VectorArrayInCoord0 = @{gaussianEliminationMethod(@TransMatrixA,@TransVectorInputArray);}; # Make a copy of the return array
		
		# 3. Now we need to return the @VectorArrayInCoord0
				
		@TransVectorOutputArray = @VectorArrayInCoord0;
		
		# 4. Return vector values in Coord. 0
				
		#foreach(@TransMatrixA){
		
			#print CODE ("TransMatrixA: $_\n");
		#}

		#foreach(@TransMatrixB){
		
			#print CODE ("TransMatrixB: $_\n");
		#}
				
		#print CODE ("************ TransVectorOutputArray:\n");
		
		#foreach(@TransVectorOutputArray){
		
			#print CODE ("TransVectorOutputArray: $_\n");
		#}
						
	}elsif($_[0] == 0 && $_[1] > 0){

		# lets say you are transferring results based on coordinate 0 to reference coordinate 1
		# first we need to calculate the transformation matrix for the transformation from Coord 0
		# to Coord 1, then pass the @TransMatrixA matrix and @VectorArrayInCoord0 (vector values
		# based on Coord 0) into calculateTransVector subroutine
		
		# 1. First we need to calculate the transformation matrix for the transformation from Coord 0
		# to Coord 1 
			
		@TransMatrixA = @{createTransMatrix(0, $_[1]);}; # Make a copy of the return array			

		# 2. Now we need pass @TransMatrixA and @VectorArrayInCoord0 into calculateTransVector
				
		@TransVectorOutputArray = @{calculateTransVector(@TransMatrixA,@TransVectorInputArray);};		
	}
	
	return \@TransVectorOutputArray;		
}

# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : calculateTransVector				                  *
# INTERNAL SUB FUNCTION PURPOSE : This function multiplies Transformation matrix with a vector	  *
#				  it receives (@TransMatrixA, ux, uy, uz)	  		  *
#				  X, Y and Z are points (vector) defined in From Coord id and     *
#				  will be transferred to To Coord id. It returns ux, uy, uz in the*
#				  new coordinate system						  *
#												  *
# *************************************************************************************************

sub calculateTransVector {

	my @TransMatrixA = ($_[0],  $_[1],  $_[2],  $_[3],	# Local transformation matrix A
		            $_[4],  $_[5],  $_[6],  $_[7],	
		    	    $_[8],  $_[9],  $_[10], $_[11],
		    	    $_[12], $_[13], $_[14], $_[15]);
			    
	my $ux0 = $_[16];  # Vector values defined in Coord 0 and will be transferred to
	my $uy0 = $_[17];  # reference coordinate frame
	my $uz0 = $_[18];
	my $scale = $_[19];
	
	my @TransVectorInputArray = ($ux0, $uy0, $uz0, $scale);
	
	my @TransVectorOutputArray = (0, 0, 0, 0);

	#print CODE ("************ Printing TransMatrixA:\n");

	my $j = 0;

	for(my $i = 0; $i < 4 ; $i++) {
					
		$TransVectorOutputArray[$i] = 	$TransMatrixA[$j]   * $TransVectorInputArray[0] + 
						$TransMatrixA[$j+1] * $TransVectorInputArray[1] + 
				    		$TransMatrixA[$j+2] * $TransVectorInputArray[2] + 
						$TransMatrixA[$j+3] * $TransVectorInputArray[3];
	
		$j = $j + 4;
	}

	
	#foreach(@TransMatrixA){
		
		#print("TransMatrixA: $_\n");
	#}
		
	#print("************ TransVectorOutputArray:\n");
		
	#foreach(@TransVectorOutputArray){
		
		#print("TransVectorOutputArray: $_\n");
	#}
	
	return \@TransVectorOutputArray;
								
}

# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : gaussianEliminationMethod			                  *
# INTERNAL SUB FUNCTION PURPOSE : This function solves for unkown vector values defined in        *
#				  Coord 0. it receives (@TransMatrixA, ux, uy, uz) where	  *
#				  TransMatrixA is 4 x 4 transformation matrix for the		  *
# 				  transformation from Coordinate Frame Zero (Coord 0) to 	  *
# 				  Reference Coordinate Frame (Coord Ref)			  *
# 				  ux, uy and uz are vectors defined in From Coord id (Reference   *
# 				  Coordinate Frame). Solution will give the ux, uy and uz in 	  * 
#				  Coordinate Frame Zero (Coord 0). The subroutine returns @x      *
#				  where A � x = b, A is 4 x 4 matrix, @b array contains 	  *
#				  ux, uy, uz defined in Coord Ref, and @x contains ux', uy', uz'  *
#				  defined in Coord 0. @x = (ux', uy', uz', 1)			  *
#												  *
# *************************************************************************************************

sub gaussianEliminationMethod{

# *******************************************************************************************
# Gaussian Elimintion Method to solve N number of linear algebraic equations with N number
# of unknowns
#
# Consider a set of linear algebraic equations
#
# a11x1 + a12x2 + a13x3 + � � � + a1NxN = b1
# a21x1 + a22x2 + a23x3 + � � � + a2NxN = b2
# a31x1 + a32x2 + a33x3 + � � � + a3NxN = b3
# � � � � � �
# aM1x1 + aM2x2 + aM3x3 + � � � + aMNxN = bM
#
# Here the N unknowns xj , j = 1, 2, . . .,N are related by M equations. The
# coefficients aij with i = 1, 2, . . .,M and j = 1, 2, . . .,N are known numbers, as
# are the right-hand side quantities bi, i = 1, 2, . . .,M.
#
# The Equation above can be written in matrix form as
#
# A � x = b
#
# dot denotes matrix multiplication, A is the matrix of coefficients, and
# b is the right-hand side written as a column vector,
#
# A =  a11 a12 . . . a1N
#      a21 a22 . . . a2N
#      � � �
#      aM1 aM2 . . . aMN
#
# b = b1
#     b2
#     � � �
#     bM
#
# *******************************************************************************************
# Input b is the right-hand side written as a column vector
# If we know the transformation matrix A, which transforms a vector 
# defined in the Coordinate Zero to a reference coordinate system
# then if we multiply this vector with the transformation MatrixA 
# we get the vector defined in the reference cordinate system
# if we want to transfer a vector defined in the reference coodinate
# system to coordinate zero:
#
# Coord Ref -> Coord 0
#
# and we know the transformation matrix
# that transforms a vector from Coord 0 to Coord Ref
#
# TransMatrix(Coord 0 -> Coord Ref)
#
# Then we need to use Gaussian Elimination method to solve
# a set of linear algebraic equations.
# assuming a vector with Fx, Fy, Fz, and I do not know these values defined in Coord 0
# but I know the transformation matrix, and I know the results of multiplying this 
# vector with the transformation matrix, whic are the values defined in reference coord.
# Then we need to solve
#
#  A � x = b
#
# where A is the transformation matrix, b is the values of the vector defined in reference
# coordinate frame. x is the unknown values of the same vector defined in coordinate frame 0.
#
# ********************************************************************************************


	# 1. Setup the input values

	my @TransMatrixA = ($_[0],  $_[1],  $_[2],  $_[3],	# Local transformation matrix A
		            $_[4],  $_[5],  $_[6],  $_[7],	
		    	    $_[8],  $_[9],  $_[10], $_[11],
		    	    $_[12], $_[13], $_[14], $_[15]);

	my $ux = $_[16]; # Vectors defined in the coordinate frame that the results are given
	my $uy = $_[17]; # Values to be transferred to Coord 0.
	my $uz = $_[18];
	my $scale = $_[19];

	my @a = (); 				# Matrix A in the  A � x = b matrix equation
	my @x = (0, 0, 0, 0);			# x
	my @b = ($ux, $uy, $uz, $scale);	# b
				
	my $o = 0;

	for(my $j = 0; $j < 4 ; $j++) {

		for(my $i = 0; $i < 4 ; $i++) {

			$a[$i][$j] = $TransMatrixA[$o];
		
			$o = $o + 4;		
		}
	
		$o = $o % 4 + 1;
	}

	for(my $i = 0; $i < 4 ; $i++) {

		$a[$i][4] = $b[$i];

	}

	# 2. Gaussian Elimination Method

	#print CODE ("*********** 1. Input ************\n");
	#print CODE ("$a[0][0] $a[0][1] $a[0][2] $a[0][3] $a[0][4]\n");
	#print CODE ("$a[1][0] $a[1][1] $a[1][2] $a[1][3] $a[1][4]\n");
	#print CODE ("$a[2][0] $a[2][1] $a[2][2] $a[2][3] $a[2][4]\n");
	#print CODE ("$a[3][0] $a[3][1] $a[3][2] $a[3][3] $a[3][4]\n");

	#$a[0][0] = 2; 	$a[0][1] = 1; 	$a[0][2] = -1; 	$a[0][3] = 0; $a[0][4] = 8;
	#$a[1][0] = -3; $a[1][1] = -1; 	$a[1][2] = 2; 	$a[1][3] = 0; $a[1][4] = -11;
	#$a[2][0] = -2; $a[2][1] = 1; 	$a[2][2] = 2; 	$a[2][3] = 0; $a[2][4] = -3;
	#$a[3][0] = 0; 	$a[3][1] = 0; 	$a[3][2] = 0; 	$a[3][3] = 1; $a[3][4] = 1;

	# Forward Substitution

	my $n = 4;
	my $i = 0;
	my $j = 0;
	my $k = 0;
	my $max = 0;
	my $t = 0;

	for($i = 0; $i < $n ; ++$i) {
	
		$max = $i;
	
		for($j = $i + 1; $j < $n ; ++$j) {
		
			if(abs($a[$j][$i]) > abs($a[$max][$i])){
		
				$max = $j;
			}
		}
	
		for($j = 0; $j < $n + 1; ++$j) {
		
			$t = $a[$max][$j];
			$a[$max][$j] = $a[$i][$j];
			$a[$i][$j] = $t;
		
		}

		for($j = $n; $j >= $i; --$j) {

			for($k = $i + 1; $k < $n; ++$k) {
		
				$a[$k][$j] -= $a[$k][$i] / $a[$i][$i] * $a[$i][$j];	
		
			}	
		}	
		
	}

	#print CODE ("*********** 2. ************\n");
	#print CODE ("$a[0][0] $a[0][1] $a[0][2] $a[0][3] $a[0][4]\n");
	#print CODE ("$a[1][0] $a[1][1] $a[1][2] $a[1][3] $a[1][4]\n");
	#print CODE ("$a[2][0] $a[2][1] $a[2][2] $a[2][3] $a[2][4]\n");
	#print CODE ("$a[3][0] $a[3][1] $a[3][2] $a[3][3] $a[3][4]\n");

	# 3. Reverse Elimination

	$i = 0;
	$j = 0;

	for($i = $n - 1; $i >= 0; --$i) {

		$a[$i][$n] = $a[$i][$n] / $a[$i][$i];
		$a[$i][$i] = 1;

		for($j = $i - 1; $j >= 0; --$j) {

			$a[$j][$n] -= $a[$j][$i] * $a[$i][$n];
			$a[$j][$i] = 0;
		}	
	}

	#print CODE ("*********** 3. ************\n");
	#print CODE ("$a[0][0] $a[0][1] $a[0][2] $a[0][3] $a[0][4]\n");
	#print CODE ("$a[1][0] $a[1][1] $a[1][2] $a[1][3] $a[1][4]\n");
	#print CODE ("$a[2][0] $a[2][1] $a[2][2] $a[2][3] $a[2][4]\n");
	#print CODE ("$a[3][0] $a[3][1] $a[3][2] $a[3][3] $a[3][4]\n");

	# Printing the results
	#print CODE ("*********** 4. ************\n");
	
	#for($i = 0; $i < $n; ++$i) {

		#for($j = 0; $j < $n + 1; ++$j) {

			#print CODE ("a[$i][$j] $a[$i][$j]\n");
		#}	
	#}

	for($i = 0; $i < 4; ++$i) {
	
		$x[$i] = $a[$i][4];
	}
	
	return \@x;
}


# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : createTransMatrix				                  *
# INTERNAL SUB FUNCTION PURPOSE : This function creates the transformation matrix of 		  *
#				  a transformation from coord. frame 0 to reference coordinate    *
#				  frame. it receives (From Coord id (Always Coord 0),To Coord id) *
#				  It returns 4 x 4 transformation matrix			  *
#												  *
# *************************************************************************************************

sub createTransMatrix {

		my @TransMatrix = (1, 0, 0, 0,	# Local transformation matrix A
		    		   0, 1, 0, 0,	
		    		   0, 0, 1, 0,
		    		   0, 0, 0, 1);

		my @MatrixA = (1, 0, 0, 0,
		    	       0, 1, 0, 0,	
		    	       0, 0, 1, 0,
		    	       0, 0, 0, 1);

		my @MatrixB = (1, 0, 0, 0,
		    	       0, 1, 0, 0,	
		    	       0, 0, 1, 0,
		    	       0, 0, 0, 1);

		my @MatrixC = (0, 0, 0, 0,
		    	       0, 0, 0, 0,	
		    	       0, 0, 0, 0,
		    	       0, 0, 0, 0);

		my $SizeMA = @MatrixA;
		#print CODE ("1. SizeMA = $SizeMA\n");
				    
		my @MovedCoordArray = ();
		
		my @CroosProductArray = ();
		my $SizeCPA = 0; # Size of @CroosProductArray;

		my @AngleArray = ();
		
		my $ANGLERAD = 0;
		my $ANGLEDEG = 0;
		
		my $SizeCIA = @CoordIDArray;

		my $A1 = 0; my $A2 = 0; my $A3 = 0;
		my $B1 = 0; my $B2 = 0; my $B3 = 0;
		my $C1 = 0; my $C2 = 0; my $C3 = 0;
		my $N1 = 0; my $N2 = 0; my $N3 = 0;
		
		my $D1 = 0; my $D2 = 0; my $D3 = 0;
		
		my $C0_A1 = 0; my $C0_A2 = 0; my $C0_A3 = 0;
		my $C0_B1 = 0; my $C0_B2 = 0; my $C0_B3 = 0;
		my $C0_C1 = 0; my $C0_C2 = 0; my $C0_C3 = 0;

		my $CREF_A1 = 0; my $CREF_A2 = 0; my $CREF_A3 = 0;
		my $CREF_B1 = 0; my $CREF_B2 = 0; my $CREF_B3 = 0;
		my $CREF_C1 = 0; my $CREF_C2 = 0; my $CREF_C3 = 0;
		
		my $a1 = 0; my $a2 = 0; my $a3 = 0;
		my $b1 = 0; my $b2 = 0; my $b3 = 0;
		
		#print ("SizeCIA $SizeCIA\n");
		
		# ******************  SETTING UP COORDINATE FRAMES FOR TRANSFORMATION **************************************
		
		for(my $i = 0; $i < $SizeCIA ; $i++){

			#print ("CoordIDArray[$i] $CoordIDArray[$i] D_[0] $_[0] D_[1] $_[1]\n");
			
			if( $_[0] == 0 && $CoordIDArray[$i] == $_[1] ){
				
				$A1 = $CoordA1Array[$i]; $A2 = $CoordA2Array[$i]; $A3 = $CoordA3Array[$i];
				$B1 = $CoordB1Array[$i]; $B2 = $CoordB2Array[$i]; $B3 = $CoordB3Array[$i];
				$C1 = $CoordC1Array[$i]; $C2 = $CoordC2Array[$i]; $C3 = $CoordC3Array[$i];

				@MovedCoordArray = @{moveCoordToCoord0( $CoordIDArray[$i],
									$A1, $A2, $A3, 
			      			     	       		$B1, $B2, $B3,
			      			    	       		$C1, $C2, $C3);}; # Make a copy of the return array				
				
				next;
			}
			
			if( $_[0] == 0 && $CoordIDArray[$i] == $_[0] ){
				
				#print("Yes $CoordIDArray[$i] == $_[0]\n");
				$C0_A1 = $CoordA1Array[$i]; $C0_A2 = $CoordA2Array[$i]; $C0_A3 = $CoordA3Array[$i];
				$C0_B1 = $CoordB1Array[$i]; $C0_B2 = $CoordB2Array[$i]; $C0_B3 = $CoordB3Array[$i];
				$C0_C1 = $CoordC1Array[$i]; $C0_C2 = $CoordC2Array[$i]; $C0_C3 = $CoordC3Array[$i];

			}
		}

		$CREF_A1 = $MovedCoordArray[1]; $CREF_A2 = $MovedCoordArray[2]; $CREF_A3 = $MovedCoordArray[3];
		$CREF_B1 = $MovedCoordArray[4]; $CREF_B2 = $MovedCoordArray[5]; $CREF_B3 = $MovedCoordArray[6];
		$CREF_C1 = $MovedCoordArray[7]; $CREF_C2 = $MovedCoordArray[8]; $CREF_C3 = $MovedCoordArray[9];
		
		#print CODE ("MovedCoordArray\n");
		#print CODE ("CREF_A1 = $MovedCoordArray[1]; CREF_A2 = $MovedCoordArray[2]; CREF_A3 = $MovedCoordArray[3];\n");
		#print CODE ("CREF_B1 = $MovedCoordArray[4]; CREF_B2 = $MovedCoordArray[5]; CREF_B3 = $MovedCoordArray[6];\n");
		#print CODE ("CREF_C1 = $MovedCoordArray[7]; CREF_C2 = $MovedCoordArray[8]; CREF_C3 = $MovedCoordArray[9];\n");
		
		# ******************  TRANSFORMING X VECTOR *****************************************************************
		#print CODE ("************* Trans X vector\n");
		# Summary:
		
		# 1. Set up u and v vector
		# 2. find the cross product of u vector on axis X of reference coordinate frame and
		#    v vector on axis X of Coord 0
		# 3. Calculate angle between vector on Z axis of Coord 0 
		#    and the cross product of u and v vectors 
		#    (u vector on axis X of reference coordinate frame and v vector on axis X of Coord 0)
		# 4. Set the transformation Matrix A (4 x 4) for this transformation
		# 5. Calculate angle between vector on axis X of reference coordinate frame
		#    and the vector on axis X of Coord 0
		# 6. Set the transformation Matrix B (4 x 4) for this transformation
		# 7. Multiply Matrix A x Matrix B = Matrix C (4 x 4) 
		# 8. Set TransMatrix for the transformation of the vector on X axis (The vector on "From Coord id")
		#    setting elements 0, 1, 2, 3.
		
		# Code:
		
		# 1. Setting up u and v vector
		
		$a1 = $CREF_C1; $a2 = $CREF_C2; $a3 = $CREF_C3; # u vector
		$b1 = $C0_C1;   $b2 = $C0_C2;   $b3 = $C0_C3;	# v vector
		
		#print CODE ("Trans coord:\n");
	
		#print CODE ("CREF_C1 $a1 CREF_C2 $a2 CREF_C3 $a3\n");
		#print CODE ("C0_C1 $b1 C0_C2 $b2 C0_C3 $b3\n");		
			
		# 2. Finding the cross product of u vector on axis X of reference coordinate frame
		#    and v vector on axis X of Coord 0
		
		@CroosProductArray = @{crossPruduct( 	$C0_A1, $C0_A2, $C0_A3, 
			      				$a1,    $a2,    $a3,
			      				$b1,    $b2,    $b3    	);}; # Make a copy of the return array		
			

		# If u and v vectors are in the same or opposite direction
		
		$SizeCPA = @CroosProductArray;
		
		#print CODE ("Size of CroosProductArray: $SizeCPA\n");
		
		if($SizeCPA == 1 && ($CroosProductArray[0] == 1 || $CroosProductArray[0] == -1)){
			
			# if the two vectors are in the same or opposite direction crossProduct subroutine returns 1 or -1
			
			# Point D on cross product vector (Z') (Cross product of u and v vectors) is a point on Z axis, 
			# so that the angle between the two will be zero (between Z and Z')
			
			$D1 = $C0_B1; $D2 = $C0_B2; $D3 = $C0_B3;

			#print CODE ("Cross product 1 or -1: D1 $D1 : C0_B1 $C0_B1, D2 $D2 : C0_B2 $C0_B2, D3 $D3 : C0_B3 $C0_B3,\n");
					
		}else{

			# Point D on cross product vector (Z') (Cross product of u and v vectors)
			
			$D1 = $CroosProductArray[3]; $D2 = $CroosProductArray[4]; $D3 = $CroosProductArray[5];

			#print CODE ("Cross product normal: D1 $D1 D2 $D2 D3 $D3\n");

		}


		# 3. Calculating the angle between vector on Z axis of Coord 0 
		#    and the cross product of u and v vectors (Z')
		#    (u vector on axis X of reference coordinate frame and v vector on axis X of Coord 0)

		
		$N1 = $b1; $N2 = $b2; $N3 = $b3; # input u vector as a Normal (N) vector into the subroutine to get the sign of the rotation
		
		@AngleArray = @{calculateVectorsAngle(	$C0_A1, $C0_A2, $C0_A3, 
			      			     	$D1, 	$D2, 	$D3,
			      			    	$C0_B1, $C0_B2, $C0_B3,
							$N1,    $N2,    $N3	);}; # Make a copy of the return array
				
		$ANGLERAD = $AngleArray[0];
		$ANGLEDEG = $AngleArray[1];

		#print CODE ("ANGLEDEG = $ANGLEDEG\n");

		# 4. Set the transformation Matrix A (4 x 4) for this transformation
					
		# Rotation about X axis on Coord 0
		
		$MatrixA[5] = cos($ANGLERAD); $MatrixA[6] = -sin($ANGLERAD);
		$MatrixA[8] = sin($ANGLERAD); $MatrixA[9] =  cos($ANGLERAD);
		
		#print CODE ("MatrixA[5] cos $MatrixA[5] MatrixA[6] -sin $MatrixA[6]\nMatrixA[8] sin $MatrixA[8] MatrixA[9] cos $MatrixA[9]\n");		

		# 5. Calculate angle between vector on axis X of reference coordinate frame
		#    and the vector on axis X of Coord 0

		$N1 = $D1; $N2 = $D2; $N3 = $D3; # input u vector as a Normal (N) vector into the subroutine to get the sign of the rotation
		
		@AngleArray = @{calculateVectorsAngle($C0_A1, $C0_A2, $C0_A3, # Calculating the angle between u vector on axis X of reference coordinate frame
			      			      $a1,    $a2,    $a3,    # and v vector on axis X of Coord 0 
			      			      $b1,    $b2,    $b3,
						      $N1,    $N2,    $N3);}; # Make a copy of the return array
		
		$ANGLERAD = $AngleArray[0];
		$ANGLEDEG = $AngleArray[1];
		
		my $cosanglerad = cos($ANGLERAD);
		
		#print CODE ("ANGLERAD = $ANGLERAD cosanglerad = $cosanglerad\n");
		#print CODE ("ANGLEDEG = $ANGLEDEG\n");

		# 6. Set the transformation Matrix B (4 x 4) for this transformation

		# Rotation about Z' axis (cross product of u and v)
		
		$MatrixB[0] = cos($ANGLERAD); $MatrixB[1] = -sin($ANGLERAD);
		$MatrixB[4] = sin($ANGLERAD); $MatrixB[5] =  cos($ANGLERAD);
			
		#print CODE (" [0]: MatrixB[0] $MatrixB[0] MatrixB[1] $MatrixB[1]\nMatrixB[4] $MatrixB[4] MatrixB[5] $MatrixB[5]\n");
					
		# 7. Multiply Matrix A x Matrix B = Matrix C (4 x 4) 
		
		$SizeMA = @MatrixA;
		#print CODE ("2. SizeMA = $SizeMA\n");
		
		#my $ci = 0;
		
		#foreach(@MatrixA){
		
			#print CODE ("MatrixA: $_\n");
			
			#$ci++;
		#}				

		#$ci = 0;

		#foreach(@MatrixB){
		
			#print CODE ("MatrixB: $_\n");
			
			#$ci++;
		#}
				
		my $m = 0;
		my $n = 0;

		for(my $i = 0; $i < 4 ; $i++) {
	
			for(my $j = 0; $j < 4 ; $j++) {
		
				$n = $m + $j;

				$MatrixC[$n] =  $MatrixA[$j]   * $MatrixB[$m]   + $MatrixA[$j+4]  * $MatrixB[$m+1] + 
						$MatrixA[$j+8] * $MatrixB[$m+2] + $MatrixA[$j+12] * $MatrixB[$m+3];		
		
			}
	
			$m = $m + 4;	
		}
			
		# 8. Set TransMatrix for the transformation of the vector on X axis (The vector on "From Coord id")
		#    setting elements 0, 1, 2, 3.

		for(my $i = 0; $i < 4; $i++){	# Setting first four elements of @TransMatrix, This is for Transformation of the X vector
			
			#print("MatrixC[$i]: $MatrixC[$i]\n");
			$TransMatrix[$i] = $MatrixC[$i];
		}
		
		#foreach(@MatrixC){
		
			#print CODE ("MatrixC: $_\n");
		#}
		
		# ******************  TRANSFORMING Y VECTOR ***********************************************************
		#print CODE ("************* Trans Y vector\n");
		# Resetting Matrix A, Matrix B and Matrix C

		@MatrixA = (1, 0, 0, 0,
		    	    0, 1, 0, 0,	
		    	    0, 0, 1, 0,
		    	    0, 0, 0, 1);

		@MatrixB = (1, 0, 0, 0,
		    	    0, 1, 0, 0,	
		    	    0, 0, 1, 0,
		    	    0, 0, 0, 1);

		@MatrixC = (0, 0, 0, 0,
		    	    0, 0, 0, 0,	
		    	    0, 0, 0, 0,
		    	    0, 0, 0, 0);

		$SizeMA = @MatrixA;
		#print CODE ("1. SizeMA = $SizeMA\n");

		# Summary:
		
		# 1. Find the cross product of X and Z axis for each coordinate frame. We do this for Y axis
		#    axis because NASTRAN uses point B on Z axis and point C on XZ plane, we need to create a
		#    point, say point D on Y axis to calculate the transformation
		# 2. Set up u and v vector 
		# 3. find the cross product of u vector on axis Y of reference coordinate frame and
		#    v vector on axis Y of Coord 0
		# 4. Calculate angle between vector on Z axis of Coord 0 
		#    and the cross product of u and v vectors 
		#    (u vector on axis Y of reference coordinate frame and v vector on axis Y of Coord 0)
		# 5. Set the transformation Matrix A (4 x 4) for this transformation
		# 6. Calculate angle between vector on axis Y of reference coordinate frame
		#    and the vector on axis Y of Coord 0
		# 7. Set the transformation Matrix B (4 x 4) for this transformation
		# 8. Multiply Matrix A x Matrix B = Matrix C (4 x 4) 
		# 9. Set TransMatrix for the transformation of the vector on Y axis (The vector on "From Coord id")
		#    setting elements 4, 5, 6, 7.
		
		# Code:
		
		# 1A. The cross product of X and Z axis for each coordinate frame is the Y axis
		#     Finding the cross product of u vector on axis X of reference coordinate frame
		#     and v vector on axis Z of reference coordinate frame
		
		@CroosProductArray = @{crossPruduct( 	$CREF_A1, $CREF_A2, $CREF_A3, 
			      				$CREF_B1, $CREF_B2, $CREF_B3,
			      				$CREF_C1, $CREF_C2, $CREF_C3	);}; # Make a copy of the return array		

		# 2. Setting up u vector 
		# Point on Y axis of reference Coord frame
			
		$a1 = $CroosProductArray[3]; $a2 = $CroosProductArray[4]; $a3 = $CroosProductArray[5]; # u vector

		# 1B. The cross product of X and Z axis for each coordinate frame is the Y axis
		#     Finding the cross product of u vector on axis X of coordinate frame 0
		#     and v vector on axis Z of coordinate frame 0
		
		@CroosProductArray = @{crossPruduct( 	$C0_A1, $C0_A2, $C0_A3, 
			      				$C0_B1, $C0_B2, $C0_B3,
			      				$C0_C1, $C0_C2, $C0_C3	 	);}; # Make a copy of the return array		
		# 2. Setting up v vector 
		# Point on Y axis of Coord 0

		$b1 = $CroosProductArray[3];   $b2 = $CroosProductArray[4];   $b3 = $CroosProductArray[5]; # v vector
	
		#print ("a1 $a1 a2 $a2 a3 $a3\n");
		#print ("b1 $b1 b2 $b2 b3 $b3\n");		
			
		# 3. Finding the cross product of u vector on axis Y of reference coordinate frame
		#    and v vector on axis Y of Coord 0
		
		@CroosProductArray = @{crossPruduct( 	$C0_A1, $C0_A2, $C0_A3, 
			      				$a1,    $a2,    $a3,
			      				$b1,    $b2,    $b3    	);}; # Make a copy of the return array		
			

		# If u and v vectors are in the same or opposite direction
		
		$SizeCPA = @CroosProductArray;
		
		#print CODE ("Size of CroosProductArray: $SizeCPA\n");
		
		if($SizeCPA == 1 && ($CroosProductArray[0] == 1 || $CroosProductArray[0] == -1)){
			
			# if the two vectors are in the same or opposite direction crossProduct subroutine returns 1 or -1
			
			# Point D on cross product vector (Z'') (Cross product of u and v vectors) is a point on Z axis, 
			# so that the angle between the two will be zero (between Z and Z'')
			
			$D1 = $C0_B1; $D2 = $C0_B2; $D3 = $C0_B3;

			#print CODE ("Cross product 1 or -1: D1 $D1 : C0_B1 $C0_B1, D2 $D2 : C0_B2 $C0_B2, D3 $D3 : C0_B3 $C0_B3,\n");
					
		}else{

			# Point D on cross product vector (Z'') (Cross product of u and v vectors)
			
			$D1 = $CroosProductArray[3]; $D2 = $CroosProductArray[4]; $D3 = $CroosProductArray[5];

			#print CODE ("Cross product normal: D1 $D1 D2 $D2 D3 $D3\n");

		}


		# 4. Calculate angle between vector on Z axis of Coord 0 
		#    and the cross product of u and v vectors (Z'')
		#    (u vector on axis Y of reference coordinate frame and v vector on axis Y of Coord 0)

		$N1 = $b1; $N2 = $b2; $N3 = $b3; # input u vector as a Normal (N) vector into the subroutine to get the sign of the rotation
			
		@AngleArray = @{calculateVectorsAngle(	$C0_A1, $C0_A2, $C0_A3, 
			      			     	$D1, 	$D2, 	$D3,
			      			    	$C0_B1, $C0_B2, $C0_B3,
							$N1,    $N2,    $N3	);}; # Make a copy of the return array
		
		$ANGLERAD = $AngleArray[0];
		$ANGLEDEG = $AngleArray[1];
		
		#print CODE ("ANGLEDEG = $ANGLEDEG\n");

		# 5. Set the transformation Matrix A (4 x 4) for this transformation
					
		# Rotation about Y axis on Coord 0
		
		$MatrixA[0] =  cos($ANGLERAD); $MatrixA[2]  = sin($ANGLERAD);
		$MatrixA[8] = -sin($ANGLERAD); $MatrixA[10] = cos($ANGLERAD);

		$N1 = $D1; $N2 = $D2; $N3 = $D3; # input u vector as a Normal (N) vector into the subroutine to get the sign of the rotation
		
		@AngleArray = @{calculateVectorsAngle($C0_A1, $C0_A2, $C0_A3, # Calculating the angle between u vector on axis Y of reference coordinate frame
			      			      $a1,    $a2,    $a3,    # and v vector on axis Y of Coord 0 
			      			      $b1,    $b2,    $b3,
						      $N1,    $N2,    $N3);}; # Make a copy of the return array
		
		$ANGLERAD = $AngleArray[0];
		$ANGLEDEG = $AngleArray[1];
		
		#print CODE ("ANGLEDEG = $ANGLEDEG\n");

		# 6. Set the transformation Matrix B (4 x 4) for this transformation

		# Rotation about Z'' axis (cross product of u and v)
		
		$MatrixB[0] = cos($ANGLERAD); $MatrixB[1] = -sin($ANGLERAD);
		$MatrixB[4] = sin($ANGLERAD); $MatrixB[5] =  cos($ANGLERAD);
				
		# 7. Multiply Matrix A x Matrix B = Matrix C (4 x 4) 
		
		#print CODE ("MatrixB[0] $MatrixB[0] MatrixB[1] $MatrixB[1]\nMatrixB[4] $MatrixB[4] MatrixB[5] $MatrixB[5]\n");		

		$SizeMA = @MatrixA;
		#print CODE ("2. SizeMA = $SizeMA\n");

		#$ci = 0;

		#foreach(@MatrixA){
		
			#print CODE ("MatrixA: $_\n");
			
			#$ci++;
		#}				

		#$ci = 0;

		#foreach(@MatrixB){
		
			#print CODE ("MatrixB: $_\n");
			
			#$ci++;
		#}
				
		$m = 0;
		$n = 0;

		for(my $i = 0; $i < 4 ; $i++) {
	
			for(my $j = 0; $j < 4 ; $j++) {
			
				$n = $m + $j;

				$MatrixC[$n] =  $MatrixA[$j]   * $MatrixB[$m]   + $MatrixA[$j+4]  * $MatrixB[$m+1] + 
						$MatrixA[$j+8] * $MatrixB[$m+2] + $MatrixA[$j+12] * $MatrixB[$m+3];		
		
			}
	
			$m = $m + 4;	
		}
				
		# 8. Set TransMatrix for the transformation of the vector on X axis (The vector on "From Coord id")
		#    setting elements 0, 1, 2, 3.

		for(my $i = 4; $i < 8; $i++){	# Setting first four elements of @TransMatrix, This is for Transformation of the X vector
			
			#print("MatrixC[$i]: $MatrixC[$i]\n");
			$TransMatrix[$i] = $MatrixC[$i];
		}
		
		#foreach(@MatrixC){
		
			#print CODE ("MatrixC: $_\n");
		#}
		
		# ******************  TRANSFORMING Z VECTOR ***********************************************************
		#print CODE ("************* Trans Z vector\n");
		# Resetting Matrix A, Matrix B and Matrix C
		
		@MatrixA = (1, 0, 0, 0,
		    	    0, 1, 0, 0,	
		    	    0, 0, 1, 0,
		    	    0, 0, 0, 1);

		@MatrixB = (1, 0, 0, 0,
		    	    0, 1, 0, 0,	
		    	    0, 0, 1, 0,
		    	    0, 0, 0, 1);

		@MatrixC = (0, 0, 0, 0,
		    	    0, 0, 0, 0,	
		    	    0, 0, 0, 0,
		    	    0, 0, 0, 0);

		$SizeMA = @MatrixA;
		#print CODE ("1. SizeMA = $SizeMA\n");
		
		# Summary:
		
		# 1. Set up u and v vector 
		# 2. find the cross product of u vector on axis Z of reference coordinate frame and
		#    v vector on axis Z of Coord 0
		# 3. Calculate angle between vector on Z axis of Coord 0 
		#    and the cross product of u and v vectors 
		#    (u vector on axis Y of reference coordinate frame and v vector on axis Y of Coord 0)
		# 4. Set the transformation Matrix A (4 x 4) for this transformation
		# 5. Calculate angle between vector on axis Y of reference coordinate frame
		#    and the vector on axis Y of Coord 0
		# 6. Set the transformation Matrix B (4 x 4) for this transformation
		# 7. Multiply Matrix A x Matrix B = Matrix C (4 x 4) 
		# 8. Set TransMatrix for the transformation of the vector on Y axis (The vector on "From Coord id")
		#    setting elements 4, 5, 6, 7.
		
		# Code:
		
		# 1. Setting up u and v vector
		
		$a1 = $CREF_B1; $a2 = $CREF_B2; $a3 = $CREF_B3; # u vector
		$b1 = $C0_B1;   $b2 = $C0_B2;   $b3 = $C0_B3;	# v vector
	
		#print ("a1 $a1 a2 $a2 a3 $a3\n");
		#print ("b1 $b1 b2 $b2 b3 $b3\n");		
			
		# 2. Finding the cross product of u vector on axis Z of reference coordinate frame
		#    and v vector on axis Z of Coord 0
		
		@CroosProductArray = @{crossPruduct( 	$C0_A1, $C0_A2, $C0_A3, 
			      				$a1,    $a2,    $a3,
			      				$b1,    $b2,    $b3    	);}; # Make a copy of the return array		
			

		# If u and v vectors are in the same or opposite direction
		
		$SizeCPA = @CroosProductArray;
		
		#print CODE ("Size of CroosProductArray: $SizeCPA\n");
		
		if($SizeCPA == 1 && ($CroosProductArray[0] == 1 || $CroosProductArray[0] == -1)){
			
			# if the two vectors are in the same or opposite direction crossProduct subroutine returns 1 or -1
			
			# Point D on cross product vector (X') (Cross product of u and v vectors) is a point on X axis, 
			# so that the angle between the two will be zero (between X and X')
			
			$D1 = $C0_C1; $D2 = $C0_C2; $D3 = $C0_C3;

			#print CODE ("Cross product 1 or -1: D1 $D1 : C0_C1 $C0_C1, D2 $D2 : C0_C2 $C0_C2, D3 $D3 : C0_C3 $C0_C3,\n");
					
		}else{

			# Point D on cross product vector (X') (Cross product of u and v vectors)
			
			$D1 = $CroosProductArray[3]; $D2 = $CroosProductArray[4]; $D3 = $CroosProductArray[5];

			#print CODE ("Cross product normal: D1 $D1 D2 $D2 D3 $D3\n");

		}

		# 3. Calculate angle between vector on X axis of Coord 0 
		#    and the cross product of u and v vectors (X'')
		#    (u vector on axis Z of reference coordinate frame and v vector on axis Z of Coord 0)

		$N1 = $b1; $N2 = $b2; $N3 = $b3; # input u vector as a Normal (N) vector into the subroutine to get the sign of the rotation
			
		@AngleArray = @{calculateVectorsAngle(	$C0_A1,	$C0_A2,	$C0_A3, 
			      			     	$D1, 	$D2, 	$D3,
			      			      	$C0_C1, $C0_C2,	$C0_C3,
							$N1,    $N2,    $N3	);}; # Make a copy of the return array
		
		$ANGLERAD = $AngleArray[0];
		$ANGLEDEG = $AngleArray[1];
		
		#print CODE ("ANGLEDEG = $ANGLEDEG\n");

		# 4. Set the transformation Matrix A (4 x 4) for this transformation
			
		# Rotation about Z axis on Coord 0
		
		$MatrixA[0] = cos($ANGLERAD); $MatrixA[1] = -sin($ANGLERAD);
		$MatrixA[4] = sin($ANGLERAD); $MatrixA[5] =  cos($ANGLERAD);

		# 5. Calculate angle between u vector on axis Y of reference coordinate frame
		#    and v vector on axis Y of Coord 0

		$N1 = $D1; $N2 = $D2; $N3 = $D3; # input u vector as a Normal (N) vector into the subroutine to get the sign of the rotation

		@AngleArray = @{calculateVectorsAngle($C0_A1, $C0_A2, $C0_A3, # Calculating the angle between u vector on axis Y of reference coordinate frame
			      			      $a1,    $a2,    $a3,    # and v vector on axis Y of Coord 0 
			      			      $b1,    $b2,    $b3,
						      $N1,    $N2,    $N3);}; # Make a copy of the return array
		
		$ANGLERAD = $AngleArray[0];
		$ANGLEDEG = $AngleArray[1];
		
		#print CODE ("ANGLEDEG = $ANGLEDEG\n");

		# 6. Set the transformation Matrix B (4 x 4) for this transformation
		
		# Rotation about X' axis (cross product of u and v)
		
		$MatrixB[5] = cos($ANGLERAD); $MatrixB[6]  = -sin($ANGLERAD);
		$MatrixB[9] = sin($ANGLERAD); $MatrixB[10] =  cos($ANGLERAD);
				
		# 7. Multiply Matrix A x Matrix B = Matrix C (4 x 4) 
		
		#print CODE ("MatrixB[5] $MatrixB[5] MatrixB[6] $MatrixB[6]\nMatrixB[9] $MatrixB[9] MatrixB[10] $MatrixB[10]\n");		

		$SizeMA = @MatrixA;
		#print CODE ("2. SizeMA = $SizeMA\n");

		#$ci = 0;

		#foreach(@MatrixA){
		
			#print CODE ("MatrixA: $_\n");
			
			#$ci++;
		#}				

		#$ci = 0;

		#foreach(@MatrixB){
		
			#print CODE ("MatrixB: $_\n");
			
			#$ci++;
		#}

		$m = 0;
		$n = 0;

		for(my $i = 0; $i < 4 ; $i++) {
	
			for(my $j = 0; $j < 4 ; $j++) {
		
				$n = $m + $j;
		
				$MatrixC[$n] =  $MatrixA[$j]   * $MatrixB[$m]   + $MatrixA[$j+4]  * $MatrixB[$m+1] + 
						$MatrixA[$j+8] * $MatrixB[$m+2] + $MatrixA[$j+12] * $MatrixB[$m+3];		

			}
	
			$m = $m + 4;	
		}
				
		# 8. Set TransMatrix for the transformation of the vector on X axis (The vector on "From Coord id")
		#    setting elements 0, 1, 2, 3.

		for(my $i = 8; $i < 12; $i++){	# Setting first four elements of @TransMatrix, This is for Transformation of the X vector
			
			#print CODE ("MatrixC[$i]: $MatrixC[$i]\n");
			$TransMatrix[$i] = $MatrixC[$i];
		}
		
		#foreach(@MatrixC){
		
			#print CODE ("MatrixC: $_\n");
		#}

		#print CODE ("************* Inside createTransMatrix *************\n");
		
		#foreach(@TransMatrix){
		
			#print CODE ("TransMatrix: $_\n");
		#}

		
		return \@TransMatrix;
			
}

# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : round				                  		  *
# INTERNAL SUB FUNCTION PURPOSE : Perl does not have an explicit round function. However, it is   *
#				  very simple to create a rounding function. Since the int()      *
#				  function simply removes the decimal value and returns the       *
#				  integer portion of a number, you can use  any number greater    *
#				  than .5 will be increased to the next highest integer, and any  * 
#				  number less than .5 will remain the current integer, which has  * 
#				  the same effect as rounding.					  *
#												  *
# *************************************************************************************************

sub round {
    my($number) = shift;
    #return int($number + .5);	# Handles positive numbers
    return int($number + .5 * ($number <=> 0)); # Handles both negative and positive numbers
}

# *******************************************************************************************************
#											      	  	*
# INTERNAL SUB FUNCTION NAME    : gpfbInitialSort				                  	*
# INTERNAL SUB FUNCTION PURPOSE : This function reads f06 files and finds Grid Point Force results and  *
#				  prints them into GRID_POINT_FORCE_BALANCE.dat file.			*	
#												  	*
# *******************************************************************************************************


sub gpfbInitialSort {
	
	my $SizeNIA = $_[0];		# Local size of @NodeIDArray
	my $SizeMPCNIA = $_[1];		# Local size of @NodeIDArray
	my $SizeFBNIA = $_[2];		# Local size of @FreebodyNodeIDArray
	
	#print "SizeNIA $SizeNIA, SizeMPCNIA $SizeMPCNIA, SizeFBNIA $SizeFBNIA\n";
	
	#open (CODE, ">>$CurrentDir/ProgrammingLog.dat") or die "Unable to write input file ProgrammingLog.dat\n";
	
	#print CODE ("SizeNIA = $SizeNIA, SizeBNIA = $SizeFBNIA\n");
	
	my @NodeIDArray = ();		# Local @NodeIDArray	
	my $NIACnt = 0;

	my @MPCNodeIDArray = ();	# Local @MPCNodeIDArray	
	my $MPCNIDCnt = 0;

	my @FreebodyNodeIDArray = ();	# Local @FreebodyNodeIDArray
	my $FBNIACnt = 0;

	# Locally rebuilding @NodeIDArray
	
	for(my $i = 3; $i < ($SizeNIA + 3) ; $i++){	

		# passed variables &gpfbInitialSort($SizeNIA, $SizeMPCNIA, $SizeFBNIA, @NodeIDArray , @MPCNodeIDArray, @FreebodyNodeIDArray)
	
		$NodeIDArray[$NIACnt] = $_[$i];	#print CODE ("NodeIDArray[$NIACnt] $NodeIDArray[$NIACnt];\n");
		$NIACnt++;
	}

	# Locally rebuilding @MPCNodeIDArray
	
	for(my $i = (3 + $SizeNIA); $i < (3 + $SizeNIA + $SizeMPCNIA); $i++){ 
		
		# passed variables &gpfbInitialSort($SizeNIA, $SizeMPCNIA, $SizeFBNIA, @NodeIDArray , @MPCNodeIDArray, @FreebodyNodeIDArray)
		
		$MPCNodeIDArray[$MPCNIDCnt] = $_[$i]; #print ("MPCNodeIDArray[$MPCNIDCnt] $MPCNodeIDArray[$MPCNIDCnt];\n");
		$MPCNIDCnt++;
	}

	# Locally rebuilding @FreebodyNodeIDArray
	
	for(my $i = (3 + $SizeNIA + $SizeMPCNIA); $i < (3 + $SizeNIA + $SizeMPCNIA + $SizeFBNIA); $i++){ # starting from $i = $SizeNIA, because 
		
		# passed variables &gpfbInitialSort($SizeNIA, $SizeMPCNIA, $SizeFBNIA, @NodeIDArray , @MPCNodeIDArray, @FreebodyNodeIDArray)
			
		$FreebodyNodeIDArray[$FBNIACnt] = $_[$i]; #print ("FreebodyNodeIDArray[$FBNIACnt] $FreebodyNodeIDArray[$FBNIACnt];\n");
		$FBNIACnt++;
	}

	#foreach(@NodeIDArray){
	
		#print "NodeIDArray: $_\n";
	
	#}

	#foreach(@MPCNodeIDArray){
	
		#print "MPCNodeIDArray: $_\n";
	
	#}

	#foreach(@FreebodyNodeIDArray){
	
		#print "FreebodyNodeIDArray: $_\n";
	
	#}


	my @SUBCASE_NO = ();			# Stores subcase number
	my $var = 0;				# This variable is used to identify the last array element in @SUBCASE_NO array

	my $line = "";				# When .f06 file is being read, it stores the line being read.
	my $LOADNAME = "";			# Stores the loadname above the SBCASE or SUBCOM line
	my $LOADNAME_1 = "";			# This variable stores the $LOADNAME
	my $LOADNAME_2 = "";			# if the line ^0\s+(.+?)\s+SUBCASE has loadname in the area in brackets (.+?) 
					
	my @NodeIDArrayChk = ();
	my $NIDCHKCnt = 0;
	
	my @PageArray = ();
	my $PACnt = 0;
	my $NIAFlag = 0;
	my $MPCFlag = 0;
	my $FBFlag = 0;

	my $WorkingDir = cwd;
	my $DataDir = "$WorkingDir\/DATA";
	
 	for (my $i =0; $i<= $#f06FileArray; $i++) {
	
		(my $filenamepr) = split/\./,$f06FileArray[$i];
		
		my @filenamepr = split "\/",$filenamepr;
		my $Size = @filenamepr;
		
		$datFileArray[$i] = "$DataDir\/$filenamepr[$Size-1].dat";
		$mpcdatFileArray[$i] = "$DataDir\/$filenamepr[$Size-1].mpcdat";			
		$freebodydatFileArray[$i] = "$DataDir\/$filenamepr[$Size-1].freebodydat";		
	}

        
	for (my $i =0; $i<= $#f06FileArray; $i++) {
		
		print "Started reading f06FileArray: $f06FileArray[$i]\n";
		
		open(FILE, "<$f06FileArray[$i]") or die "Unable to open input file $f06FileArray[$i]\n";
		
		if($SizeNIA > 0){
		
			open(GPFBINFILE, ">$datFileArray[$i]") or die "Unable to open input file $datFileArray[$i]\n";

			# ***** Header for *.dat file *****************************************************
		
			$l_time = localtime;	$gm_time = gmtime;

			print GPFBINFILE ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");

			# print ("\nSizeNIA Started extracting at LOCAL TIME:$l_time	GMT:$gm_time\n\n");

			print GPFBINFILE ("\$Originated From: $f06FileArray[$i]\n");
			print GPFBINFILE ("\$\n");
			
			# ***** Header for *.dat file *****************************************************

		}

		if($SizeMPCNIA > 0){
		
			open(MPCINFILE, ">$mpcdatFileArray[$i]") or die "Unable to open input file $mpcdatFileArray[$i]\n";

			# ***** Header for *.dat file *****************************************************
		
			$l_time = localtime;	$gm_time = gmtime;

			print MPCINFILE ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");

			# print ("\nSizeMPCNIA Started extracting at LOCAL TIME:$l_time	GMT:$gm_time\n\n");

			print MPCINFILE ("\$Originated From: $f06FileArray[$i]\n");
			print MPCINFILE ("\$\n");
			
			# ***** Header for *.dat file *****************************************************

		}
		
		if($SizeFBNIA > 0){
		
			open(FREEBODYINFILE, ">$freebodydatFileArray[$i]") or die "Unable to open input file $freebodydatFileArray[$i]\n";

			# ***** Header for *.dat file *****************************************************
		
			$l_time =localtime;	$gm_time = gmtime;

			print FREEBODYINFILE ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");

			# print ("\nSizeFBNIA Started extracting at LOCAL TIME:$l_time	GMT:$gm_time\n\n");

			print FREEBODYINFILE ("\$Originated From: $f06FileArray[$i]\n");
			print FREEBODYINFILE ("\$\n");

			# ***** Header for *.dat file *****************************************************

		}
		
		while (<FILE>) { # **************** IMPORTANT ********** This is the main while loop that goes through f06 Files.

			$line = $_;
			
			if (($line =~ /^1/) && ($line =~ /MSC/) &&  ($line =~ /NASTRAN/) && ($line =~ /PAGE/)) {
				$LOADNAME = <FILE>;

				if($LOADNAME ne /^\s+$/){
					chomp ($LOADNAME);
					# Remove whitespace at the beginning and end of your string, 
					# as well as consecutive whitespace (more than one whitespace character in a row) throughout the string. 
					# $string = join(' ',split(' ',$string));

					$LOADNAME = join(' ',split(' ',$LOADNAME));					
					$LOADNAME_1 = $LOADNAME;
				}
				next;
			}

			if ( ($line =~ m/^0\s+(.+?)\s+SUBCASE/) || ($line =~ m/^0\s+(.+?)\s+SUBCOM/) || ($line =~ m/^0\s+(.+?)\s+SYM/) || ($line =~ m/^0\s+(.+?)\s+SYMCOM/) || ($line =~ m/^0\s+(.+?)\s+REPCASE/) ) {

				if ($1 eq " "){
					$LOADNAME_2 = $LOADNAME_1;
				}else{$LOADNAME_2 = $1;}

				@SUBCASE_NO = split(" ", $line);
				$var = @SUBCASE_NO;

				next;
			} 
		
			
			
			if ($line =~ /G R I D   P O I N T   F O R C E   B A L A N C E/) {

				do {
					$line = (<FILE>);
					chomp($line);
					my @LineArray = split  " ", $line;

					if ( ($line =~ /E\+\d\d/) || ($line =~ /0\.0/) || ($line =~ /\.0/) || ($line =~ /E\-\d\d/) ) {
						
						$PageArray[$PACnt] = "$line" . "        " . "$SUBCASE_NO[$var-1]" . "        " . "$LOADNAME_2\n";
						$PACnt++;
						
						if($_ =~ /^0/){
							$NodeIDArrayChk[$NIDCHKCnt] = $LineArray[1];
							$NIDCHKCnt++;
						}else{
							$NodeIDArrayChk[$NIDCHKCnt] = $LineArray[0];
							$NIDCHKCnt++;
						}
						
					}

				} until (($line =~ /^1/) && ($line =~ /MSC/) &&  ($line =~ /NASTRAN/) && ($line =~ /PAGE/));

				# The following foreach loop checks the node ids in the PageArray (Also @NodeIDArrayChk array)
				# PageArray contains the whole line information but NodeIDArrayChk array contains only the node ids
				# If the Node ID array contains a node that also exists in PageArray
				# then we turn the flag on and do the foreachloops loop starting with if($Flag == 1){...
				# This bit of the code speeds up the search. 
				# Note Quick sort algorithm might be useful, 				
				
				if($SizeNIA > 0){
				
					foreach(@NodeIDArray){

						my $NodeID = $_;

						foreach(@NodeIDArrayChk){

							if($NodeID == $_){

								$NIAFlag = 1;
							}
						}
					}
				
				}

				if($SizeMPCNIA > 0){
				
					foreach(@MPCNodeIDArray){

						my $NodeID = $_;

						foreach(@NodeIDArrayChk){

							if($NodeID == $_){

								$MPCFlag = 1;
							}
						}
					}
				
				}

				if($SizeFBNIA > 0){
				
					foreach(@FreebodyNodeIDArray){

						my $NodeID = $_;

						foreach(@NodeIDArrayChk){

							if($NodeID == $_){

								$FBFlag = 1;
							}
						}
					}
				
				}
				
				@NodeIDArrayChk = (); # This array contains the node ids that exist in the PageArray
				$NIDCHKCnt =0;	      # This is a counter for NodeIDArrayChk array

				# The following foreach loop prints the selected node ids
				# because the flag is turned on, we know that PageArray contains at least one of the nodes
				# we are interested in			
				
				if($NIAFlag == 1 || $MPCFlag == 1 || $FBFlag == 1){
				
					if($SizeNIA > 0 && $NIAFlag == 1){
					
						foreach(@NodeIDArray) {

							my $NID = $_;

							foreach(@PageArray){

								chomp($_);
								my @LineArray = split  " ", $_; 

								if($_ =~ /^0/ && $NID == $LineArray[1]){

									print GPFBINFILE ("$_\n"); 
									# No need for $SUBCASE_NO[$var-1] $LOADNAME_2 PageArray already contains the subcase id and subcase name

								}elsif($NID == $LineArray[0]){	

									print GPFBINFILE ("$_\n"); 
									# No need for $SUBCASE_NO[$var-1] $LOADNAME_2 PageArray already contains the subcase id and subcase name

								}else{
									next; # Having this next statement speeds up the search
								}
							}

						}
						
					} # End of if($SizeNIA > 0){

					if($SizeMPCNIA > 0 && $MPCFlag == 1){
					
						foreach(@MPCNodeIDArray) {

							my $NID = $_;

							foreach(@PageArray){

								chomp($_);
								my @LineArray = split  " ", $_; 

								if($_ =~ /^0/ && $NID == $LineArray[1]){

									print MPCINFILE ("$_\n"); 
									# No need for $SUBCASE_NO[$var-1] $LOADNAME_2 PageArray already contains the subcase id and subcase name

								}elsif($NID == $LineArray[0]){	

									print MPCINFILE ("$_\n"); 
									# No need for $SUBCASE_NO[$var-1] $LOADNAME_2 PageArray already contains the subcase id and subcase name

								}else{
									next; # Having this next statement speeds up the search
								}
							}

						}
						
					} # End of if($SizeMPCNIA > 0){

					if($SizeFBNIA > 0 && $FBFlag == 1){
					
						foreach(@FreebodyNodeIDArray) {

							my $NID = $_;

							foreach(@PageArray){

								chomp($_);
								my @LineArray = split  " ", $_; 

								if($_ =~ /^0/ && $NID == $LineArray[1]){

									print FREEBODYINFILE ("$_\n"); 
									# No need for $SUBCASE_NO[$var-1] $LOADNAME_2 PageArray already contains the subcase id and subcase name

								}elsif($NID == $LineArray[0]){	

									print FREEBODYINFILE ("$_\n"); 
									# No need for $SUBCASE_NO[$var-1] $LOADNAME_2 PageArray already contains the subcase id and subcase name

								}else{
									next; # Having this next statement speeds up the search
								}
							}

						}
						
					} # End if($SizeFBNIA > 0){
					
					$NIAFlag = 0; 
					$MPCFlag = 0;
					$FBFlag = 0; # Turn off the flags

				} # End of if($Flag == 1){
				
				@PageArray = ();
				$PACnt = 0;
				
				# *** PLEASE NOTE : ***
				
					# This code makes sure that the correct load name is updated. Previously without
					# this code program did not get correct load names for various element types
					# As a result, it was decided that this following code would be inserted for all element types.
					# This information applies to all elemet types. You should
					# see the following code in all element types after the line:


					# }until (($line =~ /^1/) && ($line =~ /MSC/) &&  ($line =~ /NASTRAN/) && ($line =~ /PAGE/));


					# The code needs to be placed after this line (above):

					$LOADNAME = <FILE>;

					if($LOADNAME ne /^\s+$/){
						chomp ($LOADNAME);
						# Remove whitespace at the beginning and end of your string, 
						# as well as consecutive whitespace (more than one whitespace character in a row) throughout the string. 
						# $string = join(' ',split(' ',$string));

						$LOADNAME = join(' ',split(' ',$LOADNAME));						
						$LOADNAME_1 = $LOADNAME;
					}
					
				# *** END OF PLEASE NOTE ***				
			}
			
		}

		close FILE;
		close GPFBINFILE;
		close MPCINFILE;
		close FREEBODYINFILE;
		
		print("Finished reading $f06FileArray[$i]\n");
		
		$MainText->insert("end", "Finished reading $f06FileArray[$i]\n");
		$mw->update;

		# *********************************************************************************
		
	}

}

# end gpfbInitialSort -------------------------------------------------------------------------------------------------------------------------------------


# *******************************************************************************************************
#											      	  	*
# INTERNAL SUB FUNCTION NAME    : dispInitialSort				                  	*
# INTERNAL SUB FUNCTION PURPOSE : This function reads f06 files and finds displacement results and	*
#				  prints them into GRID_POINT_FORCE_BALANCE.dat file.			*	
#												  	*
# *******************************************************************************************************


sub dispInitialSort {
	
	my $SizeNIA = $_[0];		# Local size of @NodeIDArray
		
	my @NodeIDArray = ();		# Local @NodeIDArray	
	my $NIACnt = 0;

	# Locally rebuilding @NodeIDArray
	
	for(my $i = 1; $i < ($SizeNIA + 1) ; $i++){	# starting from $i = 2, because #$SizeNIA, are in $_[0]
	
		$NodeIDArray[$NIACnt] = $_[$i];	#print CODE ("NodeIDArray[$NIACnt] $NodeIDArray[$NIACnt];\n");
		$NIACnt++;
	}

	my @SUBCASE_NO = ();			# Stores subcase number
	my $var = 0;				# This variable is used to identify the last array element in @SUBCASE_NO array

	my $line = "";				# When .f06 file is being read, it stores the line being read.
	my $LOADNAME = "";			# Stores the loadname above the SBCASE or SUBCOM line
	my $LOADNAME_1 = "";			# This variable stores the $LOADNAME
	my $LOADNAME_2 = "";			# if the line ^0\s+(.+?)\s+SUBCASE has loadname in the area in brackets (.+?) 
					
	my @NodeIDArrayChk = ();
	my $NIDCHKCnt = 0;
	
	my @PageArray = ();
	my $PACnt = 0;
	my $Flag = 0;


	my $WorkingDir = cwd;	
	my $DataDir = "$WorkingDir\/DATA";

	(my $filenamepr) = split/\./,$f06FileArray[0];
	
	my $datFile = "$filenamepr.dat";

	if($SizeNIA > 0){
		
		open(DISPINFILE, ">>$datFile") or die "Unable to open input file $datFile\n";

		# ***** Header for *.dat file *****************************************************
		
		$l_time = localtime;	$gm_time = gmtime;

		print DISPINFILE ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");

		#print ("\nStarted extracting at LOCAL TIME:$l_time	GMT:$gm_time\n\n");

		foreach(@f06FileArray){

			print DISPINFILE ("\$Originated From: $_\n");

		}
		
		print DISPINFILE ("\$\n");
			
		# ***** Header for *.dat file *****************************************************

	}
		
	for (my $i =0; $i<= $#f06FileArray; $i++) {

		open(FILE, "<$f06FileArray[$i]") or die "Unable to open input file $f06FileArray[$i]\n";
				
		while (<FILE>) { # **************** IMPORTANT ********** This is the main while loop that goes through f06 Files.

			$line = $_;
			
			if (($line =~ /^1/) && ($line =~ /MSC/) &&  ($line =~ /NASTRAN/) && ($line =~ /PAGE/)) {
				$LOADNAME = <FILE>;

				if($LOADNAME ne /^\s+$/){
					chomp ($LOADNAME);
					# Remove whitespace at the beginning and end of your string, 
					# as well as consecutive whitespace (more than one whitespace character in a row) throughout the string. 
					# $string = join(' ',split(' ',$string));

					$LOADNAME = join(' ',split(' ',$LOADNAME));					
					$LOADNAME_1 = $LOADNAME;
				}
				next;
			}

			if ( ($line =~ m/^0\s+(.+?)\s+SUBCASE/) || ($line =~ m/^0\s+(.+?)\s+SUBCOM/) || ($line =~ m/^0\s+(.+?)\s+SYM/) || ($line =~ m/^0\s+(.+?)\s+SYMCOM/) || ($line =~ m/^0\s+(.+?)\s+REPCASE/) ) {

				if ($1 eq " "){
					$LOADNAME_2 = $LOADNAME_1;
				}else{$LOADNAME_2 = $1;}

				@SUBCASE_NO = split(" ", $line);
				$var = @SUBCASE_NO;

				next;
			} 
		
			
			
			if ($line =~ /D I S P L A C E M E N T   V E C T O R/) {

				do {
					$line = (<FILE>);
					chomp($line);
					my @LineArray = split  " ", $line;

					if ( ($line =~ /E\+\d\d/) || ($line =~ /0\.0/) || ($line =~ /\.0/) || ($line =~ /E\-\d\d/) ) {
						
						$PageArray[$PACnt] = "$line" . "        " . "$SUBCASE_NO[$var-1]" . "        " . "$LOADNAME_2\n";
						$PACnt++;
						
						$NodeIDArrayChk[$NIDCHKCnt] = $LineArray[0];
						$NIDCHKCnt++;	
					}

				} until (($line =~ /^1/) && ($line =~ /MSC/) &&  ($line =~ /NASTRAN/) && ($line =~ /PAGE/));

				# The following foreach loop checks the node ids in the PageArray (Also @NodeIDArrayChk array)
				# PageArray contains the whole line information but NodeIDArrayChk array contains only the node ids
				# If the Node ID array contains a node that also exists in PageArray
				# then we turn the flag on and do the foreachloops loop starting with if($Flag == 1){...
				# This bit of the code speeds up the search. 
				# Note Quick sort algorithm might be useful, 				
				
				if($SizeNIA > 0){
				
					foreach(@NodeIDArray){

						my $NodeID = $_;

						foreach(@NodeIDArrayChk){

							if($NodeID == $_){

								$Flag = 1;
							}
						}
					}
				
				}
				
				@NodeIDArrayChk = (); # This array contains the node ids that exist in the PageArray
				$NIDCHKCnt =0;	      # This is a counter for NodeIDArrayChk array

				# The following foreach loop prints the selected node ids
				# because the flag is turned on, we know that PageArray contains at least one of the nodes
				# we are interested in			
				
				if($Flag == 1){
				
					if($SizeNIA > 0){
					
						foreach(@NodeIDArray) {

							my $NID = $_;

							foreach(@PageArray){

								chomp($_);
								my @LineArray = split  " ", $_; 

								if($NID == $LineArray[0]){	

									print DISPINFILE ("$_\n"); 
									# No need for $SUBCASE_NO[$var-1] $LOADNAME_2 PageArray already contains the subcase id and subcase name

								}else{
									next; # Having this next statement speeds up the search
								}
							}

						}
						
					} # End of if($SizeNIA > 0){
					
					$Flag = 0; # Turn off the flag

				} # End of if($Flag == 1){
				
				@PageArray = ();
				$PACnt = 0;
				
				# *** PLEASE NOTE : ***
				
					# This code makes sure that the correct load name is updated. Previously without
					# this code program did not get correct load names for various element types
					# As a result, it was decided that this following code would be inserted for all element types.
					# This information applies to all elemet types. You should
					# see the following code in all element types after the line:


					# }until (($line =~ /^1/) && ($line =~ /MSC/) &&  ($line =~ /NASTRAN/) && ($line =~ /PAGE/));


					# The code needs to be placed after this line (above):

					$LOADNAME = <FILE>;

					if($LOADNAME ne /^\s+$/){
						chomp ($LOADNAME);
						# Remove whitespace at the beginning and end of your string, 
						# as well as consecutive whitespace (more than one whitespace character in a row) throughout the string. 
						# $string = join(' ',split(' ',$string));

						$LOADNAME = join(' ',split(' ',$LOADNAME));						
						$LOADNAME_1 = $LOADNAME;
					}
					
				# *** END OF PLEASE NOTE ***				
			}
			
		}

		close FILE;
		close DISPINFILE;
		
		print("Finished reading $f06FileArray[$i]\n");
		
		$MainText->insert("end", "Finished reading $f06FileArray[$i]\n");
		$mw->update;

		# *********************************************************************************
		
	}

}

# end dispInitialSort -------------------------------------------------------------------------------------------------------------------------------------


# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : fastenerInitialSort			                  	  *
# INTERNAL SUB FUNCTION PURPOSE : This function reads f06 files and finds CBEAMFC results and     *
#				  prints them into CBEAMFC_FORCE_TABLE.dat file. It is quicker	  *
# 				  then the INSORT function, because INSORT function creates       *
#				  subcase id text file and looks for superelements                *
#												  *
# *************************************************************************************************


sub fastenerInitialSort {
	
	my $SizeEIA = $_[0];		# Local size of @ElmIDArray
		
	my @ElmIDArray = ();		# Local @ElmIDArray	
	my $EIDCnt = 0;

	# Locally rebuilding @ElmIDArray
	
	for(my $i = 1; $i < ($SizeEIA + 1) ; $i++){	# starting from $i = 2, because #$SizeNIA, are in $_[0]
	
		$ElmIDArray[$EIDCnt] = $_[$i];	#print CODE ("ElmIDArray[$EIDCnt] $ElmIDArray[$EIDCnt];\n");
		$EIDCnt++;
	}

	foreach(@ElmIDArray){
	
		print "ElmIDArray: $_\n";
	}

	my @SUBCASE_NO = ();			# Stores subcase number
	my $var = 0;				# This variable is used to identify the last array element in @SUBCASE_NO array

	my $line = "";				# When .f06 file is being read, it stores the line being read.
	my $LOADNAME = "";			# Stores the loadname above the SBCASE or SUBCOM line
	my $LOADNAME_1 = "";			# This variable stores the $LOADNAME
	my $LOADNAME_2 = "";			# if the line ^0\s+(.+?)\s+SUBCASE has loadname in the area in brackets (.+?) 
					
	my @ElmIDArrayChk = ();
	my $EIDCHKCnt = 0;
	
	my @PageArray = ();
	my $PACnt = 0;
	my $Flag = 0;

	my $CBEAMFC_Element_Id = 0; 	# Elemnt Id declaration for CBEAM FORCES 
	my @CBEAMFC_Line_Array = ();

	my $WorkingDir = cwd;	
	my $DataDir = "$WorkingDir\/DATA";

	for (my $i = 0; $i<= $#f06FileArray; $i++) {
	
		(my $filenamepr) = split/\./,$f06FileArray[$i];
		
		print "filenamepr: $filenamepr\n";
	
		$cbardatFileArray[$i] = "$filenamepr.cbardat";
		$cbeamdatFileArray[$i] = "$filenamepr.cbeamdat";
		$cbushdatFileArray[$i] = "$filenamepr.cbushdat";
		$croddatFileArray[$i] = "$filenamepr.croddat";
		
		print "cbardatFileArray[$i]: $cbardatFileArray[$i]\n";

		open(CBARINFILE, ">$cbardatFileArray[$i]") or die "Unable to open input file $cbardatFileArray[$i]\n";
		open(CBEAMINFILE, ">$cbeamdatFileArray[$i]") or die "Unable to open input file $cbeamdatFileArray[$i]\n";
		open(CBUSHINFILE, ">$cbushdatFileArray[$i]") or die "Unable to open input file $cbushdatFileArray[$i]\n";
		open(CRODINFILE, ">$croddatFileArray[$i]") or die "Unable to open input file $croddatFileArray[$i]\n";
	
		# ***** Header for *.dat file *****************************************************
	
		$l_time = localtime;	$gm_time = gmtime;

		print CBARINFILE ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");
		print CBEAMINFILE ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");
		print CBUSHINFILE ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");
		print CRODINFILE ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");
		
		#print ("\nStarted extracting at LOCAL TIME:$l_time	GMT:$gm_time\n\n");

		print CBARINFILE ("\$Originated From: $f06FileArray[$i]\n");
		print CBEAMINFILE ("\$Originated From: $f06FileArray[$i]\n");
		print CBUSHINFILE ("\$Originated From: $f06FileArray[$i]\n");
		print CRODINFILE ("\$Originated From: $f06FileArray[$i]\n");

		print CBARINFILE ("\$\n");
		print CBEAMINFILE ("\$\n");
		print CBARINFILE ("\$\n");
		print CBARINFILE ("\$\n");
		
		# ***** Header for *.dat file *****************************************************
	}
		
	for (my $i = 0; $i<= $#f06FileArray; $i++) {

		open(FILE, "<$f06FileArray[$i]") or die "Unable to open input file $f06FileArray[$i]\n";
				
		while (<FILE>) { # **************** IMPORTANT ********** This is the main while loop that goes through f06 Files.

			$line = $_;
			
			if (($line =~ /^1/) && ($line =~ /MSC/) &&  ($line =~ /NASTRAN/) && ($line =~ /PAGE/)) {
				$LOADNAME = <FILE>;

				if($LOADNAME ne /^\s+$/){
					chomp ($LOADNAME);
					# Remove whitespace at the beginning and end of your string, 
					# as well as consecutive whitespace (more than one whitespace character in a row) throughout the string. 
					# $string = join(' ',split(' ',$string));

					$LOADNAME = join(' ',split(' ',$LOADNAME));					
					$LOADNAME_1 = $LOADNAME;
				}
				next;
			}

			if ( ($line =~ m/^0\s+(.+?)\s+SUBCASE/) || ($line =~ m/^0\s+(.+?)\s+SUBCOM/) || ($line =~ m/^0\s+(.+?)\s+SYM/) || ($line =~ m/^0\s+(.+?)\s+SYMCOM/) || ($line =~ m/^0\s+(.+?)\s+REPCASE/) ) {

				if ($1 eq " "){
					$LOADNAME_2 = $LOADNAME_1;
				}else{$LOADNAME_2 = $1;}

				@SUBCASE_NO = split(" ", $line);
				$var = @SUBCASE_NO;

				next;
			} 
			

			if( ($line =~ /F O R C E S   I N   B A R   E L E M E N T S/) && ($line =~ /( C B A R )/) ) {

				do {
				         $line = (<FILE>);
				         chomp($line);
					 my @LineArray = split  " ", $line;
					 
					 if ( ($line =~ /E\+\d\d/) || ($line =~ /0\.0/) || ($line =~ /\.0/) || ($line =~ /E\-\d\d/) ) {
					    
						$PageArray[$PACnt] = "$line" . "        " . "$SUBCASE_NO[$var-1]" . "        " . "$LOADNAME_2\n";
						$PACnt++;
						
						$ElmIDArrayChk[$EIDCHKCnt] = $LineArray[0];
						$EIDCHKCnt++;
					 }
					 
				}until (($line =~ /^1/) && ($line =~ /MSC/) &&  ($line =~ /NASTRAN/) && ($line =~ /PAGE/));

				# The following foreach loop checks the node ids in the PageArray (Also @ElmIDArrayChk array)
				# PageArray contains the whole line information but NodeIDArrayChk array contains only the node ids
				# If the Elm ID array contains an element that also exists in PageArray
				# then we turn the flag on and do the foreachloops loop starting with if($Flag == 1){...
				# This bit of the code speeds up the search. 
				# Note Quick sort algorithm might be useful, 				
				
				if($SizeEIA > 0){
				
					foreach(@ElmIDArray){

						my $ElmID = $_;

						foreach(@ElmIDArrayChk){

							if($ElmID == $_){

								$Flag = 1;
							}
						}
					}
				
				}
				
				@ElmIDArrayChk = (); # This array contains the node ids that exist in the PageArray
				$EIDCHKCnt =0;	      # This is a counter for ElmIDArrayChk array

				# The following foreach loop prints the selected node ids
				# because the flag is turned on, we know that PageArray contains at least one of the nodes
				# we are interested in			
				
				if($Flag == 1){
				
					if($SizeEIA > 0){
					
						foreach(@ElmIDArray) {

							my $EID = $_;

							foreach(@PageArray){

								chomp($_);
								my @LineArray = split  " ", $_; 

								if($EID == $LineArray[0]){	

									print CBARINFILE ("$_\n"); 
									# No need for $SUBCASE_NO[$var-1] $LOADNAME_2 PageArray already contains the subcase id and subcase name

								}else{
									next; # Having this next statement speeds up the search
								}
							}

						}
						
					} # End of if($SizeNIA > 0){
					
					$Flag = 0; # Turn off the flag

				} # End of if($Flag == 1){
				
				@PageArray = ();
				$PACnt = 0;

				# *** PLEASE NOTE : Following pieace of code is same as sub LOADNAME in INSORT.exe. ***
				
					# This code makes sure that the correct load name is updated. Previously without
					# this code program did not get correct load names for various element types
					# As a result, it was decided that this following code would be inserted for all element types.
					# This information applies to all elemet types. You should
					# see the following code in all element types after the line:


					# }until (($line =~ /^1/) && ($line =~ /MSC/) &&  ($line =~ /NASTRAN/) && ($line =~ /PAGE/));


					# The code needs to be placed just after this line (above):

					$LOADNAME = <FILE>;

					if($LOADNAME ne /^\s+$/){
						chomp ($LOADNAME);
						# Remove whitespace at the beginning and end of your string, 
						# as well as consecutive whitespace (more than one whitespace character in a row) throughout the string. 
						# $string = join(' ',split(' ',$string));

						$LOADNAME = join(' ',split(' ',$LOADNAME));						
						$LOADNAME_1 = $LOADNAME;
					}

				# *** END OF PLEASE NOTE ***
				
			} # End of if( ($line =~ /F O R C E S   I N   B A R   E L E M E N T S/) && ($line =~ /( C B A R )/) ) {

			if( ($line =~ /F O R C E S   I N   B E A M   E L E M E N T S/) && ($line =~ /( C B E A M )/) ) {

				do {
				 	$line = (<FILE>);
				 	chomp($line);
					
					if ( ($line =~ /E\+\d\d/) || ($line =~ /0\.0/) || ($line =~ /\.0/) || ($line =~ /E\-\d\d/) || ($line =~ /^0\s+(\d+)$/) || ($line =~ /^\s+(\d+)$/) || ($line =~ /^0(\d+)$/) || ($line =~ /^0(.+?)/) || ($line =~ /^0(.+?)$/) ) {

						if( ($line =~ /^0\s+(\d+)$/) || ($line =~ /^0(\d+)$/) || ($line =~ /^\s+(\d+)$/) || ($line =~ /^0(.+?)/) || ($line =~ /^0(.+?)$/) ){
							$CBEAMFC_Element_Id = $1;
						}

						@CBEAMFC_Line_Array = split(" ", $line);

						if( (defined $CBEAMFC_Line_Array[1]) && ($CBEAMFC_Line_Array[1]== 0) ){
							#print CBEAMINFILE ("$CBEAMFC_Element_Id    $line    $SUBCASE_NO[$var-1]    $LOADNAME_2\n");

							$PageArray[$PACnt] = "$CBEAMFC_Element_Id" . "        " . "$line" . "        " . "$SUBCASE_NO[$var-1]" . "        " . "$LOADNAME_2\n";
							$PACnt++;
						
							$ElmIDArrayChk[$EIDCHKCnt] = $CBEAMFC_Element_Id;
							$EIDCHKCnt++;

						}elsif( (defined $CBEAMFC_Line_Array[1]) && ($CBEAMFC_Line_Array[1] == 1) ){
							#print CBEAMINFILE ("$CBEAMFC_Element_Id    $line    $SUBCASE_NO[$var-1]    $LOADNAME_2\n");
						
							$PageArray[$PACnt] = "$CBEAMFC_Element_Id" . "        " . "$line" . "        " . "$SUBCASE_NO[$var-1]" . "        " . "$LOADNAME_2\n";
							$PACnt++;
						
							$ElmIDArrayChk[$EIDCHKCnt] = $CBEAMFC_Element_Id;
							$EIDCHKCnt++;
						}
					}
					
				}until (($line =~ /^1/) && ($line =~ /MSC/) &&  ($line =~ /NASTRAN/) && ($line =~ /PAGE/));

				# The following foreach loop checks the node ids in the PageArray (Also @ElmIDArrayChk array)
				# PageArray contains the whole line information but NodeIDArrayChk array contains only the node ids
				# If the Elm ID array contains an element that also exists in PageArray
				# then we turn the flag on and do the foreachloops loop starting with if($Flag == 1){...
				# This bit of the code speeds up the search. 
				# Note Quick sort algorithm might be useful, 				
				
				if($SizeEIA > 0){
				
					foreach(@ElmIDArray){

						my $ElmID = $_;

						foreach(@ElmIDArrayChk){

							if($ElmID == $_){

								$Flag = 1;
							}
						}
					}
				
				}
				
				@ElmIDArrayChk = (); # This array contains the node ids that exist in the PageArray
				$EIDCHKCnt =0;	      # This is a counter for ElmIDArrayChk array

				# The following foreach loop prints the selected node ids
				# because the flag is turned on, we know that PageArray contains at least one of the nodes
				# we are interested in			
				
				if($Flag == 1){
				
					if($SizeEIA > 0){
					
						foreach(@ElmIDArray) {

							my $EID = $_;

							foreach(@PageArray){

								chomp($_);
								my @LineArray = split  " ", $_; 

								if($EID == $LineArray[0]){	

									print CBEAMINFILE ("$_\n"); 
									# No need for $SUBCASE_NO[$var-1] $LOADNAME_2 PageArray already contains the subcase id and subcase name

								}else{
									next; # Having this next statement speeds up the search
								}
							}

						}
						
					} # End of if($SizeNIA > 0){
					
					$Flag = 0; # Turn off the flag

				} # End of if($Flag == 1){
				
				@PageArray = ();
				$PACnt = 0;


				# *** PLEASE NOTE : Following pieace of code is same as sub LOADNAME in INSORT.exe. ***
				
					# This code makes sure that the correct load name is updated. Previously without
					# this code program did not get correct load names for various element types
					# As a result, it was decided that this following code would be inserted for all element types.
					# This information applies to all elemet types. You should
					# see the following code in all element types after the line:


					# }until (($line =~ /^1/) && ($line =~ /MSC/) &&  ($line =~ /NASTRAN/) && ($line =~ /PAGE/));


					# The code needs to be placed just after this line (above):

					$LOADNAME = <FILE>;

					if($LOADNAME ne /^\s+$/){
						chomp ($LOADNAME);
						# Remove whitespace at the beginning and end of your string, 
						# as well as consecutive whitespace (more than one whitespace character in a row) throughout the string. 
						# $string = join(' ',split(' ',$string));

						$LOADNAME = join(' ',split(' ',$LOADNAME));						
						$LOADNAME_1 = $LOADNAME;
					}

				# *** END OF PLEASE NOTE ***
				
			} # End of if( ($line =~ /F O R C E S   I N   B E A M   E L E M E N T S/) && ($line =~ /( C B E A M )/) ) {

			if( ($line =~ /F O R C E S   I N   B U S H   E L E M E N T S/) && ($line =~ /( C B U S H )/) ) {

				do {
					 $line = (<FILE>);
					 chomp($line);
					 

					 if ( ($line =~ /E\+\d\d/) || ($line =~ /0\.0/) || ($line =~ /\.0/) || ($line =~ /E\-\d\d/) ) {

						if ( ($line =~ m/^0\s+(.*)/) || ($line =~ m/^\s+(.*)/) ) {

							$PageArray[$PACnt] = "$1" . "        " . "$SUBCASE_NO[$var-1]" . "        " . "$LOADNAME_2\n";
							$PACnt++;
							
							my @LineArray = split  " ", $1;
							
							$ElmIDArrayChk[$EIDCHKCnt] = $LineArray[0];
							$EIDCHKCnt++;
						}
					 }

				}until (($line =~ /^1/) && ($line =~ /MSC/) &&  ($line =~ /NASTRAN/) && ($line =~ /PAGE/));

				# The following foreach loop checks the node ids in the PageArray (Also @ElmIDArrayChk array)
				# PageArray contains the whole line information but NodeIDArrayChk array contains only the node ids
				# If the Elm ID array contains an element that also exists in PageArray
				# then we turn the flag on and do the foreachloops loop starting with if($Flag == 1){...
				# This bit of the code speeds up the search. 
				# Note Quick sort algorithm might be useful, 				
				
				if($SizeEIA > 0){
				
					foreach(@ElmIDArray){

						my $ElmID = $_;

						foreach(@ElmIDArrayChk){

							if($ElmID == $_){

								$Flag = 1;
							}
						}
					}
				
				}
				
				@ElmIDArrayChk = (); # This array contains the node ids that exist in the PageArray
				$EIDCHKCnt =0;	      # This is a counter for ElmIDArrayChk array

				# The following foreach loop prints the selected node ids
				# because the flag is turned on, we know that PageArray contains at least one of the nodes
				# we are interested in			
				
				if($Flag == 1){
				
					if($SizeEIA > 0){
					
						foreach(@ElmIDArray) {

							my $EID = $_;

							foreach(@PageArray){

								chomp($_);
								my @LineArray = split  " ", $_; 

								if($EID == $LineArray[0]){	

									print CBUSHINFILE ("$_\n"); 
									# No need for $SUBCASE_NO[$var-1] $LOADNAME_2 PageArray already contains the subcase id and subcase name

								}else{
									next; # Having this next statement speeds up the search
								}
							}

						}
						
					} # End of if($SizeNIA > 0){
					
					$Flag = 0; # Turn off the flag

				} # End of if($Flag == 1){
				
				@PageArray = ();
				$PACnt = 0;


				# *** PLEASE NOTE : Following pieace of code is same as sub LOADNAME in INSORT.exe. ***
				
					# This code makes sure that the correct load name is updated. Previously without
					# this code program did not get correct load names for various element types
					# As a result, it was decided that this following code would be inserted for all element types.
					# This information applies to all elemet types. You should
					# see the following code in all element types after the line:


					# }until (($line =~ /^1/) && ($line =~ /MSC/) &&  ($line =~ /NASTRAN/) && ($line =~ /PAGE/));


					# The code needs to be placed just after this line (above):

					$LOADNAME = <FILE>;

					if($LOADNAME ne /^\s+$/){
						chomp ($LOADNAME);
						# Remove whitespace at the beginning and end of your string, 
						# as well as consecutive whitespace (more than one whitespace character in a row) throughout the string. 
						# $string = join(' ',split(' ',$string));

						$LOADNAME = join(' ',split(' ',$LOADNAME));						
						$LOADNAME_1 = $LOADNAME;
					}

				# *** END OF PLEASE NOTE ***
				
			} # End of if( ($line =~ /F O R C E S   I N   B U S H   E L E M E N T S/) && ($line =~ /( C B U S H )/) ) {

			if ( ($line =~ /F O R C E S   I N   R O D   E L E M E N T S/) && ($line =~ /( C R O D )/) ) {

				do {
					$line = (<FILE>);
					chomp($line);
					
					if ( ($line =~ /E\+\d\d/) || ($line =~ /0\.0/) || ($line =~ /\.0/) || ($line =~ /E\-\d\d/) )  {

						my @CRODFC_Array = split (" ", $line);
						my $Size_Of_CRODFC_Array = @CRODFC_Array;

						if($Size_Of_CRODFC_Array == 6){
							
							$PageArray[$PACnt] = "$CRODFC_Array[0]" . "        " . "$CRODFC_Array[1]" . "        " . "$CRODFC_Array[2]" . "        " . "$SUBCASE_NO[$var-1]" . "        " . "$LOADNAME_2\n";
							$PACnt++;
													
							$ElmIDArrayChk[$EIDCHKCnt] = $CRODFC_Array[0];
							$EIDCHKCnt++;

							$PageArray[$PACnt] = "$CRODFC_Array[3]" . "        " . "$CRODFC_Array[4]" . "        " . "$CRODFC_Array[5]" . "        " . "$SUBCASE_NO[$var-1]" . "        " . "$LOADNAME_2\n";
							$PACnt++;

							$ElmIDArrayChk[$EIDCHKCnt] = $CRODFC_Array[3];
							$EIDCHKCnt++;

						}elsif($Size_Of_CRODFC_Array == 3){
							
							$PageArray[$PACnt] = "$CRODFC_Array[0]" . "        " . "$CRODFC_Array[1]" . "        " . "$CRODFC_Array[2]" . "        " . "$SUBCASE_NO[$var-1]" . "        " . "$LOADNAME_2\n";
							$PACnt++;
													
							$ElmIDArrayChk[$EIDCHKCnt] = $CRODFC_Array[0];
							$EIDCHKCnt++;	
						}
					}
				} until (($line =~ /^1/) && ($line =~ /MSC/) &&  ($line =~ /NASTRAN/) && ($line =~ /PAGE/));


				# The following foreach loop checks the node ids in the PageArray (Also @ElmIDArrayChk array)
				# PageArray contains the whole line information but NodeIDArrayChk array contains only the node ids
				# If the Elm ID array contains an element that also exists in PageArray
				# then we turn the flag on and do the foreachloops loop starting with if($Flag == 1){...
				# This bit of the code speeds up the search. 
				# Note Quick sort algorithm might be useful, 				
				
				if($SizeEIA > 0){
				
					foreach(@ElmIDArray){

						my $ElmID = $_;

						foreach(@ElmIDArrayChk){

							if($ElmID == $_){

								$Flag = 1;
							}
						}
					}
				
				}
				
				@ElmIDArrayChk = (); # This array contains the node ids that exist in the PageArray
				$EIDCHKCnt =0;	      # This is a counter for ElmIDArrayChk array

				# The following foreach loop prints the selected node ids
				# because the flag is turned on, we know that PageArray contains at least one of the nodes
				# we are interested in			
				
				if($Flag == 1){
				
					if($SizeEIA > 0){
					
						foreach(@ElmIDArray) {

							my $EID = $_;

							foreach(@PageArray){

								chomp($_);
								my @LineArray = split  " ", $_; 

								if($EID == $LineArray[0]){	

									print CRODINFILE ("$_\n"); 
									# No need for $SUBCASE_NO[$var-1] $LOADNAME_2 PageArray already contains the subcase id and subcase name

								}else{
									next; # Having this next statement speeds up the search
								}
							}

						}
						
					} # End of if($SizeNIA > 0){
					
					$Flag = 0; # Turn off the flag

				} # End of if($Flag == 1){
				
				@PageArray = ();
				$PACnt = 0;

				# *** PLEASE NOTE : Following pieace of code is same as sub LOADNAME in INSORT.exe. ***
				
					# This code makes sure that the correct load name is updated. Previously without
					# this code program did not get correct load names for various element types
					# As a result, it was decided that this following code would be inserted for all element types.
					# This information applies to all elemet types. You should
					# see the following code in all element types after the line:


					# }until (($line =~ /^1/) && ($line =~ /MSC/) &&  ($line =~ /NASTRAN/) && ($line =~ /PAGE/));


					# The code needs to be placed just after this line (above):

					$LOADNAME = <FILE>;

					if($LOADNAME ne /^\s+$/){
						chomp ($LOADNAME);
						# Remove whitespace at the beginning and end of your string, 
						# as well as consecutive whitespace (more than one whitespace character in a row) throughout the string. 
						# $string = join(' ',split(' ',$string));

						$LOADNAME = join(' ',split(' ',$LOADNAME));						
						$LOADNAME_1 = $LOADNAME;
					}

				# *** END OF PLEASE NOTE ***
			} # End of if ( ($line =~ /F O R C E S   I N   R O D   E L E M E N T S/) && ($line =~ /( C R O D )/) ) { 
	
		}

		close FILE;
		close CBARINFILE;
		close CBEAMINFILE;
		close CBUSHINFILE;
		close CRODINFILE;
		
		print("Finished reading $f06FileArray[$i]\n");
		
		$MainText->insert("end", "Finished reading $f06FileArray[$i]\n");
		$mw->update;

		# *********************************************************************************
	}
}


# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : extractInterfaceLoads				                  *
# INTERNAL SUB FUNCTION PURPOSE : This function extracts grid point forces and moments from       *
#                                 initial sort file						  *
#												  *
# *************************************************************************************************


sub extractInterfaceLoads {

	# 1. Setup the input values

	my $SizeIIA = 0;
	my $SizeNXYZCA = 0;
	
	my @InterfaceInfoArray = ();
	my $IIACnt = 0;
	
	my @NodeXYZCoordArray = ();
	my $NXYZCACnt = 0;
	
	#&extractInterfaceLoads($SizeIIA, $SizeNXYZCA, @InterfaceInfoArray, @NodeXYZCoordArray);

	if(defined $_[0] && $_[0] > 0){ 
	
		$SizeIIA = $_[0];		# Local size of @NodeIDArray
	}

	if(defined $_[1] && $_[1] > 0){ 
	
		$SizeNXYZCA = $_[1];		# Local size of @NodeIDArray
	}

	# Locally rebuilding @InterfaceInfoArray
	
	for(my $i = 2; $i < ($SizeIIA + 2) ; $i++){	

		#&extractInterfaceLoads($SizeIIA, $SizeNXYZCA, @InterfaceInfoArray, @NodeXYZCoordArray);
	
		$InterfaceInfoArray[$IIACnt] = $_[$i];
		$IIACnt++;
	}

	# Locally rebuilding @NodeXYZCoordArray
	
	for(my $i = (2 + $SizeIIA); $i < (2 + $SizeIIA + $SizeNXYZCA); $i++){ 
		
		#&extractInterfaceLoads($SizeIIA, $SizeNXYZCA, @InterfaceInfoArray, @NodeXYZCoordArray);
		
		$NodeXYZCoordArray[$NXYZCACnt] = $_[$i];
		$NXYZCACnt++;
	}

	#open (CODE, ">>$CurrentDir/ProgrammingLog.dat") or die "Unable to write input file ProgrammingLog.dat\n";
	
	#foreach(@InterfaceInfoArray){
	
		#print "InterfaceInfoArray: $_\n";
	
	#}

	my $RefCoord = 0;

	my $XSummed = 0;
	my $YSummed = 0;
	my $ZSummed = 0;
		
	my $ANALYSIS_COORD = -1;
	my $REF_COORD = -1;
	
	my $scale = 0;

	my $POINT_ID = 0;
	my $IDENT_TEXT = 0;
	my $NODE_ID = 0; 
	
	my $X = 0; 
	my $Y = 0; 
	my $Z = 0; 
	
	my $Fx = 0; 
	my $Fy = 0;
	my $Fz = 0;
	
	my $Mx = 0;
	my $My = 0;
	my $Mz = 0;
	
	my $LOAD_NO = 0; 
	my $LOAD_NAME = "LC";


format INTERFACERESULTS_TOP =

				@||||||||||||||||||||||||||||||||||||||||||||||||||                    Pg. @<<<<<
				"Grid Point Force Balance about a Summation Point",                     $%

 Point_Id   Identification_Text    Node_Id     Analy.Coord    Ref.Coord        X              Y            Z          X_Summed      Y_Summed      Z_Summed          Fx            Fy            Fz            Mx            My            Mz         Load_No      Load_Name
----------- ------------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- 
. 

format INTERFACERESULTS =
@<<<<<<<<<<<@||||||||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @*
$POINT_ID,$IDENT_TEXT, $NODE_ID, $ANALYSIS_COORD, $REF_COORD, $X, $Y, $Z, $XSummed, $YSummed, $ZSummed, $Fx, $Fy, $Fz, $Mx, $My, $Mz, $LOAD_NO, $LOAD_NAME 
.


format INTERFACETOTALS_TOP =

				@||||||||||||||||||||||||||||||||||||||||||||||||||                    Pg. @<<<<<
				"Interface Load Totals for each Summation Position",		        $%

 Point_Id   Identification_Text    Node_Id     Analy.Coord    Ref.Coord        X              Y            Z          X_Summed      Y_Summed      Z_Summed          Fx            Fy            Fz            Mx            My            Mz         Load_No      Load_Name
----------- ------------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- 
. 

format INTERFACETOTALS =
@<<<<<<<<<<<@||||||||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @*
$POINT_ID,$IDENT_TEXT, $NODE_ID, $ANALYSIS_COORD, $REF_COORD, $X, $Y, $Z, $XSummed, $YSummed, $ZSummed, $Fx, $Fy, $Fz, $Mx, $My, $Mz, $LOAD_NO, $LOAD_NAME 
.



format INTERFACEDATA_TOP =

				@||||||||||||||||||||||||||||||||||||||||||||||||||                    Pg. @<<<<<
				"Grid Point Force Balance about a Summation Point",                     $%

 Point_Id   Identification_Text    Node_Id     Analy.Coord    Ref.Coord        X              Y            Z          X_Summed      Y_Summed      Z_Summed          Fx            Fy            Fz            Mx            My            Mz         Load_No      Load_Name
----------- ------------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- 
. 

format INTERFACEDATA =
@<<<<<<<<<<<@||||||||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @*
$POINT_ID,$IDENT_TEXT, $NODE_ID, $ANALYSIS_COORD, $REF_COORD, $X, $Y, $Z, $XSummed, $YSummed, $ZSummed, $Fx, $Fy, $Fz, $Mx, $My, $Mz, $LOAD_NO, $LOAD_NAME 
.


format INTERFACESUMMED_TOP =

				@||||||||||||||||||||||||||||||||||||||||||||||||||                    Pg. @<<<<<
				"Grid Point Force Balance about a Summation Point",                     $%

 Point_Id   Identification_Text    Node_Id     Analy.Coord    Ref.Coord        X              Y            Z          X_Summed      Y_Summed      Z_Summed          Fx            Fy            Fz            Mx            My            Mz         Load_No      Load_Name
----------- ------------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- 
. 

format INTERFACESUMMED =
@<<<<<<<<<<<@||||||||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @*
$POINT_ID,$IDENT_TEXT, $NODE_ID, $ANALYSIS_COORD, $REF_COORD, $X, $Y, $Z, $XSummed, $YSummed, $ZSummed, $Fx, $Fy, $Fz, $Mx, $My, $Mz, $LOAD_NO, $LOAD_NAME 
.


	my $WorkingDir = cwd;	
	my $DataDir = "$WorkingDir\/DATA";
		
	# ******************** Interface totals file *******************
	
	(my $intfilenamepr) = split/\./,$f06FileArray[0];

	my @intfilenamepr = split "\/",$intfilenamepr;
	my $Intsize = @intfilenamepr;
	
	my $interfacetotalsFile = "$intfilenamepr.interfacetotals";
	my $interfaceresultsFile = "$intfilenamepr.interfaceresults";

	open (INTERFACETOTALS, ">$interfacetotalsFile") or die "could not open outfile $interfacetotalsFile";
	open (INTERFACERESULTS, ">$interfaceresultsFile") or die "could not open outfile $interfaceresultsFile";
		
	print INTERFACETOTALS ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");
	print INTERFACERESULTS ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");

	for (my $i =0; $i<= $#f06FileArray; $i++) {
	
		print INTERFACETOTALS ("\$Originated From: $f06FileArray[$i]\n");
		print INTERFACERESULTS ("\$Originated From: $f06FileArray[$i]\n");
	}

	print INTERFACETOTALS ("\$\n");
	print INTERFACERESULTS ("\$\n");
	
	# ******************* Interface totals file ********************
	
	for (my $i =0; $i<= $#f06FileArray; $i++) {
	
		(my $filenamepr) = split/\./,$f06FileArray[$i];

		my @filenamepr = split "\/",$filenamepr;
		my $Size = @filenamepr;

		$interfacedataFileArray[$i] = "$DataDir\/$filenamepr[$Size-1].interfacedata";				
		$interfacesummedFileArray[$i] = "$DataDir\/$filenamepr[$Size-1].interfacesummed";
	}
       
	for (my $i =0; $i<= $#f06FileArray; $i++) {

		my @ElmPosArray = ();
		my $EPACnt = 0;

		my $NodeIDCnt = 0; # Counts the number of nodes, indicates which node id is active. 
				   # Note there are more than one line for each node. Therefore
				   # This counter indicates which node it is 

		my $SubcaseIDCnt = 0;

		open(INFILE, "<$datFileArray[$i]") or die "Unable to open input file $datFileArray[$i]\n";
		
		#open (GPFB, ">$gpfbFileArray[$i]") or die "could not open outfile $gpfbFileArray[$i]"; # DO NOT DELETE

		open (INTERFACEDATA, ">$interfacedataFileArray[$i]") or die "could not open outfile $interfacedataFileArray[$i]";
		open (INTERFACESUMMED, ">$interfacesummedFileArray[$i]") or die "could not open outfile $interfacesummedFileArray[$i]";

		# ***** Header for *.gpfb file *****************************************************
		
		$l_time =localtime;	$gm_time = gmtime;

		print INTERFACEDATA ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");
		print INTERFACESUMMED ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");

		print INTERFACEDATA ("\$Originated From: $f06FileArray[$i]\n");
		print INTERFACESUMMED ("\$Originated From: $f06FileArray[$i]\n");			

		print INTERFACEDATA ("\$NOTE: IF THE REFERENCE COORDINATE ID IS BIGGER THAN ZERO,OR THE ANALYSIS COORDINATE ID IS BIGGER THAN ZERO, Fx Fy Fz Mx My Mz\n");
		print INTERFACEDATA ("\$      VALUES ARE TRANSFORMED ACCORDINGLY AND THE THE TRANSFORMED Fx Fy Fz Mx My Mz VALUES ARE PRINTED. IN THIS FILE THE TRANSFORMED\n");
		print INTERFACEDATA ("\$      AND SUMMED VALUES FOR EACH NODE IS PRINTED FIRST. THE *TOTALS* ARE CALCULATED AND PRINTED USING TRANSFORMED AND SUMMED VALUES.\n");
	
		print INTERFACESUMMED ("\$NOTE: THE DIFFERENCE BETWEEN THIS FILE AND THE FILE WITH \".summed\" EXTENSION IS THE WAY IN WHICH TRANSFORMED AND SUMMED\n");
		print INTERFACESUMMED ("\$      Fx Fy Fz Mx My Mz VALUES ARE PRINTED. IF THE REFERENCE COORDINATE ID AND THE ANALYSIS COORDINATE ID ARE BOTH BIGGER\n");
		print INTERFACESUMMED ("\$      THAN ZERO, Fx Fy Fz Mx My Mz VALUES ARE TRANSFORMED TO COORD ZERO FIRST AND THEN PRINTED IN IN THIS FILE. AND THEN SUMMATION IS CALCULATED.\n");
		print INTERFACESUMMED ("\$      FOR EXAMPLE IF: ANALYSIS COORD ID IS 2 AND REF.COORD ID IS 4, PRINTED RESULTS FOR EACH NODE IN THIS FILE WILL BE DEFINED IN COORD 0\n");
		print INTERFACESUMMED ("\$      TOTAL RESULTS WILL BE DEFINED IN COORD 4. WHEREAS IN THE FILE WITH \".summed\" EXTENSION, PRINTED RESULTS FOR EACH NODE AND THE TOTAL\n");		
		print INTERFACESUMMED ("\$      RESULTS WILL BE DEFINED IN COORD 4.\n");		
		
		print INTERFACEDATA ("\$\n");
		print INTERFACESUMMED ("\$\n");		

		# ***** Header for *.gpfb file *****************************************************

		for(my $i = 0; $i < 3 ; $i++) {
			<INFILE>;
		}

		$NODE_ID = 0; $Fx = 0; $Fy = 0; $Fz = 0; $Mx = 0; $My = 0; $Mz = 0; $LOAD_NO = 0; $LOAD_NAME = "LC";

		my $line = <INFILE>;
		my @column = split " ", $line;
		my $size = @column;

		SUBCASE: while (defined $line) {

			my $subcaseid   = 0;
			my $subcasename = "";

			$NodeIDCnt = 0; # Counts the number of nodes, indicates which node id is active.

			if($size == 10){ # Program determines where the subcase id and name is for each line

                            $subcaseid = $column[8];
                            $subcasename = $column[9];

			}elsif($column[0] =~ /^0/ &&  $size == 11){

                            $subcaseid = $column[9];
                            $subcasename = $column[10];

			}elsif($size == 11){

                            $subcaseid = $column[9];
                            $subcasename = $column[10];

			}elsif($column[0] =~ /^0/ &&  $size == 12){

                            $subcaseid = $column[10];
                            $subcasename = $column[11];
			}

			my @EachSubcaseMatrix = (); # Grid point force balance info for each sub case is put into a big matrix
			my $ESMCnt = 0;             # Counter for @EachSubcaseMatrix

			$EachSubcaseMatrix[$ESMCnt] = $line;
			$ESMCnt++;
			
			my @GPFBMatrix = (); # GPFB lines are saved in this matrix to use them later for summation calculations
			my $GPFBMCnt = 0;		  # Counter for @SummationMatrix
			
			my $SumTotalFx = 0;  my $SumTotalFy = 0; my $SumTotalFz = 0; my $SumTotalMx = 0; my $SumTotalMy = 0; my $SumTotalMz = 0;

			while (1) {    

				$line = <INFILE>;

				if (!defined $line){@column = ();}else{@column = split  " ", $line; $size = @column;}

				if ( defined $column[8]  && ($size == 10 && $subcaseid == $column[8]) || 
				     defined $column[9]  && ($size == 11 && $subcaseid == $column[9]) || 
				     defined $column[10] && ($size == 12 && $subcaseid == $column[10]) ) {

					$EachSubcaseMatrix[$ESMCnt] = $line; # Grid point force balance info for each sub case is put into a big matrix
					$ESMCnt++;			     # first then analysed after else statement.		    
				}else {

					my $LN = $EachSubcaseMatrix[0];
					my @ndcolumn = split  " ", $LN;
					my $SZ = @ndcolumn;
					my $ESMIncrement = 0; # Increments Each Subcase matrix by 1 while program analysing the node information

					NODE: while (defined $LN) {

						my $nodeid = 0;
						my $XCoord = 0; my $YCoord = 0; my $ZCoord = 0; # X, Y, Z coordinates of the nodes
						my $AnalysisCoord = -1; # Analysis Coordinate of the Grid

						###### OFTEN APP-LOAD SECTION BUT CAN START WITH ELEMENTS AS WELL ######

						my @NodeInfoArray = ();
						my $NIACnt = 0;

						my @ElmPosTmpArray = ();
						my $EPTACnt = 0;

						my $NodeId = 0;

						my @T1_Array = (); my @T2_Array = (); my @T3_Array = (); my @R1_Array = (); my @R2_Array = (); my @R3_Array = ();
						my $T1ACnt = 0;    my $T2ACnt = 0;    my $T3ACnt = 0;    my $R1ACnt = 0;    my $R2ACnt = 0;    my $R3ACnt = 0;
						my $T1_Total = 0;  my $T2_Total = 0;  my $T3_Total = 0;  my $R1_Total = 0;  my $R2_Total = 0;  my $R3_Total = 0;

						my @MPCFLineArray = ();
						my $MPCFLACnt = 0;

						my $ElmPos = 0;

						my @FirstLineArray = (); # Array for the first node line
						my $T1Pos = 0;
						my $NodeIDPos = 0;

						my $SizeFLA = 0; # Size of @FirstLineArray

						if($SZ == 10){

							$nodeid = $ndcolumn[0];

						}elsif($ndcolumn[0] =~ /^0/ &&  $SZ == 11){

							$nodeid = $ndcolumn[1];

						}elsif($SZ == 11){

							$nodeid = $ndcolumn[0];

						}elsif($ndcolumn[0] =~ /^0/ &&  $SZ == 12){

							$nodeid = $ndcolumn[1];
						}

						$ElmPosTmpArray[$EPTACnt] = "$nodeid";
						$EPTACnt++; 

						if ( defined $LN ) { @FirstLineArray = split  " ", $LN; $SizeFLA = @FirstLineArray}

						if ($SizeFLA == 10) {
							$T1Pos = 2;  
						}elsif($SizeFLA == 11 ){
							$ElmPos= 1; $T1Pos = 3;
						}elsif($SizeFLA == 12 ){
							$ElmPos= 2; $T1Pos = 4;
						}

						if(($SizeFLA == 11 || $SizeFLA == 12)) {

							foreach(@ElmIDArray) {

								if($_ == $FirstLineArray[$ElmPos]){

									$ElmPosTmpArray[$EPTACnt] = $NIACnt; # Counts the number of lines, indicates which line is 
													     # active for a particular node. Note: There are
													     # more than one line for each node in grid point force balance outputs
									$EPTACnt++;
								}							 
							}
						}

						$T1_Array[$T1ACnt] = $FirstLineArray[$T1Pos];  $T2_Array[$T2ACnt] = $FirstLineArray[$T1Pos+1]; $T3_Array[$T3ACnt] = $FirstLineArray[$T1Pos+2];
						$T1ACnt++;    				       $T2ACnt++;				       $T3ACnt++;

						$R1_Array[$R1ACnt] = $FirstLineArray[$T1Pos+3]; $R2_Array[$R2ACnt] = $FirstLineArray[$T1Pos+4]; $R3_Array[$R3ACnt] = $FirstLineArray[$T1Pos+5];
						$R1ACnt++;				        $R2ACnt++;				        $R3ACnt++;

						if($SZ == 10 && $nodeid == $ndcolumn[0] && $LN =~ /F\-OF\-MPC/){
						
							$MPCFLineArray[$MPCFLACnt] = $LN;
							$MPCFLACnt++;
						}

						#print OUTFILE  ("AAAAAAAAAAAAA\n");
						#print OUTFILE  ("ESMIncrement: $ESMIncrement\n");
						# DON'T DELETE THIS: print OUTFILE  ("SZ: $SZ line: $LN");


						$NodeInfoArray[$NIACnt] = "$LN";
						$NIACnt++; # This counter is not $NodeIDCnt! This one counts the line id for each node id
							   # in other words $NIACnt counts the number of lines, indicates which line is 
							   # active for a particular node. Note: There are more than one line for each node 
							   # in grid point force balance outputs. 

						###### APP-LOAD SECTION BUT IT DOESN'T ALWAYS START WITH APP-LOAD, IT COULD ALSO START WITH BEAM OR QUAD etc. ######

						while (1) {    

							$ESMIncrement++;
							$LN = $EachSubcaseMatrix[$ESMIncrement];

							if (!defined $LN){@ndcolumn = ();}else{@ndcolumn = split  " ", $LN;} 
							$SZ = @ndcolumn;

							#print OUTFILE  ("BBBBBBBBBBBBBBB\n");
							#print OUTFILE  ("ESMIncrement: $ESMIncrement\n");
							#print OUTFILE  ("LN:  $LN\n");

							if (($SZ == 10 && $nodeid == $ndcolumn[0]) || ($SZ == 11 && $nodeid == $ndcolumn[1]) ||
							    ($SZ == 11 && $nodeid == $ndcolumn[0]) || ($SZ == 12 && $nodeid == $ndcolumn[1]) ) {

								my @NodeElmLine = ();
								my $T1Pos = 0;
								my $SizeNELA = 0;

								if ( defined $LN ) { @NodeElmLine = split  " ", $LN; $SizeNELA = @NodeElmLine}

								if ($SizeNELA == 10) {
									$NodeIDPos = 0; $T1Pos = 2;
								}elsif($SizeNELA == 11 ){
									$NodeIDPos = 1; $ElmPos= 1; $T1Pos = 3;
								}elsif($SizeNELA == 12 ){
									$NodeIDPos = 1; $ElmPos= 2; $T1Pos = 4;
								}else {

								}

								if(($SizeNELA == 11 || $SizeNELA == 12)) {

									foreach(@ElmIDArray) {

										if($_ == $NodeElmLine[$ElmPos]){

											$ElmPosTmpArray[$EPTACnt] = $NIACnt;
											$EPTACnt++;
										}							 
									}
								}


								$NodeInfoArray[$NIACnt] = "$LN";								
								$NIACnt++; # Counts the number of lines, indicates which line is 
									   # active for a particular node. Note: There are
									   # more than one line for each node in grid point force balance outputs

								$NodeId = $NodeElmLine[$NodeIDPos];

								$T1_Array[$T1ACnt] = $NodeElmLine[$T1Pos];   $T2_Array[$T2ACnt] = $NodeElmLine[$T1Pos+1]; $T3_Array[$T3ACnt] = $NodeElmLine[$T1Pos+2];
								$T1ACnt++;    				     $T2ACnt++;					  $T3ACnt++;

								$R1_Array[$R1ACnt] = $NodeElmLine[$T1Pos+3]; $R2_Array[$R2ACnt] = $NodeElmLine[$T1Pos+4]; $R3_Array[$R3ACnt] = $NodeElmLine[$T1Pos+5];
								$R1ACnt++;				     $R2ACnt++;				          $R3ACnt++;

								# DON'T DELETE THIS: print OUTFILE  ("SZ: $SZ line: $LN");

								if($SZ == 10 && $nodeid == $ndcolumn[0] && $LN =~ /F\-OF\-MPC/){
						
									$MPCFLineArray[$MPCFLACnt] = $LN;
									$MPCFLACnt++;
								}

								if($SZ == 10 && $nodeid == $ndcolumn[0] && $LN =~ /\*TOTALS\*/){
									# Multiplying by 1 to convert scientific text to integer
									$T1_Total = $NodeElmLine[$T1Pos] * 1;    $T2_Total = $NodeElmLine[$T1Pos+1] * 1;  $T3_Total = $NodeElmLine[$T1Pos+2] * 1;  
									$R1_Total = $NodeElmLine[$T1Pos+3] * 1;  $R2_Total = $NodeElmLine[$T1Pos+4] * 1;  $R3_Total = $NodeElmLine[$T1Pos+5] * 1;
								}

							}else {

								#print OUTFILE  ("CCCCCCCCCCCCCC\n");
								#print OUTFILE  ("SZ: $SZ\nelm: $nodeid\nndcolumn0: $ndcolumn[0]\nndcolumn[1] $ndcolumn[1]\n");

								my @XYZCoordArray = split ",", $NodeXYZCoordArray[$NodeIDCnt];

								$XCoord = $XYZCoordArray[1]; 
								$YCoord = $XYZCoordArray[2]; 
								$ZCoord = $XYZCoordArray[3];
								
								$AnalysisCoord = $XYZCoordArray[4];
                                                                
                                                                #print "NodeXYZCoordArray[$NodeIDCnt]: $NodeXYZCoordArray[$NodeIDCnt]\n";
                                                                #print "SubcaseIDCnt $SubcaseIDCnt NodeIDCnt:$NodeIDCnt $InterfaceInfoArray[$NodeIDCnt]\n";

								# The following is because $AnalysisCoord and $RefCoord are local variables inside conditions
								# $ANALYSIS_COORD and $REF_COORD are a higher level variables in the subroutine used for writing
								
								$ANALYSIS_COORD = $AnalysisCoord;
								
								my $NodeElmPosLine = "";
								my $AddT1 = 0; my $AddT2 = 0; my $AddT3 = 0; my $AddR1 = 0; my $AddR2 = 0; my $AddR3 = 0;

								my $SizeEPTA = @ElmPosTmpArray;
								my $i = 0;
								
								foreach(@ElmPosTmpArray){

									$NodeElmPosLine = "$NodeElmPosLine" . "$_" . " ";

									if ($i > 0){ # program adds T1 ... R3 values for specified elements, later added value will be substracted from the total value

										$AddT1 = $AddT1+$T1_Array[$_]; $AddT2 = $AddT2+$T2_Array[$_]; $AddT3 = $AddT3+$T3_Array[$_];
										$AddR1 = $AddR1+$R1_Array[$_]; $AddR2 = $AddR2+$R2_Array[$_]; $AddR3 = $AddR3+$R3_Array[$_];
									}

									$i++; # Don't forget to increment, very important :)
								}

								$ElmPosArray[$EPACnt] = $NodeElmPosLine; # example: "1125 1" 1125(node id) 1 (pos id)
								$EPACnt++;

								$NODE_ID = $NodeId;
								
								$X = $XCoord; $Y = $YCoord; $Z = $ZCoord;
                                                                
                                                                #print "X:$X = $XCoord; Y:$Y = $YCoord; Z:$Z = $ZCoord;\n";

								$Fx = $T1_Total - $AddT1; $Fy = $T2_Total - $AddT2; $Fz = $T3_Total - $AddT3;
								$Mx = $R1_Total - $AddR1; $My = $R2_Total - $AddR2; $Mz = $R3_Total - $AddR3;

								$LOAD_NO = $subcaseid;
								$LOAD_NAME = $subcasename;
								
								# ******* GPFB Section *******
								
								if($SizeEPTA > 1){
								
									# if $SizeEPTA > 1, this means that there is at least one element connecting to 
									# the current node, if $SizeEPTA = 1, then $Fx = $T1_Total - 0
									# $Fx = $T1_Total, and the value of $T1_Total would have been printed
									
									# write(GPFB); # DO NOT DELETE

									$GPFBMatrix[$GPFBMCnt] = "$NODE_ID, $X, $Y, $Z, $ANALYSIS_COORD, $Fx, $Fy, $Fz, $Mx, $My, $Mz, $LOAD_NO, $LOAD_NAME";
									$GPFBMCnt++;									
								}
								
								@NodeInfoArray = (); # This array contains information for each node (contains more than 
										     # one line. That's why it is emptied for the next node For example:
										     # 10                  APP-LOAD       1.000620E+00  ...
         									     # 10                  F-OF-MPC       2.245491E+01  ...
         									     # 10        112120    BUSH          -2.345553E+01  ...
         									     # 10                  *TOTALS*      -1.389166E-08  ...

								# NIACnt = 0; No need to make this value zero here, it becomes zero when program moves to next node
									

								$NodeIDCnt++; # Counts the number of nodes, indicates which node id is active 
									      # Note: there are more than one line starting with this id.

								next NODE;
								
							} #if (($SZ == 10 && $nodeid == $ndcolumn[0]) || ($SZ == 11 && $nodeid == $ndcolumn[1]) ||
						} #while (1) { 
					} #NODE: while (defined $LN) {	    

					#foreach(@ElmPosArray){
						#print OUTFILE ("$_\n");
					#}
					
					# ******* Summation Totals *******
					
					#print "Subcase\n";
					
					foreach(@InterfaceInfoArray){
					
						my @LineArray = split (",", $_);
						my @NodeArray = split (" ", $LineArray[2]);
						my @SummCoordArray = split (" ", $LineArray[5]); # X, Y, Z of the Summation Point
						
						$RefCoord = $LineArray[4];	# Reference Coordinate id for transformation
						$REF_COORD = $RefCoord;
						
						$POINT_ID = $LineArray[0];
						$IDENT_TEXT = $LineArray[1];
						
						$XSummed = $SummCoordArray[0]; $YSummed = $SummCoordArray[1]; $ZSummed = $SummCoordArray[2];

						my $SumTotalFx = 0; my $SumTotalFy = 0; my $SumTotalFz = 0;				
						my $SumTotalMx = 0; my $SumTotalMy = 0; my $SumTotalMz = 0;						
						
						foreach(@NodeArray){
						
							my $Node = $_;
							
							foreach(@GPFBMatrix){

								my @GPFBArray = split (",", $_);

								$NODE_ID = $GPFBArray[0];
								
								$X = $GPFBArray[1];  $Y = $GPFBArray[2];  $Z = $GPFBArray[3];
								
								my $AnalysisCoord = $GPFBArray[4];
								$ANALYSIS_COORD = $AnalysisCoord;
								
								$Fx = $GPFBArray[5]; $Fy = $GPFBArray[6]; $Fz = $GPFBArray[7];
								$Mx = $GPFBArray[8]; $My = $GPFBArray[9]; $Mz = $GPFBArray[10];
								
								$LOAD_NO = $GPFBArray[11];
								$LOAD_NAME = $GPFBArray[12];
								
								if($Node == $GPFBArray[0]){
									
									# ******* Transformation Section 1 *******
									# Because of the summation we cannot use the following function for example 
									# Transformation from Coord 2 to Coord 4: @ForceArray = @{transCoord(2, 4, $Fx, $Fy, $Fz, $scale);};
									# This is because summation needs to be calculated based on values defined in global axis system (Coord 0)
									# Or summation Coordinates needs to be transformed as well to get the correct results
									
									my @ForceArray = ();
									my @MomentArray = ();
								
									$scale = 1;
									
									if(!defined $AnalysisCoord || $AnalysisCoord == 0){
								
										#No need to calculate TransMatrixA for the $AnalysisCoord to Coord 0!
										@ForceArray = ($Fx, $Fy, $Fz);
										@MomentArray = ($Mx, $My, $Mz);
									
									}elsif(defined $AnalysisCoord  && $AnalysisCoord > 0){
																			
										my $RefCoordUser = $RefCoord;  # Reference Coordinate defined by the user
										$RefCoord = 0;  # We need to transfer the results from the analysis coord to Coordinate zero
										
										#Calculate TransMatrixA for the $AnalysisCoord to Coord 0!
										@ForceArray = @{transCoord($AnalysisCoord, $RefCoord, $Fx, $Fy, $Fz, $scale);};
										@MomentArray = @{transCoord($AnalysisCoord, $RefCoord, $Mx, $My, $Mz, $scale);};
										
										$RefCoord = $RefCoordUser; # Reasigning $RefCoord variable with user defined value
									
									}

									$Fx = $ForceArray[0];  $Fy = $ForceArray[1];  $Fz = $ForceArray[2];
									$Mx = $MomentArray[0]; $My = $MomentArray[1]; $Mz = $MomentArray[2];
									
									# ******* Summation Section *******
									
									$Mx = $Mx - ($Fy * ($Z - $ZSummed)) + ($Fz * ($Y - $YSummed));
									$My = $My - ($Fz * ($X - $XSummed)) + ($Fx * ($Z - $ZSummed));
									$Mz = $Mz - ($Fx * ($Y - $YSummed)) + ($Fy * ($X - $XSummed));
									
									# The line $Fx = sprintf("%.6f", $Fx); converts scientific notation to integers
									# This is because if the value is too long Perl uses scientific notation,
									# and the printed results can be wrong because printing cuts for example e-19 (1.07854145176532154e-19)									
									
									$Fx = sprintf("%.6f", $Fx); $Fy = sprintf("%.6f", $Fy); $Fz = sprintf("%.6f", $Fz);
									$Mx = sprintf("%.6f", $Mx); $My = sprintf("%.6f", $My); $Mz = sprintf("%.6f", $Mz);
									
									write(INTERFACESUMMED);

									# ******* Transformation Section 2 *******
								
									@ForceArray = ();
									@MomentArray = ();
								
									$scale = 1;
								
									if($RefCoord == 0){
								
										#No need to calculate TransMatrixA for the $AnalysisCoord to Coord 0!
										@ForceArray = ($Fx, $Fy, $Fz);
										@MomentArray = ($Mx, $My, $Mz);
									
									}elsif($RefCoord > 0){
										
										my $AnalysisCoordDefined = $AnalysisCoord;
										$AnalysisCoord = 0;
										
										#Calculate TransMatrixA for the $AnalysisCoord to Coord 0!
										@ForceArray = @{transCoord($AnalysisCoord, $RefCoord, $Fx, $Fy, $Fz, $scale);};
										@MomentArray = @{transCoord($AnalysisCoord, $RefCoord, $Mx, $My, $Mz, $scale);};
									
										$AnalysisCoord = $AnalysisCoordDefined;
									}
								
									$Fx = $ForceArray[0];  $Fy = $ForceArray[1];  $Fz = $ForceArray[2];
									$Mx = $MomentArray[0]; $My = $MomentArray[1]; $Mz = $MomentArray[2];
									
									$Fx = sprintf("%.6f", $Fx); $Fy = sprintf("%.6f", $Fy); $Fz = sprintf("%.6f", $Fz);
									$Mx = sprintf("%.6f", $Mx); $My = sprintf("%.6f", $My); $Mz = sprintf("%.6f", $Mz);

									write(INTERFACEDATA);
									write(INTERFACERESULTS);

									# ******* Summation Totals *******

									$SumTotalFx = $SumTotalFx + $Fx; 
									$SumTotalFy = $SumTotalFy + $Fy; 
									$SumTotalFz = $SumTotalFz + $Fz; 
									
									$SumTotalMx = $SumTotalMx + $Mx; 
									$SumTotalMy = $SumTotalMy + $My; 
									$SumTotalMz = $SumTotalMz + $Mz;									
								}
							}
						}
											
						$Fx = $SumTotalFx; $Fy = $SumTotalFy; $Fz = $SumTotalFz; 		
						$Mx = $SumTotalMx; $My = $SumTotalMy; $Mz = $SumTotalMz;

						$Fx = sprintf("%.6f", $Fx); $Fy = sprintf("%.6f", $Fy); $Fz = sprintf("%.6f", $Fz);
						$Mx = sprintf("%.6f", $Mx); $My = sprintf("%.6f", $My); $Mz = sprintf("%.6f", $Mz);
					
						write(INTERFACEDATA);
						write(INTERFACESUMMED);
						
                                                $NODE_ID = "***";
                                                $X = "***"; $Y = "***"; $Z = "***";
                                                
                                                write(INTERFACETOTALS);
						
						$REF_COORD = "***";
						$ANALYSIS_COORD = "***";
								
						$X = "***"; $Y = "***"; $Z = "\*TOTALS\*";

						$Fx = $SumTotalFx; $Fy = $SumTotalFy; $Fz = $SumTotalFz; 		
						$Mx = $SumTotalMx; $My = $SumTotalMy; $Mz = $SumTotalMz;

						$Fx = sprintf("%.6f", $Fx); $Fy = sprintf("%.6f", $Fy); $Fz = sprintf("%.6f", $Fz);
						$Mx = sprintf("%.6f", $Mx); $My = sprintf("%.6f", $My); $Mz = sprintf("%.6f", $Mz);

						write(INTERFACERESULTS);
					}
					
					print INTERFACETOTALS "\$\n\$\n\$\n";
					print INTERFACERESULTS "\$\n\$\n\$\n";
					
					# *************************************
					
					$SubcaseIDCnt++;
									
					next SUBCASE;
				} # if ( defined $column[8]  && ($size == 10 && $subcaseid == $column[8]) || 
			} # while (1) { 
		} # SUBCASE: while (defined $line) {

		close INFILE;
	
	} # for (my $i =0; $i<= $#f06FileArray; $i++) {

	close INTERFACEDATA;
	close INTERFACESUMMED;
	close INTERFACETOTALS;

	#close CODE;
}	

# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : extractMPCLoads				                  *
# INTERNAL SUB FUNCTION PURPOSE : This function extracts grid point forces and moments from       *
#                                 initial sort file						  *
#												  *
# *************************************************************************************************


sub extractMPCLoads {

	# 1. Setup the input values

	my $SizeMPCIA = 0;
	my $SizeMPCNXYZCA = 0;
	
	my @MPCInfoArray = ();
	my $MPCIACnt = 0;
	
	my @MPCNodeXYZCoordArray = ();
	my $MPCNXYZCACnt = 0;
	
	# &extractMPCLoads($SizeMPCIA, $SizeMPCNXYZCA, @MPCInfoArray, @MPCNodeXYZCoordArray);

	if(defined $_[0]){ 
	
		$SizeMPCIA = $_[0];		# Local size of @NodeIDArray
	}

	if(defined $_[1]){ 
	
		$SizeMPCNXYZCA = $_[1];		# Local size of @NodeIDArray
	}

	# Locally rebuilding @MPCInfoArray
	
	for(my $i = 2; $i < ($SizeMPCIA + 2) ; $i++){	

		# &extractMPCLoads($SizeMPCIA, $SizeMPCNXYZCA, @MPCInfoArray, @MPCNodeXYZCoordArray);
	
		$MPCInfoArray[$MPCIACnt] = $_[$i];
		$MPCIACnt++;
	}

	# Locally rebuilding @MPCNodeXYZCoordArray
	
	for(my $i = (2 + $SizeMPCIA); $i < (2 + $SizeMPCIA + $SizeMPCNXYZCA); $i++){ 
		
		# &extractMPCLoads($SizeMPCIA, $SizeMPCNXYZCA, @MPCInfoArray, @MPCNodeXYZCoordArray);
		
		$MPCNodeXYZCoordArray[$MPCIACnt] = $_[$i];
		$MPCIACnt++;
	}

	
	#open (CODE, ">>$CurrentDir/ProgrammingLog.dat") or die "Unable to write input file ProgrammingLog.dat\n";
	
	#print CODE ("SizeIIA = $SizeIIA, SizeMPCIA = $SizeMPCIA\n");

		
	#foreach(@MPCInfoArray){
	
		#print "$_\n";
	
	#}

	my $RefCoord = 0;

	my $XSummed = 0;
	my $YSummed = 0;
	my $ZSummed = 0;
		
	my $ANALYSIS_COORD = -1;
	my $REF_COORD = -1;
	
	my $scale = 0;

	my $POINT_ID = 0;
	my $NODE_ID = 0; 
	
	my $X = 0; 
	my $Y = 0; 
	my $Z = 0; 
	
	my $MPCFx = 0; 
	my $MPCFy = 0;
	my $MPCFz = 0;
	my $MPCMx = 0;
	my $MPCMy = 0;
	my $MPCMz = 0;
	
	my $LOAD_NO = 0; 
	my $LOAD_NAME = "LC";

format MPCFORCES_TOP =

					@||||||||||||||||||||||||||||||||||                            Pg. @<<<<<
					  "        MPC Force       ",                                   $%

Node_Id         X             Y             Z             Fx            Fy            Fz            Mx             My           Mz          Load_No     Load_Name
---------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- 
. 

format MPCFORCES =
@<<<<<<<<<<<@||||||||||  @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||    @||||||||||  @||||||||||   @||||||||||    @*
$NODE_ID, $X, $Y, $Z, $MPCFx, $MPCFy, $MPCFz, $MPCMx, $MPCMy, $MPCMz, $LOAD_NO, $LOAD_NAME 
.

format MPCSUMMED_TOP =

				@||||||||||||||||||||||||||||||||||||||||||||||||||||||		       Pg. @<<<<<
				"MPC Force Transformed to Reference Coordinate Frame",	 		$%

Node_Id     Analy.Coord   Ref.Coord         X             Y             Z             Fx            Fy            Fz            Mx             My           Mz          Load_No     Load_Name
---------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- 
. 

format MPCSUMMED =
@<<<<<<<<<<<@||||||||||  @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||    @*
$NODE_ID, $ANALYSIS_COORD, $REF_COORD, $X, $Y, $Z, $MPCFx, $MPCFy, $MPCFz, $MPCMx, $MPCMy, $MPCMz, $LOAD_NO, $LOAD_NAME 
.

format MPCRESULTS_TOP =

				@||||||||||||||||||||||||||||||||||||||||||||||||||||||		       Pg. @<<<<<
				"MPC Force Transformed to Reference Coordinate Frame",	 		$%

Node_Id     Analy.Coord   Ref.Coord         X             Y             Z             Fx            Fy            Fz            Mx             My           Mz          Load_No     Load_Name
---------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- 
. 

format MPCRESULTS =
@<<<<<<<<<<<@||||||||||  @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||    @*
$NODE_ID, $ANALYSIS_COORD, $REF_COORD, $X, $Y, $Z, $MPCFx, $MPCFy, $MPCFz, $MPCMx, $MPCMy, $MPCMz, $LOAD_NO, $LOAD_NAME 
.


	my $WorkingDir = cwd;	
	my $DataDir = "$WorkingDir\/DATA";
		
	# ******************** Interface totals file *******************
	
	(my $mpcfilenamepr) = split/\./,$f06FileArray[0];
	my $MPCResultsFile = "$mpcfilenamepr.MPCresults";

	open (MPCRESULTS, ">$MPCResultsFile") or die "Could not open outfile $MPCResultsFile";		
	print MPCRESULTS ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");

	for (my $i =0; $i<= $#f06FileArray; $i++) {
	
		print MPCRESULTS ("\$Originated From: $f06FileArray[$i]\n");
	}

	print MPCRESULTS ("\$\n");
	
	# ******************* Interface totals file ********************
	
	for (my $i =0; $i<= $#f06FileArray; $i++) {
	
		(my $filenamepr) = split/\./,$f06FileArray[$i];
		
		my @filenamepr = split "\/",$filenamepr;
		my $Size = @filenamepr;
		
		$mpcforcesFileArray[$i] = "$DataDir\/$filenamepr[$Size-1].MPCforces";
		$mpcsummedFileArray[$i] = "$DataDir\/$filenamepr[$Size-1].MPCsummed";
	}
       
	for (my $i =0; $i<= $#f06FileArray; $i++) {

		my @ElmPosArray = ();
		my $EPACnt = 0;

		my $NodeIDCnt = 0; # Counts the number of nodes, indicates which node id is active. 
				   # Note there are more than one line for each node. Therefore
				   # This counter indicates which node it is 

		my $SubcaseIDCnt = 0;

		open(INFILE, "<$mpcdatFileArray[$i]") or die "Unable to open input file $mpcdatFileArray[$i]\n";

		open (MPCFORCES, ">$mpcforcesFileArray[$i]") or die "could not open outfile $mpcforcesFileArray[$i]";
		open (MPCSUMMED, ">$mpcsummedFileArray[$i]") or die "could not open outfile $mpcsummedFileArray[$i]";

		# ***** Header for *.gpfb file *****************************************************
		
		$l_time =localtime;	$gm_time = gmtime;

		print MPCFORCES ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");
		print MPCSUMMED ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");

		print MPCFORCES ("\$Originated From: $f06FileArray[$i]\n");
		print MPCSUMMED ("\$Originated From: $f06FileArray[$i]\n");			
					
		print MPCFORCES ("\$\n");
		print MPCSUMMED ("\$\n");		

		# ***** Header for *.gpfb file *****************************************************

		for(my $i = 0; $i < 3 ; $i++) {
			<INFILE>;
		}

		$NODE_ID = 0; $MPCFx = 0; $MPCFy = 0; $MPCFz = 0; $MPCMx = 0; $MPCMy = 0; $MPCMz = 0; $LOAD_NO = 0; $LOAD_NAME = "LC";

		my $line = <INFILE>;
		my @column = split " ", $line;
		my $size = @column;

		SUBCASE: while (defined $line) {

			my $subcaseid   = 0;
			my $subcasename = "";

			$NodeIDCnt = 0; # Counts the number of nodes, indicates which node id is active.

			if($size == 10){ # Program determines where the subcase id and name is for each line

                            $subcaseid = $column[8];
                            $subcasename = $column[9];

			}elsif($column[0] =~ /^0/ &&  $size == 11){

                            $subcaseid = $column[9];
                            $subcasename = $column[10];

			}elsif($size == 11){

                            $subcaseid = $column[9];
                            $subcasename = $column[10];

			}elsif($column[0] =~ /^0/ &&  $size == 12){

                            $subcaseid = $column[10];
                            $subcasename = $column[11];
			}

			my @EachSubcaseMatrix = (); # Grid point force balance info for each sub case is put into a big matrix
			my $ESMCnt = 0;             # Counter for @EachSubcaseMatrix

			$EachSubcaseMatrix[$ESMCnt] = $line;
			$ESMCnt++;
			
			my @MPCMatrix = (); 	# MPC lines are saved in this matrix to use them later for summation calculations
			my $MPCMCnt = 0;	# Counter for @SummationMatrix
			
			while (1) {    

				$line = <INFILE>;

				if (!defined $line){@column = ();}else{@column = split  " ", $line; $size = @column;}

				if ( defined $column[8]  && ($size == 10 && $subcaseid == $column[8]) || 
				     defined $column[9]  && ($size == 11 && $subcaseid == $column[9]) || 
				     defined $column[10] && ($size == 12 && $subcaseid == $column[10]) ) {

					$EachSubcaseMatrix[$ESMCnt] = $line; # Grid point force balance info for each sub case is put into a big matrix
					$ESMCnt++;			     # first then analysed after else statement.		    
				}else {

					my $LN = $EachSubcaseMatrix[0];
					my @ndcolumn = split  " ", $LN;
					my $SZ = @ndcolumn;
					my $ESMIncrement = 0; # Increments Each Subcase matrix by 1 while program analysing the node information

					NODE: while (defined $LN) {

						my $nodeid = 0;
						my $XCoord = 0; my $YCoord = 0; my $ZCoord = 0; # X, Y, Z coordinates of the nodes
						my $AnalysisCoord = -1; # Analysis Coordinate of the Grid

						###### OFTEN APP-LOAD SECTION BUT CAN START WITH ELEMENTS AS WELL ######

						my @NodeInfoArray = ();
						my $NIACnt = 0;

						my $NodeId = 0;

						my @MPCFLineArray = ();
						my $MPCFLACnt = 0;

						if($SZ == 10){

							$nodeid = $ndcolumn[0];

						}elsif($ndcolumn[0] =~ /^0/ &&  $SZ == 11){

							$nodeid = $ndcolumn[1];

						}elsif($SZ == 11){

							$nodeid = $ndcolumn[0];

						}elsif($ndcolumn[0] =~ /^0/ &&  $SZ == 12){

							$nodeid = $ndcolumn[1];
						}  

						if($SZ == 10 && $nodeid == $ndcolumn[0] && $LN =~ /F\-OF\-MPC/){

							$MPCFLineArray[$MPCFLACnt] = $LN;
							$MPCFLACnt++;
						}

						#print OUTFILE  ("AAAAAAAAAAAAA\n");
						#print OUTFILE  ("ESMIncrement: $ESMIncrement\n");
						# DON'T DELETE THIS: print OUTFILE  ("SZ: $SZ line: $LN");

						$NodeInfoArray[$NIACnt] = "$LN";
						$NIACnt++; # This counter is not $NodeIDCnt! This one counts the line id for each node id
							   # in other words $NIACnt counts the number of lines, indicates which line is 
							   # active for a particular node. Note: There are more than one line for each node 
							   # in grid point force balance outputs. 

						###### APP-LOAD SECTION BUT IT DOESN'T ALWAYS START WITH APP-LOAD, IT COULD ALSO START WITH BEAM OR QUAD etc. ######

						while (1) {    

							$ESMIncrement++;
							$LN = $EachSubcaseMatrix[$ESMIncrement];

							if (!defined $LN){@ndcolumn = ();}else{@ndcolumn = split  " ", $LN;} 
							$SZ = @ndcolumn;

							#print OUTFILE  ("BBBBBBBBBBBBBBB\n");
							#print OUTFILE  ("ESMIncrement: $ESMIncrement\n");
							#print OUTFILE  ("LN:  $LN\n");

							if (($SZ == 10 && $nodeid == $ndcolumn[0]) || ($SZ == 11 && $nodeid == $ndcolumn[1]) ||
							    ($SZ == 11 && $nodeid == $ndcolumn[0]) || ($SZ == 12 && $nodeid == $ndcolumn[1]) ) {

								$NodeInfoArray[$NIACnt] = "$LN";								
								$NIACnt++; # Counts the number of lines, indicates which line is 
									   # active for a particular node. Note: There are
									   # more than one line for each node in grid point force balance outputs

								#$NodeId = $NodeElmLine[$NodeIDPos];

								# DON'T DELETE THIS: print OUTFILE  ("SZ: $SZ line: $LN");

								if($SZ == 10 && $nodeid == $ndcolumn[0] && $LN =~ /F\-OF\-MPC/){

									$MPCFLineArray[$MPCFLACnt] = $LN;
									$MPCFLACnt++;
								}

							}else {

								#print OUTFILE  ("CCCCCCCCCCCCCC\n");
								#print OUTFILE  ("SZ: $SZ\nelm: $nodeid\nndcolumn0: $ndcolumn[0]\nndcolumn[1] $ndcolumn[1]\n");

								my @MPCXYZCoordArray = split ",", $MPCNodeXYZCoordArray[$NodeIDCnt];

								$XCoord = $MPCXYZCoordArray[1]; 
								$YCoord = $MPCXYZCoordArray[2]; 
								$ZCoord = $MPCXYZCoordArray[3];
								
								$AnalysisCoord = $MPCXYZCoordArray[4];
                                                                
                                                                #print "SubcaseIDCnt $SubcaseIDCnt NodeIDCnt:$NodeIDCnt $MPCInfoArray[$NodeIDCnt]\n";
								#print MPCRESULTS "SubcaseIDCnt $SubcaseIDCnt NodeIDCnt:$NodeIDCnt $MPCInfoArray[$NodeIDCnt]\n";

								# The following is because $AnalysisCoord and $RefCoord are local variables inside conditions
								# $ANALYSIS_COORD and $REF_COORD are a higher level variables in the subroutine used for writing
								
								$ANALYSIS_COORD = $AnalysisCoord;
																
								$X = $XCoord; $Y = $YCoord; $Z = $ZCoord;
								
								#print MPCRESULTS ("AnalysisCoord $AnalysisCoord, XCoord $XCoord YCoord $YCoord ZCoord $ZCoord\n");
																									
								# ******* MPC Force Section *******

								$LOAD_NO = $subcaseid;
								$LOAD_NAME = $subcasename;
								
								my $SizeMPCFLA = @MPCFLineArray;
								
								foreach(@MPCFLineArray){

									# ******* MPC Force Section *******
									
									#print MPCRESULTS ("MPCFLineArray: $_\n");
									
									my @MPCFLine = split  " ", $_;
								
									$NODE_ID = $MPCFLine[0];
									
									$MPCFx = $MPCFLine[2]; $MPCFy = $MPCFLine[3]; $MPCFz = $MPCFLine[4];
									$MPCMx = $MPCFLine[5]; $MPCMy = $MPCFLine[6]; $MPCMz = $MPCFLine[7];

									$MPCFx = sprintf("%.6f", $MPCFx); $MPCFy = sprintf("%.6f", $MPCFy); $MPCFz = sprintf("%.6f", $MPCFz);
									$MPCMx = sprintf("%.6f", $MPCMx); $MPCMy = sprintf("%.6f", $MPCMy); $MPCMz = sprintf("%.6f", $MPCMz);

									$MPCMatrix[$MPCMCnt] = "$NODE_ID, $X, $Y, $Z, $ANALYSIS_COORD, $MPCFx, $MPCFy, $MPCFz, $MPCMx, $MPCMy, $MPCMz, $LOAD_NO, $LOAD_NAME";
									$MPCMCnt++;									
								
									write(MPCFORCES);
									
									#print MPCRESULTS ("$NODE_ID, $X, $Y, $Z, $ANALYSIS_COORD, $MPCFx, $MPCFy, $MPCFz, $MPCMx, $MPCMy, $MPCMz, $LOAD_NO, $LOAD_NAME\n");
																									
								} # End of foreach(@MPCFLineArray){

								@NodeInfoArray = (); # This array contains information for each node (contains more than 
										     # one line. That's why it is emptied for the next node For example:
										     # 10                  APP-LOAD       1.000620E+00  ...
         									     # 10                  F-OF-MPC       2.245491E+01  ...
         									     # 10        112120    BUSH          -2.345553E+01  ...
         									     # 10                  *TOTALS*      -1.389166E-08  ...

								# NIACnt = 0; No need to make this value zero here, it becomes zero when program moves to next node
									

								$NodeIDCnt++; # Counts the number of nodes, indicates which node id is active 
									      # Note: there are more than one line starting with this id.

								next NODE;
								
							} #if (($SZ == 10 && $nodeid == $ndcolumn[0]) || ($SZ == 11 && $nodeid == $ndcolumn[1]) ||
						} #while (1) { 
					} #NODE: while (defined $LN) {	    

					# ******* Summation Totals *******
					
					#print "Subcase\n";
					
					foreach(@MPCInfoArray){
					
						my @LineArray = split (",", $_);
						my @SummCoordArray = split (" ", $LineArray[2]);
						
						$RefCoord = $LineArray[1];
						$REF_COORD = $RefCoord;
						
						$XSummed = $SummCoordArray[0]; $YSummed = $SummCoordArray[1]; $ZSummed = $SummCoordArray[2];

						foreach(@MPCMatrix){

							my @MPCArray = split (",", $_);

							$NODE_ID = $MPCArray[0];
							
							$X = $MPCArray[1];  $Y = $MPCArray[2];  $Z = $MPCArray[3];
							
							my $AnalysisCoord = $MPCArray[4];
							$ANALYSIS_COORD = $AnalysisCoord;
							
							$MPCFx = $MPCArray[5]; $MPCFy = $MPCArray[6]; $MPCFz = $MPCArray[7];
							$MPCMx = $MPCArray[8]; $MPCMy = $MPCArray[9]; $MPCMz = $MPCArray[10];
							
							$LOAD_NO = $MPCArray[11];
							$LOAD_NAME = $MPCArray[12];
							
							if($LineArray[0] == $MPCArray[0]){
								
								# ******* Transformation Section 1 *******
								# Because of the summation we cannot use the following function for example 
								# Transformation from Coord 2 to Coord 4: @ForceArray = @{transCoord(2, 4, $Fx, $Fy, $Fz, $scale);};
								# This is because summation needs to be calculated based on values defined in global axis system (Coord 0)
								# Or summation Coordinates needs to be transformed as well to get the correct results
								
								my @ForceArray = ();
								my @MomentArray = ();
							
								$scale = 1;
								
								if(!defined $AnalysisCoord || $AnalysisCoord == 0){
							
									#No need to calculate TransMatrixA for the $AnalysisCoord to Coord 0!
									@ForceArray = ($MPCFx, $MPCFy, $MPCFz);
									@MomentArray = ($MPCMx, $MPCMy, $MPCMz);
								
								}elsif(defined $AnalysisCoord  && $AnalysisCoord > 0){
																		
									my $RefCoordUser = $RefCoord;  # Reference Coordinate defined by the user
									$RefCoord = 0;  # We need to transfer the results from the analysis coord to Coordinate zero
									
									#Calculate TransMatrixA for the $AnalysisCoord to Coord 0!
									@ForceArray = @{transCoord($AnalysisCoord, $RefCoord, $MPCFx, $MPCFy, $MPCFz, $scale);};
									@MomentArray = @{transCoord($AnalysisCoord, $RefCoord, $MPCMx, $MPCMy, $MPCMz, $scale);};
									
									$RefCoord = $RefCoordUser; # Reasigning $RefCoord variable with user defined value
								
								}

								$MPCFx = $ForceArray[0];  $MPCFy = $ForceArray[1];  $MPCFz = $ForceArray[2];
								$MPCMx = $MomentArray[0]; $MPCMy = $MomentArray[1]; $MPCMz = $MomentArray[2];
								
								# ******* Summation Section *******
								
								$MPCMx = $MPCMx - ($MPCFy * ($Z - $ZSummed)) + ($MPCFz * ($Y - $YSummed));
								$MPCMy = $MPCMy - ($MPCFz * ($X - $XSummed)) + ($MPCFx * ($Z - $ZSummed));
								$MPCMz = $MPCMz - ($MPCFx * ($Y - $YSummed)) + ($MPCFy * ($X - $XSummed));
								
								# The line $Fx = sprintf("%.6f", $Fx); converts scientific notation to integers
								# This is because if the value is too long Perl uses scientific notation,
								# and the printed results can be wrong because printing cuts for example e-19 (1.07854145176532154e-19)									
								
								$MPCFx = sprintf("%.6f", $MPCFx); $MPCFy = sprintf("%.6f", $MPCFy); $MPCFz = sprintf("%.6f", $MPCFz);
								$MPCMx = sprintf("%.6f", $MPCMx); $MPCMy = sprintf("%.6f", $MPCMy); $MPCMz = sprintf("%.6f", $MPCMz);
								
								write(MPCSUMMED);

								# ******* Transformation Section 2 *******
							
								@ForceArray = ();
								@MomentArray = ();
							
								$scale = 1;
							
								if($RefCoord == 0){
							
									#No need to calculate TransMatrixA for the $AnalysisCoord to Coord 0!
									@ForceArray = ($MPCFx, $MPCFy, $MPCFz);
									@MomentArray = ($MPCMx, $MPCMy, $MPCMz);
								
								}elsif($RefCoord > 0){
									
									my $AnalysisCoordDefined = $AnalysisCoord;
									$AnalysisCoord = 0;
									
									#Calculate TransMatrixA for the $AnalysisCoord to Coord 0!
									@ForceArray = @{transCoord($AnalysisCoord, $RefCoord, $MPCFx, $MPCFy, $MPCFz, $scale);};
									@MomentArray = @{transCoord($AnalysisCoord, $RefCoord, $MPCMx, $MPCMy, $MPCMz, $scale);};
								
									$AnalysisCoord = $AnalysisCoordDefined;
								}
							
								$MPCFx = $ForceArray[0];  $MPCFy = $ForceArray[1];  $MPCFz = $ForceArray[2];
								$MPCMx = $MomentArray[0]; $MPCMy = $MomentArray[1]; $MPCMz = $MomentArray[2];
								
								$MPCFx = sprintf("%.6f", $MPCFx); $MPCFy = sprintf("%.6f", $MPCFy); $MPCFz = sprintf("%.6f", $MPCFz);
								$MPCMx = sprintf("%.6f", $MPCMx); $MPCMy = sprintf("%.6f", $MPCMy); $MPCMz = sprintf("%.6f", $MPCMz);

								write(MPCRESULTS);
							}
						}					
					}
					
					# *********************************
					
					$SubcaseIDCnt++;
									
					next SUBCASE;
				} # if ( defined $column[8]  && ($size == 10 && $subcaseid == $column[8]) || 
			} # while (1) { 
		} # SUBCASE: while (defined $line) {

		close INFILE;
	
	} # for (my $i =0; $i<= $#f06FileArray; $i++) {
	
	close MPCSUMMED;
	close MPCFORCES;
	close MPCRESULTS;
	
	#close CODE;
}

# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : extractFreebodyLoads				                  *
# INTERNAL SUB FUNCTION PURPOSE : This function extracts grid point forces and moments from       *
#                                 initial sort file for the elements representing freebodys	  *
#				  and transfers the loads into freebody coordinates		  *
#												  *
# *************************************************************************************************

sub extractFreebodyLoads {

	# 1. Setup the input values

	my $SizeFNXYZCA = 0;
	
	my @FreebodyNodeXYZCoordArray = ();
	my $FNXYZCACnt = 0;
	
	# &extractFreebodyLoads($SizeFNXYZCA, @FreebodyNodeXYZCoordArray);

	if(defined $_[0]){ 
	
		$SizeFNXYZCA = $_[0];		# Local size of @NodeIDArray
	}

	# Locally rebuilding @FreebodyNodeXYZCoordArray
	
	for(my $i = 1; $i < ($SizeFNXYZCA + 1) ; $i++){	

		# &extractFreebodyLoads($SizeFNXYZCA, @FreebodyNodeXYZCoordArray);
	
		$FreebodyNodeXYZCoordArray[$FNXYZCACnt] = $_[$i];
		$FNXYZCACnt++;
	}


	my $NumberOfMaxMins = 0;
	my $scale = 0;
	
	my $ANALYSIS_COORD = -1;
	my $REF_COORD = -1;

	my $NODE_ID = 0; 
	my $X = 0; 
	my $Y = 0; 
	my $Z = 0; 
	my $Fx = 0;  
	my $Fy = 0; 
	my $Fz = 0; 
	my $Mx = 0; 
	my $My = 0; 
	my $Mz = 0; 
	my $LOAD_NO = 0; 
	my $LOAD_NAME = "LC";

format FREEBODYLOADS_TOP =

					@|||||||||||||||||||||||||||||||||||||||                        Pg. @<<<<<
					"Grid Point Force Balance (Freebody Loads)",                         $%

Node_Id     Analy.Coord       X             Y             Z             Fx            Fy            Fz            Mx             My           Mz          Load_No     Load_Name
---------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- 
. 

format FREEBODYLOADS =
@<<<<<<<<<<<@||||||||||  @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||    @*
$NODE_ID,$ANALYSIS_COORD, $X, $Y, $Z, $Fx, $Fy, $Fz, $Mx, $My, $Mz, $LOAD_NO, $LOAD_NAME 
.

format FREEBODYTRANSFORMED_TOP =

					@|||||||||||||||||||||||||||||||||||||||                        Pg. @<<<<<
					"Grid Point Force Balance (Freebody Loads)",                         $%

Node_Id     Analy.Coord   Ref.Coord         X             Y             Z             Fx            Fy            Fz            Mx             My           Mz          Load_No     Load_Name
---------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- 
. 

format FREEBODYTRANSFORMED =
@<<<<<<<<<<<@||||||||||  @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||    @*
$NODE_ID,$ANALYSIS_COORD, $REF_COORD, $X, $Y, $Z, $Fx, $Fy, $Fz, $Mx, $My, $Mz, $LOAD_NO, $LOAD_NAME 
.


	for (my $i =0; $i<= $#f06FileArray; $i++) {
	
		(my $filenamepr) = split/\./,$f06FileArray[$i];
		
		$freebodyloadsFileArray[$i] = "$filenamepr.freebodyloads";
		$freebodytransformedFileArray[$i] = "$filenamepr.freebodytransformed";
		$freebodytempFileArray[$i] = "$filenamepr.freebodytemp";
		
		$i++;
	}

	for (my $i =0; $i<= $#f06FileArray; $i++) {

		my @ElmPosArray = ();
		my $EPACnt = 0;

		my $NodeIDCnt = 0; # Counts the number of nodes, indicates which node id is active. 
				   # Note there are more than one line for each node. Therefore
				   # This counter indicates which node it is 

		my $SubcaseIDCnt = 0;

		open(INFILE, "<$freebodydatFileArray[$i]") or die "Unable to open input file $freebodydatFileArray[$i]\n";
		
		open (FREEBODYLOADS, ">$freebodyloadsFileArray[$i]") or die "could not open outfile $freebodyloadsFileArray[$i]";
		open (FREEBODYTRANSFORMED, ">$freebodytransformedFileArray[$i]") or die "could not open outfile $freebodytransformedFileArray[$i]";
		open (FREEBODYTEMP, ">$freebodytempFileArray[$i]") or die "could not open outfile $freebodytempFileArray[$i]";

		# ***** Header for *.gpfb file *****************************************************
		
		$l_time =localtime;	$gm_time = gmtime;

		print FREEBODYLOADS ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");
		print FREEBODYTRANSFORMED ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");
		print FREEBODYTEMP ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");

		for (my $i =0; $i<= $#f06FileArray; $i++) {
		
			print FREEBODYLOADS ("\$Originated From: $f06FileArray[$i]\n");
			print FREEBODYTRANSFORMED ("\$Originated From: $f06FileArray[$i]\n");
			print FREEBODYTEMP ("\$Originated From: $f06FileArray[$i]\n");
		}

		print FREEBODYLOADS ("\$\n");
		print FREEBODYTRANSFORMED ("\$\n");
		print FREEBODYTEMP ("\$\n");
		
		# ***** Header for *.gpfb file *****************************************************

		for(my $i = 0; $i < 3 ; $i++) {
			<INFILE>;
		}

		$NODE_ID = 0; $Fx = 0; $Fy = 0; $Fz = 0; $Mx = 0; $My = 0; $Mz = 0; $LOAD_NO = 0; $LOAD_NAME = "LC";

		my $line = <INFILE>;
		my @column = split " ", $line;
		my $size = @column;

		SUBCASE: while (defined $line) {

			my $subcaseid   = 0;
			my $subcasename = "";

			$NodeIDCnt = 0; # Counts the number of nodes, indicates which node id is active.

			if($size == 10){ # Program determines where the subcase id and name is for each line

                            $subcaseid = $column[8];
                            $subcasename = $column[9];

			}elsif($column[0] =~ /^0/ &&  $size == 11){

                            $subcaseid = $column[9];
                            $subcasename = $column[10];

			}elsif($size == 11){

                            $subcaseid = $column[9];
                            $subcasename = $column[10];

			}elsif($column[0] =~ /^0/ &&  $size == 12){

                            $subcaseid = $column[10];
                            $subcasename = $column[11];
			}

			my @EachSubcaseMatrix = (); # Grid point force balance info for each sub case is put into a big matrix
			my $ESMCnt = 0;             # Counter for @EachSubcaseMatrix

			$EachSubcaseMatrix[$ESMCnt] = $line;
			$ESMCnt++;    

			while (1) {    

				$line = <INFILE>;

				if (!defined $line){@column = ();}else{@column = split  " ", $line; $size = @column;}

				if ( defined $column[8]  && ($size == 10 && $subcaseid == $column[8]) || 
				     defined $column[9]  && ($size == 11 && $subcaseid == $column[9]) || 
				     defined $column[10] && ($size == 12 && $subcaseid == $column[10]) ) {

					$EachSubcaseMatrix[$ESMCnt] = $line; # Grid point force balance info for each sub case is put into a big matrix
					$ESMCnt++;			     # first then analysed after else statement.		    
				}else {

					my $LN = $EachSubcaseMatrix[0];
					my @ndcolumn = split  " ", $LN;
					my $SZ = @ndcolumn;
					my $ESMIncrement = 0; # Increments Each Subcase matrix by 1 while program analysing the node information

					NODE: while (defined $LN) {

						my $nodeid = 0;
						my $XCoord = 0; my $YCoord = 0; my $ZCoord = 0; # X, Y, Z coordinates of the nodes
						my $AnalysisCoord = -1; # Analysis Coordinate of the Grid
						my $RefCoord = -1; # Transformation Coordinate of the grid

						###### OFTEN APP-LOAD SECTION BUT CAN START WITH ELEMENTS AS WELL ######

						my @NodeInfoArray = ();
						my $NIACnt = 0;

						my @ElmPosTmpArray = ();
						my $EPTACnt = 0;

						my $NodeId = 0;

						my @T1_Array = (); my @T2_Array = (); my @T3_Array = (); my @R1_Array = (); my @R2_Array = (); my @R3_Array = ();
						my $T1ACnt = 0;    my $T2ACnt = 0;    my $T3ACnt = 0;    my $R1ACnt = 0;    my $R2ACnt = 0;    my $R3ACnt = 0;
						my $T1_Total = 0;  my $T2_Total = 0;  my $T3_Total = 0;  my $R1_Total = 0;  my $R2_Total = 0;  my $R3_Total = 0;

						my @MPCFLineArray = ();
						my $MPCFLACnt = 0;

						my $ElmPos = 0;

						my @FirstLineArray = (); # Array for the first node line
						my $T1Pos = 0;
						my $NodeIDPos = 0;

						my $SizeFLA = 0; # Size of @FirstLineArray

						if($SZ == 10){

							$nodeid = $ndcolumn[0];

						}elsif($ndcolumn[0] =~ /^0/ &&  $SZ == 11){

							$nodeid = $ndcolumn[1];

						}elsif($SZ == 11){

							$nodeid = $ndcolumn[0];

						}elsif($ndcolumn[0] =~ /^0/ &&  $SZ == 12){

							$nodeid = $ndcolumn[1];
						}  

						$ElmPosTmpArray[$EPTACnt] = "$nodeid";
						$EPTACnt++; 

						if ( defined $LN ) { @FirstLineArray = split  " ", $LN; $SizeFLA = @FirstLineArray}

						if ($SizeFLA == 10) {
							$T1Pos = 2;  
						}elsif($SizeFLA == 11 ){
							$ElmPos= 1; $T1Pos = 3;
						}elsif($SizeFLA == 12 ){
							$ElmPos= 2; $T1Pos = 4;
						}

						if(($SizeFLA == 11 || $SizeFLA == 12)) {

							foreach(@FreebodyElmIDArray) {
								
								# @FreebodyElmIDArray is a global variable array and not passed to this subroutine

								if($_ == $FirstLineArray[$ElmPos]){

									$ElmPosTmpArray[$EPTACnt] = $NIACnt; # Counts the number of lines, indicates which line is 
													     # active for a particular node. Note: There are
													     # more than one line for each node in grid point force balance outputs
									$EPTACnt++;
								}							 
							}
						}

						$T1_Array[$T1ACnt] = $FirstLineArray[$T1Pos];  $T2_Array[$T2ACnt] = $FirstLineArray[$T1Pos+1]; $T3_Array[$T3ACnt] = $FirstLineArray[$T1Pos+2];
						$T1ACnt++;    				       $T2ACnt++;				       $T3ACnt++;

						$R1_Array[$R1ACnt] = $FirstLineArray[$T1Pos+3]; $R2_Array[$R2ACnt] = $FirstLineArray[$T1Pos+4]; $R3_Array[$R3ACnt] = $FirstLineArray[$T1Pos+5];
						$R1ACnt++;				        $R2ACnt++;				        $R3ACnt++;

						#print OUTFILE  ("AAAAAAAAAAAAA\n");
						#print OUTFILE  ("ESMIncrement: $ESMIncrement\n");
						# DON'T DELETE THIS: print OUTFILE  ("SZ: $SZ line: $LN");


						$NodeInfoArray[$NIACnt] = "$LN";
						$NIACnt++; # This counter is not $NodeIDCnt! This one counts the line id for each node id
							   # in other words $NIACnt counts the number of lines, indicates which line is 
							   # active for a particular node. Note: There are more than one line for each node 
							   # in grid point force balance outputs. 

						###### APP-LOAD SECTION BUT IT DOESN'T ALWAYS START WITH APP-LOAD, IT COULD ALSO START WITH BEAM OR QUAD etc. ######

						while (1) {    

							$ESMIncrement++;
							$LN = $EachSubcaseMatrix[$ESMIncrement];

							if (!defined $LN){@ndcolumn = ();}else{@ndcolumn = split  " ", $LN;} 
							$SZ = @ndcolumn;

							#print OUTFILE  ("BBBBBBBBBBBBBBB\n");
							#print OUTFILE  ("ESMIncrement: $ESMIncrement\n");
							#print OUTFILE  ("LN:  $LN\n");

							if (($SZ == 10 && $nodeid == $ndcolumn[0]) || ($SZ == 11 && $nodeid == $ndcolumn[1]) ||
							    ($SZ == 11 && $nodeid == $ndcolumn[0]) || ($SZ == 12 && $nodeid == $ndcolumn[1]) ) {

								my @NodeElmLine = ();
								my $T1Pos = 0;
								my $SizeNELA = 0;

								if ( defined $LN ) { @NodeElmLine = split  " ", $LN; $SizeNELA = @NodeElmLine}

								if ($SizeNELA == 10) {
									$NodeIDPos = 0; $T1Pos = 2;
								}elsif($SizeNELA == 11 ){
									$NodeIDPos = 1; $ElmPos= 1; $T1Pos = 3;
								}elsif($SizeNELA == 12 ){
									$NodeIDPos = 1; $ElmPos= 2; $T1Pos = 4;
								}else {

								}

								if(($SizeNELA == 11 || $SizeNELA == 12)) {

									foreach(@FreebodyElmIDArray) {
										
										# @FreebodyElmIDArray is a global variable array and not passed to this subroutine

										if($_ == $NodeElmLine[$ElmPos]){

											$ElmPosTmpArray[$EPTACnt] = $NIACnt;
											$EPTACnt++;
										}							 
									}
								}


								$NodeInfoArray[$NIACnt] = "$LN";								
								$NIACnt++; # Counts the number of lines, indicates which line is 
									   # active for a particular node. Note: There are
									   # more than one line for each node in grid point force balance outputs

								$NodeId = $NodeElmLine[$NodeIDPos];

								$T1_Array[$T1ACnt] = $NodeElmLine[$T1Pos];   $T2_Array[$T2ACnt] = $NodeElmLine[$T1Pos+1]; $T3_Array[$T3ACnt] = $NodeElmLine[$T1Pos+2];
								$T1ACnt++;    				     $T2ACnt++;					  $T3ACnt++;

								$R1_Array[$R1ACnt] = $NodeElmLine[$T1Pos+3]; $R2_Array[$R2ACnt] = $NodeElmLine[$T1Pos+4]; $R3_Array[$R3ACnt] = $NodeElmLine[$T1Pos+5];
								$R1ACnt++;				     $R2ACnt++;				          $R3ACnt++;

								# DON'T DELETE THIS: print OUTFILE  ("SZ: $SZ line: $LN");

								if($SZ == 10 && $nodeid == $ndcolumn[0] && $LN =~ /\*TOTALS\*/){
									# Multiplying by 1 to convert scientific text to integer
									$T1_Total = $NodeElmLine[$T1Pos] * 1;    $T2_Total = $NodeElmLine[$T1Pos+1] * 1;  $T3_Total = $NodeElmLine[$T1Pos+2] * 1;  
									$R1_Total = $NodeElmLine[$T1Pos+3] * 1;  $R2_Total = $NodeElmLine[$T1Pos+4] * 1;  $R3_Total = $NodeElmLine[$T1Pos+5] * 1;
								}

							}else {

								#print OUTFILE  ("CCCCCCCCCCCCCC\n");
								#print OUTFILE  ("SZ: $SZ\nelm: $nodeid\nndcolumn0: $ndcolumn[0]\nndcolumn[1] $ndcolumn[1]\n");

								my @FreebodyXYZCoordArray = split ",", $FreebodyNodeXYZCoordArray[$NodeIDCnt];
								
								$XCoord = $FreebodyXYZCoordArray[1]; 
								$YCoord = $FreebodyXYZCoordArray[2]; 
								$ZCoord = $FreebodyXYZCoordArray[3];

								$AnalysisCoord = $FreebodyXYZCoordArray[4];
								
								$RefCoord = $FreebodyCoordIDArray[$NodeIDCnt];
								$NumberOfMaxMins = $FreebodyMaxMinArray[$NodeIDCnt];
								
								# The following is because $AnalysisCoord and $RefCoord are local variables inside conditions
								# $ANALYSIS_COORD and $REF_COORD are a higher level variables in the subroutine used for writing
								
								$ANALYSIS_COORD = $AnalysisCoord;
								$REF_COORD = $RefCoord; # Transformation Coordinate of the grid

								my $NodeElmPosLine = "";
								my $AddT1 = 0; my $AddT2 = 0; my $AddT3 = 0; my $AddR1 = 0; my $AddR2 = 0; my $AddR3 = 0;

								my $SizeEPTA = @ElmPosTmpArray;
								my $i = 0;
								
								foreach(@ElmPosTmpArray){

									$NodeElmPosLine = "$NodeElmPosLine" . "$_" . " ";

									if ($i > 0){ # program adds T1 ... R3 values for specified elements, later added value will be substracted from the total value

										$AddT1 = $AddT1+$T1_Array[$_]; $AddT2 = $AddT2+$T2_Array[$_]; $AddT3 = $AddT3+$T3_Array[$_];
										$AddR1 = $AddR1+$R1_Array[$_]; $AddR2 = $AddR2+$R2_Array[$_]; $AddR3 = $AddR3+$R3_Array[$_];
									}

									$i++; # Don't forget to increment, very important :)
								}

								$ElmPosArray[$EPACnt] = $NodeElmPosLine; # example: "1125 1" 1125(node id) 1 (pos id)
								$EPACnt++;

								$NODE_ID = $NodeId; # this is because $NodeId is local variable inside conditions
										    # $NODE_ID is a higher level variable in the subroutine
								
								$X = $XCoord; $Y = $YCoord; $Z = $ZCoord;

								$Fx = $T1_Total - $AddT1; $Fy = $T2_Total - $AddT2; $Fz = $T3_Total - $AddT3;
								$Mx = $R1_Total - $AddR1; $My = $R2_Total - $AddR2; $Mz = $R3_Total - $AddR3;

								$LOAD_NO = $subcaseid;
								$LOAD_NAME = $subcasename;
								
								# ******* GPFB Section *******
								
								if($SizeEPTA > 1){
								
									# if $SizeEPTA > 1, this means that there is at least one element connecting to 
									# the current node, if $SizeEPTA = 1, then $Fx = $T1_Total - 0
									# $Fx = $T1_Total, and the value of $T1_Total would have been printed
									
									write(FREEBODYLOADS);
								}
																
								# ******* Summation Section *******
								
								#my $MxTmp = $Mx; my $MyTmp = $My; my $MzTmp = $Mz; # Put original values into temporary storage
								
								#$Mx = $Mx - ($Fy * ($Z - $ZSummed)) + ($Fz * ($Y - $YSummed));
								#$My = $My - ($Fz * ($X - $XSummed)) + ($Fx * ($Z - $ZSummed));
								#$Mz = $Mz - ($Fx * ($Y - $YSummed)) + ($Fy * ($X - $XSummed));

								#if($SizeEPTA > 1){
								
									# if $SizeEPTA > 1, this means that there is at least one element connecting to 
									# the current node, if $SizeEPTA = 1, then $Fx = $T1_Total - 0
									# $Fx = $T1_Total, and the line where the value of $T1_Total is used would have
									# been printed

									#write(INTERFACEDATA);
								#}
								
								# ******* Transformation Section *******
								
								#$Mx = $MxTmp; $My = $MyTmp; $Mz = $MzTmp; # Reassign the original values into Mx, My and Mz
								
								my @ForceArray = ();
								my @MomentArray = ();
								
								$scale = 1;
								
								
								if(((!defined $AnalysisCoord || $AnalysisCoord == 0) && $RefCoord == 0) ||
								   ( $AnalysisCoord > 0 && $RefCoord > 0 && $AnalysisCoord == $RefCoord)){
								
									#No need to calculate TransMatrixA for the $AnalysisCoord to Coord 0!
									@ForceArray = ($Fx, $Fy, $Fz);
									@MomentArray = ($Mx, $My, $Mz);
									
								}elsif(((!defined $AnalysisCoord || $AnalysisCoord == 0) && $RefCoord > 0) ||
								       ((defined $AnalysisCoord  && $AnalysisCoord > 0) && $RefCoord >= 0)){
									
									#Calculate TransMatrixA for the $AnalysisCoord to Coord 0!
									@ForceArray = @{transCoord($AnalysisCoord, $RefCoord, $Fx, $Fy, $Fz, $scale);};
									@MomentArray = @{transCoord($AnalysisCoord, $RefCoord, $Mx, $My, $Mz, $scale);};
									
								}
								
								$Fx = $ForceArray[0];  $Fy = $ForceArray[1];  $Fz = $ForceArray[2];
								$Mx = $MomentArray[0]; $My = $MomentArray[1]; $Mz = $MomentArray[2];								

								if($SizeEPTA > 1){
								
									# if $SizeEPTA > 1, this means that there is at least one element connecting to 
									# the current node, if $SizeEPTA = 1, then $Fx = $T1_Total - 0
									# $Fx = $T1_Total, and the line where the value of $T1_Total is used would have
									# been printed

									# The line $Fx = sprintf("%.6f", $Fx); converts scientific notation to integers
									# This is because if the value is too long Perl uses scientific notation,
									# and the printed results can be wrong because printing cuts for example e-19 (1.07854145176532154e-19)									

									$Fx = sprintf("%.6f", $Fx); $Fy = sprintf("%.6f", $Fy); $Fz = sprintf("%.6f", $Fz);
									$Mx = sprintf("%.6f", $Mx); $My = sprintf("%.6f", $My); $Mz = sprintf("%.6f", $Mz);
								
									write(FREEBODYTRANSFORMED);
									
									# Printing same info into .freebodytemp file, this file will be easier to read
									# .freebodyloads will have the same information but will have header info
					
									print FREEBODYTEMP ("$NODE_ID $AnalysisCoord $RefCoord $NumberOfMaxMins $X $Y $Z $Fx $Fy $Fz $Mx $My $Mz $LOAD_NO $LOAD_NAME\n");
								}
								
								# ***************************************								
								
								@NodeInfoArray = (); # This array contains information for each node (contains more than 
										     # one line. That's why it is emptied for the next node For example:
										     # 10                  APP-LOAD       1.000620E+00  ...
         									     # 10                  F-OF-MPC       2.245491E+01  ...
         									     # 10        112120    BUSH          -2.345553E+01  ...
         									     # 10                  *TOTALS*      -1.389166E-08  ...

								# NIACnt = 0; No need to make this value zero here, it becomes zero when program moves to next node

								$NodeIDCnt++; # Counts the number of nodes, indicates which node id is active 
									      # Note: there are more than one line starting with this id.

								next NODE;
								
							} #if (($SZ == 10 && $nodeid == $ndcolumn[0]) || ($SZ == 11 && $nodeid == $ndcolumn[1]) ||
						} #while (1) { 
					} #NODE: while (defined $LN) {	    

					#foreach(@ElmPosArray){
						#print OUTFILE ("$_\n");
					#}

					$SubcaseIDCnt++;

					next SUBCASE;
				} # if ( defined $column[8]  && ($size == 10 && $subcaseid == $column[8]) || 
			} # while (1) { 
		} # SUBCASE: while (defined $line) {

		close INFILE;
	
	} # for (my $i =0; $i<= $#gpfbFileArray; $i++) {
	
	#close OUTFILE;
	close FREEBODYLOADS;
	close FREEBODYTRANSFORMED;
	close FREEBODYTEMP;
	#close CODE;
}	

# ******************************************************************************************************
#											      	       *
# INTERNAL SUB FUNCTION NAME    : sortNodeIds					             	       *
# INTERNAL SUB FUNCTION PURPOSE : This fuction sorts the first column of printed data in .freebodytemp *
# 				  file. This sorted file will be later used for sorting the loads      *
#				  for maximum and minimum load cases.			  	       *
#												       *
# ******************************************************************************************************

sub sortNodeIds {

	# **************** checking .freebodydat file *******************************************************************
	# This section looks for .freebodytemp file to open for sorting the result data based on the first column
	# which is the node id data. This is then used for searching for max and min load

	for (my $i =0; $i<= $#f06FileArray; $i++) {
	
		(my $filenamepr) = split/\./,$f06FileArray[$i];

		$freebodytempFileArray[$i] = "$filenamepr.freebodytemp";
		$freebodytemp2FileArray[$i] = "$filenamepr.freebodytemp2";
	}
	

	for (my $i =0; $i<= $#f06FileArray; $i++) {
	

		if(-e $freebodytempFileArray[$i]){

			open (INFILE, "<$freebodytempFileArray[$i]") or die "Could not open file $freebodytempFileArray[$i]";
			open (FREEBODYTEMPTWO, ">$freebodytemp2FileArray[$i]") or die "Could not open file $freebodytemp2FileArray[$i]";
			
		}else{
			print("Could not open file $freebodydatFileArray[$i]\n");
		}

		# ***** Header for *.freebodymaxmins file *****************************************************
		
		$l_time =localtime;	$gm_time = gmtime;

		print FREEBODYTEMPTWO ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");
		print FREEBODYTEMPTWO ("\$Originated From: $f06FileArray[$i]\n");
		print FREEBODYTEMPTWO ("\$\n");
			
		my @array = ();
		my @column = ();
		my $line = "";

		do {
			$line = <INFILE>;

		}while($line =~ /^\$/);

		@column = split (" ", $line);
		push @array, [$line, $column[0]];
		
		while(<INFILE>) {
		
			$line = $_;
			
			@column = split (" ", $line);
			
			push @array, [$line, $column[0]];
		}

		@array = map {$_->[0]}
			sort {$a->[1] <=> $b->[1]}
			@array;

		print FREEBODYTEMPTWO @array;

		close FILE;
		close FREEBODYTEMPTWO;
	}

}

# **************************************************************************************************
#											      	   *
# INTERNAL SUB FUNCTION NAME    : extractMaxMins				             	   *
# INTERNAL SUB FUNCTION PURPOSE : This fuction extracts maximum and minimum load case values for   *
#				  the freebody loads.						   *
#												   *
# **************************************************************************************************

sub extractMaxMins {


	my $NODE_ID = 0; 
	my $ANALYSIS_COORD = -1;
	my $REF_COORD = -1;
	my $X = 0; 
	my $Y = 0; 
	my $Z = 0; 
	my $Fx = 0;
	my $LOAD_Fx = 0;  
	my $Fy = 0;
	my $LOAD_Fy = 0;
	my $Fz = 0;
	my $LOAD_Fz = 0;
	my $Mx = 0;
	my $LOAD_Mx = 0; 
	my $My = 0; 
	my $LOAD_My = 0;
	my $Mz = 0;
	my $LOAD_Mz = 0;

format FREEBODYMAXMINS_TOP =

					@|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||          Pg. @<<<<<
					"Grid Point Force Balance (Freebody Loads Max Min Load Cases)",            $%

Node_Id     Analy.Coord   Ref.Coord          X             Y             Z            Fx          Load_No         Fy          Load_No         Fz          Load_No         Mx          Load_No         My          Load_No         Mz          Load_No   
---------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- 
. 

format FREEBODYMAXMINS =
@<<<<<<<<<<<@||||||||||  @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||    @||||||||||   @||||||||||   @||||||||||
$NODE_ID,$ANALYSIS_COORD, $REF_COORD, $X, $Y, $Z, $Fx, $LOAD_Fx, $Fy, $LOAD_Fy, $Fz, $LOAD_Fz, $Mx, $LOAD_Mx, $My, $LOAD_My, $Mz, $LOAD_Mz
.

	# **************** checking .freebodytemp2 file *******************************************************************
	# This section looks for .freebodytemp2 file to open for sorting the resultd data based on the first column
	# which is the node id data. This is then used for searching for max and min load
	
	for (my $i =0; $i<= $#f06FileArray; $i++) {
	
		(my $filenamepr) = split/\./,$_;

		$freebodytempFileArray[$i] = "$filenamepr.freebodytemp";
		$freebodytemp2FileArray[$i] = "$filenamepr.freebodytemp2";
		$freebodymaxminsFileArray[$i] = "$filenamepr.freebodymaxmins";				
	}

	for (my $i =0; $i<= $#f06FileArray; $i++) {

		if(-e $freebodytempFileArray[$i]){

			open (INFILE, "<$freebodytemp2FileArray[$i]") or die "Could not open file $freebodytemp2FileArray[$i]";
			open (FREEBODYMAXMINS, ">$freebodymaxminsFileArray[$i]") or die "Could not open file $freebodymaxminsFileArray[$i]";
			
		}else{
			print("Could not open file $freebodydatFileArray[$i]\n");
		}
	
		# ***** Header for *.freebodymaxmins file *****************************************************
		
		$l_time =localtime;	$gm_time = gmtime;

		print FREEBODYMAXMINS ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");
		print FREEBODYMAXMINS ("\$Originated From: $f06FileArray[$i]\n");
		print FREEBODYMAXMINS ("\$\n");

		my @column = ();
		my $line = "";

		do {
	
			$line = <INFILE>;
		
		}while($line =~ /^\$/);

		$line = <INFILE>;
		if (!defined $line){@column = ();}else{@column = split  " ", $line;}

	
		NODE: while (defined $line) {
		
			my $element = $column[0];
		
			my $NumberOfMaxMins = 0;
		
			my @Fxarray = ();
			my @Fyarray = ();
			my @Fzarray = ();
			my @Mxarray = ();
			my @Myarray = ();
			my @Mzarray = ();
	    
			push @Fxarray, [$line, $column[7]];
			push @Fyarray, [$line, $column[8]];
			push @Fzarray, [$line, $column[9]];
			push @Mxarray, [$line, $column[10]];
			push @Myarray, [$line, $column[11]];
			push @Mzarray, [$line, $column[12]];
	    
			while (1) {
		
				$line = <INFILE>;
			
				if (!defined $line){@column = ();}else{@column = split  " ", $line;}
		
				if (defined $column[0] && $element == $column[0]) {
				
					push @Fxarray, [$line, $column[7]];
					push @Fyarray, [$line, $column[8]];
					push @Fzarray, [$line, $column[9]];
					push @Mxarray, [$line, $column[10]];
					push @Myarray, [$line, $column[11]];
					push @Mzarray, [$line, $column[12]];
					
				}else {

					#sort using psudo-Schwartzian Transform
				
					# ************** Fx Section ************************************
				
					@Fxarray = map {$_->[0]} 
					   	sort {$a->[1] <=> $b->[1]} 
					   	@Fxarray;
				
					my @Fxline = split  " ", $Fxarray[0];
				
					$NODE_ID = $Fxline[0]; 
					$ANALYSIS_COORD = $Fxline[1];
					$REF_COORD = $Fxline[2];
					$NumberOfMaxMins = $Fxline[3];
					$X = $Fxline[4]; 
					$Y = $Fxline[5]; 
					$Z = $Fxline[6];
				
					my $SizeFxA = @Fxarray;
					my @FxMaxMinArray = ();
					my $FxMMACnt = 0;
					my @FxMaxMinLoadArray = ();
				
					for(my $i = 0; $i < $NumberOfMaxMins; $i++){
				
						@Fxline = split  " ", $Fxarray[$i];
						
						$FxMaxMinArray[$FxMMACnt] = $Fxline[7];
						$FxMaxMinLoadArray[$FxMMACnt] = $Fxline[13];
						$FxMMACnt++
					
										
					}

					for(my $j = ($SizeFxA-$NumberOfMaxMins); $j < $SizeFxA; $j++){
				
						@Fxline = split  " ", $Fxarray[$j];
						
						$FxMaxMinArray[$FxMMACnt] = $Fxline[7];
						$FxMaxMinLoadArray[$FxMMACnt] = $Fxline[13];
						$FxMMACnt++
					}				
				
					# ************** Fy Section ************************************
				
					@Fyarray = map {$_->[0]} 
					   	   sort {$a->[1] <=> $b->[1]} 
					   	   @Fyarray;
				
					my @Fyline = ();
				
					my $SizeFyA = @Fyarray;
					my @FyMaxMinArray = ();
					my $FyMMACnt = 0;
					my @FyMaxMinLoadArray = ();
				
					for(my $i = 0; $i < $NumberOfMaxMins; $i++){
				
						@Fyline = split  " ", $Fyarray[$i];
						
						$FyMaxMinArray[$FyMMACnt] = $Fyline[8];
						$FyMaxMinLoadArray[$FyMMACnt] = $Fyline[13];
						$FyMMACnt++
					
										
					}

					for(my $j = ($SizeFyA-$NumberOfMaxMins); $j < $SizeFyA; $j++){
				
						@Fyline = split  " ", $Fyarray[$j];
						
						$FyMaxMinArray[$FyMMACnt] = $Fyline[8];
						$FyMaxMinLoadArray[$FyMMACnt] = $Fyline[13];
						$FyMMACnt++
					}				

					# ************** Fz Section ************************************
				
					@Fzarray = map {$_->[0]} 
					   	   sort {$a->[1] <=> $b->[1]} 
					   	   @Fzarray;
				
					my @Fzline = ();
				
					my $SizeFzA = @Fzarray;
					my @FzMaxMinArray = ();
					my $FzMMACnt = 0;
					my @FzMaxMinLoadArray = ();
				
					for(my $i = 0; $i < $NumberOfMaxMins; $i++){
				
						@Fzline = split  " ", $Fzarray[$i];
						
						$FzMaxMinArray[$FzMMACnt] = $Fzline[9];
						$FzMaxMinLoadArray[$FzMMACnt] = $Fzline[13];
						$FzMMACnt++						
					}

					for(my $j = ($SizeFzA-$NumberOfMaxMins); $j < $SizeFzA; $j++){
				
						@Fzline = split  " ", $Fzarray[$j];
						
						$FzMaxMinArray[$FzMMACnt] = $Fzline[9];
						$FzMaxMinLoadArray[$FzMMACnt] = $Fzline[13];
						$FzMMACnt++
					}
				
					# ************** Mx Section ************************************
				
					@Mxarray = map {$_->[0]} 
					   	   sort {$a->[1] <=> $b->[1]} 
					   	   @Mxarray;
				
					my @Mxline = ();
				
					my $SizeMxA = @Mxarray;
					my @MxMaxMinArray = ();
					my $MxMMACnt = 0;
					my @MxMaxMinLoadArray = ();
				
					for(my $i = 0; $i < $NumberOfMaxMins; $i++){
				
						@Mxline = split  " ", $Mxarray[$i];
						
						$MxMaxMinArray[$MxMMACnt] = $Mxline[10];
						$MxMaxMinLoadArray[$MxMMACnt] = $Mxline[13];
						$MxMMACnt++
					
										
					}

					for(my $j = ($SizeMxA-$NumberOfMaxMins); $j < $SizeMxA; $j++){
				
						@Mxline = split  " ", $Mxarray[$j];
						
						$MxMaxMinArray[$MxMMACnt] = $Mxline[10];
						$MxMaxMinLoadArray[$MxMMACnt] = $Mxline[13];
						$MxMMACnt++
					}
				
					# ************** My Section ************************************
				
					@Myarray = map {$_->[0]} 
					   	   sort {$a->[1] <=> $b->[1]} 
					   	   @Myarray;
				
					my @Myline = ();
				
					my $SizeMyA = @Myarray;
					my @MyMaxMinArray = ();
					my $MyMMACnt = 0;
					my @MyMaxMinLoadArray = ();
				
					for(my $i = 0; $i < $NumberOfMaxMins; $i++){
				
						@Myline = split  " ", $Myarray[$i];
						
						$MyMaxMinArray[$MyMMACnt] = $Myline[11];
						$MyMaxMinLoadArray[$MyMMACnt] = $Myline[13];
						$MyMMACnt++
					
										
					}

					for(my $j = ($SizeMyA-$NumberOfMaxMins); $j < $SizeMyA; $j++){
				
						@Myline = split  " ", $Myarray[$j];
						
						$MyMaxMinArray[$MyMMACnt] = $Myline[11];
						$MyMaxMinLoadArray[$MyMMACnt] = $Myline[13];
						$MyMMACnt++
					}
				
					# ************** Mz Section ************************************
				
					@Mzarray = map {$_->[0]} 
					   	   sort {$a->[1] <=> $b->[1]} 
					   	   @Mzarray;
				
					my @Mzline = ();
				
					my $SizeMzA = @Mzarray;
					my @MzMaxMinArray = ();
					my $MzMMACnt = 0;
					my @MzMaxMinLoadArray = ();
				
					for(my $i = 0; $i < $NumberOfMaxMins; $i++){
				
						@Mzline = split  " ", $Mzarray[$i];
						
						$MzMaxMinArray[$MzMMACnt] = $Mzline[12];
						$MzMaxMinLoadArray[$MzMMACnt] = $Mzline[13];
						$MzMMACnt++
										
					}

					for(my $j = ($SizeMzA-$NumberOfMaxMins); $j < $SizeMzA; $j++){
				
						@Mzline = split  " ", $Mzarray[$j];
						
						$MzMaxMinArray[$MzMMACnt] = $Mzline[12];
						$MzMaxMinLoadArray[$MzMMACnt] = $Mzline[13];
						$MzMMACnt++
					}
																			
					for(my $i = 0; $i <=$#FxMaxMinArray; $i++){
					
						$Fx = $FxMaxMinArray[$i]; $LOAD_Fx = $FxMaxMinLoadArray[$i]; 
						$Fy = $FyMaxMinArray[$i]; $LOAD_Fy = $FyMaxMinLoadArray[$i];
						$Fz = $FzMaxMinArray[$i]; $LOAD_Fz = $FzMaxMinLoadArray[$i]; 
					
						$Mx = $MxMaxMinArray[$i]; $LOAD_Mx = $MxMaxMinLoadArray[$i];
						$My = $MyMaxMinArray[$i]; $LOAD_My = $MyMaxMinLoadArray[$i]; 
						$Mz = $MzMaxMinArray[$i]; $LOAD_Mz = $MzMaxMinLoadArray[$i];
					
						write(FREEBODYMAXMINS);
					}
				
					next NODE;
				}
			}
		}

		close INFILE;
		close FREEBODYMAXMINS;
		
		if(-e $freebodytempFileArray[$i]){
			
			unlink ("$freebodytempFileArray[$i]") or die "Could not unlink file $freebodytempFileArray[$i]";
		}
		
		if(-e $freebodytemp2FileArray[$i]){
		
			unlink ("$freebodytemp2FileArray[$i]") or die "Could not unlink file $freebodytemp2FileArray[$i]";
		}
	}
}


# *************************************************************************************************
#											      	  *
# INTERNAL SUB FUNCTION NAME    : extractDisp					                  *
# INTERNAL SUB FUNCTION PURPOSE : This function extracts grid point forces and moments from       *
#                                 initial sort file						  *
#												  *
# *************************************************************************************************


sub extractDisp {

	my @NodeIDArray = ();
	my $NIACnt = 0;
	my $SizeNIA = 0;
	
	my @CoordIDCheckArray = ();
	my $CICACnt = 0;
	my $SizeCIEA = 0;

	my @GamahCouplingInfoArray = ();
	my $GCIACnt = 0;
	my $SizeGCIA = 0;
		
	if(defined $_[0] && defined $_[1]){ 

		$SizeNIA = $_[0];
		$SizeCIEA = $_[1];
		$SizeGCIA = $_[2];
	}else{
		print "SizeNIA : Size of NodeIDArray or SizeCIEA : CoordIDCheckArray not defined!";
		
	}

	for(my $i = 3; $i < (3 + $SizeNIA); $i++){
						
		$NodeIDArray[$NIACnt] = $_[$i];
		$NIACnt++;
		
	}

	for(my $i = (3 + $SizeNIA) ; $i < (3 + $SizeNIA + $SizeCIEA); $i++){
						
		$CoordIDCheckArray[$CICACnt] = $_[$i];
		$CICACnt++;
		
	}

	for(my $i = (3 + $SizeNIA + $SizeGCIA) ; $i < (3 + $SizeNIA + $SizeCIEA + $SizeGCIA); $i++){
						
		$GamahCouplingInfoArray[$GCIACnt] = $_[$i];
		$GCIACnt++;
	}

	#foreach(@NodeIDArray){
		
	#	print "NodeIDArray: $_\n";
	#}

	#foreach(@CoordIDCheckArray){
		
	#	print "CoordIDCheckArray: $_\n";
	#}
	
	#foreach(@GamahCouplingInfoArray){
		
	#	print "GamahCouplingInfoArray: $_\n";
	#}	
	
	#my $XSummed = 0;
	#my $YSummed = 0;
	#my $ZSummed = 0;
		
	my $ANALYSIS_COORD = -1;
	my $REF_COORD = -1;
	
	my $scale = 0;

	my $NODE_ID = 0;
	 
	#my $X = 0; 
	#my $Y = 0; 
	#my $Z = 0; 
	
	my $Fx = 0; my $MPCFx = 0; 
	my $Fy = 0; my $MPCFy = 0;
	my $Fz = 0; my $MPCFz = 0;
	my $Mx = 0; my $MPCMx = 0;
	my $My = 0; my $MPCMy = 0;
	my $Mz = 0; my $MPCMz = 0;
	
	my $LOAD_NO = 0; 
	my $LOAD_NAME = "LC";

	my $COMPONENT = "";
	my $NODE1 = 0;
	my $NODE2 = 0;
	my $NODE3 = 0;
	my $NODE4 = 0;
	my $NODE5 = 0;
	my $NODE6 = 0;

	my $RELDISP_XX = 0;
	my $RELDISP_YY  = 0;
	my $RELDISP_ZZ  = 0;
	my $RELDISP_YZ  = 0;
	
	my $RELROT_N13_YY  = 0;
	my $RELROT_N13_ZZ  = 0;
	my $RELROT_N13_YZ  = 0;
	
	my $RELROT_N46_YY  = 0;
	my $RELROT_N46_ZZ  = 0;
	my $RELROT_N46_YZ  = 0;
	
	my @TransResultsArray = ();
	my $TRACnt = 0;
	
	my @RotResultsArray = ();
	my $RRACnt = 0;
	
format TRANSDISP_TOP =

				                   Grid Point Force Balance about a Summation Point

Node_Id        Analy.Coord   Ref.Coord         Fx            Fy            Fz            Mx            My            Mz          Load_No      Load_Name
------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- 
. 


format TRANSDISP =
@<<<<<<<<<<<@||||||||||     @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @*
$NODE_ID, $ANALYSIS_COORD, $REF_COORD, $Fx, $Fy, $Fz, $Mx, $My, $Mz, $LOAD_NO, $LOAD_NAME 
.

format DISPRESULTS_TOP =

				                                 Gamah Coupling Results

Result_Component  Analy.Coord   Ref.Coord        Node1         Node2        Node3         Node4         Node5         Node6         Load_No      Load_Name
---------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- 
. 


format DISPRESULTS =
@<<<<<<<<<<<<<<<@||||||||||    @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @||||||||||   @*
$COMPONENT, $ANALYSIS_COORD, $REF_COORD, $NODE1, $NODE2, $NODE3, $NODE4, $NODE5, $NODE6, $LOAD_NO, $LOAD_NAME 
.

format TRANSRESULTS_TOP =

******************************************************************************************************************************************************************************************************************************
*																											     *
*					GAMAH COUPLING TRANSLATIONAL AND ROTATIONAL DISPLACEMENT RESULTS SUMMARY													     *
*																											     *
******************************************************************************************************************************************************************************************************************************

Gamah_Coupling_ID      Analy.Coord   Ref.Coord   Rel.Disp.XX_Node1-Node3(Or_Node_6)  Rel.Disp.YY_Node1-Node3(Or_Node_6)   Rel.Disp.ZZ_Node1-Node3(Or_Node_6)  Rel.Disp.YZ_Node1-Node3(Or_Node_6)    Load_No      Load_Name
--------------------- ------------- ----------- ----------------------------------- ------------------------------------ ----------------------------------- ------------------------------------ ------------- ------------- 
. 

format TRANSRESULTS =
@<<<<<<<<<<<<<<<<<<<<<@||||||||||   @||||||||||    @||||||||||||||||||||||||||         @||||||||||||||||||||||||||            @||||||||||||||||||||||||||        @||||||||||||||||||||||||||      @||||||||||   @*
$COMPONENT, $ANALYSIS_COORD, $REF_COORD, $RELDISP_XX , $RELDISP_YY , $RELDISP_ZZ, $RELDISP_YZ , $LOAD_NO, $LOAD_NAME 
.

format ROTRESULTS_TOP =

Gamah_Coupling_ID      Analy.Coord   Ref.Coord   Rel.Rot.YY_Node1-Node3   Rel.Rot.ZZ_Node1-Node3   Rel.Rot.YZ_Node1-Node3   Rel.Rot.YY_Node4-Node6   Rel.Rot.ZZ_Node4-Node6   Rel.Rot.YZ_Node4-Node6    Load_No      Load_Name
--------------------- ------------- ----------- ------------------------ ------------------------ ------------------------ ------------------------ ------------------------ ------------------------ ------------- ------------- 
. 

format ROTRESULTS =
@<<<<<<<<<<<<<<<<<<<<<@||||||||||   @|||||||||| @||||||||||||||||||||||| @||||||||||||||||||||||| @||||||||||||||||||||||| @||||||||||||||||||||||| @||||||||||||||||||||||| @||||||||||||||||||||||| @||||||||||   @*
$COMPONENT, $ANALYSIS_COORD, $REF_COORD, $RELROT_N13_YY, $RELROT_N13_ZZ, $RELROT_N13_YZ, $RELROT_N46_YY, $RELROT_N46_ZZ, $RELROT_N46_YZ, $LOAD_NO, $LOAD_NAME 
.

	(my $filenamepr) = split/\./,$f06FileArray[0];
	
	my $datFile = "$filenamepr.dat";
	my $transdispFile = "$filenamepr.transdisp";
	my $dispresultsFile = "$filenamepr.dispresults";
	
	for (my $i =0; $i<= $#f06FileArray; $i++) {

		my $SubcaseIDCnt = 0;

		open(INFILE, "<$datFile") or die "Unable to open input file $datFile\n";
		open (TRANSDISP, ">>$transdispFile") or die "could not open outfile $transdispFile";
		open (DISPRESULTS, ">>$dispresultsFile") or die "could not open outfile $dispresultsFile";
			
		# ***** Header for *.gpfb file *****************************************************
		
		$l_time =localtime;	$gm_time = gmtime;

		print TRANSDISP ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");
		print DISPRESULTS ("\$LOCAL TIME:$l_time	GMT:$gm_time\n");
		

		print TRANSDISP ("\$Originated From: $f06FileArray[$i]\n");
		print DISPRESULTS ("\$Originated From: $f06FileArray[$i]\n");		
		
		print TRANSDISP ("\$\n");
		print DISPRESULTS ("\$\n");
		
		# ***** Header for *.gpfb file *****************************************************

		for(my $i = 0; $i < 3 ; $i++) {
			<INFILE>;
		}


		my @EachSubcaseMatrix = (); # Grid point force balance info for each sub case is put into a big matrix
		my $ESMCnt = 0;             # Counter for @EachSubcaseMatrix

		my $line = <INFILE>;
		my @column = split " ", $line;

		SUBCASE: while (defined $line) {

			my $subcaseid   = $column[8];
			my $subcasename = $column[9];

			$EachSubcaseMatrix[$ESMCnt] = $line;
			$ESMCnt++;
						
			while (1) {    

				$line = <INFILE>;

				if (!defined $line){@column = ();}else{@column = split  " ", $line;}

				if (defined $column[8]  && $subcaseid == $column[8]) {
					
					$EachSubcaseMatrix[$ESMCnt] = $line; # node displacement info for each sub case is put into a big matrix
					$ESMCnt++;			     # first then analysed after else statement.		    
				}else {

					#my $XCoord = 0; my $YCoord = 0; my $ZCoord = 0; # X, Y, Z coordinates of the nodes
					my $AnalysisCoord = -1; # Analysis Coordinate of the Grid
					my $RefCoord = -1; # Analysis Coordinate of the Grid
					
					#$XCoord = $SelNodeXCoordArray[$NodeIDCnt]; 
					#$YCoord = $SelNodeYCoordArray[$NodeIDCnt]; 
					#$ZCoord = $SelNodeZCoordArray[$NodeIDCnt];
					#$AnalysisCoord = $AnalysisCoordArray[$NodeIDCnt];
					
					#my $NodeIDCnt = 0;
									
					my @TransformedMatrix = ();
					my $TMCnt = 0;					

					for(my $i = 0; $i <= $#GamahCouplingInfoArray; $i++){
						
						chomp($GamahCouplingInfoArray[$i]);
						
						my @linearray1 = split  ",", $GamahCouplingInfoArray[$i];
						my $size = @linearray1;
						$RefCoord = $linearray1[$size-1];

						for(my $j = 1; $j < $#linearray1; $j++){
						
							my $node = $linearray1[$j];
							
							for(my $k = 0; $k <= $#EachSubcaseMatrix; $k++){
							
								chomp($EachSubcaseMatrix[$k]);
								my @ForceMatrix = split  " ", $EachSubcaseMatrix[$k];

								if($ForceMatrix[0] == $node){
								
									#print "ForceMatrix[0]:$ForceMatrix[0] node:$node\n";
								
									$NODE_ID = $ForceMatrix[0];
									$LOAD_NO = $ForceMatrix[8]; 
									$LOAD_NAME = $ForceMatrix[9];
						
									# NOTE (IMPORTANT!): $i is the same as $NodeIDCnt in the interface.pl
									my @DispXYZCoordArray = split ",", $DispNodeXYZCoordArray[$i]; # $i is the same as $NodeIDCnt in the interface.pl
						
									$AnalysisCoord = $DispXYZCoordArray[4]; 
									$ANALYSIS_COORD = $AnalysisCoord;
						
									$Fx = $ForceMatrix[2]; $Fy = $ForceMatrix[3]; $Fz = $ForceMatrix[4];
									$Mx = $ForceMatrix[5]; $My = $ForceMatrix[6]; $Mz = $ForceMatrix[7];

									# ******* Transformation Section 1 *******
									# Because of the summation we cannot use the following function for example 
									# Transformation from Coord 2 to Coord 4: @ForceArray = @{transCoord(2, 4, $Fx, $Fy, $Fz, $scale);};
									# This is because summation needs to be calculated based on values defined in global axis system (Coord 0)
									# Or summation Coordinates needs to be transformed as well to get the correct results
						
									my @ForceArray = ();
									my @MomentArray = ();
						
									$scale = 1;
						
									if(!defined $AnalysisCoord || $AnalysisCoord == 0){
						
										#No need to calculate TransMatrixA for the $AnalysisCoord to Coord 0!
										@ForceArray = ($Fx, $Fy, $Fz);
										@MomentArray = ($Mx, $My, $Mz);
						
									}elsif(defined $AnalysisCoord  && $AnalysisCoord > 0){
																
										$RefCoord = 0;  # We need to transfer the results from the analysis coord to Coordinate zero
							
										#Calculate TransMatrixA for the $AnalysisCoord to Coord 0!
										@ForceArray = @{transCoord($AnalysisCoord, $RefCoord, $Fx, $Fy, $Fz, $scale);};
										@MomentArray = @{transCoord($AnalysisCoord, $RefCoord, $Mx, $My, $Mz, $scale);};
																
									}

									$Fx = $ForceArray[0];  $Fy = $ForceArray[1];  $Fz = $ForceArray[2];
									$Mx = $MomentArray[0]; $My = $MomentArray[1]; $Mz = $MomentArray[2];
															
									$Fx = sprintf("%.6f", $Fx); $Fy = sprintf("%.6f", $Fy); $Fz = sprintf("%.6f", $Fz);
									$Mx = sprintf("%.6f", $Mx); $My = sprintf("%.6f", $My); $Mz = sprintf("%.6f", $Mz);
						
									# ******* Transformation Section 2 *******
						
									@ForceArray = ();
									@MomentArray = ();
						
									$scale = 1;
												
									$REF_COORD = $RefCoord;
											
									if($RefCoord == 0){
						
										#No need to calculate TransMatrixA for the $AnalysisCoord to Coord 0!
										@ForceArray = ($Fx, $Fy, $Fz);
										@MomentArray = ($Mx, $My, $Mz);
						
									}elsif($RefCoord > 0){
							
										$AnalysisCoord = 0;
							
										#Calculate TransMatrixA for the $AnalysisCoord to Coord 0!
										@ForceArray = @{transCoord($AnalysisCoord, $RefCoord, $Fx, $Fy, $Fz, $scale);};
										@MomentArray = @{transCoord($AnalysisCoord, $RefCoord, $Mx, $My, $Mz, $scale);};
						
									}
						
									$Fx = $ForceArray[0];  $Fy = $ForceArray[1];  $Fz = $ForceArray[2];
									$Mx = $MomentArray[0]; $My = $MomentArray[1]; $Mz = $MomentArray[2];
						
									$Fx = sprintf("%.6f", $Fx); $Fy = sprintf("%.6f", $Fy); $Fz = sprintf("%.6f", $Fz);
						
									# Converting rotations to degrees
									$Mx = (57.3 * $Mx);         $My = (57.3 * $My);         $Mz = (57.3 * $Mz);
									$Mx = sprintf("%.6f", $Mx); $My = sprintf("%.6f", $My); $Mz = sprintf("%.6f", $Mz);
							
									write(TRANSDISP); 

									# ***** Putting the transformed values into @TransformedMatrix *********
						
									$TransformedMatrix[$TMCnt] = "$NODE_ID,$ANALYSIS_COORD,$REF_COORD,$Fx,$Fy,$Fz,$Mx,$My,$Mz,$LOAD_NO,$LOAD_NAME";
									$TMCnt++;
								
									# **********************************************************************
								
								} # End of if($ForceMatrix[0] == $node){
					
							} # End of for(my $k = 0; $k <= $#EachSubcaseMatrix; $k++){
						
						} # End of for(my $j = 1; $j < $#linearray1; $j++){
					
					} # End of for(my $i = 0; $i <= $#GamahCouplingInfoArray; $i++){
					
					#foreach(@TransformedMatrix){
					
						#print "$_\n";
					#}
								
					for(my $i = 0; $i <= $#GamahCouplingInfoArray; $i++){

						my $ResultsTransXX = "";
						my $ResultsTransYY = "";
						my $ResultsTransZZ = "";
						my $ResultsTransYZ = "";
						my $ResultsTransZX = "";
						my $ResultsTransXY = "";
						my $ResultsTransXYZ = "";
					
						my $ResultsRotXX = "";
						my $ResultsRotYY = "";
						my $ResultsRotZZ = "";
						my $ResultsRotYZ = "";
						my $ResultsRotZX = "";
						my $ResultsRotXY = "";
						my $ResultsRotXYZ = "";
						
						chomp($GamahCouplingInfoArray[$i]);
						
						my @linearray1 = split  ",", $GamahCouplingInfoArray[$i];
						my $size = @linearray1;
						$REF_COORD = $linearray1[$size-1];
						
						my $CouplingLabel = $linearray1[0];
						
						$COMPONENT = "***";
										
						my $ANALYSIS_COORD_TMP = $ANALYSIS_COORD;
						my $REF_COORD_TMP = $REF_COORD;
						my $LOAD_NO_TMP = $LOAD_NO;
						my $LOAD_NAME_TMP = $LOAD_NAME;
						
						$ANALYSIS_COORD = "***";
						$REF_COORD = "***";
						$LOAD_NO = "***";
						$LOAD_NAME = "***";						
						
						$NODE1 = "Node" . " $linearray1[1]"; $NODE2 = "Node" . " $linearray1[2]"; $NODE3 = "Node" . " $linearray1[3]";
						
						if(defined $linearray1[5]){ # If results for single gamah coupling is being printed. Note $linearray1[4] contains ref coord id!
							$NODE4 = "Node" . " $linearray1[4]"; $NODE5 = "Node" . " $linearray1[5]"; $NODE6 = "Node" . " $linearray1[6]";
						}else{
							$NODE4 = "***"; $NODE5 = "***"; $NODE6 = "***";
						}
						
						write(DISPRESULTS);
						
						$ANALYSIS_COORD = $ANALYSIS_COORD_TMP;
						$REF_COORD = $REF_COORD_TMP;
						$LOAD_NO = $LOAD_NO_TMP;
						$LOAD_NAME = $LOAD_NAME_TMP;
						
						for(my $j = 1; $j < $#linearray1; $j++){
						
							my $Node = $linearray1[$j];

							my $size = @linearray1;
							my $CoordID = $linearray1[$size-1];
													
							for(my $k = 0; $k <=$#TransformedMatrix; $k++){
						
								my @linearray2 = split  ",", $TransformedMatrix[$k];
						
								if($Node == $linearray2[0] && $CoordID == $linearray2[2]){
								
									# Note: $TransformedMatrix[$i] = "$NODE_ID,$ANALYSIS_COORD,$REF_COORD,$Fx,$Fy,$Fz,$Mx,$My,$Mz,$LOAD_NO,$LOAD_NAME";
									
									$ResultsTransXX = $ResultsTransXX . " " . "$linearray2[3]";
									$ResultsTransYY = $ResultsTransYY . " " . "$linearray2[4]";
									$ResultsTransZZ = $ResultsTransZZ . " " . "$linearray2[5]";

									my $TransYZ = sqrt($linearray2[4]**2+$linearray2[5]**2);
									my $TransZX = sqrt($linearray2[5]**2+$linearray2[3]**2);
									my $TransXY = sqrt($linearray2[3]**2+$linearray2[4]**2);
									my $TransXYZ = sqrt($linearray2[3]**2+$linearray2[4]**2+$linearray2[5]**2);

									$ResultsTransYZ = $ResultsTransYZ . " " . "$TransYZ";
									$ResultsTransZX = $ResultsTransZX . " " . "$TransZX";
									$ResultsTransXY = $ResultsTransXY . " " . "$TransXY";
									$ResultsTransXYZ = $ResultsTransXYZ . " " . "$TransXYZ";
									
									$ResultsRotXX = $ResultsRotXX . " " . "$linearray2[6]";
									$ResultsRotYY = $ResultsRotYY . " " . "$linearray2[7]";
									$ResultsRotZZ = $ResultsRotZZ . " " . "$linearray2[8]";
									
									my $RotYZ = sqrt($linearray2[7]**2+$linearray2[8]**2);
									my $RotZX = sqrt($linearray2[8]**2+$linearray2[6]**2);
									my $RotXY = sqrt($linearray2[6]**2+$linearray2[7]**2);
									my $RotXYZ = sqrt($linearray2[6]**2+$linearray2[7]**2+$linearray2[8]**2);
									
									$ResultsRotYZ = $ResultsRotYZ . " " . "$RotYZ";
									$ResultsRotZX = $ResultsRotZX . " " . "$RotZX";
									$ResultsRotXY = $ResultsRotXY . " " . "$RotXY";
									$ResultsRotXYZ = $ResultsRotXYZ . " " . "$RotXYZ";
									
									# Rotations are converted using scale factor 57.3 for conversion from rad to degrees.!!!
									# Look above
								}
							} # End of for(my $k = 0; $k <= $#TransformedMatrix; $k++){s
						} # End of for(my $j = 0; $j <= $#linearray1; $j++){

						my $RelativeDispXX = 0;
						my $RelativeDispYY = 0;
						my $RelativeDispZZ = 0;
						my $RelativeDispYZ = 0;
						
						my $RelativeRotYY1 = 0;
						my $RelativeRotZZ1 = 0;
						my $RelativeRotYZ1 = 0;
						
						my $RelativeRotYY2 = 0;
						my $RelativeRotZZ2 = 0;
						my $RelativeRotYZ2 = 0;
							
						$COMPONENT = $CouplingLabel . "_" . "TransXX";
					
						my @ResultsTransXX = split " ", $ResultsTransXX;
					
						$NODE1 = $ResultsTransXX[0]; $NODE2 = $ResultsTransXX[1]; $NODE3 = $ResultsTransXX[2];						
						
						$RelativeDispXX = $NODE1 - $NODE3;
						
						if(defined $ResultsTransXX[3]){ # If results for single gamah coupling is being printed.
							
							$NODE4 = $ResultsTransXX[3]; $NODE5 = $ResultsTransXX[4]; $NODE6 = $ResultsTransXX[5];
							
							$RelativeDispXX = $NODE1 - $NODE6;
						}else{
							$NODE4 = "---"; $NODE5 = "---"; $NODE6 = "---";
						}
						
						write(DISPRESULTS);

						$COMPONENT = $CouplingLabel . "_" . "TransYY";
					
						my @ResultsTransYY = split " ", $ResultsTransYY;
					
						$NODE1 = $ResultsTransYY[0]; $NODE2 = $ResultsTransYY[1]; $NODE3 = $ResultsTransYY[2];
						
						$RelativeDispYY = $NODE1 - $NODE3;
						
						if(defined $ResultsTransYY[3]){ # If results for single gamah coupling is being printed.
							
							$NODE4 = $ResultsTransYY[3]; $NODE5 = $ResultsTransYY[4]; $NODE6 = $ResultsTransYY[5];
							
							$RelativeDispYY = $NODE1 - $NODE6;
						}else{
							$NODE4 = "---"; $NODE5 = "---"; $NODE6 = "---";
						}
						
						write(DISPRESULTS);

						$COMPONENT = $CouplingLabel . "_" . "TransZZ";
					
						my @ResultsTransZZ = split " ", $ResultsTransZZ;
					
						$NODE1 = $ResultsTransZZ[0]; $NODE2 = $ResultsTransZZ[1]; $NODE3 = $ResultsTransZZ[2];
						
						$RelativeDispZZ = $NODE1 - $NODE3;
												
						if(defined $ResultsTransZZ[3]){ # If results for single gamah coupling is being printed.
							
							$NODE4 = $ResultsTransZZ[3]; $NODE5 = $ResultsTransZZ[4]; $NODE6 = $ResultsTransZZ[5];
							
							$RelativeDispZZ = $NODE1 - $NODE6;
						}else{
							$NODE4 = "---"; $NODE5 = "---"; $NODE6 = "---";

						}
						
						$RelativeDispYZ = sqrt($RelativeDispYY**2+$RelativeDispZZ**2);
						
						write(DISPRESULTS);

						$COMPONENT = $CouplingLabel . "_" . "TransYZ";
					
						my @ResultsTransYZ = split " ", $ResultsTransYZ;
					
						$NODE1 = $ResultsTransYZ[0]; $NODE2 = $ResultsTransYZ[1]; $NODE3 = $ResultsTransYZ[2];
					
						if(defined $ResultsTransYZ[3]){ # If results for single gamah coupling is being printed.
							$NODE4 = $ResultsTransYZ[3]; $NODE5 = $ResultsTransYZ[4]; $NODE6 = $ResultsTransYZ[5];
						}else{
							$NODE4 = "---"; $NODE5 = "---"; $NODE6 = "---";
						}
					
						write(DISPRESULTS);

						$COMPONENT = $CouplingLabel . "_" . "TransZX";
					
						my @ResultsTransZX = split " ", $ResultsTransZX;
					
						$NODE1 = $ResultsTransZX[0]; $NODE2 = $ResultsTransZX[1]; $NODE3 = $ResultsTransZX[2];
					
						if(defined $ResultsTransZX[3]){ # If results for single gamah coupling is being printed.
							$NODE4 = $ResultsTransZX[3]; $NODE5 = $ResultsTransZX[4]; $NODE6 = $ResultsTransZX[5];
						}else{
							$NODE4 = "---"; $NODE5 = "---"; $NODE6 = "---";
						}
					
						write(DISPRESULTS);

						$COMPONENT = $CouplingLabel . "_" . "TransXY";
					
						my @ResultsTransXY = split " ", $ResultsTransXY;
					
						$NODE1 = $ResultsTransXY[0]; $NODE2 = $ResultsTransXY[1]; $NODE3 = $ResultsTransXY[2];
					
						if(defined $ResultsTransXY[3]){ # If results for single gamah coupling is being printed.
							$NODE4 = $ResultsTransXY[3]; $NODE5 = $ResultsTransXY[4]; $NODE6 = $ResultsTransXY[5];
						}else{
							$NODE4 = "---"; $NODE5 = "---"; $NODE6 = "---";
						}
					
						write(DISPRESULTS);

						$COMPONENT = $CouplingLabel . "_" . "TransXYZ";
					
						my @ResultsTransXYZ = split " ", $ResultsTransXYZ;
					
						$NODE1 = $ResultsTransXYZ[0]; $NODE2 = $ResultsTransXYZ[1]; $NODE3 = $ResultsTransXYZ[2];
					
						if(defined $ResultsTransXYZ[3]){ # If results for single gamah coupling is being printed.
							$NODE4 = $ResultsTransXYZ[3]; $NODE5 = $ResultsTransXYZ[4]; $NODE6 = $ResultsTransXYZ[5];
						}else{
							$NODE4 = "---"; $NODE5 = "---"; $NODE6 = "---";
						}
					
						write(DISPRESULTS);
					
						$COMPONENT = $CouplingLabel . "_" . "RotXX";
					
						my @ResultsRotXX = split " ", $ResultsRotXX;
					
						$NODE1 = $ResultsRotXX[0]; $NODE2 = $ResultsRotXX[1]; $NODE3 = $ResultsRotXX[2];
						
						if(defined $ResultsRotXX[3]){ # If results for single gamah coupling is being printed.
							
							$NODE4 = $ResultsRotXX[3]; $NODE5 = $ResultsRotXX[4]; $NODE6 = $ResultsRotXX[5];
							
						}else{
							$NODE4 = "---"; $NODE5 = "---"; $NODE6 = "---";
						}
											
						write(DISPRESULTS);

						$COMPONENT = $CouplingLabel . "_" . "RotYY";
					
						my @ResultsRotYY = split " ", $ResultsRotYY;
					
						$NODE1 = $ResultsRotYY[0]; $NODE2 = $ResultsRotYY[1]; $NODE3 = $ResultsRotYY[2];

						$RelativeRotYY1 = $NODE1 - $NODE3;
						
						if(defined $ResultsRotYY[3]){ # If results for single gamah coupling is being printed.

							$NODE4 = $ResultsRotYY[3]; $NODE5 = $ResultsRotYY[4]; $NODE6 = $ResultsRotYY[5];
							
							$RelativeRotYY2 = $NODE4 - $NODE6;
						}else{
							$NODE4 = "---"; $NODE5 = "---"; $NODE6 = "---";
							$RelativeRotYY2 = "---";
						}
						
						write(DISPRESULTS);

						$COMPONENT = $CouplingLabel . "_" . "RotZZ";
					
						my @ResultsRotZZ = split " ", $ResultsRotZZ;
					
						$NODE1 = $ResultsRotZZ[0]; $NODE2 = $ResultsRotZZ[1]; $NODE3 = $ResultsRotZZ[2];

						$RelativeRotZZ1 = $NODE1 - $NODE3;
						
						if(defined $ResultsRotZZ[3]){ # If results for single gamah coupling is being printed.
							
							$NODE4 = $ResultsRotZZ[3]; $NODE5 = $ResultsRotZZ[4]; $NODE6 = $ResultsRotZZ[5];
							$RelativeRotZZ2 = $NODE4 - $NODE6;
						}else{
							$NODE4 = "---"; $NODE5 = "---"; $NODE6 = "---";
							$RelativeRotZZ2 = "---";
						}
					
						$RelativeRotYZ1 = sqrt($RelativeRotYY1**2+$RelativeRotZZ1**2);
						
						if(defined $ResultsRotYY[3] && defined $ResultsRotZZ[3]){
							$RelativeRotYZ2 = sqrt($RelativeRotYY2**2+$RelativeRotZZ2**2);
						}else{
							$RelativeRotYZ2 = "---";
						}
						
						write(DISPRESULTS);

						$COMPONENT = $CouplingLabel . "_" . "RotYZ";
					
						my @ResultsRotYZ = split " ", $ResultsRotYZ;
					
						$NODE1 = $ResultsRotYZ[0]; $NODE2 = $ResultsRotYZ[1]; $NODE3 = $ResultsRotYZ[2];
					
						if(defined $ResultsRotYZ[3]){ # If results for single gamah coupling is being printed.
							$NODE4 = $ResultsRotYZ[3]; $NODE5 = $ResultsRotYZ[4]; $NODE6 = $ResultsRotYZ[5];
						}else{
							$NODE4 = "---"; $NODE5 = "---"; $NODE6 = "---";
						}
					
						write(DISPRESULTS);

						$COMPONENT = $CouplingLabel . "_" . "RotZX";
					
						my @ResultsRotZX = split " ", $ResultsRotZX;
					
						$NODE1 = $ResultsRotZX[0]; $NODE2 = $ResultsRotZX[1]; $NODE3 = $ResultsRotZX[2];
					
						if(defined $ResultsRotZX[3]){ # If results for single gamah coupling is being printed.
							$NODE4 = $ResultsRotZX[3]; $NODE5 = $ResultsRotZX[4]; $NODE6 = $ResultsRotZX[5];
						}else{
							$NODE4 = "---"; $NODE5 = "---"; $NODE6 = "---";
						}
					
						write(DISPRESULTS);

						$COMPONENT = $CouplingLabel . "_" . "RotXY";
					
						my @ResultsRotXY = split " ", $ResultsRotXY;
					
						$NODE1 = $ResultsRotXY[0]; $NODE2 = $ResultsRotXY[1]; $NODE3 = $ResultsRotXY[2];
					
						if(defined $ResultsRotXY[3]){ # If results for single gamah coupling is being printed.
							$NODE4 = $ResultsRotXY[3]; $NODE5 = $ResultsRotXY[4]; $NODE6 = $ResultsRotXY[5];
						}else{
							$NODE4 = "---"; $NODE5 = "---"; $NODE6 = "---";
						}
					
						write(DISPRESULTS);

						$COMPONENT = $CouplingLabel . "_" . "RotXYZ";
					
						my @ResultsRotXYZ = split " ", $ResultsRotXYZ;
					
						$NODE1 = $ResultsRotXYZ[0]; $NODE2 = $ResultsRotXYZ[1]; $NODE3 = $ResultsRotXYZ[2];
					
						if(defined $ResultsRotXYZ[3]){ # If results for single gamah coupling is being printed.
							$NODE4 = $ResultsRotXYZ[3]; $NODE5 = $ResultsRotXYZ[4]; $NODE6 = $ResultsRotXYZ[5];					
						}else{
							$NODE4 = "---"; $NODE5 = "---"; $NODE6 = "---";
						}
					
						write(DISPRESULTS);

						$COMPONENT = $CouplingLabel . "_" . "Trans.Results";
												
						$TransResultsArray[$TRACnt] = "$COMPONENT,$ANALYSIS_COORD,$REF_COORD,$RelativeDispXX,$RelativeDispYY,$RelativeDispZZ,$RelativeDispYZ,$LOAD_NO,$LOAD_NAME";
						$TRACnt++;
	
						$COMPONENT = $CouplingLabel . "_" . "Rot.Results";
						$RotResultsArray[$RRACnt] = "$COMPONENT,$ANALYSIS_COORD,$REF_COORD,$RelativeRotYY1,$RelativeRotZZ1,$RelativeRotYZ1,$RelativeRotYY2,$RelativeRotZZ2,$RelativeRotYZ2,$LOAD_NO,$LOAD_NAME";
						$RRACnt++;
						
					} # End of for(my $i = 0; $i <= $#GamahCouplingInfoArray; $i++){
					
					@TransformedMatrix = ();
					$TMCnt = 0;
					
					@EachSubcaseMatrix = ();
					$ESMCnt = 0;
					
					$SubcaseIDCnt++;
									
					next SUBCASE;
					
				} # if ( defined $column[8]  && ($size == 10 && $subcaseid == $column[8]) || 
			} # while (1) { 
		} # SUBCASE: while (defined $line) {

		close INFILE;
	
	} # for (my $i =0; $i<= $#dispFileArray; $i++) {

	close DISPRESULTS;					
	
	open (TRANSRESULTS, ">>$dispresultsFile") or die "could not open outfile $dispresultsFile";
		
	foreach(@TransResultsArray){
			
		my @ResultsLine = split ",",$_;
	
		$COMPONENT = $ResultsLine[0];
		$ANALYSIS_COORD = $ResultsLine[1];
		$REF_COORD = $ResultsLine[2];
		$RELDISP_XX = $ResultsLine[3];
		$RELDISP_YY = $ResultsLine[4];
		$RELDISP_ZZ = $ResultsLine[5];
		$RELDISP_YZ = $ResultsLine[6];
		$LOAD_NO = $ResultsLine[7];
		$LOAD_NAME = $ResultsLine[8];

		write(TRANSRESULTS);
	}
	
	close TRANSRESULTS;

	open (ROTRESULTS, ">>$dispresultsFile") or die "could not open outfile $dispresultsFile";
		
	foreach(@RotResultsArray){
			
		my @ResultsLine = split ",",$_;
	
		$COMPONENT = $ResultsLine[0];
		$ANALYSIS_COORD = $ResultsLine[1];
		$REF_COORD = $ResultsLine[2];
			
		$RELROT_N13_YY  = $ResultsLine[3];
		$RELROT_N13_ZZ  = $ResultsLine[4];
		$RELROT_N13_YZ  = $ResultsLine[5];
	
		$RELROT_N46_YY  = $ResultsLine[6];
		$RELROT_N46_ZZ  = $ResultsLine[7];
		$RELROT_N46_YZ  = $ResultsLine[8];
			
		$LOAD_NO = $ResultsLine[9];
		$LOAD_NAME = $ResultsLine[10];

		write(ROTRESULTS);	
	}
	
	close ROTRESULTS;
	close TRANSDISP;
	close DISPRESULTS;
}	


# **************************************************************************************************
#											      	   *
# INTERNAL SUB FUNCTION NAME    : deleteFiles					             	   *
# INTERNAL SUB FUNCTION PURPOSE : This deletes files generated from a previous extracting  	   *
#												   *
# **************************************************************************************************

sub deleteFiles {
	
	if (-e $ProgrammingLog_dat){
		unlink($ProgrammingLog_dat);
	}

	my $WorkingDir = cwd;	
	my $DataDir = "$WorkingDir\/DATA";

	for (my $i =0; $i<= $#f06FileArray; $i++) {
	
		(my $filenamepr) = split/\./,$f06FileArray[$i];

		my @filenamepr = split "\/",$filenamepr;
		my $Size = @filenamepr;

		$datFileArray[$i] = "$DataDir\/$filenamepr[$Size-1].dat";
		$mpcdatFileArray[$i] = "$DataDir\/$filenamepr[$Size-1].mpcdat";			
		$freebodydatFileArray[$i] = "$DataDir\/$filenamepr[$Size-1].freebodydat";		

		$interfacedataFileArray[$i] = "$DataDir\/$filenamepr[$Size-1].interfacedata";				
		$interfacesummedFileArray[$i] = "$DataDir\/$filenamepr[$Size-1].interfacesummed";		
		
		$mpcforcesFileArray[$i] = "$DataDir\/$filenamepr[$Size-1].MPCforces";
		$mpcsummedFileArray[$i] = "$DataDir\/$filenamepr[$Size-1].MPCsummed";

		my $interfacetotalsFile = "$filenamepr.interfacetotals";
		my $interfaceresultsFile = "$filenamepr.interfaceresults";
		
		my $MPCResultsFile = "$filenamepr.MPCresults";

		if (-e $datFileArray[$i]){		
			unlink($datFileArray[$i]);
		}
				
		if (-e $mpcdatFileArray[$i]){		
			unlink($mpcdatFileArray[$i]);
		}

		if (-e $mpcdatFileArray[$i]){		
			unlink($mpcdatFileArray[$i]);
		}

		if (-e $freebodydatFileArray[$i]){		
			unlink($freebodydatFileArray[$i]);
		}

		if (-e $interfacedataFileArray[$i]){
			unlink($interfacedataFileArray[$i]);
		}

		if (-e $interfacesummedFileArray[$i]){
			unlink($interfacesummedFileArray[$i]);
		}	

		if (-e $mpcforcesFileArray[$i]){
			unlink($mpcforcesFileArray[$i]);
		}

		if (-e $mpcsummedFileArray[$i]){
			unlink($mpcsummedFileArray[$i]);
		}

		if (-e $interfacetotalsFile){
			unlink($interfacetotalsFile);
		}

		if (-e $interfaceresultsFile){
			unlink($interfaceresultsFile);
		}

		if (-e $MPCResultsFile){
			unlink($MPCResultsFile);
		}
		
		$i++;
	}			
}


sub createExampleTxt{

    my $CurrentDir = cwd;

    mkdir ("$CurrentDir\/EXAMPLE_INPUT_TXT");

    open (INTERFACEINPUT, ">$CurrentDir\/EXAMPLE_INPUT_TXT\/InterfaceLoadsInputExample.txt") or die "Could not open $CurrentDir\/EXAMPLE_INPUT_TXT\/InterfaceLoadsInputExample.txt";

    print INTERFACEINPUT ("Point 1, POS1, Node 10, Element 300016:300017 302549, Coord 0,[16624.559    2010.5704    1810.4006]\n");
    print INTERFACEINPUT ("Point 3, POS3, Node 30, Element 300016:300017 302549, Coord 0,[16624.562    2226.906     1546.6548]\n");
    print INTERFACEINPUT ("Point 4, POS4, Node 40, Element 300016:300017 302549, Coord 0,[16624.6      2320.75      1394.6]\n");
    
    close INTERFACEINPUT;
}

# END ----------------------------------------------------------------------------------------------------------------------
