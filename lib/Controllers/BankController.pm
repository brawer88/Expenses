package Controllers::BankController;
use Dancer2 appname => 'Expenses';
use Models::Database;
use Models::Utilities;
use Dancer2::Plugin::Passphrase;

my $db = Models::Database->new();

prefix '/bank';

#------------------------------------------
#   Get method for adding a bank
#------------------------------------------
get '/add' => sub
{
    my $user = session('user') // Models::User->new();

    template 'addbank' => {
        'title'     => 'Expenses: Add Bank',
        'pageTitle' => 'Add Bank',
        'logged_in' => $user->logged_in // 0,
    };
};

#------------------------------------------
#   Post method for adding a bank
#------------------------------------------
post '/add' => sub
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
            'title'     => 'Expenses: Add Bank',
            'pageTitle' => 'Add Bank',
            'msg'       => Models::Utilities::get_flash(),
            'logged_in' => $user->logged_in // 0,
        };
    }
};


#------------------------------------------
#   Get method for adding a bank
#------------------------------------------
get '/edit/:name' => sub
{
    my $user      = session('user') // Models::User->new();
    my $bank_name = param("name");

    my $bank = $db->GetBank( $user->UID, $bank_name );

    template 'editbank' => {
        'title'     => 'Expenses: Edit Bank',
        'pageTitle' => 'Edit Bank',
        'name'      => $bank->name,
        'balance'   => $bank->balance,
        'logged_in' => $user->logged_in // 0,
    };
};

#------------------------------------------
#   Post method for adding a bank
#------------------------------------------
post '/edit/:name' => sub
{
    my $user     = session('user') // Models::User->new();
    my $old_name = param("name");

    my $new_name = body_parameters->get('name');
    my $balance  = body_parameters->get('balance');

    my $result = $db->EditBank( $user->UID, $old_name, $new_name, $balance );

    if ($result)
    {
        set_flash("Editing Bank $old_name successfully.");
        return redirect uri_for('/');
    }
    else
    {
        set_flash("Editing bank failed.");
        my $bank = $db->GetBank( $user->UID, $old_name );

        template 'editbank' => {
            'title'     => 'Expenses: Edit Bank',
            'pageTitle' => 'Edit Bank',
            'name'      => $bank->name,
            'balance'   => $bank->balance,
            'logged_in' => $user->logged_in // 0,
        };
    }
};

#------------------------------------------
#   Post method for adding a bank
#------------------------------------------
post '/delete/:name' => sub
{
    my $user     = session('user') // Models::User->new();
    my $name = param("name");


    my $result = $db->DeleteBank( $user->UID, $name );
    my $bank = $db->GetBank( $user->UID, $name );

    if ($result)
    {
        set_flash("Deleting Bank $name successfully.");
        return redirect uri_for('/');
    }
    else
    {
        set_flash("Deleting bank failed.");
        template 'editbank' => {
            'title'     => 'Expenses: Edit Bank',
            'pageTitle' => 'Edit Bank',
            'name'      => $bank->name,
            'balance'   => $bank->balance,
            'logged_in' => $user->logged_in // 0,
        };
    }
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