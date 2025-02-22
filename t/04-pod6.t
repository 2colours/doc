#!/usr/bin/env raku

use lib $*PROGRAM.parent(2).child('lib');
use Test;
BEGIN plan :skip-all<Test applicable to git checkout only> unless '.git'.IO.e;

use Test-Files;

my @files = Test-Files.files;

my @pod-only-files = @files.grep({$_.ends-with: '.pod'}) ;

plan 1;
is @pod-only-files.elems, 0, "no .pod files, only .pod6" ;
