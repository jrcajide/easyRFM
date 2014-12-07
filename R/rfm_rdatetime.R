#'Generate random dateteime sequence
#'
#'
#'@export
rfm_rdatetime <- function(n, begin=as.POSIXct("2014-12-01", tz=Sys.timezone()), 
                          end=as.POSIXct("2014-12-31", tz=Sys.timezone())) {
  datetime_seq <- seq(begin, end, by="sec")
  sample(datetime_seq, size = n, replace = TRUE)
}
