# SQL Queryf Codegen

_Customize your queryf DSL to your heart's content._

This package contains some presets for you own sql-queryf engines.
The basic `HH\\Lib\\SQL\\Query`-like engine can be generated with
`vendor/bin/sql-queryf --vanilla`. If you want to see what's possible,
use `--extended` instead of `--vanilla`. If you want to customize,
see `HTL\\SqlQueryfCodegen\\Presets`. A usage example can be found in
`vendor/hershel-theodore-layton/sql-queryf-codegen/bin/sql-queryf.hack`.

```HACK
$your_engine = PrintfStateMachine\Factory::create(
  PrintfStateMachine\hack_type('Sql'),
  SqlQueryfCodegen\StaticTypeAssertionGenerator::create(dict[]),
)
  |> $$->apply(SqlQueryfCodegen\Presets::vanilla<>)
  |> SqlQueryfCodegen\codegen($$, PrintfStateMachine\ENGINE_TEMPLATE);
```
