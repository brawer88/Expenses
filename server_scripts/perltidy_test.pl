use Test::PerlTidy qw( run_tests );

my $start_dir = '/var/www/html/Wiki/lib';

run_tests(
          path     => $start_dir,
          exclude  => [ qr{\.t$}, '/var/www/html/Wiki/lib/Wiki/'],
          mute     => 1
);