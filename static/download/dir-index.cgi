#!/usr/bin/perl

# dir-index.cgi - print a "directory index" for LEDE download pages.
#
# See the README.md file for a description of the files this script generates

use strict;
use warnings;

use Fcntl ':mode';
use JSON;

# htmlenc - html-encode the argument
sub htmlenc {
  my $s = shift;

  if (defined($s) && length($s)) {
    $s =~ s!([<>"])!sprintf '&#%u;', ord $1!eg; # "
  }

  return $s;
}

# getchecksums - read the checksum file and return a hash for all the named files and their checksums
sub getchecksums {
  my $filename = shift;
  my %sums;
  if (open(my $fh, '<:encoding(UTF-8)', $filename)) {
    while (my $row = <$fh>) {
      chomp $row;
      if ($row =~ m!^([a-f0-9]+) [ *](.+)$!) {
        $sums{$2} = $1;
      }
      elsif ($row =~ m!SHA256\((.+)\)= ([a-f0-9]+)$!) {
        $sums{$1} = $2;
      }
    }
  }
  return %sums;
}

# printentry - print a <tr> row for a target file (not in an ordinary directory)
#   $entry - full path to the file
#   $prefix - empty string if it's a meta-file;
#       otherwise, it's the prefix to remove from the displayed file name
#   $checksums - reference to the checksums for this directory
sub printentry {
  my $entry = shift;
  my $prefix = shift;
  my $checksums = shift;
  my ($basename) = $entry =~ m!([^/]+)$!; # / strip off path info
  my $size = "-";
  my $checksum = $checksums->{$basename};

  if (!$checksum) {                                              # if not present in hash, use "-"
    $checksum = "-";
  }

  my @s = stat $entry;
  my $link = (-l $entry)                                          # if it's a symlink
    ? sprintf('<var> -&#62; %s</var>', htmlenc(readlink($entry))) # add '->' to the link
    : '';                                                         # (is this ever used?)
  my $date = scalar localtime $s[9];

  if (S_ISDIR($s[2])) {
    $size = "-";
    $checksum = "-";
    $basename = $basename."/";
  }
  else {
    $size = sprintf('%.1f KB', $s[7] / 1024);
  }
  my $imagename = $basename;
  if ($prefix && (index($basename, $prefix) == 0)) {              # if there's a prefix, and it matches at front
    $imagename = substr($basename, length($prefix));              # trim it off
  }

# All preparatory work complete: here are the variables
#   $entry:     "./SampleData/config.seed"
#   $basename:  "config.seed"
#   $imagename: $basename, or shortened version of image name
#   $link:      "" or "-> actual-file-following-link"
#   $checksum:  the sum, or "-"
#   $size:      the size ("1234.5 KB") or "-"
#   $date:      in the form "Tue Feb 21 04:03:38 2017"

  # Output the html for the row
  print '  <tr>';
  printf '<td class="n"><a href="%s">%s</a>%s</td>',
    htmlenc($basename),
    htmlenc($imagename),
    $link;
  printf '<td class="sh">%s</td>', $checksum;
  printf '<td class="s">%s</td>', $size;
  printf '<td class="d">%s</td>', $date;
  print  "</tr>\n";
}

# printh1() print the "Index of (root) / releases / ##.##.# / targets / ..."
#
sub printh1 {
  my $virt = shift;
  my @parts = split /\//, $virt;
  my $s = '';

  if (@parts == 0) {
    @parts = ('');
  }

  for (my $i = 0; $i < @parts; $i++) {
    $s .= sprintf '<a href="%s/">%s</a> / ',
  htmlenc(join('/', @parts[0..$i])),
  $i ? htmlenc($parts[$i]) : '<em>(root)</em>';
  }

  printf "<h1>Index of %s</h1>\n", $s;
  print "<hr>\n"; 
}

sub print404 {
  my $virt = shift;
  print "<div class='container'>\n";
  printf "<h1>Not found: %s</h1>\n", htmlenc($virt);
  print "<hr>";
  print "<p>The requested resource could not be found on the server.</p>";
  print "<p>Try returning to the <a href=\"/\">root directory</a> to browse available directories.</p>";
  print "</div>\n";
  print "</body></html>";
}

# printtop() - Print the stuff at the "top of the page"
#  - HTTP headers (only if being run as a CGI)
#  - HTML content including
#     - <!DOCTYPE html>
#     - opening <html> tag
#     - <head> including title and style sheets 
#     - opening <body> tag
#
sub printtop {
  my $virt = shift;
  my $htmlstatus = shift;

  # HTTP Headers, followed by \n\n 
  
  use constant IS_CGI => exists $ENV{'GATEWAY_INTERFACE'};
  # Note - to avoid the ugly HTTP headers in the browser during testing
  # wrap the next few lines in `if (IS_CGI) { ... }`
  if ($htmlstatus ne "") {
    printf "%s\n", $htmlstatus;
  }
  print "Content-type:text/html\n\n";

  # HTML heading
  print "<!DOCTYPE html>\n";
  print "<html lang='en'>\n";
  print "<head>\n";
  print "<meta charset='utf-8'/>\n";
  print "<link rel='stylesheet' href='/openwrt.css' />\n";
  printf "<title>Index of %s</title>\n", $virt;
  print "</head>\n";

  # HTML body
  print "<body>\n";
  print "<!-- This directory index page is auto-generated by dir-index.cgi -->\n";
  print "<!-- Do not edit this file -->\n";
  
  printheader();
}

# printjson
#
sub printjson {
  my $phys = shift;
  my $query_string = shift;

  my ($type, $mindepth, $maxdepth) = ('f', 0, 3);

  if ($query_string =~ m!\btargets!) {
    ($type, $mindepth, $maxdepth) = ('d', 2, 2);
  }

  if (open F, '-|', 'find', $phys, '-mindepth', $mindepth, '-maxdepth', $maxdepth, '-type', $type) {
    my @list;

    while (defined(my $line = readline F)) {
      chomp $line;
      push @list, substr $line, length $phys;
    }
    close F;

    # output the HTTP Content-Type header and a blank line
    print "Content-Type: application/json\n\n";

    # output the JSON of the file
    print encode_json (\@list);
  }

}

# printheader - print the banner at the top of the page
# 
sub printheader{
    print <<EOT;
      <header>
      <div>
        <img src="/images/logo.png" alt="Download OpenWrt Firmware">
      </div>
    </header>
EOT

}

# printfooter - a place to put everything else on the page
# Should remain within the 'container' div
#
sub printfooter {
print <<EOT;
  <footer>
    CDN powered by <a href='https://www.fastly.com/'>fastly.com</a>
  </footer>\n
EOT

}

# printtargets - print 'targets' directories
#   This special cases directories of LEDE image files and their associated meta-files
sub printtargets {
  my $entries = shift;
  my $phys = shift;
  my $virt = shift;
  my @metafiles = (                         # names of files to be displayed as "meta files" at the top of the page
    qr/packages/,
    qr/config.seed/,
    qr/manifest/,
    qr/lede-imagebuilder/,
    qr/lede-sdk/,
    qr/[Oo]pen[Ww]rt-[Ii]mage[Bb]uilder/,
    qr/[Oo]pen[Ww]rt-[Ss][Dd][Kk]/,
    qr/[Oo]pen[Ww]rt-[Tt]oolchain/,
    qr/md5sums/,
    qr/sha256sums/,
    );

  my $metafiles_re = join '|', @metafiles;  # build the master regex for meta files
     $metafiles_re = qr/$metafiles_re/o;

  # Parse checksum files to get a hash of the file names/sums
  my $checktype = "sha256sum";
  my %checksums = getchecksums($phys.$checktype."s");

  if (!keys %checksums) {
    $checktype = "md5sum";
    %checksums = getchecksums($phys.$checktype."s");
  }

  # To trim image file names intelligently, factor in the following:
  #   $virt e.g.,          "releases/17.01.0/targets/ar71xx/generic/"
  #   $phys e.g.,          "./SampleData/" and
  #   typical entry, e.g., "./SampleData/lede-17.01.0-r3205-59508e3-ar71xx-generic-archer-c7-v2-squashfs-sysupgrade.bin"

  # $trimmedprefix is derived from the last two items of $virt, e.g., "ar71xx-generic-"
  # $prefix comes from the first of @images array that begins with "lede" after ignoring the $phys string

  my ($target, $subtarget, $tuple, %prefixes, $prefix);

  ($target, $subtarget) = $virt =~ m!/([^0-9][^/]+)/([^/]+)/?$!;
  ($target, $subtarget) = ($virt =~ m!/([^/]+)/?$!, '') unless $target;

  $tuple = $target . ($subtarget ? '/' . $subtarget : '');


  # Build a mapping table (prefix => number of occurences)
  # For each image basename, try to find a prefix that either ends in -$target-$subtarget- or in -$target-
  # and if found, use it as key in the %prefixes dictionary and count its value up by one.
  foreach my $image (@$entries) {
    my ($base) = $image =~ m!/([^/]+)$!;
    my $i1 = $subtarget ? index($base, "-$target-$subtarget-") : 0;
    my $i2 = index($base, "-$target-");

    if ($i1 > 0) {
      my $s = substr($base, 0, $i1 + length("-$target-$subtarget-"));
      $prefixes{$s}++;
    }
    elsif ($i2 > 0) {
      my $s = substr($base, 0, $i2 + length("-$target-"));
      $prefixes{$s}++;
    }
  }
  
  # Sort the found prefix substrings descending by number of occurences and put the first (most used)
  # one into $prefix.
  ($prefix) = sort { $prefixes{$b} <=> $prefixes{$a} } keys %prefixes;


  my @metas;                                    # contains meta-file names
  my @images;                                   # contains image files that could be flashed

  foreach my $entry (@$entries) {               # push files into the proper array
    if ($entry =~ m!/$prefix!o && $entry !~ $metafiles_re) {
      push @images, $entry;
    }
    else {
      push @metas, $entry;
    }
  }

  print <<EOT;
  <h2>Image Files</h2>
  <p>These are the image files for the <b>$tuple</b> target.
  Check that the $checktype of the file you downloaded matches the $checktype below.<br />
  <i>Shortened image file names below have the same prefix: <code>$prefix...</code></i>
  </p>
EOT
  # /

  print "<table>\n";
  print '  <tr><th class="n">Image for your Device</th><th>'.$checktype.'</th><th class="s">File Size</th><th class="d">Date</th></tr>'."\n";
  foreach my $entry (@images) {
    printentry($entry, $prefix, \%checksums)
  }
  print "</table>\n";

  print <<EOT;
  <h2>Supplementary Files</h2>
  <p>These are supplementary resources for the <b>$tuple</b> target.
  They include build tools, the imagebuilder, $checktype, GPG signature file, and other useful files. </p>
EOT
  # /

  print "<table>\n";
  print '  <tr><th class="n">Filename</th><th>'.$checktype.'</th><th class="s">File Size</th><th class="d">Date</th></tr>'."\n";
  foreach my $entry (@metas) {
    printentry($entry, "", \%checksums)
  }
  print "</table>\n";

  # print '<footer>Open Source Downloads supported by <a href="https://www.keycdn.com/">KeyCDN</a>.</footer>'."\n";
  # print "</body></html>\n";
}

# printdirectory - print any directory in a pleasing format
#   This substantially copies the format used by downloads.lede-project.org in early 2017
sub printdirectory {
  my $entries = shift;
  my $phys = shift;
  my $virt = shift;

  print "<table>\n";
  print '  <tr><th class="n">File Name</th><th class="s">File Size</th><th class="d">Date</th></tr>'."\n";

  foreach my $entry (@$entries) {
    my ($basename) = $entry =~ m!([^/]+)$!; # /

    print "  <tr>";

    my @s = stat $entry;
    my $link = (-l $entry)
      ? sprintf('<var> -&#62; %s</var>', htmlenc(readlink($entry)))
      : '';

    if (S_ISDIR($s[2])) {
      printf '<td class="n"><a href="%s/">%s</a>/%s</td>',
        htmlenc($basename),
        htmlenc($basename),
        $link;
      printf '<td class="s">-</td>';
      printf '<td class="d">%s</td>', scalar localtime $s[9];
    }
    else {
      printf '<td class="n"><a href="%s">%s</a>%s</td>',
        htmlenc($basename),
        htmlenc($basename),
        $link;
      printf '<td class="s">%.1f KB</td>', $s[7] / 1024;
      printf '<td class="d">%s</td>', scalar localtime $s[9];
    }

    print "</tr>\n";
  }

  print "</table>\n";

  # print '<footer>Open Source Downloads supported by <a href="https://www.keycdn.com/">KeyCDN</a>.</footer>'."\n";
  # print "</body></html>\n";
}

# ====== Main Routine ======
my $phys = $ENV{'DOCUMENT_ROOT'};
my $virt = '/'.$ENV{'PATH_INFO'};
my $query_string = exists $ENV{'QUERY_STRING'} ? $ENV{'QUERY_STRING'} : "";

# printf "QUERY_STRING: %s\n", $query_string;

my @hidden = (                            # hide these files - never consider them
  qr!^/releases/\d\d\.\d\d-SNAPSHOT/?$!,
  qr!^/releases/faillogs/?$!,
  qr!^/packages-\d\d\.\d\d/?$!,
  qr!/\.[^/]+$!,                          # ignore hidden files and directories
  qr!index\.html!                         # test script generates index.html in the SampleData directory
);

my $hidden_re = join '|', @hidden;        # build the master regex for hidden files
   $hidden_re = qr/$hidden_re/o;

my @entries;                              # holds all files in the directory, except hidden files

if (opendir(D, $phys)) {                  # read all the files from the directory
  while (defined(my $entry = readdir D)) {
    my $vpath = $virt . $entry;
    next if $entry eq '.' || $entry eq '..' || $vpath =~ $hidden_re;  # ignore filenames "." or in $hidden_re
    push @entries, $phys . $entry;
  }
  closedir D;
}
else {
  printtop($virt, "Status: 404 Not found");
  print404($virt);
  exit 0;
}

@entries = sort {
  my $d1 = !-d $a;
  my $d2 = !-d $b;
  return (($d1 <=> $d2) || ($a cmp $b));
} @entries;

# @entries contains list of files from the directory that should be processed

# If $virt is the /targets/ directory and query string is "json", print as JSON
if ($virt =~ m!/targets/$! && $query_string =~ m!^json\b!) {
  printjson($phys, $query_string);
}
else {
  printtop($virt, "");
  print "<div class='container'>\n";

  printh1($virt);

  if ($virt =~ m!/targets/[^/]+/[^/]+/?$! || # special handling for 'targets' - LEDE image file directories
       $virt =~ m!/(backfire|kamikaze)/[^/]+/[^/]+/?$! ||
       $virt =~ m!/(attitude_adjustment|barrier_breaker|chaos_calmer)/[^/]+/[^/]+/[^/]+/?$!) {
    printtargets(\@entries, $phys, $virt)
  }
  else {                                        # otherwise use standard directory display format
    printdirectory(\@entries, $phys, $virt)
  }

  printfooter();                                  # print the footer

  print "</div>\n";                             # end of the container div
  print "</body></html>\n";                     # and clean up the page nicely
}

