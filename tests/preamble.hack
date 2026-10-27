/** sql-queryf-codegen is MIT licensed, see /LICENSE. */
namespace HTL\SqlQueryfCodegen\Tests;

use namespace HH\Lib\{Str, Vec};
use namespace HTL\TestChain;
use function HTL\HH4Shim\to_mixed;
use function exec;

<<TestChain\Discover>>
function preamble(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('CLI preamble formatting and signing', ()[defaults] ==> {
      $output = vec[];
      $status = 0;
      // Test-chain and CI invoke this group from the repository root.
      exec(
        'sh tests/cli/preamble.sh 2>&1',
        inout $output,
        inout $status,
      );
      invariant(
        $status === 0,
        'CLI regression failed: %s',
        Vec\map(to_mixed($output) as vec<_>, $line ==> $line as string)
          |> Str\join($$, "\n"),
      );
    });
}
