#!/usr/bin/perl

use warnings;
use strict;

my $archive_tmp_path = '_tmp_archive';

mkdir $archive_tmp_path;

foreach my $arch_base ("$archive_tmp_path/all", "$archive_tmp_path/min") {
  mkdir $arch_base;
  mkdir "$arch_base/bin";
  mkdir "$arch_base/include";
  mkdir "$arch_base/lib";
}

my ($obj_out_path, $include_out_path, $artifact_zip_min_name,
    $artifact_zip_all_name) = @ENV{qw( OBJ_OUT_PATH INCLUDE_OUT_PATH
                                       ARTIFACT_ZIP_MIN_NAME
                                       ARTIFACT_ZIP_ALL_NAME )};

# create 'all' archive
my_system(qq{robocopy "$obj_out_path" "$archive_tmp_path\\all\\bin" *.dll *.exe /COPYALL /E});
my_system(qq{robocopy "$obj_out_path" "$archive_tmp_path\\all\\lib" *.lib /COPYALL /E});
my_system(qq{robocopy "$include_out_path" "$archive_tmp_path\\all\\include" * /COPYALL /E});
chdir "$archive_tmp_path/all";
my_system(qq{7z a "..\\..\\$artifact_zip_all_name" "*"});
chdir "..\\..";

#create 'min' archive
foreach my $path ('ssleay32.lib', 'libeay32.lib') {
  my_system(qq{copy "$obj_out_path\\$path" "$archive_tmp_path\\min\\lib"});
}
foreach my $path ('ssleay32.dll', 'libeay32.dll', 'openssl.exe') {
  my_system(qq{copy "$obj_out_path\\$path" "$archive_tmp_path\\min\\bin"});
}
my_system(qq{robocopy "$include_out_path" "$archive_tmp_path\\min\\include" * /COPYALL /E});
chdir "$archive_tmp_path/min";
my_system(qq{7z a "..\\..\\$artifact_zip_min_name" "*"});
chdir "..\\..";

sub my_system {
  print( join(' ',@_)."\n" );
  system(@_);
}
