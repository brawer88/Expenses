package Controllers::MainController;
use Dancer2 appname => 'Expenses';
use Models::Utilities;

my $db = Models::Database->new();

#------------------------------------------
#   Get method for the index page
#------------------------------------------
get '/' => sub
{
    my $user = session('user') // Models::User->new();
    my $banks;
    my $envelopes;

    $envelopes = $db->GetEnvelopes( $user->UID );
    $db->ResetUnallocated( $user->UID );

    $banks = $db->GetBanks( $user->UID );

    template 'index' => {
        'title'     => 'Expenses: Home',
        'logged_in' => $user->logged_in // 0,
        'banks'     => $banks,
        'envelopes' => $envelopes,
        'msg'       => get_flash()
    };
};


#------------------------------------------
#   Get method for Ava's easter egg
#------------------------------------------
get '/ava' => sub
{
    my $user = session('user') // Models::User->new();

    template 'ava' => {
        'title'     => 'Ava\'s Page',
        'logged_in' => $user->logged_in // 0,
    };
};

1;
