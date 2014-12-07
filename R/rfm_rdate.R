#'Generate random Date sequence
#'
#'
#'@export
rfm_rdate <- function(n, begin=as.Date("2014-12-01"), end=as.Date("2014-12-31"),
                      by="days") {
  if(is.character(begin)) begin <- as.Date(begin)
  if(is.character(end)) end <- as.Date(end)  
  date_seq <- seq(begin, end, by=by)
  sample(date_seq, size = n, replace = TRUE)
}
