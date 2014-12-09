# easyRFM - An easy way to RFM analysis by R
Koji MAKIYAMA  



## Overview

About RFM analysis:

- [RFM (customer value) - Wikipedia](http://en.wikipedia.org/wiki/RFM_%28customer_value%29)

> RFM is a method used for analyzing customer value. It is commonly used in database marketing and direct marketing and has received particular attention in retail and professional services industries.
> 
> RFM stands for
>
> - Recency - How recently did the customer purchase?
> - Frequency - How often do they purchase?
> - Monetary Value - How much do they spend?

First, ready transaction data like below:




```r
head(data)
```

```
  id payment       date
1  1    1710 2014-12-23
2  2    6130 2014-12-31
3  2    2870 2014-12-19
4  2     440 2014-12-27
5  3    2080 2014-12-28
6  3    8220 2014-12-18
```

The "id" means user ID, the "payment" means a payment for purchase and the "date" means a purchase date.

Then you can execute RFM analysis by a simple command:


```r
result <- rfm_auto(data)
```

The result contains three components.

`result$rfm` is which class each user was assigned.


```r
head(result$rfm)
```

```
  id    Recency Frequency Monetary RecencyClass FrequencyClass
1  1 2014-12-23         1     1710            3              1
2  2 2014-12-31         3     9440            5              3
3  3 2014-12-28         2    10300            4              2
4  4 2014-12-28         4    14360            4              4
5  5 2014-12-15         4     6820            2              4
6  7 2014-12-25         2     5430            4              2
  MonetaryClass
1             1
2             4
3             4
4             5
5             3
6             2
```

`result$breaks` is the breaks for each classes.


```r
result$breaks
```

```
$recency_breaks
[1] "2014-12-01 JST" "2014-12-14 JST" "2014-12-21 JST" "2014-12-25 JST"
[5] "2014-12-29 JST" "2015-01-01 JST"

$recency_breaks_days
Time differences in days
[1] 31 18 11  7  3  0

$frequency_breaks
[1] 0 1 2 3 5 8

$monetary_breaks
[1]   120  3600  6100  9100 14000 38000
```

`result$classes` is the ranges for each classes.


```r
result$classes
```

```
$recency_class
[1] "2014-12-01 00:00:00 to 2014-12-14" "2014-12-14 00:00:01 to 2014-12-21"
[3] "2014-12-21 00:00:01 to 2014-12-25" "2014-12-25 00:00:01 to 2014-12-29"
[5] "2014-12-29 00:00:01 to 2015-01-01"

$recency_class_days
[1] "31 to 18" "17 to 11" "10 to 7"  "6 to 3"   "2 to 0"  

$frequency_class
[1] "1"      "2"      "3"      "4 to 5" "6 to 8"

$monetary_class
[1] "120 to 3600"    "3601 to 6100"   "6101 to 9100"   "9101 to 14000" 
[5] "14001 to 38000"
```

`result$tables`


```r
result$tables
```

```
$recency_frequecy_table
          Frequency
Recency      1   2   3 4 to 5 6 to 8
  31 to 18 120  43   8      6      0
  17 to 11  65  72  38     14      0
  10 to 7   43  56  42     27      2
  6 to 3    31  56  48     42      6
  2 to 0    18  47  41     34      9

$frequency_monetary_table
         Monetary
Frequency 120 to 3600 3601 to 6100 6101 to 9100 9101 to 14000
   1              147           76           39            13
   2               29           77           88            63
   3                0           21           33            75
   4 to 5           0            1           10            29
   6 to 8           0            0            0             1
         Monetary
Frequency 14001 to 38000
   1                   2
   2                  17
   3                  48
   4 to 5             83
   6 to 8             16

$monetary_recency_table
                Recency
Monetary         31 to 18 17 to 11 10 to 7 6 to 3 2 to 0
  120 to 3600          70       38      29     26     13
  3601 to 6100         46       47      34     24     24
  6101 to 9100         31       32      40     35     32
  9101 to 14000        22       46      38     46     29
  14001 to 38000        8       26      29     52     51
```

## How to install


```r
install.packages("devtools") # if you have not installed "devtools" package
devtools::install_github("hoxo-m/easyRFM")
```

## Try it with sample data

easyRFM package provide `rfm_generate_data()` function towords to generate sample data for `rfm_auto()`:


```r
data <- rfm_generate_data()
head(data)
```

```
  id payment       date
1  1    9790 2014-12-10
2  1    1080 2014-12-23
3  2    1150 2014-12-05
4  2    6050 2014-12-23
5  2    2380 2014-12-24
6  2    4310 2014-12-21
```

Try `rfm_auto()` and look over the result:


```r
result <- rfm_auto(data)
```

## How to input to rfm_auto()

If your data have different column names from default: "id", "payment" and "date", for example:




```r
head(data)
```

```
  user_id payment purchase_date
1       1    1710    2014-12-23
2       2    6130    2014-12-31
3       2    2870    2014-12-19
4       2     440    2014-12-27
5       3    2080    2014-12-28
6       3    8220    2014-12-18
```

You can indicate the column names:


```r
result <- rfm_auto(data, id="user_id", payment="payment", date="purchase_date")
```

If your data have different date format from default: "yyyy-mm-dd", for example:




```r
head(data)
```

```
  id payment       date
1  1    1710 2014/12/23
2  2    6130 2014/12/31
3  2    2870 2014/12/19
4  2     440 2014/12/27
5  3    2080 2014/12/28
6  3    8220 2014/12/18
```

You can indicate date format:


```r
result <- rfm_auto(data, date_format = "%Y/%m/%d")
```

For more information for date_format, see [Date-time Conversion Functions to and from Character](http://stat.ethz.ch/R-manual/R-patched/library/base/html/strptime.html).

You can use datetime object(POSIXlt or POSIXct) instead of date, for example:




```r
head(data)
```

```
  id payment                date
1  1    1710 2014/12/23 00:18:23
2  2    6130 2014/12/31 17:26:00
3  2    2870 2014/12/19 05:28:46
4  2     440 2014/12/27 16:58:33
5  3    2080 2014/12/28 10:54:42
6  3    8220 2014/12/18 02:28:57
```


```r
result <- rfm_auto(data, date_format = "%Y/%m/%d %H:%M:%S")
```
