/** sql-queryf-codegen is MIT licensed, see /LICENSE. */
namespace HTL\SqlQueryfCodegen;

use namespace HTL\PrintfStateMachine;

final class EmbeddedLiteralStringHandler implements PrintfStateMachine\Handler {
  public function getArgumentTypeText()[]: ?PrintfStateMachine\HackType {
    return null;
  }

  public function getCaseBlock()[]: PrintfStateMachine\CaseBlock {
    return <<<'CODE'
$end = \HH\Lib\Str\search($old_format, ')%', $char_i);
invariant($end is nonnull, 'Non-terminated embedded literal string found.');
$text = \HH\Lib\Str\slice($old_format, $char_i + 1, $end - $char_i - 1);
$new_format .= '%s';
$new_args[] = $text;
$char_i = $end + 1;
$done = true;
break;
CODE
      |> PrintfStateMachine\case_block($$);
  }

  public function getHandCraftedInterfaceName()[]: PrintfStateMachine\HackType {
    return \HTL\SqlQueryf\EmbeddedString::class
      |> PrintfStateMachine\hack_type('\\'.$$);
  }

  public function getSpecifierText()[]: string {
    return '(';
  }
}
