# Example of running caret models in parallel

library(caret)
library(gmodels)
library(gbm)
library(doParallel)

# LPlatt changed the dataset to be only 4 
#   columns and randomized based on min & max of those columns.

example_data <- readRDS("Webinar-5-1-2019/data/example_data.rds")

## ------------------------------------------------------------------------

grid <-  expand.grid(n.trees = seq(500,1000,by=500), interaction.depth = c(2,4), shrinkage = c(.008,0.01),n.minobsinnode=seq(8,10,by=2))  ## simple; comment out to use full tuning grid in next statement
head(grid, n=20)  ## prints up to first 20 rows

# the following ensures reproducible results during parallel processing
# modify if you change no. tuning grid rows or no. CV folds
set.seed(714)
seeds <- vector(mode = "list", length = 11) ## length is = (n_repeats*nresampling)+1
for(i in 1:10) seeds[[i]]<- sample.int(n=1000, 8) ## last value is the number of tuning parameters; change accordingly for simple vs. complex above
# for boosted models such as gbm, use levels of interaction.depth X shrinkage X n.minobsinnode to get last value in the preceding line  
seeds[[11]]<-sample.int(1000, 1) ## for the last model
print(seeds)

fitControl <- trainControl(method="repeatedcv",number = 10,repeats = 1,seeds=seeds,returnData=TRUE,verboseIter=FALSE)  ## call seeds from previous step 

## ------------------------------------------------------------------------

# See how long without parallel
# lplatt got ~45 seconds 

system.time({
  Tune <- train(LNNO3~., data=example_data,
                method="gbm",
                bag.fraction=.5,
                distribution = "gaussian",
                metric="RMSE",
                tuneGrid=grid, 
                trControl=fitControl,
                verbose=FALSE)
})

## ------------------------------------------------------------------------
# set up parallel processing - PC version
# library(doParallel) # lplatt moved this to the top

getDoParWorkers() ## shows number available threads, 2 per processor typically
cl <- makeCluster(detectCores()) # setup a cluster using all cores
registerDoParallel(cl) ## register package for use by caret, which has foreach package built-in

# open Windows Task Manager/Performance to see CPU usage for all threads when running model in parallel
# alternatively, set up parallel processing for the Mac
# library(doMC)
# registerDoMC(cores=4)

# run gbm within caret in parallel
# lplatt got ~ 23 seconds
system.time({
  Tune <- train(LNNO3~., data=example_data,
                method="gbm",
                bag.fraction=.5,
                distribution = "gaussian",
                metric="RMSE",
                tuneGrid=grid, 
                trControl=fitControl,
                verbose=FALSE)
})

stopCluster(cl)
