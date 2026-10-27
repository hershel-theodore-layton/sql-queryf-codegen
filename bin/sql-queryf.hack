#!/usr/bin/env hhvm
/** sql-queryf-codegen is MIT licensed, see /LICENSE. */
namespace HTL\SqlQueryfCodegen\Bin;

use namespace HH;
use namespace HH\Lib\{IO, OS, Str, Vec};
use namespace HTL\{HackCompiler, PrintfStateMachine, SqlQueryfCodegen};

/**
 * Usage: cat tests/codegen/preamble.in | hhvm bin/sql-queryf.hack --extended > tests/codegen/engine.hack
 * Usage: cat vendor/hershel-theodore-layton/sql-queryf/src/_Private/preamble.in | hhvm bin/sql-queryf.hack --to-string
 */
<<__EntryPoint>>
async function sql_queryf_async()[defaults]: Awaitable<void> {
  $argv = HH\global_get('argv') as vec<_> |> Vec\map($$, $x ==> $x as string);

  $preset = null;
  $help = false;
  foreach (Vec\drop($argv, 1) as $arg) {
    if ($arg === '--help') {
      $help = true;
      continue;
    }
    if (
      $arg !== '--vanilla' && $arg !== '--extended' && $arg !== '--to-string'
    ) {
      await IO\request_errorx()->writeAllAsync(
        Str\format("Unknown option: %s. Use --help for usage.\n", $arg),
      );
      exit(1);
    }
    if ($preset is nonnull && $preset !== $arg) {
      await IO\request_errorx()->writeAllAsync(
        "Choose only one preset: --vanilla, --extended, or --to-string.\n",
      );
      exit(1);
    }
    $preset = $arg;
  }

  if ($help) {
    await IO\request_errorx()->writeAllAsync(
      Str\format(
        "Usage: %s [--vanilla | --extended | --to-string] [--help]\n".
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

  // Pipes and files contain a complete document; wait for EOF.
  // An interactive invocation uses the default without consuming terminal input.
  if (!OS\isatty(OS\stdin())) {
    $preamble = await IO\request_input()->readAllAsync();
  } else {
    $preamble = Str\format(
      "// NO LICENSE HEADER INCLUDED\n".
      "// You can specify this preamble by catting in a preamble file.\n".
      "// `cat your_preamble.hack | %s`\n".
      "namespace YouDidNotPickANamespace;\n\n",
      Str\join($argv, ' '),
    );
  }

  $factory = PrintfStateMachine\Factory::create(
    PrintfStateMachine\hack_type('Sql'),
    SqlQueryfCodegen\StaticTypeAssertionGenerator::create(dict[]),
  );

  if ($preset === '--extended') {
    $factory = SqlQueryfCodegen\Presets::extended($factory);
  } else if ($preset === '--to-string') {
    $factory = SqlQueryfCodegen\Presets::renderToString($factory);
  } else {
    $factory = SqlQueryfCodegen\Presets::vanilla($factory);
  }

  $code = HackCompiler\prepare_signing_preamble($preamble).
    "\n".
    SqlQueryfCodegen\codegen($factory, PrintfStateMachine\ENGINE_TEMPLATE);
  echo await HackCompiler\process_source_file_async($code);
}
