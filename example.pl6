use v6;

if '/etc/pacman.d'.IO.e { pacman }
if '/etc/apt'.IO.e { apt }
if '/etc/yum'.IO.e { yum }

sub apt {
  my @out-update = (run 'apt-get', 'update', :out).out.lines;
  my @out-upgrade = (run 'apt-get', '--just-print', 'upgrade', :out).out.lines;

  for @out-upgrade -> $i { 
    if $i ~~ m:g:s/Inst\s(.*?)\s\[(.*?)\]\s\((.*?)\)/ {
      say "Packet: " ~ $/[0][0].Str ~ " Current: " ~ $/[0][1].Str ~ " New: " ~ $/[0][2].Str;    
    }
  }
}

sub pacman {
  my @out-update = (run 'pacman', '-Sy', :out).out.lines;
  my @out-upgrade = (run 'pacman', '-Qu', :out).out.lines;

  for @out-upgrade -> $i {
    if $i ~~ m:g:s/^(.*?)\s(.*?)\s\-\>\s(.*?)$/ {
      say "Packet: " ~ $/[0][0].Str ~ " Current: " ~ $/[0][1].Str ~ " New: " ~ $/[0][2].Str;    
    }
  }
}

sub yum {
  my @out-update = (run 'yum', '-q', 'check-update', :out).out.lines;

  for @out-update -> $i {
    next if !$i;
    next if !$i.words[0] || !$i.words[1];
    my $packet = $i.words[0];
    my $newver = $i.words[1];

    my $out-current = (run 'yum', 'list', $packet, :out).out.slurp-rest;

    if $out-current ~~ m:s/$packet\s+(.*?)\s+/ {
      say "Packet: " ~ $packet ~ " Current: " ~ $/[0].Str ~ " New: " ~ $newver;
    }
  }
}
