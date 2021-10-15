package Controllers::EnvelopeController;
use Dancer2 appname => 'Expenses';
use Models::Utilities;

my $db = Models::Database->new();

prefix '/envelope';

#------------------------------------------
#   Get method for transaction page
#------------------------------------------
get '/:envelope' => sub
{
    my $name = param('envelope');
    my $user = session('user') // Models::User->new();

    my $envelope = $db->GetEnvelope( $user->UID, $name );

    my $due   = getDateSelected( $envelope->duedate );
    my $banks = $db->GetBanksSelected( $user->UID, $envelope->bankid );
    my $owns  = $db->UserOwns( $user->UID, $name );

    template 'editenvelope' => {
        'title'     => 'Expenses: Add Transaction',
        'logged_in' => $user->logged_in // 0,
        'name'      => $envelope->name,
        'banks'     => $banks,
        'balance'   => $envelope->balance,
        'goal'      => $envelope->goalamount,
        'autofill'  => $envelope->autofillamount,
        'owns'      => $owns,
        'date'      => $due,
        'msg'       => get_flash()
    };
};

#------------------------------------------
#   Post method for transaction page
#------------------------------------------
post '/:envelope' => sub
{
    my $name = param('envelope');
    my $user = session('user') // Models::User->new();

    my $type        = body_parameters->get('ExpenseType');
    my $transfer_to = body_parameters->get('transfer_to');
    my $amount      = body_parameters->get('amount');
    my $for         = body_parameters->get('for');
    my $to_name     = $db->GetEnvelopeName($transfer_to);

    $db->AddExpense( $user->UID, $name, $amount, $for, $type, $transfer_to );

    if ( $type eq "Transfer" )
    {
        $for = qq~Transfer from $name to $to_name.~;
        $db->AddIncome( $user->UID, $transfer_to, $amount, $for, $type, $name );
    }

    return redirect uri_for('/');
};

prefix '/';
1;