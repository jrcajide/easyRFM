#'Compute breaks
#'
#'@export
rfm_compute_breaks <- function(values, break_num=5) {
  breaks <- quantile(values, probs = seq(0, 1, length.out = break_num + 1))
  if(break_num == 2 && is.integer(values)) {
    min_value <- min(values)
    max_value <- max(values)
    for(i in min_value:(max_value-1)) {
      breaks <- c(min_value-1, i, max_value)
      tbl <- table(cut(values, breaks))
      if(tbl[1] > tbl[2]) break
    }
    return(breaks)
  }
  breaks <- unname(breaks)
  if(length(breaks) == length(unique(breaks))) return(breaks)
  min_value <- min(values)
  next_values <- Filter(function(x) x != min_value, values)
  next_breaks <- rfm_compute_breaks(next_values, break_num = break_num - 1)
  min_value <- max(1, min_value)
  unname(c(min_value - 1, next_breaks))
}
