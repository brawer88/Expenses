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
    my $edit_name = param('envelope');
    my $user = session('user') // Models::User->new();
        
    my $name     = body_parameters->get('name');
    my $balance  = body_parameters->get('balance');
    my $goal     = body_parameters->get('goal');
    my $bank_id  = body_parameters->get('banks');
    my $autofill = body_parameters->get('autofill');
    my $due      = body_parameters->get('due');

    my $due_html   = getDateSelected( $due );
    my $banks = $db->GetBanksSelected( $user->UID, $bank_id );
    my $owns  = $db->UserOwns( $user->UID, $edit_name );

    my $result;

    if ($owns)
    {
        $result = $db->UpdateEnvelope( $user->UID, $name, $balance, $goal, $bank_id, $autofill,
        $due );
    }

    if ($result)
    {
        return redirect uri_for("/");
    }

    template 'editenvelope' => {
        'title'     => 'Expenses: Add Transaction',
        'logged_in' => $user->logged_in // 0,
        'name'      => $name,
        'banks'     => $banks,
        'balance'   => $balance,
        'goal'      => $goal,
        'autofill'  => $autofill,
        'owns'      => $owns,
        'date'      => $due_html,
        'msg'       => "Updating envelope failed."
    };
    
};

prefix '/';
1;