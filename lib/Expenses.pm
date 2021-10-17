package Expenses;
use Dancer2;

use Models::Database;
use Models::User;
use Time::HiRes qw( time );
use Module::Runtime 'require_module';

my $db = Models::Database->new();

use Controllers::UserController;
use Controllers::MainController;
use Controllers::TransactionController;
use Controllers::EnvelopeController;
use Controllers::AjaxController;

our $VERSION = '0.1';

my @times;
my $start_time;
my $finish_time;

# hook before => sub
# {
#     $start_time = time();
# };

# hook after => sub
# {
#     $finish_time = time();

#     my $delta = ( $finish_time - $start_time );

#     print "\n\nDelta this run is: $delta seconds\n\n";
#     push @times, $delta;

#     if ( scalar @times > 1 )
#     {
#         my $total;
#         my $count = scalar @times;
#         grep { $total += $_ } @times;

#         my $average = ( $total / $count );

#         print "\n\nAverage of $count is $average seconds\n\n";
#     }
# };

any qr{.*} => sub
{
    my $user       = session('user') // Models::User->new();
    template 'special_404',
      {
        'path'       => request->path,
        'logged_in'  => $user->logged_in
      };
};

1;