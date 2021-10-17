package Controllers::AjaxController;
use Dancer2 appname => 'Expenses';
use Models::Utilities;

my $db = Models::Database->new();

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

    $banks = $db->GetBanks( $user->UID );

    header 'Content-Type' => 'application/json';
    return to_json { text => $banks };
};


1;