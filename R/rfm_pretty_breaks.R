#'Pretty breaks
#'
#'
#'@export
rfm_pretty_breaks <- function(breaks) {
  digits <- floor(log10(breaks))
  head <- ifelse(digits[1] <= 0, floor(breaks[1]), {
    base <- 10 ^ (digits[1] - 1)
    floor(breaks[1] / base) * base
  })
  tail <- Map(function(break_, digit) {
    if(digit <= 0) {
      ceiling(break_)
    } else {
      base <- 10 ^ (digit - 1)
      ceiling(break_ / base) * base
    }
  }, breaks[-1], digits[-1]) %>% unlist
  c(head, tail)
}
