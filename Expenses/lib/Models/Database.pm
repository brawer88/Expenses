package Models::Database;
use strict;
use warnings;

use Models::Utilities;
use Models::User;
use Dancer2 appname => 'Expenses';
use Dancer2::Plugin::Passphrase;
use Dancer2::Plugin::DBIC;
use Expense::Schema;
use Time::Piece::MySQL;

#------------------------------------------
#  Constructor
#------------------------------------------
sub new
{
    my ($class) = @_;
    my $self = {};

    bless $self, $class;
    return $self;
}


#  Login
#  Abstract: Logs a user in, or returns a null User object
#  params: ( $username, $password )
#  returns: $user - a User object
sub Login
{
    my ( $self, $username, $password ) = @_;

    my $user = Models::User->new();

    my $row = resultset('User')->search(
        {
            username => $username
        }
    )->single;

    return $user if !$row;

    my $firstname     = $row->get_column('firstname');
    my $lastname      = $row->get_column('lastname');
    my $UID           = $row->get_column('userid');
    my $user_password = $row->get_column('password');

    if ( passphrase($password)->matches($user_password) )
    {
        $user->logged_in(TRUE);
        $user->UID($UID);
        $user->username($username);
        $user->firstname($firstname);
        $user->lastname($lastname);
    }
    else
    {
        $user->logged_in(FALSE);
    }
    return $user;
}

#  GetEnvelopes
#  Abstract: Gets envelopes
#  params: ( $UID )
#  returns: $html - the html rep of all envelopes belonging to the user
sub GetEnvelopes
{
    my ($self, $UID) = @_;
    my $html;

    my $rs = resultset('Envelope')->search(
        {
            userid => $UID
        }
    );

    while ( my $row = $rs->next )
    {
        my $balance = $row->get_column("balance");
        print "\n\n$balance\n\n";
        my $name = $row->get_column("name");
        my $goal = $row->get_column("goalamount");
        my $diff = 0;
        
        $diff = $goal - $balance if $goal > 0;

        $html .= qq~
                <div class="card">
                    <div class="card-header">
                        $name
                    </div>
                    <div class="card-body">
                        <table id="envelope" class="table table-bordered"><thead><tr><th>Balance</th><th>Goal</th><th>Difference</th></tr></thead>
                        <tbody><tr><td>$balance</td><td>$goal</td><td>$diff</td></tr></tbody></table>
                        <a href="/envelope/$name" class="btn btn-primary">Manage</a>
                        <a href="/transaction/$name" class="btn btn-primary">Add Transaction</a>
                    </div>
                </div>        
        ~;
    }

    return $html;
}

#------------------------------------------
#   Destructor
#------------------------------------------
sub DESTROY
{
    # DEFINE Destructors
    my ($self) = @_;
    print "Database Destroyed :P";
}

1;
