#'Generate sample data for RFM analysis
#'
#'
#'@export
rfm_generate_data <- function(id.num=100, 
                              date=c("char", "Date", "POSIXct", "POSIXlt"),
                              seed, ...) {
  date <- match.arg(date)
  if(!missing(seed)) set.seed(seed)
  data <- data.frame(id=seq_len(id.num), count=rpois(id.num, lambda = 2))
  ids <- apply(data, 1, function(x) rep(x[["id"]], x[["count"]])) %>% unlist
  n <- length(ids)
  payment <- round(rgamma(n, shape = 2, scale = 2) * 100) * 10
  if(date == "char") {
    date <- rfm_rdate(n, ...) %>% as.character
  } else if(date == "Date") {
    date <- rfm_rdate(n, ...)
  } else if(date == "POSIXlt"){
    date <- rfm_rdatetime(n, ...) %>% as.POSIXlt
  } else if(date == "POSIXct") {
    date <- rfm_rdatetime(n, ...)
  }
  
  data.frame(id=ids, payment=payment, date=date)
}
