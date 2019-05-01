# Capturing and saving output
# Answering this issue from GitHub:
#   - https://github.com/USGS-R/hypeRusgs/issues/21

# First functions I thought of, but they don't get the commands
?sink
?capture.output

# There is a package that does keep the commands
# You can use ?txtStart at the very beginning of your script
# And then add ?txtStop at the very end
# See variations below

library(TeachingDemos)

# Commands + output is the default
txtStart("Webinar-5-1-2019/output/captured_model_run.txt")
max(1:10)
x <- seq(0,20,4)
txtStop()

# Just commands
txtStart("Webinar-5-1-2019/output/captured_commands.txt", results=FALSE)
max(1:10)
x <- seq(0,20,4)
txtStop()

# Just output
txtStart("Webinar-5-1-2019/output/captured_output.txt", commands=FALSE)
max(1:10)
x <- seq(0,20,4)
txtStop()
