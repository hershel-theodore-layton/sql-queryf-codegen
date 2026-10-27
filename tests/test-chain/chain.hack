/** sql-queryf-codegen is MIT licensed, see /LICENSE. */
namespace HTL\Project_otqInSrDULKY\GeneratedTestChain;

use namespace HTL\TestChain;
use type HTL\Pragma\Pragmas;

<<file: Pragmas(vec['PhaLinters', 'digest:414517169e570ef5f68a'])>>

async function tests_async(
  TestChain\ChainController<\HTL\TestChain\Chain> $controller,
)[defaults]: Awaitable<TestChain\ChainController<\HTL\TestChain\Chain>> {
  return $controller
    ->addTestGroup(\HTL\SqlQueryfCodegen\Tests\preamble<>)
    ->addTestGroup(\HTL\SqlQueryfCodegen\Tests\shapes<>)
    ->addTestGroup(\HTL\SqlQueryfCodegen\Tests\usage<>);
}
