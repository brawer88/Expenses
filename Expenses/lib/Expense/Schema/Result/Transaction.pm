use utf8;
package Expense::Schema::Result::Transaction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Expense::Schema::Result::Transaction

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 TABLE: C<Transaction>

=cut

__PACKAGE__->table("Transaction");

=head1 ACCESSORS

=head2 transactionid

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0

=head2 amount

  data_type: 'decimal'
  is_nullable: 0
  size: [13,2]

=head2 for

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 envelopeid

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 type

  data_type: 'enum'
  extra: {list => ["Income","Expense","Transfer"]}
  is_nullable: 0

=head2 userid

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 bankid

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "transactionid",
  { data_type => "bigint", is_auto_increment => 1, is_nullable => 0 },
  "amount",
  { data_type => "decimal", is_nullable => 0, size => [13, 2] },
  "for",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "envelopeid",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "type",
  {
    data_type => "enum",
    extra => { list => ["Income", "Expense", "Transfer"] },
    is_nullable => 0,
  },
  "userid",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "bankid",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</transactionid>

=back

=cut

__PACKAGE__->set_primary_key("transactionid");

=head1 RELATIONS

=head2 bankid

Type: belongs_to

Related object: L<Expense::Schema::Result::Bank>

=cut

__PACKAGE__->belongs_to(
  "bankid",
  "Expense::Schema::Result::Bank",
  { bankid => "bankid" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 envelopeid

Type: belongs_to

Related object: L<Expense::Schema::Result::Envelope>

=cut

__PACKAGE__->belongs_to(
  "envelopeid",
  "Expense::Schema::Result::Envelope",
  { envelopeid => "envelopeid" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 userid

Type: belongs_to

Related object: L<Expense::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "userid",
  "Expense::Schema::Result::User",
  { userid => "userid" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-10-02 14:36:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pOKszufSMKadI19SJdXuFw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
