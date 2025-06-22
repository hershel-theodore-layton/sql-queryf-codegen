/** sql-queryf-codegen is MIT licensed, see /LICENSE. */
namespace HTL\SqlQueryfCodegen\Tests\Extended;

use type HTL\Pragma\Pragmas;

<<file:
  Pragmas(
    vec['PhaLinters', 'fixme:camel_cased_methods_underscored_functions'],
  )>>

interface Sql {
  public function format_0x28()[]: \HTL\SqlQueryf\EmbeddedString;
  public function format_upcase_c(string $_)[]: string;
  public function format_upcase_d(\HTL\SqlQueryf\OpaqueInt $_)[]: string;
  public function format_upcase_k(string $_)[]: string;
  public function format_upcase_q(\HH\Lib\SQL\Query $_)[]: string;
  public function format_upcase_s(\HTL\SqlQueryf\OpaqueString $_)[]: string;
  public function format_upcase_t(string $_)[]: string;
  public function format_b(bool $_)[]: string;
  public function format_d(int $_)[]: string;
  public function format_e(\HTL\SqlQueryf\AnyEnum $_)[]: string;
  public function format_f(float $_)[]: string;
  public function format_q(\HTL\SqlQueryf\QueryPack $_)[]: string;
  public function format_s(string $_)[]: string;
  public function format_0x25()[]: string;
  public function format_0x3d()[]: SqlWithEquals;
  public function format_0x3f()[]: SqlWithQuestion;
  public function format_upcase_l()[]: SqlWithUpperL;
}

interface SqlWithEquals {
  public function format_upcase_d(\HTL\SqlQueryf\OpaqueInt $_)[]: string;
  public function format_upcase_s(\HTL\SqlQueryf\OpaqueString $_)[]: string;
  public function format_b(bool $_)[]: string;
  public function format_d(int $_)[]: string;
  public function format_e(\HTL\SqlQueryf\AnyEnum $_)[]: string;
  public function format_f(float $_)[]: string;
  public function format_s(string $_)[]: string;
}

interface SqlWithQuestion {
  public function format_upcase_d(?\HTL\SqlQueryf\OpaqueInt $_)[]: string;
  public function format_upcase_s(?\HTL\SqlQueryf\OpaqueString $_)[]: string;
  public function format_b(?bool $_)[]: string;
  public function format_d(?int $_)[]: string;
  public function format_e(?\HTL\SqlQueryf\AnyEnum $_)[]: string;
  public function format_f(?float $_)[]: string;
  public function format_s(?string $_)[]: string;
  public function format_0x3d()[]: SqlWithQuestionWithEquals;
}

interface SqlWithQuestionWithEquals {
  public function format_upcase_d(?\HTL\SqlQueryf\OpaqueInt $_)[]: string;
  public function format_upcase_s(?\HTL\SqlQueryf\OpaqueString $_)[]: string;
  public function format_b(?bool $_)[]: string;
  public function format_d(?int $_)[]: string;
  public function format_e(?\HTL\SqlQueryf\AnyEnum $_)[]: string;
  public function format_f(?float $_)[]: string;
  public function format_s(?string $_)[]: string;
}

interface SqlWithUpperL {
  public function format_upcase_c(vec<string> $_)[]: string;
  public function format_upcase_d(vec<\HTL\SqlQueryf\OpaqueInt> $_)[]: string;
  public function format_upcase_s(
    vec<\HTL\SqlQueryf\OpaqueString> $_,
  )[]: string;
  public function format_b(vec<bool> $_)[]: string;
  public function format_d(vec<int> $_)[]: string;
  public function format_e(vec<\HTL\SqlQueryf\AnyEnum> $_)[]: string;
  public function format_f(vec<float> $_)[]: string;
  public function format_s(vec<string> $_)[]: string;
  public function format_0x26()[]: SqlWithUpperLWithAmpersand;
  public function format_0x2c()[]: SqlWithUpperLWithComma;
  public function format_0x7c()[]: SqlWithUpperLWithPipe;
}

