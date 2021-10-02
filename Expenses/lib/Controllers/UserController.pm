package Controllers::UserController;
use Dancer2 appname => 'Expenses';
use Models::Database;
use Models::Utilities;
use Dancer2::Plugin::Passphrase;

my $db = Models::Database->new();

prefix '/user';

#------------------------------------------
#   Get method for logging out
#------------------------------------------
get '/logout' => sub
{
    context->destroy_session;

    return redirect uri_for('/');
};

#------------------------------------------
#   Get method for logging in
#------------------------------------------
get '/login' => sub
{
    my $user       = session('user') // Models::User->new();

    template 'login' => {
        'title'      => 'Expenses: Login',
        'pageTitle'  => 'Login',
        'logged_in'  => $user->logged_in // 0,
    };
};

#------------------------------------------
#   Post method for logging in
#------------------------------------------
post '/login' => sub
{
    my $username   = body_parameters->get('user');
    my $password   = body_parameters->get('password');

    my $user = $db->Login( $username, $password );

    if ( $user->logged_in == TRUE )
    {
        session user => $user;
        set_flash("Logged in successfully.");
        return redirect uri_for('/user');
    }

    template 'login' => {
        'title'      => 'Expenses: Login',
        'pageTitle'  => 'Login',
        'user'       => $username,
        'logged_in'  => $user->logged_in // 0,
        'password'   => $password,
        'error'      => "Username and password do not match. Please try again.",
    };
};

#------------------------------------------
#   Get method for user
#------------------------------------------
get qr{\/?} => sub
{
    my $user       = session('user') // Models::User->new();

    template 'user' => {
        'title'      => 'Expenses: User',
        'logged_in'  => $user->logged_in // 0,
        'pageTitle'  => 'Account Management',
        'usertype'   => $user->usertype // 'Viewer',
        'name'       => $user->firstname . " " . $user->lastname,
        'msg'        => get_flash(),
    };
};

prefix '/';
1;
