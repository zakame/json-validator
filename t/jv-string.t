use lib '.';
use t::Helper;
use Test::More;
use utf8;
use Data::Dumper;

my $schema = {
  type       => 'object',
  properties => {nick => {type => 'string', minLength => 3, maxLength => 10, pattern => qr{^\w+$}}}
};

validate_ok {nick => 'batman'}, $schema;
validate_ok {nick => 1000},     $schema, E('/nick', 'Expected string - got number.');
validate_ok {nick => '1000'},   $schema;
validate_ok {nick => 'aa'},     $schema, E('/nick', 'String is too short: 2/3.');
validate_ok {nick => 'a' x 11}, $schema, E('/nick', 'String is too long: 11/10.');
like +join('', t::Helper->validator->validate({nick => '[nick]'})),
  qr{/nick: String does not match}, 'String does not match';

delete $schema->{properties}{nick}{pattern};
validate_ok {nick => 'Déjà vu'}, $schema;

t::Helper->validator->coerce(1);
validate_ok {nick => 1000}, $schema;
# testing that the original value is altered after validation
# this is a Binary.com specific operation. 
my $string_to_coerce = {nick => 123};
validate_ok $string_to_coerce, $schema;
# In pure Perl it is difficult/impossible to test for a string versus a string containing a number
# Data::Dumper uses c code for its operation so it can tell the difference. 
my $result =  Dumper($string_to_coerce);
my $expected = Dumper({nick =>'123'});
cmp_ok($result, 'eq', $expected, 'Original value was coerced'); 
done_testing;
