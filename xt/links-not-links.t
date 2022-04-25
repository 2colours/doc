#!/usr/bin/env raku

=begin overview

Avoid I<bare> URLs that are not links; URLs should go inside C<L<>> clauses,
even if they have no text to link to.

Eliminates as false positives URLs that are output, or those that are
included in some IRC log file. URLs in code might still show up as false
positive.

Needs to install independently Pod::To::HTML, which is used only for this
specific test.

=end overview

use Test;
use lib $*PROGRAM.parent(2).child('lib');
use Test-Files;
use Pod::To::HTML;
use MONKEY-SEE-NO-EVAL;

# Every .pod6 file in the Type and Language directory.
my @files = Test-Files.pods.grep(* ~~ /Type | Language/);

plan +@files;

for @files -> $file {
    my @lines;
    my Int $line-no = 1;
    # say $file.IO.lines.grep( * ~~ / https?\: /)
    #        .grep( * !~~ /review\:\s+ | "wget" | ^\# | \#\s+OUTPUT /  ).raku;
    my @links = $file.IO.lines.grep( * ~~ / https?\: /)
      .grep( * !~~ /review\:\s+/) # eliminate review lines from IRC logs
      .grep( * !~~ /wget/)
      .grep( * !~~ /disclaimer\.txt/)
      .grep( * !~~ /^\#/)
      .grep( * !~~ /\#\s+OUTPUT/);       # eliminates output lines
    my @links-not-links;
    for @links -> $link {
        my $pod=qq:to/END/;
=pod
$link
=pod
END

        my @number-of-links = ( $link ~~ m:g{\| https?\: } );
        my $html = pod2html(EVAL($pod~ "\n\$=pod"));
        my @number-of-hrefs = ( $html ~~ m:g{a\s+href\= } );
        push @links-not-links, $link if +@number-of-links > +@number-of-hrefs;
    }
    if @links-not-links {
        flunk "$file uses non-linked links « " ~ @links-not-links.join("\n\n") ~ " »";
    } else {
        pass "$file return types are ok";
    }
}
