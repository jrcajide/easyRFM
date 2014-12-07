#'Pretty breaks
#'
#'
#'@export
rfm_pretty_breaks <- function(breaks) {
  digits <- floor(log10(breaks))
  Map(function(break_, digit) {
    if(digit <= 0) {
      round(break_)
    } else {
      base <- 10 ^ (digit - 1)
      round(break_ / base) * base
    }
  }, breaks, digits) %>% unlist
}
