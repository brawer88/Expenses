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

    template 'index' => {
        'title'     => 'Expenses: Home',
        'logged_in' => $user->logged_in // 0,
        'msg'       => get_flash()
    };
};

#------------------------------------------
#   Get method for returning an ajax of envelopes html
#------------------------------------------
get '/envelopes' => sub
{
    my $user = session('user') // Models::User->new();
    my $envelopes;

    $envelopes = $db->GetEnvelopes($user->UID);

    header 'Content-Type' => 'application/json';
    return to_json { text => $envelopes };
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
