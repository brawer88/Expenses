package Controllers::TransactionController;
use Dancer2 appname => 'Expenses';
use Models::Utilities;

my $db = Models::Database->new();

prefix '/transaction';

#------------------------------------------
#   Get method for transaction page
#------------------------------------------
get '/:envelope' => sub
{
    my $name = param('envelope');
    my $user = session('user') // Models::User->new();

    my $envelopes = $db->GetEnvelopesSelect( $user->UID );

    template 'transaction' => {
        'title'               => 'Expenses: Add Transaction',
        'logged_in'           => $user->logged_in // 0,
        'name'                => $name,
        'available_envelopes' => $envelopes,
        'msg'                 => get_flash()
    };
};

#------------------------------------------
#   Post method for transaction page
#------------------------------------------
post '/:envelope' => sub
{
    my $name = param('envelope');
    my $user = session('user') // Models::User->new();

    my $type = body_parameters->get('ExpenseType');
    my $transfer_to = body_parameters->get('transfer_to');
    my $amount = body_parameters->get('amount');
    my $for = body_parameters->get('for');

    $db->AddExpense($name, $amount, $for);

    return redirect uri_for('/');
};

prefix '/';
1;