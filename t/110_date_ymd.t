#!perl
use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Chrono::Date');
}

while (<DATA>) {
    next if /\A \# /x;
    chomp;
    my ($y, $m, $d, $dow, $rdn, $cjdn) = split /,\s*/, $_;

    my $exp = sprintf '%.4d-%.2d-%.2d', $y, $m, $d;

    {
        my $date = Chrono::Date->new(year => $y, month => $m, day => $d);
        my $from = "->new(year => $y, month => $m, day => $d)";
        is($date->year,         $y,    "$from->year");
        is($date->month,        $m,    "$from->month");
        is($date->day_of_month, $d,    "$from->day_of_month");
        is($date->day_of_week,  $dow,  "$from->day_of_week");
        is($date->rdn,          $rdn,  "$from->rdn");
        is($date->cjdn,         $cjdn, "$from->cjdn");
        is($date->to_string,    $exp,  "$from->to_string");
    }

    {
        my $date = Chrono::Date->from_ymd($y, $m, $d);
        my $from = "->from_ymd($y, $m, $d)";
        is($date->to_string, $exp, "$from->to_string");
    }

    {
        my $date = Chrono::Date->from_cjdn($cjdn);
        my $from = "->from_cjdn($cjdn)";
        is($date->cjdn,       $cjdn, "$from->cjdn");
        is($date->to_string,  $exp,  "$from->to_string");
    }

    {
        my $date = Chrono::Date->from_rdn($rdn);
        my $from = "->from_rdn($rdn)";
        is($date->rdn,        $rdn,  "$from->rdn");
        is($date->to_string,  $exp,  "$from->to_string");
    }
}

done_testing;

__DATA__
# Test cases extracted from <http://www.merlyn.demon.co.uk/ourdates.txt>
1700,  1, 11, 1, 620558, 2341983
1700,  2, 28, 7, 620606, 2342031
1700,  3,  1, 1, 620607, 2342032
1700,  3, 11, 4, 620617, 2342042
1700,  3, 12, 5, 620618, 2342043
1701,  1, 12, 3, 620924, 2342349
1701,  3, 11, 5, 620982, 2342407
1701,  3, 12, 6, 620983, 2342408
1748,  1, 12, 5, 638090, 2359515
1748,  3, 10, 7, 638148, 2359573
1748,  3, 11, 1, 638149, 2359574
1748,  3, 12, 2, 638150, 2359575
1748,  4,  4, 4, 638173, 2359598
1748,  4,  5, 5, 638174, 2359599
1749,  1, 12, 7, 638456, 2359881
1750,  1, 12, 1, 638821, 2360246
1751,  1, 11, 1, 639185, 2360610
1751,  1, 12, 2, 639186, 2360611
1751,  4,  4, 7, 639268, 2360693
1751,  4,  5, 1, 639269, 2360694
1751,  4, 12, 1, 639276, 2360701
1752,  1, 11, 2, 639550, 2360975
1752,  1, 12, 3, 639551, 2360976
1752,  2, 29, 2, 639599, 2361024
1752,  3,  1, 3, 639600, 2361025
1752,  3, 10, 5, 639609, 2361034
1752,  3, 11, 6, 639610, 2361035
1752,  3, 12, 7, 639611, 2361036
1752,  9, 12, 2, 639795, 2361220
1752,  9, 13, 3, 639796, 2361221
1752,  9, 14, 4, 639797, 2361222
1753,  1,  1, 1, 639906, 2361331
1800,  1,  1, 3, 657072, 2378497
1858, 11, 17, 3, 678576, 2400001
1900,  1,  1, 1, 693596, 2415021
1900,  2, 28, 3, 693654, 2415079
1900,  3,  1, 4, 693655, 2415080
1901,  1,  1, 2, 693961, 2415386
1910,  1,  1, 6, 697248, 2418673
1920,  1,  1, 4, 700900, 2422325
1930,  1,  1, 3, 704553, 2425978
1940,  1,  1, 1, 708205, 2429630
1950,  1,  1, 7, 711858, 2433283
1960,  1,  1, 5, 715510, 2436935
1970,  1,  1, 4, 719163, 2440588
1980,  1,  1, 2, 722815, 2444240
1990,  1,  1, 1, 726468, 2447893
1995, 10, 10, 2, 728576, 2450001
2000,  1,  1, 6, 730120, 2451545
2010,  1,  1, 5, 733773, 2455198
2020,  1,  1, 3, 737425, 2458850
2030,  1,  1, 2, 741078, 2462503
2040,  1,  1, 7, 744730, 2466155
2050,  1,  1, 6, 748383, 2469808
2132,  8, 31, 7, 778575, 2500000
