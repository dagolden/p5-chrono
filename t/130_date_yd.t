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
    my ($y, $m, $d, $doy) = split /,\s*/, $_;

    my $exp = sprintf '%.4d-%.2d-%.2d', $y, $m, $d;

    {
        my $date = Chrono::Date->from_yd($y, $doy);
        my $from = "->from_yd($y, $doy)";
        is($date->year,         $y,   "$from->year");
        is($date->month,        $m,   "$from->month");
        is($date->day_of_month, $d,   "$from->day_of_month");
        is($date->day_of_year,  $doy, "$from->day_of_year");
        is($date->to_string,    $exp, "$from->to_string");
        is_deeply([$date->to_yd], [$y, $doy], "$from->to_yd");
    }

    {
        my $date = Chrono::Date->from_ymd($y, $m, $d);
        my $from = "->from_ymd($y, $m, $d)";
        is($date->day_of_year, $doy, "$from->day_of_year");
    }
}

done_testing;

__DATA__
1020,  5, 27, 148
1030,  5,  3, 123
1056,  8,  1, 214
1059,  4, 30, 120
1089,  7, 17, 198
1091, 12, 22, 356
1091,  5, 19, 139
1092,  4, 20, 111
1097,  7,  3, 184
1110,  7, 30, 211
1111,  9,  8, 251
1115, 11, 12, 316
1130,  1, 29,  29
1131, 11, 16, 320
1147, 10, 14, 287
1149,  4, 13, 103
1158,  7, 22, 203
1173,  4, 26, 116
1174,  3, 29,  88
1177,  6,  6, 157
1190,  8,  1, 213
1191,  8, 23, 235
1194,  7, 18, 199
1203,  9,  3, 246
1206,  2,  1,  32
1218,  8, 28, 240
1218,  9, 20, 263
1243, 10, 20, 293
1257,  8, 17, 229
1267, 11, 24, 328
1283,  2,  2,  33
1291,  9, 15, 258
1294,  9, 27, 270
1319,  7, 31, 212
1330, 10, 30, 303
1353,  3, 28,  87
1359,  6,  5, 156
1384,  2, 23,  54
1399,  2,  9,  40
1440, 11,  7, 312
1455, 10, 18, 291
1459, 10, 16, 289
1470,  3, 25,  84
1480, 12, 25, 360
1482, 12, 14, 348
1493,  1, 21,  21
1519,  6,  1, 152
1525,  4, 20, 110
1632,  7, 28, 210
1669,  8, 12, 224
1671, 10, 15, 288
1683,  3, 24,  83
1685,  1, 14,  14
1698,  3, 13,  72
1719,  4, 29, 119
1720,  5,  5, 126
1722, 11,  4, 308
1751,  4,  9,  99
1764,  6, 21, 173
1778, 10, 22, 295
1785,  7, 17, 198
1786,  9, 16, 259
1795, 12, 19, 353
1796,  4, 14, 105
1808,  7, 21, 203
1809,  6, 25, 176
1814,  8,  2, 214
1823,  4,  7,  97
1829, 11, 29, 333
1844, 10, 16, 290
1861,  3, 16,  75
1867,  3, 14,  73
1892, 11, 23, 328
1943,  9, 19, 262
1950,  2,  8,  39
1980,  1, 24,  24
1981,  2, 24,  55
2002,  6, 12, 163
2022,  8, 16, 228
2025, 11,  2, 306
2050,  8,  1, 213
2056,  8, 19, 232
2064, 10,  6, 280
2064,  2,  5,  36
2074,  5, 30, 150
2077,  1, 26,  26
2077,  8,  3, 215
2081, 11, 17, 321
2086, 12,  1, 335
2126,  3, 24,  83
2146, 10, 30, 303
2155, 11, 19, 323
2163, 11, 15, 319
2168,  7, 17, 199
2173,  6, 29, 180
2174,  9, 24, 267
2175, 10, 21, 294
2190, 11, 30, 334
2193, 11,  1, 305
2198,  4, 18, 108
