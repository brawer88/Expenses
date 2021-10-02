use utf8;
package Expense::Schema::Result::Envelope;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Expense::Schema::Result::Envelope

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

=head1 TABLE: C<Envelope>

=cut

__PACKAGE__->table("Envelope");

=head1 ACCESSORS

=head2 envelopeid

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'bigint'
  is_nullable: 0

=head2 currentbalance

  data_type: 'decimal'
  is_nullable: 0
  size: [13,2]

=head2 userid

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "envelopeid",
  { data_type => "bigint", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "bigint", is_nullable => 0 },
  "currentbalance",
  { data_type => "decimal", is_nullable => 0, size => [13, 2] },
  "userid",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</envelopeid>

=back

=cut

__PACKAGE__->set_primary_key("envelopeid");

=head1 RELATIONS

=head2 transactions

Type: has_many

Related object: L<Expense::Schema::Result::Transaction>

=cut

__PACKAGE__->has_many(
  "transactions",
  "Expense::Schema::Result::Transaction",
  { "foreign.envelopeid" => "self.envelopeid" },
  { cascade_copy => 0, cascade_delete => 0 },
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7L6himJCh9ZsTqX28IYPCA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