interface SqlWithUpperLWithAmpersand {
  public function format_q(vec<\HTL\SqlQueryf\QueryPack> $_)[]: string;
}

interface SqlWithUpperLWithComma {
  public function format_q(vec<\HTL\SqlQueryf\QueryPack> $_)[]: string;
}

interface SqlWithUpperLWithPipe {
  public function format_q(vec<\HTL\SqlQueryf\QueryPack> $_)[]: string;
}

function engine(
  string $old_format,
  vec<mixed> $old_args,
)[]: (string, vec<mixed>) {
  $new_format = '';
  $new_args = vec[];

  for ($percent = 0, $arg_i = 0, $unseen_part = 0; ; ) {
    $percent = \HH\Lib\Str\search($old_format, '%', $unseen_part);
    $new_format .= \HH\Lib\Str\slice(
      $old_format,
      $unseen_part,
      $percent is nonnull ? $percent - $unseen_part : null,
    );

    if ($percent is null) {
      $consumed_arg_count = \HH\Lib\C\count($old_args);
      invariant(
        $consumed_arg_count === $arg_i,
        'Arguments were not consumed correctly. %d arguments were provided, but %d were consumed',
        $consumed_arg_count,
        $arg_i,
      );
      return tuple($new_format, $new_args);
    }

    if ($old_format[$percent + 1] === '%') {
      $new_format .= '%%';
      $unseen_part = $percent + 2;
      continue;
    }

    $done = false;
    $state = 0;
    for ($char_i = $percent + 1; !$done; ++$char_i) {
      $arg = $old_args[$arg_i] ?? null;
      $char = \ord($old_format[$char_i] ?? '');
      switch ($state) {
        case 0:
          switch ($char) {
            case 0x28: // '('
              $end = \HH\Lib\Str\search($old_format, ')%', $char_i);
              invariant(
                $end is nonnull,
                'Non-terminated embedded literal string found.',
              );
              $text =
                \HH\Lib\Str\slice($old_format, $char_i + 1, $end - $char_i - 1);
              $new_format .= '%s';
              $new_args[] = $text;
              $char_i = $end + 1;
              $done = true;
              break;
            case 0x43: // 'C'
              $new_format .= '%C';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x44: // 'D'
              $new_format .= '%d';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x4b: // 'K'
              $new_format .= '%K';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x51: // 'Q'
              $new_format .= '%Q';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x53: // 'S'
              $new_format .= '%s';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x54: // 'T'
              $new_format .= '%T';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x62: // 'b'
              $arg = $arg |> cast_generated_7a2b2654ad49cb7ee47a8980($$);
              $new_format .= '%d';
              $new_args[] = $arg |> \HTL\SqlQueryf\bool_to_int($$);
              ++$arg_i;
              $done = true;
              break;
            case 0x64: // 'd'
              $new_format .= '%d';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x65: // 'e'
              $new_format .= $arg |> $$ is int ? '%d' : '%s';
              $new_args[] = $arg |> $$;
              ++$arg_i;
              $done = true;
              break;
            case 0x66: // 'f'
              $new_format .= '%f';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x71: // 'q'
              $arg = $arg |> $$ as \HTL\SqlQueryf\QueryPack;
              $new_format .= '%Q';
              $new_args[] = $arg
                |> engine($$->getFormat(), $$->getArguments())
                |> \HTL\SqlQueryf\HipHopLibSqlQueryPack::createWithoutTypechecking_UNSAFE(
                  ...$$
                );
              ++$arg_i;
              $done = true;
              break;
            case 0x73: // 's'
              $new_format .= '%s';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x25: // '%' -> string
              $state = 1;
              break;
            case 0x3d: // '=' -> SqlWithEquals
              $state = 2;
              break;
            case 0x3f: // '?' -> SqlWithQuestion
              $state = 3;
              break;
            case 0x4c: // 'L' -> SqlWithUpperL
              $state = 4;
              break;
            default:
              invariant_violation('Unexpected 0x%x at %d', $char, $char_i);
          }
          break;

        case 1:
          switch ($char) {

            default:
              invariant_violation('Unexpected 0x%x at %d', $char, $char_i);
          }
          break;

        case 2:
          switch ($char) {
            case 0x44: // '=D'
              $new_format .= '%=d';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x53: // '=S'
              $new_format .= '%=s';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x62: // '=b'
              $arg = $arg |> cast_generated_7a2b2654ad49cb7ee47a8980($$);
              $new_format .= '%=d';
              $new_args[] = $arg |> \HTL\SqlQueryf\bool_to_int($$);
              ++$arg_i;
              $done = true;
              break;
            case 0x64: // '=d'
              $new_format .= '%=d';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x65: // '=e'
              $new_format .= $arg |> $$ is int ? '%=d' : '%=s';
              $new_args[] = $arg |> $$;
              ++$arg_i;
              $done = true;
              break;
            case 0x66: // '=f'
              $new_format .= '%=f';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x73: // '=s'
              $new_format .= '%=s';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            default:
              invariant_violation('Unexpected 0x%x at %d', $char, $char_i);
          }
          break;

        case 3:
          switch ($char) {
            case 0x44: // '?D'
              $new_format .= '%d';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x53: // '?S'
              $new_format .= '%s';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x62: // '?b'
              $arg = $arg |> cast_generated_ff01216ead153d988989ed5e($$);
              $new_format .= '%d';
              $new_args[] =
                $arg |> $$ is null ? null : \HTL\SqlQueryf\bool_to_int($$);
              ++$arg_i;
              $done = true;
              break;
            case 0x64: // '?d'
              $new_format .= '%d';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x65: // '?e'
              $new_format .= $arg |> $$ is int ? '%d' : '%s';
              $new_args[] = $arg |> $$;
              ++$arg_i;
              $done = true;
              break;
            case 0x66: // '?f'
              $new_format .= '%f';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x73: // '?s'
              $new_format .= '%s';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x3d: // '?=' -> SqlWithQuestionWithEquals
              $state = 5;
              break;
            default:
              invariant_violation('Unexpected 0x%x at %d', $char, $char_i);
          }
          break;

        case 4:
          switch ($char) {
            case 0x43: // 'LC'
              $new_format .= '%LC';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x44: // 'LD'
              $new_format .= '%Ld';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x53: // 'LS'
              $new_format .= '%Ls';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x62: // 'Lb'
              $arg = $arg |> cast_generated_10c116dbb756318c8d6376e9($$);
              $new_format .= '%Ld';
              $new_args[] =
                $arg |> \HH\Lib\Vec\map($$, \HTL\SqlQueryf\bool_to_int<>);
              ++$arg_i;
              $done = true;
              break;
            case 0x64: // 'Ld'
              $new_format .= '%Ld';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x65: // 'Le'
              $arg = $arg |> $$ as vec<_>;
              $new_format .= $arg |> ($$[0] ?? '') is string ? '%Ls' : '%Ld';
              $new_args[] = $arg |> $$;
              ++$arg_i;
              $done = true;
              break;
            case 0x66: // 'Lf'
              $new_format .= '%Lf';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x73: // 'Ls'
              $new_format .= '%Ls';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x26: // 'L&' -> SqlWithUpperLWithAmpersand
              $state = 6;
              break;
            case 0x2c: // 'L,' -> SqlWithUpperLWithComma
              $state = 7;
              break;
            case 0x7c: // 'L|' -> SqlWithUpperLWithPipe
              $state = 8;
              break;
            default:
              invariant_violation('Unexpected 0x%x at %d', $char, $char_i);
          }
          break;

        case 5:
          switch ($char) {
            case 0x44: // '?=D'
              $new_format .= '%=d';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x53: // '?=S'
              $new_format .= '%=s';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x62: // '?=b'
              $arg = $arg |> cast_generated_ff01216ead153d988989ed5e($$);
              $new_format .= '%=d';
              $new_args[] =
                $arg |> $$ is null ? null : \HTL\SqlQueryf\bool_to_int($$);
              ++$arg_i;
              $done = true;
              break;
            case 0x64: // '?=d'
              $new_format .= '%=d';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x65: // '?=e'
              $new_format .= $arg |> $$ is int ? '%=d' : '%=s';
              $new_args[] = $arg |> $$;
              ++$arg_i;
              $done = true;
              break;
            case 0x66: // '?=f'
              $new_format .= '%=f';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            case 0x73: // '?=s'
              $new_format .= '%=s';
              $new_args[] = $arg;
              ++$arg_i;
              $done = true;
              break;
            default:
              invariant_violation('Unexpected 0x%x at %d', $char, $char_i);
          }
          break;

        case 6:
          switch ($char) {
            case 0x71: // 'L&q'
              $arg as vec<_>;
              $new_format .= \HH\Lib\C\count($arg)
                |> \HH\Lib\Vec\fill($$, '%Q')
                |> \HH\Lib\Str\join($$, ' AND ');
              foreach ($arg as $pack) {
                $pack as \HTL\SqlQueryf\QueryPack;
                $new_args[] = engine($pack->getFormat(), $pack->getArguments())
                  |> \HTL\SqlQueryf\HipHopLibSqlQueryPack::createWithoutTypechecking_UNSAFE(
                    ...$$
                  );
              }
              ++$arg_i;
              $done = true;
              break;
            default:
              invariant_violation('Unexpected 0x%x at %d', $char, $char_i);
          }
          break;

        case 7:
          switch ($char) {
            case 0x71: // 'L,q'
              $arg as vec<_>;
              $new_format .= \HH\Lib\C\count($arg)
                |> \HH\Lib\Vec\fill($$, '%Q')
                |> \HH\Lib\Str\join($$, ', ');
              foreach ($arg as $pack) {
                $pack as \HTL\SqlQueryf\QueryPack;
                $new_args[] = engine($pack->getFormat(), $pack->getArguments())
                  |> \HTL\SqlQueryf\HipHopLibSqlQueryPack::createWithoutTypechecking_UNSAFE(
                    ...$$
                  );
              }
              ++$arg_i;
              $done = true;
              break;
            default:
              invariant_violation('Unexpected 0x%x at %d', $char, $char_i);
          }
          break;

        case 8:
          switch ($char) {
            case 0x71: // 'L|q'
              $arg as vec<_>;
              $new_format .= \HH\Lib\C\count($arg)
                |> \HH\Lib\Vec\fill($$, '%Q')
                |> \HH\Lib\Str\join($$, ' OR ');
              foreach ($arg as $pack) {
                $pack as \HTL\SqlQueryf\QueryPack;
                $new_args[] = engine($pack->getFormat(), $pack->getArguments())
                  |> \HTL\SqlQueryf\HipHopLibSqlQueryPack::createWithoutTypechecking_UNSAFE(
                    ...$$
                  );
              }
              ++$arg_i;
              $done = true;
              break;
            default:
              invariant_violation('Unexpected 0x%x at %d', $char, $char_i);
          }
          break;
        default:
          invariant_violation('unreachable');
      }
    }

    $unseen_part = $char_i;
  }
}

function cast_generated_7a2b2654ad49cb7ee47a8980(
  mixed $htl_untyped_variable,
)[]: bool {
  return $htl_untyped_variable as bool;
}

function cast_generated_ff01216ead153d988989ed5e(
  mixed $htl_untyped_variable,
)[]: ?bool {
  return $htl_untyped_variable as ?bool;
}

function cast_generated_10c116dbb756318c8d6376e9(
  mixed $htl_untyped_variable,
)[]: vec<bool> {
  $out__1 = vec[];
  foreach (($htl_untyped_variable as vec<_>) as $v__1) {
    $out__1[] = $v__1 as bool;
  }
  return $out__1;
}
