package Controllers::MainController;
use Dancer2 appname => 'Expenses';

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