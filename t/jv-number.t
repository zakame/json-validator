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
validate_ok {mynumber => '+1'},     $schema;
validate_ok {mynumber => '001'},    $schema;
validate_ok {validNumber => 2.01},
    {
    type       => 'object',
    properties => {
        validNumber => {
            type       => 'number',
            multipleOf => 0.01
        }}};


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
                },
            
                  mytext => {
                      type => 'string'
                  }
            }},
          amount => {
                type =>'number'
          }      
    }};

my $number_to_coerce = {test => {mynumber => '001'}};
validate_ok $number_to_coerce, $schema;
is($number_to_coerce->{test}->{mynumber}.'t', '1t', 'Number has been coerced');



$number_to_coerce = {test => {mynumber => '.01'}};
validate_ok $number_to_coerce, $schema;
is($number_to_coerce->{test}->{mynumber}, '0.01', 'Number has been coerced');
my $coerce_with_string = {test =>{mynumber => '001', mytext => 'asdad'}};
validate_ok $coerce_with_string, $schema;
is($coerce_with_string->{test}->{mynumber}, '1', 'Number has been coerced');
is($coerce_with_string->{test}->{mytext}, 'asdad', 'Number has been coerced');

my $base_property = {amount => '.01' };
validate_ok $base_property, $schema;
is ($base_property->{amount}, '0.01',  'Base property coerced');



done_testing;
