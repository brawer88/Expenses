package Controllers::EnvelopeController;
use Dancer2 appname => 'Expenses';
use Models::Utilities;

my $db = Models::Database->new();

prefix '/envelope';

#------------------------------------------
#   Post method for transaction page
#------------------------------------------
post '/delete/:envelope' => sub
{
    my $edit_name = param('envelope');
    my $user      = session('user') // Models::User->new();

    my $name     = body_parameters->get('name');
    my $balance  = body_parameters->get('balance');
    my $goal     = body_parameters->get('goal');
    my $bank_id  = body_parameters->get('banks');
    my $autofill = body_parameters->get('autofill');
    my $due      = body_parameters->get('due');

    my $due_html = getDateSelected($due);
    my $banks    = $db->GetBanksSelected( $user->UID, $bank_id );
    my $owns     = $db->UserOwns( $user->UID, $edit_name );

    my $result;

    if ($owns)
    {
        $result = $db->DeleteEnvelope( $user->UID, $name );
    }

    if ($result)
    {
        return redirect uri_for("/");
    }

    template 'editenvelope' => {
        'title'     => 'Expenses: Edit Envelope',
        'logged_in' => $user->logged_in // 0,
        'name'      => $name,
        'banks'     => $banks,
        'balance'   => $balance,
        'goal'      => $goal,
        'autofill'  => $autofill,
        'owns'      => $owns,
        'msg'       => "Deleting envelope failed."
    };

};

#------------------------------------------
#   Get method for adding a bank
#------------------------------------------
get '/fillenvelope' => sub
{
    my $user = session('user') // Models::User->new();

    my $banks     = $db->GetBanksSelect( $user->UID );
    my $envelopes = $db->GetEnvelopesSelect( $user->UID );

    template 'fillenvelope' => {
        'title'     => 'Expenses: Fill Envelope',
        'pageTitle' => 'Fill Envelope',
        'banks'     => $banks,
        'envelopes' => $envelopes,
        'msg'       => Models::Utilities::get_flash(),
        'logged_in' => $user->logged_in // 0,
    };
};

#------------------------------------------
#   Post method for adding a paycheck
#------------------------------------------
post '/fillenvelope' => sub
{
    my $user = session('user') // Models::User->new();

    my $bank_id     = body_parameters->get('banks');
    my $transfer_to = body_parameters->get('transfer_to');
    my $amount      = body_parameters->get('amount');

    my $result = $db->FillEnvelope( $user->UID, $transfer_to, $bank_id, $amount );
    my $name   = $db->GetEnvelopeName($transfer_to);

    if ($result)
    {
        set_flash("Filled envelope $name successfully.");
        return redirect uri_for('/');
    }
    else
    {
        set_flash("Filling envelope failed.");
        return redirect uri_for('/user/fillenvelope');
    }
};

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
        'title'     => 'Expenses: Edit Envelope',
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
    my $user      = session('user') // Models::User->new();

    my $name     = body_parameters->get('name');
    my $balance  = body_parameters->get('balance');
    my $goal     = body_parameters->get('goal');
    my $bank_id  = body_parameters->get('banks');
    my $autofill = body_parameters->get('autofill');
    my $due      = body_parameters->get('due');

    my $due_html = getDateSelected($due);
    my $banks    = $db->GetBanksSelected( $user->UID, $bank_id );
    my $owns     = $db->UserOwns( $user->UID, $edit_name );

    my $result;

    if ($owns)
    {
        $result =
          $db->UpdateEnvelope( $user->UID, $name, $balance, $goal, $bank_id, $autofill,
            $due, $edit_name );
    }

    if ($result)
    {
        return redirect uri_for("/");
    }

    template 'editenvelope' => {
        'title'     => 'Expenses: Edit Envelope',
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