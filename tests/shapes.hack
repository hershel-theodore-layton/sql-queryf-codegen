/** sql-queryf-codegen is MIT licensed, see /LICENSE. */
namespace HTL\SqlQueryfCodegen\Tests;

use namespace HH\Lib\Str;
use namespace HTL\{PrintfStateMachine, SqlQueryfCodegen, TestChain};
use function HTL\Expect\expect;

final class ShapeKeys {
  const string ID = 'id';
}

function shape_id(shape('id' => int /*_*/) $value)[]: int {
  return $value['id'];
}

function optional_shape_id(shape(?'id' => int /*_*/) $value)[]: int {
  return $value['id'] ?? 0;
}

function nested_shape_id(
  shape('value' => shape('id' => int /*_*/) /*_*/) $value,
)[]: int {
  return $value['value']['id'];
}

<<TestChain\Discover>>
function shapes(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('shape conversions generate assertions and interfaces', () ==> {
      $factory = PrintfStateMachine\Factory::create(
        PrintfStateMachine\hack_type('ShapeSql'),
        SqlQueryfCodegen\StaticTypeAssertionGenerator::create(dict[]),
      )
        ->withRewrite<shape('id' => int /*_*/)>('I', 'd', shape_id<>)
        ->withRewrite<shape(?'id' => int /*_*/)>('O', 'd', optional_shape_id<>)
        ->withRewriteOfNullable<shape('id' => int /*_*/)>('N', 'd', shape_id<>)
        ->withRewrite<shape('value' => shape('id' => int /*_*/) /*_*/)>(
          'V',
          'd',
          nested_shape_id<>,
        );
      $code =
        SqlQueryfCodegen\codegen($factory, PrintfStateMachine\ENGINE_TEMPLATE);
      expect(Str\contains($code, 'format_upcase_i'))->toEqual(true);
      expect(Str\contains($code, 'cast_generated_'))->toEqual(true);
    })
    ->test('class constant string fields generate assertions', () ==> {
      list($generator, $_) =
        SqlQueryfCodegen\StaticTypeAssertionGenerator::create(dict[])
          ->forType<shape(ShapeKeys::ID => int /*_*/)>();
      expect(Str\contains($generator->generateCasts(), "'id'"))->toEqual(true);
    });
}
