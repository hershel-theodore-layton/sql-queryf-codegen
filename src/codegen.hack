/** sql-queryf-codegen is MIT licensed, see /LICENSE. */
namespace HTL\SqlQueryfCodegen;

use namespace HTL\PrintfStateMachine;

function codegen(
  PrintfStateMachine\Factory $factory,
  string $template,
)[]: PrintfStateMachine\Entities {
  return PrintfStateMachine\codegen($factory, $template);
}
