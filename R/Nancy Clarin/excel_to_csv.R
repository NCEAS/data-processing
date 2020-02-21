slx <- read_excel("/home/clarinnancy/tickets/Hamilton2016/Alaska_place_time_16b (1).xls")
slx <- as.data.frame(slx)
write.csv(slx,"/home/clarinnancy/tickets/Hamilton2016/alaska_place_time.csv", row.names = FALSE)