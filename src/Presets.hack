/** sql-queryf-codegen is MIT licensed, see /LICENSE. */
namespace HTL\SqlQueryfCodegen;

use namespace HH\Lib\SQL;
use namespace HTL\{PrintfStateMachine, SqlQueryf};

final abstract class Presets {
  /**
   * This preset includes many of the conversions I use in my applications
   * and some which demonstate the possibilities. You can mix and match what
   * you like to create your own extended set, or use these as-is, your pick.
   *
   * The scalars are null-aware, so `%d` accepts `int`, not `?int`.
   * If you wanted to pass a nullable int, use `%?d`.
   * Support for booleans (`%b`), enums (`%e`),
   * opaque ints and strings (`%D`) and (`%S`) respectively,
   * and lists of queries (`%L&q`, `%L|q`, and `%L,q`) are all included.
   * 
   * This preset also allows you to add literal strings into your queries,
   * like so: `SELECT * FROM %T WHERE %C = %(Some constant string)%`.
   * The embedded string literals are `%(` + `)%` delimited.
   * At runtime, these will emit a `%s` specifier, to placate the "no-quotes"
   * check in squangle.
   */
  public static function extended(
    PrintfStateMachine\Factory $factory,
  )[]: PrintfStateMachine\Factory {
    return $factory
      ->apply(static::partialBase<>)
      ->apply(static::partialScalarsNullAware<>)
      ->apply(static::partialBooleans<>)
      ->apply(static::partialEnums<>)
      ->apply(static::partialOpaqueStringsAndInts<>)
      ->apply(static::partialListsOfQueries<>)
      ->apply(static::partialEmbeddedLiteralStrings<>);
  }

  /**
   * Emulate `HH\Lib\SQL\Query`, but add `%q` to support `Format\Pack`.
   * You don't need to change your existing queries with this preset.
   */
  public static function vanilla(
    PrintfStateMachine\Factory $factory,
  )[]: PrintfStateMachine\Factory {
    return $factory
      ->apply(static::partialBase<>)
      ->apply(static::partialScalarsNullOblivious<>);
  }

  /**
   * This is the engine you get when installing sql-queryf from packagist.
   * It consumes the same templates as `HH\Lib\SQL\Query`, but emits a format
   * and args for `\vsprintf()` instead of `HH\Lib\SQL\Query`. If you want to
   * map from your custom DSL (for example `extended`) to a loggable query,
   * you must first go to `vanilla`. Do not construct `HH\Lib\SQL\Query` objects
   * from your `HipHopLibSqlQueryPack` objects. Then pass the vanilla format
   * and args to the `to-string` engine.
   */
  public static function renderToString(
    PrintfStateMachine\Factory $factory,
  )[]: PrintfStateMachine\Factory {
    return $factory
      ->withRewrite<string>('C', 's', SqlQueryf\render_column<>)
      ->withRewrite<string>('T', 's', SqlQueryf\render_column<>)
      ->withRewrite<vec<string>>('LC', 's', SqlQueryf\render_list_of_column<>)
      ->withRewrite<string>('K', 's', SqlQueryf\render_comment<>)
      ->with(
        new PrintfStateMachine\SingleArgumentHandler(
          'Q',
          PrintfStateMachine\sequence_transform("'%s'"),
          PrintfStateMachine\hack_type(
            '\\'.SqlQueryf\HipHopLibSqlQueryPack::class,
          ),
          null,
          PrintfStateMachine\value_transform(
            '$$ is \HTL\SqlQueryf\HipHopLibSqlQueryPack'.
            ' ? \HTL\SqlQueryf\render_hh_lib_sql_style_pack($$)'.
            ' : \HTL\SqlQueryf\unsupported_query_object($$)',
          ),
        ),
      )
      ->withRewrite<?int>('d', 's', SqlQueryf\render_int<>)
      ->withRewrite<?int>('=d', 's', SqlQueryf\render_int_equality<>)
      ->withRewrite<vec<int>>('Ld', 's', SqlQueryf\render_list_of_int<>)
      ->withRewrite<?float>('f', 's', SqlQueryf\render_float<>)
      ->withRewrite<?float>('=f', 's', SqlQueryf\render_float_equality<>)
      ->withRewrite<vec<float>>('Lf', 's', SqlQueryf\render_list_of_float<>)
      ->withRewrite<?string>('s', 's', SqlQueryf\render_string<>)
      ->withRewrite<?string>('=s', 's', SqlQueryf\render_string_equality<>)
      ->withRewrite<vec<string>>('Ls', 's', SqlQueryf\render_list_of_string<>);
  }

