#!/usr/bin/env perl
# Strip JSONC extensions from stdin and output valid JSON to stdout.
# Handles:
#   - Single-line // comments (not inside strings)
#   - Trailing commas before } or ]
use strict;
use warnings;

my $content = do { local $/; <STDIN> };
$content =~ s!("(?:[^"\\]|\\.)*")|//[^\n]*!defined($1) ? $1 : ""!ge;
$content =~ s!,(\s*[}\]])!$1!g;
print $content;
