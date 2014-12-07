#'Generate sample data for RFM analysis
#'
#'
#'@export
rfm_generate_data <- function(id_num=1000, 
                              date_type=c("char", "Date", "POSIXct", "POSIXlt"),
                              seed, ...) {
  date_type <- match.arg(date_type)
  if(!missing(seed)) set.seed(seed)
  data <- data.frame(id=seq_len(id_num), count=rpois(id_num, lambda = 2))
  ids <- apply(data, 1, function(x) rep(x[["id"]], x[["count"]])) %>% unlist
  n <- length(ids)
  payment <- round(rgamma(n, shape = 2, scale = 2) * 100) * 10
  if(date_type == "char") {
    date <- rfm_rdate(n, ...) %>% as.character
  } else if(date_type == "Date") {
    date <- rfm_rdate(n, ...)
  } else if(date_type == "POSIXlt"){
    date <- rfm_rdatetime(n, ...) %>% as.POSIXlt
  } else if(date_type == "POSIXct") {
    date <- rfm_rdatetime(n, ...)
  }
  
  data.frame(id=ids, payment=payment, date=date)
}