  /**
   * Adds support for `%C`, `%T`, `%LC`, `%K`, `%Q`, and `%q`.
   * The first five are all lifted from HH\Lib\Sql\Query.
   * The latter repacks a `SqlQueryf\QueryPack` into a `HipHopLibSqlQueryPack`,
   * which is compatible with `HH\Lib\SQL\Query`.
   */
  public static function partialBase(
    PrintfStateMachine\Factory $factory,
  )[]: PrintfStateMachine\Factory {
    $pack = '\\'.SqlQueryf\QueryPack::class;
    return $factory
      ->withRewrite<string>('C')
      ->withRewrite<string>('T')
      ->withRewrite<vec<string>>('LC')
      ->withRewrite<string>('K')
      ->withRewrite<SQL\Query>('Q')
      ->with(
        new PrintfStateMachine\SingleArgumentHandler(
          'q',
          PrintfStateMachine\sequence_transform("'%Q'"),
          PrintfStateMachine\hack_type($pack),
          PrintfStateMachine\type_assertion_expression('$$ as '.$pack),
          PrintfStateMachine\value_transform(
            'engine($$->getFormat(), $$->getArguments())'.
            ' |> \HTL\SqlQueryf\HipHopLibSqlQueryPack::createWithoutTypechecking_UNSAFE(...$$)',
          ),
        ),
      );
  }

  /**
   * Adds support for `%d`, `%=d`, `%Ld`, `%f`, `%=f`, `%Lf`, `%s`, `%=s`, and `%Ls`.
   * The behavior, including the acceptance of null values, is mapped from HH\Lib\SQL\Query.
   * I prefer to use `partialScalarsNullAware`, but these extensions are easier
   * to adopt in a codebase that has many existing HH\Lib\SQL\Query queries.
   */
  public static function partialScalarsNullOblivious(
    PrintfStateMachine\Factory $factory,
  )[]: PrintfStateMachine\Factory {
    return $factory
      ->withRewrite<int>('d')
      ->withRewrite<int>('=d')
      ->withRewrite<vec<int>>('Ld')
      ->withRewrite<float>('f')
      ->withRewrite<float>('=f')
      ->withRewrite<vec<float>>('Lf')
      ->withRewrite<string>('s')
      ->withRewrite<string>('=s')
      ->withRewrite<vec<string>>('Ls');
  }

  public static function partialScalarsNullAware(
    PrintfStateMachine\Factory $factory,
  )[]: PrintfStateMachine\Factory {
    return $factory
      ->withRewrite<int>('d')
      ->withRewrite<?int>('?d', 'd')
      ->withRewrite<int>('=d')
      ->withRewrite<?int>('?=d', '=d')
      ->withRewrite<vec<int>>('Ld')
      ->withRewrite<float>('f')
      ->withRewrite<?float>('?f', 'f')
      ->withRewrite<float>('=f')
      ->withRewrite<?float>('?=f', '=f')
      ->withRewrite<vec<float>>('Lf')
      ->withRewrite<string>('s')
      ->withRewrite<?string>('?s', 's')
      ->withRewrite<string>('=s')
      ->withRewrite<?string>('?=s', '=s')
      ->withRewrite<vec<string>>('Ls');
  }

  /**
   * Adds support for `%b`, `%?b`, `%=b`, `%?=b`, and `%Lb`.
   * True and false are rewritten to `0` and `1` respectively.
   */
  public static function partialBooleans(
    PrintfStateMachine\Factory $factory,
  )[]: PrintfStateMachine\Factory {
    return $factory
      ->withRewrite<bool>('b', 'd', SqlQueryf\bool_to_int<>)
      ->withRewriteOfNullable<bool>('?b', 'd', SqlQueryf\bool_to_int<>)
      ->withRewrite<bool>('=b', '=d', SqlQueryf\bool_to_int<>)
      ->withRewriteOfNullable<bool>('?=b', '=d', SqlQueryf\bool_to_int<>)
      ->withRewriteOfVec<bool>('Lb', 'Ld', SqlQueryf\bool_to_int<>);
  }

