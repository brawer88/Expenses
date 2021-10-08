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
    my $user     = session('user') // Models::User->new();
    my $username = $user->username;

    set_flash("$username logged out.");
    context->destroy_session;

    return redirect uri_for('/');
};

#------------------------------------------
#   Get method for logging in
#------------------------------------------
get '/login' => sub
{
    my $user = session('user') // Models::User->new();

    template 'login' => {
        'title'     => 'Expenses: Login',
        'pageTitle' => 'Login',
        'logged_in' => $user->logged_in // 0,
        'msg'       => get_flash()
    };
};

#------------------------------------------
#   Post method for logging in
#------------------------------------------
post '/login' => sub
{
    my $username = body_parameters->get('user');
    my $password = body_parameters->get('password');

    my $user = $db->Login( $username, $password );

    if ( $user->logged_in == TRUE )
    {
        session user => $user;
        set_flash("Logged in successfully.");
        return redirect uri_for('/');
    }

    template 'login' => {
        'title'     => 'Expenses: Login',
        'pageTitle' => 'Login',
        'user'      => $username,
        'logged_in' => $user->logged_in // 0,
        'password'  => $password,
        'error'     => "Username and password do not match. Please try again.",
    };
};

#------------------------------------------
#   Get method for adding a bank
#------------------------------------------
get '/addbank' => sub
{
    my $user = session('user') // Models::User->new();

    template 'addbank' => {
        'title'     => 'Expenses: Login',
        'pageTitle' => 'Login',
        'logged_in' => $user->logged_in // 0,
    };
};

#------------------------------------------
#   Post method for adding a bank
#------------------------------------------
post '/addbank' => sub
{
    my $user = session('user') // Models::User->new();

    my $name    = body_parameters->get('name');
    my $balance = body_parameters->get('balance');

    my $result = $db->AddBank( $user->UID, $name, $balance );

    if ($result)
    {
        set_flash("Added Bank $name successfully.");
        return redirect uri_for('/');
    }
    else
    {
        set_flash("Adding bank failed.");
        template 'addbank' => {
            'title'     => 'Expenses: Login',
            'pageTitle' => 'Login',
            'msg'       => Models::Utilities::get_flash(),
            'logged_in' => $user->logged_in // 0,
        };
    }
};

#------------------------------------------
#   Get method for adding an envelope
#------------------------------------------
get '/addenvelope' => sub
{
    my $user = session('user') // Models::User->new();

    my $banks = $db->GetBanksSelect( $user->UID );

    my $has_bank = TRUE;
    $has_bank = FALSE if ( !$banks );

    template 'addenvelope' => {
        'title'     => 'Expenses: Login',
        'pageTitle' => 'Login',
        'banks'     => $banks,
        'has_bank'  => $has_bank,
        'logged_in' => $user->logged_in // 0,
    };
};

#------------------------------------------
#   Post method for adding an envelope
#------------------------------------------
post '/addenvelope' => sub
{
    my $user = session('user') // Models::User->new();

    my $name     = body_parameters->get('name');
    my $balance  = body_parameters->get('balance');
    my $goal     = body_parameters->get('goal');
    my $bank_id  = body_parameters->get('bank');
    my $autofill = body_parameters->get('autofill');

    

    my $result =
      $db->AddEnvelope( $user->UID, $name, $balance, $goal, $bank_id, $autofill );

    if ($result)
    {
        set_flash("Added envelope $name successfully.");
        return redirect uri_for('/');
    }
    else
    {
        set_flash("Adding envelope failed.");
        template 'addenvelope' => {
            'title'     => 'Expenses: Login',
            'pageTitle' => 'Login',
            'msg'       => Models::Utilities::get_flash(),
            'logged_in' => $user->logged_in // 0,
        };
    }
};

#------------------------------------------
#   Get method for adding a bank
#------------------------------------------
get '/addpaycheck' => sub
{
    my $user = session('user') // Models::User->new();

    template 'addpaycheck' => {
        'title'     => 'Expenses: Login',
        'pageTitle' => 'Login',
        'logged_in' => $user->logged_in // 0,
    };
};

#------------------------------------------
#   Post method for adding a paycheck
#------------------------------------------
post '/addpaycheck' => sub
{
    my $user = session('user') // Models::User->new();

    template 'addpaycheck' => {
        'title'     => 'Expenses: Login',
        'pageTitle' => 'Login',
        'logged_in' => $user->logged_in // 0,
    };
};

#------------------------------------------
#   Get method for user
#------------------------------------------
get qr{\/?} => sub
{
    my $user = session('user') // Models::User->new();

    template 'user' => {
        'title'     => 'Expenses: User',
        'logged_in' => $user->logged_in // 0,
        'pageTitle' => 'Account Management',
        'usertype'  => $user->usertype // 'Viewer',
        'name'      => $user->firstname . " " . $user->lastname,
        'msg'       => get_flash(),
    };
};

prefix '/';
1;
