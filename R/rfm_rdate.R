#'Generate random Date sequence
#'
#'
#'@export
rfm_rdate <- function(n, begin=as.Date("2014-12-01"), end=as.Date("2015-01-01"),
                      by="days", tz=Sys.timezone()) {
  if(is.character(begin)) begin <- as.Date(begin, tz=tz)
  if(is.character(end)) end <- as.Date(end, tz=tz)
  date_seq <- seq(begin, end - 1, by=by)
  sample(date_seq, size = n, replace = TRUE)
}
