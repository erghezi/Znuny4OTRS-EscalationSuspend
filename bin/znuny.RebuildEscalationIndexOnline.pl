#!/usr/bin/perl -w
# --
# znuny.RebuildEscalationIndexOnline.pl - rebuild escalation index
# Copyright (C) 2014 Znuny GmbH, http://znuny.com/
# --

use strict;
use warnings;

# use ../ as lib location
use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);
use lib dirname($RealBin) . "/Kernel/cpan-lib";
use Getopt::Std;

# get options
my %Opts = ();
getopt( 'h', \%Opts );
if ( $Opts{h} ) {
    print "znuny.RebuildEscalationIndexOnline.pl - rebuild escalation index\n";
    print "Copyright (C) 2014 Znuny GmbH, http://znuny.com/\n";
    print "usage: znuny.RebuildEscalationIndexOnline.pl\n";
    exit 1;
}

use Kernel::System::ObjectManager;

# create common objects
local $Kernel::OM = Kernel::System::ObjectManager->new(
    'Kernel::System::Log' => {
        LogPrefix => 'OTRS-znuny.RebuildEscalationIndexOnline',
    },
);

# get database object
my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');
my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
my $MainObject   = $Kernel::OM->Get('Kernel::System::Main');


# get all tickets
my @TicketIDs = $Kernel::OM->Get('Kernel::System::Ticket')->TicketSearch(

    # result (required)
    Result => 'ARRAY',

    States => $ConfigObject->Get('EscalationSuspendStates'),

    # result limit
    #Limit      => 100_000_000,
    Limit      => 1000,
    UserID     => 1,
    Permission => 'ro',
);

my $Count = 0;
for my $TicketID (@TicketIDs) {
    $Count++;
    $Kernel::OM->Get('Kernel::System::Ticket')->TicketEscalationIndexBuild(
        TicketID => $TicketID,
        UserID   => 1,
    );
 
    if ( ( $Count / 2000 ) == int( $Count / 2000 ) ) {
        my $Percent = int( $Count / ( $#TicketIDs / 100 ) );
        print "NOTICE: $Count of $#TicketIDs processed ($Percent% done).\n";
    }
}
print "NOTICE: Index creation done.\n";

exit(0);
