#!/usr/bin/perl

my $arch = `arch`;
chomp $arch;

my $docker_arch = $arch eq 'x86_64' ? 'amd64'
                : $arch eq 'arm64'  ? 'arm64'
                : die "Unsupported arch $arch";

my $operation = $ARGV[0] // 'build';

my $tag = 'marcbradshaw/bimivalidator:latest-'.$docker_arch;

system(
  'docker',
  'build',
  '--compress',
  '-t', $tag,
  '--file', 'Dockerfile',
  '.',
) if $operation eq 'build';

system(
  'docker',
  'push', $tag,
) if $operation eq 'push';