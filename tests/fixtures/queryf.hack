/** sql-queryf-codegen is MIT licensed, see /LICENSE. */
namespace HTL\SqlQueryfCodegen\Tests;

use namespace HH;
use namespace HTL\SqlQueryf;
use namespace HTL\SqlQueryf\ToString;

function queryf(
  HH\FormatString<Extended\Sql> $format,
  mixed ...$args
)[]: SqlQueryf\QueryPack {
  return SqlQueryf\QueryPack::createWithoutTypechecking_UNSAFE(
    $format as string,
    vec($args),
  );
}

function queryf_to_vanilla(
  HH\FormatString<Extended\Sql> $format,
  mixed ...$args
)[]: (string, vec<mixed>) {
  return Extended\engine($format as string, vec($args));
}

function queryf_to_string(
  HH\FormatString<Extended\Sql> $format,
  mixed ...$args
)[]: string {
  return SqlQueryf\QueryPack::createWithoutTypechecking_UNSAFE(
    $format as string,
    vec($args),
  )
    |> Extended\engine($$->getFormat(), $$->getArguments())
    |> ToString\engine(...$$)
    |> \vsprintf(...$$);
}
