context("Test for rfm_auto()")

test_that("deafult", {
  data <- rfm_generate_data(10, seed=123)
  rfm <- rfm_auto(data, breaks=list(r=2, f=2, m=2))
  with(rfm$breaks, {
    expect_equal(recency_breaks, as.POSIXct(c("2014-12-10 JST","2014-12-22 JST","2015-01-01 JST")))
    expect_equal(recency_breaks_days, as.difftime(c(22, 10, 0), units="days"))
    expect_equal(frequency_breaks, c(0, 2, 4))
    expect_equal(monetary_breaks, c(3800, 8700, 17000))
  })
})

test_that("input factor date", {
  data <- rfm_generate_data(10, seed=123)
  data <- transform(data, date=as.factor(date))
  rfm <- rfm_auto(data, breaks=list(r=2, f=2, m=2))
  expect_equal(1, 1)
})
