/** sql-queryf-codegen is MIT licensed, see /LICENSE. */
namespace HTL\Project_otqInSrDULKY\GeneratedTestChain;

use namespace HTL\TestChain;

async function tests_async(
  TestChain\ChainController<\HTL\TestChain\Chain> $controller
)[defaults]: Awaitable<TestChain\ChainController<\HTL\TestChain\Chain>> {
  return $controller
    ->addTestGroup(\HTL\SqlQueryfCodegen\Tests\usage<>);
}
