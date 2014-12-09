#'Automatic RFM amalysis
#'
#'@examples
#'data <- rfm_generate_data(date_type = "POSIXct")
#'result <- rfm_auto(data)
#'result
#'
#'@export
rfm_auto <- function(data, id="id", payment="payment", date="date", 
                     breaks=c(r=5, f=5, m=5), date_format, 
                     to_text=" to ", exact=FALSE, tz=Sys.timezone()) {
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
  
  if(!missing(date_format) && is.character(data[,date]))
    data[,date] <- strptime(data[,date], format = format, tz = tz)
  
  dots <- list(sprintf("max(%s)", date), ~n(), sprintf("sum(%s)", payment))
  rfm <- data %>% 
    mutate(date=as.POSIXct(date %>% as.character, tz=tz)) %>%
    group_by_(.dots = id) %>%
    summarise_(.dots = setNames(dots, c("Recency", "Frequency", "Monetary")))
  
  r_breaks <- rfm_compute_breaks(rfm$Recency,   breaks["r"])
  f_breaks <- rfm_compute_breaks(rfm$Frequency, breaks["f"])
  m_breaks <- rfm_compute_breaks(rfm$Monetary,  breaks["m"])
  
  max_date <- max(r_breaks)
  if(!exact) {
    r_breaks_date <- r_breaks %>% as.Date(tz=tz)
    r_breaks_date <- c(r_breaks_date[1], Map(function(d) d+1, r_breaks_date[-1]) %>% unlist)
    r_breaks <- r_breaks_date %>% as.character %>% as.POSIXct(tz=tz)
    f_breaks <- rfm_pretty_breaks(f_breaks)
    m_breaks <- rfm_pretty_breaks(m_breaks)
  }
  
  lower_breaks <- function(breaks) {
    c(breaks[1], breaks[-c(1,length(breaks))] + 1)
  }

  upper_breaks <- function(breaks) {
    c(breaks[1], breaks[-c(1,length(breaks))] - 1)
  }
  
  r_class <- paste(lower_breaks(r_breaks), r_breaks[-1], sep=to_text)
  f_class <- Map(function(upper, count) {
      ifelse(count == 1, upper, paste(upper - count + 1, upper, sep=to_text)) 
    }, f_breaks[-1], diff(f_breaks)) %>% unlist
  m_class <- paste(lower_breaks(m_breaks), m_breaks[-1], sep=to_text)
  
  r <- cut(rfm$Recency,   r_breaks, include.lowest=TRUE) %>% as.numeric
  f <- cut(rfm$Frequency, f_breaks, include.lowest=TRUE) %>% as.numeric
  m <- cut(rfm$Monetary,  m_breaks, include.lowest=TRUE) %>% as.numeric
  
  r_breaks_date <- as.Date(r_breaks, tz=tz)
  r_breaks_days <- difftime(max(r_breaks_date), r_breaks_date, units="days")
  r_class_days <- paste(upper_breaks(r_breaks_days), r_breaks_days[-1], sep=to_text)
  
  rf_table <- table(Recency=r, Frequency=f)
  fm_table <- table(Frequency=f, Monetary=m)
  mr_table <- table(Monetary=m, Recency=r)
  rownames(rf_table) <- r_class_days
  colnames(rf_table) <- f_class
  rownames(fm_table) <- f_class
  colnames(fm_table) <- m_class
  rownames(mr_table) <- m_class
  colnames(mr_table) <- r_class_days
  
  list(rfm=data.frame(rfm, RecencyClass=r, FrequencyClass=f, MonetaryClass=m), 
       breaks=list(recency_breaks=r_breaks, recency_breaks_days=r_breaks_days,
                   frequency_breaks=f_breaks, monetary_breaks=m_breaks),
       classes=list(recency_class=r_class, recency_class_days=r_class_days,
                    frequency_class=f_class, monetary_class=m_class),
       tables=list(recency_frequecy_table=rf_table,
                   frequency_monetary_table=fm_table,
                   monetary_recency_table=mr_table))
}
