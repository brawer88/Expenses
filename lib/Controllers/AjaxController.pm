package Controllers::AjaxController;
use Dancer2 appname => 'Expenses';
use Models::Utilities;

my $db = Models::Database->new();

prefix '/ajax';

#------------------------------------------
#   Get method for returning an ajax of envelopes html
#------------------------------------------
get '/envelopes' => sub
{
    my $user = session('user') // Models::User->new();
    my $envelopes;

    $envelopes = $db->GetEnvelopes( $user->UID );

    header 'Content-Type' => 'application/json';
    return to_json { text => $envelopes };
};

#------------------------------------------
#   Get method for returning an ajax of banks html
#------------------------------------------
get '/banks' => sub
{
    my $user = session('user') // Models::User->new();
    my $banks;

    $banks = $db->GetBankManagement( $user->UID );

    header 'Content-Type' => 'application/json';
    return to_json { text => $banks };
};

#------------------------------------------
#   Get method for returning an ajax of banks html
#------------------------------------------
get '/reclaim/:name' => sub
{
    my $user = session('user') // Models::User->new();
    my $bank = param('name');

    my $collected = $db->ReclaimChange( $user->UID, $bank );

    header 'Content-Type' => 'application/json';
    return to_json { collected => $collected };
};

prefix '/';

1;