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
  
  is.Date <- function(x) is(x, "Date")
  is.POSIXlt <- function(x) is(x, "POSIXlt")
  
  if(!missing(date_format) && is.character(data[,date]))
    data[,date] <- strptime(data[,date], format = date_format, tz = tz) %>% as.POSIXct
  if(is.Date(data[,date]))
    data[,date] <- as.character(data[,date])
  if(is.character(data[,date]) || is.POSIXlt(data[,date]))
    data[,date] <- as.POSIXct(data[,date], tz = tz)
  
  dots <- list(sprintf("max(%s)", date), ~n(), sprintf("sum(%s)", payment))
  rfm <- data %>%
    group_by_(.dots = id) %>%
    summarise_(.dots = dots %>% setNames(c("Recency", "Frequency", "Monetary")))
  
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
  
  rfm <- rfm %>% mutate(RecencyClass=r, FrequencyClass=f, MonetaryClass=m) %>% 
    data.frame
                 
  r_breaks_date <- as.Date(r_breaks, tz=tz)
  r_breaks_days <- difftime(max(r_breaks_date), r_breaks_date, units="days")
  r_class_days <- paste(upper_breaks(r_breaks_days), r_breaks_days[-1], sep=to_text)
  
  rf_table <- table(Recency=r, Frequency=f)
  fr_table <- table(Frequency=f, Recency=r)
  fm_table <- table(Frequency=f, Monetary=m)
  mf_table <- table(Monetary=m, Frequency=f)
  mr_table <- table(Monetary=m, Recency=r)
  rm_table <- table(Recency=r, Monetary=m)
  
  get_table <- function(type=c("RF", "FR", "FM", "MF", "MR", "RM"), 
                        R_slice, F_slice, M_slice) {
    type <- match.arg(type)
    d <- get_sliced_rfm(R_slice=R_slice, F_slice=F_slice, M_slice=M_slice)
    
    r <- cut(d$Recency,   r_breaks, include.lowest=TRUE) %>% as.numeric
    f <- cut(d$Frequency, f_breaks, include.lowest=TRUE) %>% as.numeric
    m <- cut(d$Monetary,  m_breaks, include.lowest=TRUE) %>% as.numeric
    tbl <- switch(type, 
                  "RF"=table(Recency=r, Frequency=f),
                  "FR"=table(Frequency=f, Recency=r),
                  "FM"=table(Frequency=f, Monetary=m),
                  "MF"=table(Monetary=m, Frequency=f),
                  "MR"=table(Monetary=m, Recency=r),
                  "RM"=table(Recency=r, Monetary=m))
    row_names <- switch(type,
                        "RF"=r_class_days, "FR"=f_class,
                        "FM"=f_class,      "MF"=m_class,
                        "MR"=m_class,      "RM"=r_class_days)
    col_names <- switch(type,
                        "RF"=f_class,      "FR"=r_class_days,
                        "FM"=m_class,      "MF"=f_class,
                        "MR"=r_class_days, "RM"=m_class)
    
    dummy_table <- switch(type,
                          "RF"=rf_table, "FR"=fr_table,
                          "FM"=fm_table, "MF"=mf_table,
                          "MR"=mr_table, "RM"=rm_table)
    dummy_table[] <- 0
    
    for(row_name in rownames(tbl)) {
      for(col_name in colnames(tbl)) {
        dummy_table[row_name, col_name] <- tbl[row_name, col_name]
      }
    }
    
    tbl <- dummy_table
    rownames(tbl) <- row_names
    colnames(tbl) <- col_names
    tbl    
  }
  
  get_sliced_rfm <- function(R_slice, F_slice, M_slice) {
    d <- rfm
    if(!missing(R_slice)) {
      d <- d %>% filter(RecencyClass %in% R_slice)
    }
    if(!missing(F_slice)) {
      d <- d %>% filter(FrequencyClass %in% F_slice)
    }
    if(!missing(M_slice)) {
      d <- d %>% filter(MonetaryClass %in% M_slice)
    }
    d
  }
  
  list(rfm=rfm, 
       breaks=list(recency_breaks=r_breaks, recency_breaks_days=r_breaks_days,
                   frequency_breaks=f_breaks, monetary_breaks=m_breaks),
       classes=list(recency_class=r_class, recency_class_days=r_class_days,
                    frequency_class=f_class, monetary_class=m_class),
       get_table=get_table, get_sliced_rfm=get_sliced_rfm)
}
