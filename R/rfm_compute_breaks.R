#'Compute breaks
#'
#'@export
rfm_compute_breaks <- function(values, break_num=5) {
  step = 1 / break_num
  breaks <- quantile(values, probs = seq(0, 1, step))
  breaks <- unname(breaks)
  if(length(breaks) == length(unique(breaks))) return(breaks)
  min_value <- min(values)
  next_values <- Filter(function(x) x != min_value, values)
  next_breaks <- rfm_compute_breaks(next_values, break_num = break_num - 1)
  min_value <- max(1, min_value)
  unname(c(min_value - 1, next_breaks))
}
