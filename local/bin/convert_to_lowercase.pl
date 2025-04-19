#!/usr/bin/perl

use strict;
use warnings;
use File::Find;

my $dir = "/Volumes/Secondary/Files/vBulletin/vBulletin-6/Manual"; # Replace with the path to the directory you want to modify

find(\&rename_files, $dir);

sub rename_files {
    if (-f $_ || -d $_) { # Only modify files and directories, not special files like "." and ".."
        my $old_name = $_;
        my $new_name = lc($old_name); # Convert to lowercase
        $new_name =~ s/ /_/g; # Replace spaces with underscores
        if ($new_name ne $old_name) { # Only rename if the new name is different from the old name
            rename($old_name, $new_name) or die "Error renaming $old_name to $new_name: $!\n";
            print "Renamed $old_name to $new_name\n";
        }
    }
}