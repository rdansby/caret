timestamp <- Sys.time()
library(caret)

model <- "deepboost"

#########################################################################

set.seed(2)
training <- twoClassSim(50, linearVars = 2)
testing <- twoClassSim(500, linearVars = 2)
trainX <- training[, -ncol(training)]
trainY <- training$Class

cctrl1 <- trainControl(method = "cv", number = 3, returnResamp = "all")
cctrl2 <- trainControl(method = "LOOCV")
cctrl3 <- trainControl(method = "none")
cctrlR <- trainControl(method = "cv", number = 3, returnResamp = "all", search = "random")

set.seed(849)
test_class_cv_model <- train(trainX, trainY, 
                             method = "deepboost", 
                             trControl = cctrl1,
                             preProc = c("center", "scale"),
                             verbose = FALSE)

set.seed(849)
test_class_cv_form <- train(Class ~ ., data = training, 
                            method = "deepboost", 
                            trControl = cctrl1,
                            preProc = c("center", "scale"),
                            verbose = FALSE)

test_class_pred <- predict(test_class_cv_model, testing[, -ncol(testing)])
test_class_pred_form <- predict(test_class_cv_form, testing[, -ncol(testing)])

set.seed(849)
test_class_rand <- train(trainX, trainY, 
                         method = "deepboost", 
                         trControl = cctrlR,
                         tuneLength = 4,
                         verbose = FALSE)

set.seed(849)
test_class_loo_model <- train(trainX, trainY, 
                              method = "deepboost", 
                              trControl = cctrl2,
                              preProc = c("center", "scale"),
                              verbose = FALSE)

set.seed(849)
test_class_none_model <- train(trainX, trainY, 
                               method = "deepboost", 
                               trControl = cctrl3,
                               tuneGrid = test_class_cv_model$bestTune,
                               preProc = c("center", "scale"),
                               verbose = FALSE)

test_class_none_pred <- predict(test_class_none_model, testing[, -ncol(testing)])

test_levels <- levels(test_class_cv_model)
if(!all(levels(trainY) %in% test_levels))
  cat("wrong levels")

#########################################################################

test_class_imp <- varImp(test_class_cv_model)

#########################################################################

tests <- grep("test_", ls(), fixed = TRUE, value = TRUE)

sInfo <- sessionInfo()
timestamp_end <- Sys.time()

save(list = c(tests, "sInfo", "timestamp", "timestamp_end"),
     file = file.path(getwd(), paste(model, ".RData", sep = "")))

q("no")


