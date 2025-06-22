/** sql-queryf-codegen is MIT licensed, see /LICENSE. */
namespace HTL\SqlQueryfCodegen\Tests;

use namespace HH\Lib\SQL;
use namespace HTL\{SqlQueryf, TestChain};
use function HTL\Expect\expect;

<<TestChain\Discover>>
function usage(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('scalars', () ==> {
      expect(queryf_to_vanilla('SELECT %b', true))
        ->toEqual(tuple('SELECT %d', vec[1]));
      expect(queryf_to_vanilla('SELECT %?b', false))
        ->toEqual(tuple('SELECT %d', vec[0]));
      expect(queryf_to_vanilla('SELECT %?b', null))
        ->toEqual(tuple('SELECT %d', vec[null]));

      expect(queryf_to_vanilla('SELECT %d', 42))
        ->toEqual(tuple('SELECT %d', vec[42]));
      expect(queryf_to_vanilla('SELECT %?d', 12))
        ->toEqual(tuple('SELECT %d', vec[12]));
      expect(queryf_to_vanilla('SELECT %?d', null))
        ->toEqual(tuple('SELECT %d', vec[null]));

      expect(queryf_to_vanilla('SELECT %e', IntEnum::ONE))
        ->toEqual(tuple('SELECT %d', vec[IntEnum::ONE]));
      expect(queryf_to_vanilla('SELECT %?e', IntEnum::ONE))
        ->toEqual(tuple('SELECT %d', vec[IntEnum::ONE]));
      expect(queryf_to_vanilla('SELECT %?e', null))
        ->toEqual(tuple('SELECT %s', vec[null]));
      // `null` didn't pick int ^^

      expect(queryf_to_vanilla('SELECT %e', StringEnum::ONE))
        ->toEqual(tuple('SELECT %s', vec[StringEnum::ONE]));
      expect(queryf_to_vanilla('SELECT %?e', StringEnum::ONE))
        ->toEqual(tuple('SELECT %s', vec[StringEnum::ONE]));
      expect(queryf_to_vanilla('SELECT %?e', null))
        ->toEqual(tuple('SELECT %s', vec[null]));

      expect(queryf_to_vanilla('SELECT %f', 12.34))
        ->toEqual(tuple('SELECT %f', vec[12.34]));
      expect(queryf_to_vanilla('SELECT %?f', 23.45))
        ->toEqual(tuple('SELECT %f', vec[23.45]));
      expect(queryf_to_vanilla('SELECT %?f', null))
        ->toEqual(tuple('SELECT %f', vec[null]));

      expect(queryf_to_vanilla('SELECT %s', '"'))
        ->toEqual(tuple('SELECT %s', vec['"']));
      expect(queryf_to_vanilla('SELECT %?s', '\\'))
        ->toEqual(tuple('SELECT %s', vec['\\']));
      expect(queryf_to_vanilla('SELECT %?s', null))
        ->toEqual(tuple('SELECT %s', vec[null]));

      expect(queryf_to_vanilla('SELECT %D', SqlQueryf\opaque_int_from_int(42)))
        ->toEqual(tuple('SELECT %d', vec[42]));
      expect(queryf_to_vanilla('SELECT %?D', SqlQueryf\opaque_int_from_int(12)))
        ->toEqual(tuple('SELECT %d', vec[12]));
      expect(queryf_to_vanilla('SELECT %?D', null))
        ->toEqual(tuple('SELECT %d', vec[null]));

      expect(queryf_to_vanilla(
        'SELECT %S',
        SqlQueryf\opaque_string_from_string('*'),
      ))
        ->toEqual(tuple('SELECT %s', vec['*']));
      expect(queryf_to_vanilla(
        'SELECT %?S',
        SqlQueryf\opaque_string_from_string('"'),
      ))
        ->toEqual(tuple('SELECT %s', vec['"']));
      expect(queryf_to_vanilla('SELECT %?S', null))
        ->toEqual(tuple('SELECT %s', vec[null]));
    })
    ->test('scalar equality', () ==> {
      expect(queryf_to_vanilla('SELECT %=b', true))
        ->toEqual(tuple('SELECT %=d', vec[1]));
      expect(queryf_to_vanilla('SELECT %?=b', false))
        ->toEqual(tuple('SELECT %=d', vec[0]));
      expect(queryf_to_vanilla('SELECT %?=b', null))
        ->toEqual(tuple('SELECT %=d', vec[null]));

      expect(queryf_to_vanilla('SELECT %=d', 42))
        ->toEqual(tuple('SELECT %=d', vec[42]));
      expect(queryf_to_vanilla('SELECT %?=d', 12))
        ->toEqual(tuple('SELECT %=d', vec[12]));
      expect(queryf_to_vanilla('SELECT %?=d', null))
        ->toEqual(tuple('SELECT %=d', vec[null]));

      expect(queryf_to_vanilla('SELECT %=e', IntEnum::ONE))
        ->toEqual(tuple('SELECT %=d', vec[IntEnum::ONE]));
      expect(queryf_to_vanilla('SELECT %?=e', IntEnum::ONE))
        ->toEqual(tuple('SELECT %=d', vec[IntEnum::ONE]));
      expect(queryf_to_vanilla('SELECT %?=e', null))
        ->toEqual(tuple('SELECT %=s', vec[null]));
      // `null` didn't pick int ^^^

      expect(queryf_to_vanilla('SELECT %=e', StringEnum::ONE))
        ->toEqual(tuple('SELECT %=s', vec[StringEnum::ONE]));
      expect(queryf_to_vanilla('SELECT %?=e', StringEnum::ONE))
        ->toEqual(tuple('SELECT %=s', vec[StringEnum::ONE]));
      expect(queryf_to_vanilla('SELECT %?=e', null))
        ->toEqual(tuple('SELECT %=s', vec[null]));

      expect(queryf_to_vanilla('SELECT %=f', 12.34))
        ->toEqual(tuple('SELECT %=f', vec[12.34]));
      expect(queryf_to_vanilla('SELECT %?=f', 23.45))
        ->toEqual(tuple('SELECT %=f', vec[23.45]));
      expect(queryf_to_vanilla('SELECT %?=f', null))
        ->toEqual(tuple('SELECT %=f', vec[null]));

      expect(queryf_to_vanilla('SELECT %=s', '"'))
        ->toEqual(tuple('SELECT %=s', vec['"']));
      expect(queryf_to_vanilla('SELECT %?=s', '\\'))
        ->toEqual(tuple('SELECT %=s', vec['\\']));
      expect(queryf_to_vanilla('SELECT %?=s', null))
        ->toEqual(tuple('SELECT %=s', vec[null]));

      expect(queryf_to_vanilla('SELECT %=D', SqlQueryf\opaque_int_from_int(42)))
        ->toEqual(tuple('SELECT %=d', vec[42]));
      expect(
        queryf_to_vanilla('SELECT %?=D', SqlQueryf\opaque_int_from_int(12)),
      )
        ->toEqual(tuple('SELECT %=d', vec[12]));
      expect(queryf_to_vanilla('SELECT %?=D', null))
        ->toEqual(tuple('SELECT %=d', vec[null]));

      expect(queryf_to_vanilla(
        'SELECT %=S',
        SqlQueryf\opaque_string_from_string('*'),
      ))
        ->toEqual(tuple('SELECT %=s', vec['*']));
      expect(queryf_to_vanilla(
        'SELECT %?=S',
        SqlQueryf\opaque_string_from_string('"'),
      ))
        ->toEqual(tuple('SELECT %=s', vec['"']));
      expect(queryf_to_vanilla('SELECT %?=S', null))
        ->toEqual(tuple('SELECT %=s', vec[null]));
    })
    ->test('lists of scalars', () ==> {
      expect(queryf_to_vanilla('SELECT %Lb', vec[true, false]))
        ->toEqual(tuple('SELECT %Ld', vec[vec[1, 0]]));

      expect(queryf_to_vanilla('SELECT %Ld', vec[42, 12]))
        ->toEqual(tuple('SELECT %Ld', vec[vec[42, 12]]));

      expect(queryf_to_vanilla('SELECT %LD', vec[
        SqlQueryf\opaque_int_from_int(42),
        SqlQueryf\opaque_int_from_int(12),
      ]))
        ->toEqual(tuple('SELECT %Ld', vec[vec[42, 12]]));

      expect(queryf_to_vanilla('SELECT %Le', vec[IntEnum::ONE]))
        ->toEqual(tuple('SELECT %Ld', vec[vec[IntEnum::ONE]]));
      expect(queryf_to_vanilla('SELECT %Le', vec[]))
        ->toEqual(tuple('SELECT %Ls', vec[vec[]]));
      // empty, didn't pick int ^^^

      expect(queryf_to_vanilla('SELECT %Le', vec[StringEnum::ONE]))
        ->toEqual(tuple('SELECT %Ls', vec[vec[StringEnum::ONE]]));
      expect(queryf_to_vanilla('SELECT %Le', vec[]))
        ->toEqual(tuple('SELECT %Ls', vec[vec[]]));

      expect(
        queryf_to_vanilla('SELECT %Le', vec[IntEnum::ONE, StringEnum::ONE]),
      )->toEqual(tuple('SELECT %Ld', vec[vec[IntEnum::ONE, StringEnum::ONE]]));
      // This fail in squangle ^^^. Do NOT mix string and int enums.

      expect(queryf_to_vanilla('SELECT %Lf', vec[12.34, 43.21]))
        ->toEqual(tuple('SELECT %Lf', vec[vec[12.34, 43.21]]));

      expect(queryf_to_vanilla('SELECT %Ls', vec['a', 'b']))
        ->toEqual(tuple('SELECT %Ls', vec[vec['a', 'b']]));

      expect(queryf_to_vanilla('SELECT %LS', vec[
        SqlQueryf\opaque_string_from_string('a'),
        SqlQueryf\opaque_string_from_string('b'),
      ]))
        ->toEqual(tuple('SELECT %Ls', vec[vec['a', 'b']]));
    })
    ->test('tables and columns', () ==> {
      expect(queryf_to_vanilla('SELECT %C FROM %T', 'mycol', 'mytable'))
        ->toEqual(tuple('SELECT %C FROM %T', vec['mycol', 'mytable']));
      expect(queryf_to_vanilla('SELECT %LC FROM %T', vec['a', 'b'], 'mytable'))
        ->toEqual(tuple('SELECT %LC FROM %T', vec[vec['a', 'b'], 'mytable']));
    })
    ->test('comments', () ==> {
      expect(queryf_to_vanilla('%K SELECT 1', 'comment'))
        ->toEqual(tuple('%K SELECT 1', vec['comment']));
    })
    ->test('embedded literal strings', () ==> {
      expect(queryf_to_vanilla('SELECT %(hello)%'))
        ->toEqual(tuple('SELECT %s', vec['hello']));

      expect(queryf_to_vanilla('SELECT %()%'))
        ->toEqual(tuple('SELECT %s', vec['']));
    })
    ->test('nested queries', () ==> {
      $query1 = queryf('%C %=d', 'col1', 1);
      $query2 = queryf('%C %?=d', 'col2', null);

      list($format, $args) = queryf_to_vanilla(
        'SELECT * FROM %T WHERE %q AND %q',
        'mytable',
        $query1,
        $query2,
      );

      expect($format)->toEqual('SELECT * FROM %T WHERE %Q AND %Q');
      expect($args[0])->toEqual('mytable');
      expect($args[1] as SqlQueryf\HipHopLibSqlQueryPack->getFormat())
        ->toEqual('%C %=d');
      expect($args[1] as SqlQueryf\HipHopLibSqlQueryPack->getArguments())
        ->toEqual(vec['col1', 1]);
    })
    ->test('native queries', ()[defaults] ==> {
      $native = new SQL\Query('%C %=d', 'col1', null);
      expect(queryf_to_vanilla('SELECT * FROM %T WHERE %Q', 'mytable', $native))
        ->toEqual(tuple('SELECT * FROM %T WHERE %Q', vec['mytable', $native]));
    })
    ->test('lists of queries', () ==> {
      expect(queryf_to_string(
        'SELECT %L,q FROM %T',
        vec[queryf('%C', 'col1'), queryf('*')],
        'mytable',
      ))->toEqual('SELECT `col1`, * FROM `mytable`');

      expect(queryf_to_string(
        'SELECT * FROM %T WHERE %L&q',
        'mytable',
        vec[queryf('%C %?=d', 'col1', null), queryf('%C %=s', 'col2', 'text')],
      ))->toEqual(
        'SELECT * FROM `mytable` WHERE `col1` IS NULL AND `col2` = "text"',
      );

      expect(queryf_to_string(
        'SELECT * FROM %T WHERE %L|q',
        'mytable',
        vec[queryf('%C %?=d', 'col1', null), queryf('%C %=s', 'col2', 'text')],
      ))->toEqual(
        'SELECT * FROM `mytable` WHERE `col1` IS NULL OR `col2` = "text"',
      );
    });
}

/*
            case 0x71: // 'L|q'
*/
