/** sql-queryf-codegen is MIT licensed, see /LICENSE. */
namespace HTL\SqlQueryfCodegen;

use namespace HTL\PrintfStateMachine;

final class ListOfQueryHandler implements PrintfStateMachine\Handler {
  public function __construct(
    private string $specifierText,
    private string $joinSequence,
  )[] {}

  public function getArgumentTypeText()[]: PrintfStateMachine\HackType {
    return PrintfStateMachine\hack_type('vec<\\HTL\\SqlQueryf\\QueryPack>');
  }

  public function getCaseBlock()[]: PrintfStateMachine\CaseBlock {
    // hackfmt-ignore
    return <<<'CODE'
$arg as vec<_>;
$new_format .= \HH\Lib\C\count($arg)
  |> \HH\Lib\Vec\fill($$, '%Q')
  |> \HH\Lib\Str\join($$, 
CODE
      . PrintfStateMachine\_Private\string_export_pure($this->joinSequence).<<<'CODE'
);
foreach ($arg as $pack) {
  $pack as \HTL\SqlQueryf\QueryPack;
  $new_args[] = engine($pack->getFormat(), $pack->getArguments())
    |> \HTL\SqlQueryf\HipHopLibSqlQueryPack::createWithoutTypechecking_UNSAFE(...$$);
}
++$arg_i;
$done = true;
break;
CODE
      |> PrintfStateMachine\case_block($$);
  }

  public function getHandCraftedInterfaceName()[]: null {
    return null;
  }

  public function getSpecifierText()[]: string {
    return $this->specifierText;
  }
}
