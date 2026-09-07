/** sql-queryf-codegen is MIT licensed, see /LICENSE. */
namespace HTL\Project_otqInSrDULKY\GeneratedTestChain;

use namespace HTL\TestChain;
use type HTL\Pragma\Pragmas;

<<file: Pragmas(vec['PhaLinters', 'digest:31d408c4853d3a6dcdf6'])>>

async function tests_async(
  TestChain\ChainController<\HTL\TestChain\Chain> $controller,
)[defaults]: Awaitable<TestChain\ChainController<\HTL\TestChain\Chain>> {
  return $controller
    ->addTestGroup(\HTL\SqlQueryfCodegen\Tests\usage<>);
}
