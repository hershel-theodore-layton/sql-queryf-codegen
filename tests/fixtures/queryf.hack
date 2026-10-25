/** sql-queryf-codegen is MIT licensed, see /LICENSE. */
namespace HTL\SqlQueryfCodegen\Tests;

use namespace HH;
use namespace HTL\{HH4Shim, SqlQueryf};
use namespace HTL\SqlQueryf\ToString;
use type HTL\Pragma\Pragmas;
use function vsprintf;

function queryf(
  HH\FormatString<Extended\Sql> $format,
  mixed ...$args
)[]: SqlQueryf\QueryPack {
  return SqlQueryf\QueryPack::createWithoutTypechecking_UNSAFE(
    HH4Shim\to_mixed($format) as string,
    vec($args),
  );
}

function queryf_to_vanilla(
  HH\FormatString<Extended\Sql> $format,
  mixed ...$args
)[]: (string, vec<mixed>) {
  return Extended\engine(HH4Shim\to_mixed($format) as string, vec($args));
}

// The generated format is a runtime string, not an HH\FormatString for Str\format.
<<Pragmas(vec['PhaLinters', 'fixme:disallowed_function_type_or_constant'])>>
function queryf_to_string(
  HH\FormatString<Extended\Sql> $format,
  mixed ...$args
)[]: string {
  return SqlQueryf\QueryPack::createWithoutTypechecking_UNSAFE(
    HH4Shim\to_mixed($format) as string,
    vec($args),
  )
    |> Extended\engine($$->getFormat(), $$->getArguments())
    |> ToString\engine(...$$)
    |> vsprintf(...$$) as string;
}