  /**
   * Adds support for `%e`, `%?e`, `%=e`, `%?=e`, and `%Le`.
   * You may pass any enum to `e`, f.e. `enum MyEnum : int { Enumerator = 1; }`.
   * If your enum has both `int` and `string` values, you should not use this.
   * The assumption is that all values are either `int` or `string`, but not a mix.
   * 
   * These extensions are not guaranteed to be stable in future versions.
   * They rely on some arcane Hack/hhvm tomfoolery.
   * Hack or hhvm may remove support for this at some point.
   */
  public static function partialEnums(
    PrintfStateMachine\Factory $factory,
  )[]: PrintfStateMachine\Factory {
    $tup = '\\'.SqlQueryf\AnyEnum::class;
    return $factory
      ->with(new PrintfStateMachine\SingleArgumentHandler(
        'e',
        PrintfStateMachine\sequence_transform("$$ is int ? '%d' : '%s'"),
        PrintfStateMachine\hack_type($tup),
        null,
        PrintfStateMachine\value_transform('$$'),
      ))
      ->with(new PrintfStateMachine\SingleArgumentHandler(
        '?e',
        PrintfStateMachine\sequence_transform("$$ is int ? '%d' : '%s'"),
        PrintfStateMachine\hack_type('?'.$tup),
        null,
        PrintfStateMachine\value_transform('$$'),
      ))
      ->with(new PrintfStateMachine\SingleArgumentHandler(
        '=e',
        PrintfStateMachine\sequence_transform("$$ is int ? '%=d' : '%=s'"),
        PrintfStateMachine\hack_type($tup),
        null,
        PrintfStateMachine\value_transform('$$'),
      ))
      ->with(new PrintfStateMachine\SingleArgumentHandler(
        '?=e',
        PrintfStateMachine\sequence_transform("$$ is int ? '%=d' : '%=s'"),
        PrintfStateMachine\hack_type('?'.$tup),
        null,
        PrintfStateMachine\value_transform('$$'),
      ))
      ->with(new PrintfStateMachine\SingleArgumentHandler(
        'Le',
        PrintfStateMachine\sequence_transform(
          "($$[0] ?? '') is string ? '%Ls' : '%Ld'",
        ),
        PrintfStateMachine\hack_type('vec<'.$tup.'>'),
        PrintfStateMachine\type_assertion_expression('$$ as vec<_>'),
        PrintfStateMachine\value_transform('$$'),
      ));
  }

  /**
   * Adds support for `%D`, `%?D`, `%=D`, `%?=D`, `%LD`, `%S`, `%?S`, `%=S`, `%?=S`, and `%LS`.
   * The `D` variant accepts an `OpaqueInt`, and the `S` variant accepts an `OpaqueString`.
   * If you define your own opaque types in terms of these, you can use them in sql.
   * 
   * `sql('SELECT * FROM %T WHERE %C %=D', $user->getId())`
   *
   * For even more type-safety,
   * you can add your own `Id` type, and add it like the code below.
   */
  public static function partialOpaqueStringsAndInts(
    PrintfStateMachine\Factory $factory,
  )[]: PrintfStateMachine\Factory {
    return $factory
      ->withRewrite<SqlQueryf\OpaqueInt>('D', 'd')
      ->withRewrite<?SqlQueryf\OpaqueInt>('?D', 'd')
      ->withRewrite<SqlQueryf\OpaqueInt>('=D', '=d')
      ->withRewrite<?SqlQueryf\OpaqueInt>('?=D', '=d')
      ->withRewrite<vec<SqlQueryf\OpaqueInt>>('LD', 'Ld')
      ->withRewrite<SqlQueryf\OpaqueString>('S', 's')
      ->withRewrite<?SqlQueryf\OpaqueString>('?S', 's')
      ->withRewrite<SqlQueryf\OpaqueString>('=S', '=s')
      ->withRewrite<?SqlQueryf\OpaqueString>('?=S', '=s')
      ->withRewrite<vec<SqlQueryf\OpaqueString>>('LS', 'Ls');
  }

  /**
   * Adds support for `%L,q`, `%L|q`, and `%&q`.
   * These take a `vec<SqlQueryf\QueryPack>` and join with `,`, ` OR `, and ` AND `
   * respectively. Useful when writing WHERE clauses or INSERT INTO statements
   * with multiple rows.
   */
  public static function partialListsOfQueries(
    PrintfStateMachine\Factory $factory,
  )[]: PrintfStateMachine\Factory {
    return $factory->with(new ListOfQueryHandler('L,q', ', '))
      ->with(new ListOfQueryHandler('L|q', ' OR '))
      ->with(new ListOfQueryHandler('L&q', ' AND '));
  }

  /**
   * This preset also allows you to add literal strings into your queries,
   * like so: `SELECT * FROM %T WHERE %C = %(Some constant string)%`.
   * The embedded string literals are `%(` + `)%` delimited.
   * At runtime, these will emit a `%s` specifier, to placate the "no-quotes"
   * check in squangle.
   */
  public static function partialEmbeddedLiteralStrings(
    PrintfStateMachine\Factory $factory,
  )[]: PrintfStateMachine\Factory {
    return $factory->with(new EmbeddedLiteralStringHandler());
  }
}
