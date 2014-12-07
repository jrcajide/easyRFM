#'Automatic RFM amalysis
#'
#'@export
rfm_auto <- function(data, id="id", payment="payment", date="date", breaks=c(r=5, f=5, m=5), to_text=" to ") {
  if(is.list(breaks)) {
    breaks <- c(r=breaks[["r"]], f=breaks[["f"]], m=breaks[["m"]])
  } else if(is.vector(breaks) && is.numeric(breaks)) {
    if(length(breaks) == 1) {
      breaks <- c(r=breaks, f=breaks, m=breaks)
    } else {
      breaks <- c(r=unname(breaks["r"]), f=unname(breaks["f"]), m=unname(breaks["m"]))
    }
  }
  if(length(breaks) != 3) stop()
  
  dots <- list(sprintf("max(%s)", date), ~n(), sprintf("sum(%s)", payment))
  rfm <- data %>% 
    group_by_(.dots = id) %>%
    summarise_(.dots = setNames(dots, c("Recency", "Frequency", "Monetary")))
  
  r_breaks <- rfm_compute_breaks(rfm$Recency,   breaks["r"])
  f_breaks <- rfm_compute_breaks(rfm$Frequency, breaks["f"])
  m_breaks <- rfm_compute_breaks(rfm$Monetary,  breaks["m"])
  
  lower_breaks <- function(breaks) {
    c(breaks[1], breaks[-c(1,length(breaks))] + 1)
  }
  
  r_class <- paste(lower_breaks(r_breaks), r_breaks[-1], sep=to_text)
  f_class <- Map(function(upper, count) ifelse(count == 1, upper, paste(upper - count + 1, upper, sep=to_text)) , f_breaks[-1], diff(f_breaks)) %>% unlist
  m_class <- paste(lower_breaks(m_breaks), m_breaks[-1], sep=to_text)
  
  r <- cut(rfm$Recency,   r_breaks) %>% as.numeric
  f <- cut(rfm$Frequency, f_breaks) %>% as.numeric
  m <- cut(rfm$Monetary,  m_breaks) %>% as.numeric
  
  list(rfm=data.frame(rfm, RecencyClass=r, FrequencyClass=f, MonetaryClass=m), 
       recency_breaks=r_breaks, frequency_breaks=f_breaks, monetary_breaks=m_breaks,
       recency_class=r_class, frequency_class=f_class, monetary_class=m_class)
}
