#!/usr/bin/env hhvm
/** sql-queryf-codegen is MIT licensed, see /LICENSE. */
namespace HTL\SqlQueryfCodegen\Bin;

use namespace HH;
use namespace HH\Lib\{C, File, IO, OS, Str, Vec};
use namespace HTL\{PrintfStateMachine, SqlQueryfCodegen};
use function escapeshellarg, exec, file_exists, shell_exec;

/**
 * Usage: cat tests/codegen/preamble.in | hhvm bin/sql-queryf.hack --extended > tests/codegen/engine.hack
 * Usage: cat vendor/hershel-theodore-layton/sql-queryf/src/_Private/preamble.in | hhvm bin/sql-queryf.hack --to-string
 */
<<__EntryPoint>>
async function sql_queryf_async()[defaults]: Awaitable<void> {
  $argv = HH\global_get('argv') as vec<_> |> Vec\map($$, $x ==> $x as string);

  $fifty_milliseconds_in_ns = (int)50e6;

  try {
    $preamble =
      await IO\request_input()->readAllAsync(null, $fifty_milliseconds_in_ns);
  } catch (OS\BlockingIOException $_) {
    $preamble = Str\format(
      "// NO LICENSE HEADER INCLUDED\n".
      "// You can specify this preamble by catting in a preamble file.\n".
      "// `cat your_preamble.hack | %s`\n".
      "namespace YouDidNotPickANamespace;\n\n",
      Str\join($argv, ' '),
    );
  }

  if (idx($argv, 1) === '--help') {
    await IO\request_errorx()->writeAllAsync(
      Str\format(
        "Usage: %s <flags>\n".
        "  --vanilla (default) behaves identically to `HH\\Lib\\SQL\\Query`.\n\n".
        "  --to-string create the engine found in sql-queryf/src/to_string_engine.hack\n".
        "  --extended create the engine found in tests/codegen/engine.hack\n".
        "    this engine has many extra features\n".
        "    - conversions for booleans, enums, opaque types, lists of queries\n".
        "    - null-aware scalar support\n".
        "    - support for embedded string literals `%%(example)%%`\n".
        "      This serves as an example of what you can do if you customize\n".
        "      your own query DSL for your application.\n",
        $argv[0],
      ),
    );
    return;
  }

  $factory = PrintfStateMachine\Factory::create(
    PrintfStateMachine\hack_type('Sql'),
    SqlQueryfCodegen\StaticTypeAssertionGenerator::create(dict[]),
  );

  if (C\contains($argv, '--extended')) {
    $factory = SqlQueryfCodegen\Presets::extended($factory);
  } else if (C\contains($argv, '--to-string')) {
    $factory = SqlQueryfCodegen\Presets::renderToString($factory);
  } else {
    $factory = SqlQueryfCodegen\Presets::vanilla($factory);
  }

  if (!Str\contains($preamble, "'digest:'")) {
    if (Str\contains($preamble, 'Pragmas(')) {
      $preamble = Str\replace(
        $preamble,
        'Pragmas(',
        "Pragmas(vec['PhaLinters', 'digest:'], ",
      );
    } else {
      if (!Str\contains($preamble, 'use type HTL\\Pragma\\Pragmas;')) {
        $preamble .= "\nuse type HTL\\Pragma\\Pragmas;\n";
      }
      $preamble .= "\n<<file: Pragmas(vec['PhaLinters', 'digest:'])>>\n\n";
    }
  }
  $code = $preamble.
    SqlQueryfCodegen\codegen($factory, PrintfStateMachine\ENGINE_TEMPLATE);
  using $temporary_file = File\temporary_file();
  $file = $temporary_file->getHandle();
  $path = $file->getPath();
  await $file->writeAllAsync($code);
  $formatted = shell_exec('hackfmt < '.escapeshellarg($path)) as string;
  $file->seek(0);
  $file->truncate();
  await $file->writeAllAsync($formatted);
  $output = vec[];
  $status = 0;
  $signer = __DIR__.
    '/../vendor/hershel-theodore-layton/portable-hack-ast-linters-server/bin/pha-sign-hack-source.sh';
  if (!file_exists($signer)) {
    $signer = __DIR__.
      '/../../portable-hack-ast-linters-server/bin/pha-sign-hack-source.sh';
  }
  exec(
    escapeshellarg($signer).' '.escapeshellarg($path),
    inout $output,
    inout $status,
  );
  invariant($status === 0, 'Could not sign generated SQL engine');
  $file->seek(0);
  echo await $file->readAllAsync();
}
