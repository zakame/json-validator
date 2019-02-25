use lib '.';
use t::Helper;
use Test::More;
my $schema = {
    type       => 'object',
    properties => {
        mynumber => {
            type    => 'number',
            minimum => -0.5,
            maximum => 2.7
        }}};

validate_ok {mynumber => 1}, $schema;
validate_ok {mynumber => '2'}, $schema, E('/mynumber', 'Expected number - got string.');

t::Helper->validator->coerce(numbers => 1);
validate_ok {mynumber => '-0.3'},   $schema;
validate_ok {mynumber => '0.1e+1'}, $schema;
validate_ok {mynumber => '2xyz'},   $schema, E('/mynumber', 'Expected number - got string.');
validate_ok {mynumber => '.1'},     $schema;
validate_ok {mynumber => '001'},    $schema;
validate_ok {validNumber => 2.01},
    {
    type       => 'object',
    properties => {
        validNumber => {
            type       => 'number',
            multipleOf => 0.01
        }}};

use JSON::Validator;
my $validator = JSON::Validator->new;
$validator->coerce(numbers => 1);

$schema = {
    type       => 'object',
    properties => {
        test => {
            type       => 'object',
            properties => {
                mynumber => {
                    type    => 'number',
                    minimum => -0.5,
                    maximum => 2.7
                }}}}};
$validator->schema($schema);
my $number_to_coerce = {test => {mynumber => '001'}};
$validator->validate($number_to_coerce);
#validate_ok $number_to_coerce, $schema;
is($number_to_coerce->{test}->{mynumber}, '1', 'Number has been coerced');

$number_to_coerce = {test => {mynumber => '.01'}};
$validator->validate($number_to_coerce);
is($number_to_coerce->{test}->{mynumber}, '0.01', 'Number has been coerced');
done_testing;
