# i = identify the scenario 
# code below produce data, analysis and summary for ONE scenario

ss  = Sys.getenv("SLURM_ARRAY_TASK_ID") 
i = as.numeric(ss) + 1

# 0 ) libraries and functions
pkgs <- c('plyr', 'dplyr', 'tidyr', 'ggplot2')
lapply(pkgs, library,  character.only = TRUE, quietly=TRUE )

# inputs
load('targets.Rdata')
source('code.R')

# ==================================================
# 1) Create a dataset, run the analysis and its summary
# 1.1 Create data set and save it
eval( parse(text= paste(datasets$target[i], datasets$command[i], sep=' <- ')  ) )
saveRDS(get(datasets$target[i]) , file = paste('datasets/', datasets$target[i], '.rds', sep='') )

# 1.2 Run all analyses that use this dataset
as <- grep(datasets$target[i], analyses$target) 
for (j in as) {
  eval( parse(text= paste(analyses$target[j], analyses$command[j], sep=' <- ')  ) )
  saveRDS(get(analyses$target[j]), file = paste('analyses/', analyses$target[j], '.rds', sep='') )
}

# 1.2 Run all summaries that use this dataset
sm <- grep(datasets$target[i], summaries$target) 
for (j in sm) {
  eval( parse(text= paste(summaries$target[j], summaries$command[j], sep=' <- ')  ) )
  saveRDS(get(summaries$target[j]) , file = paste('summaries/', summaries$target[j], '.rds', sep='') )
}

# ==================================================
#2) Collect summaries and dataests to produce results
# when i == length(datasets$target) + 1 everithing is done 
#is this true though?? how can I check last job is finished ?
if (i < length(datasets$target) ) {
  rm(list = ls())
} else {
  rm(list = ls() )
  
  # 2.1 gather summaries
  ll.res <- list.files('summaries')
  rr <- list()
  for( k in 1:length(ll.res)) {
    rr[[k]] <- readRDS( paste('summaries/', ll.res[k], sep='') )
  }
  names(rr) <- gsub('.rds', '', ll.res)
  mse <- bind_rows(rr[grep('mse', ll.res)], .id = "info")
  coefs <- bind_rows(rr[grep('coef', ll.res)], .id = "info")
  rm(rr, k)
  
  mse <- mse %>% 
    separate(info, sep='_', into =c('x1', 'an', 'dts', 'rep') ) %>% 
    dplyr::select(-x1)
  coefs <- coefs %>% 
    separate(info, sep='_', into =c('x1', 'an', 'dts', 'rep') ) %>% 
    dplyr::select(-x1)
  
  # Outputs
  save(mse, coefs, file='output/output.Rdata')
  
  write.csv(coefs, file='output/coefs.csv')
  
  p <- mse %>% ggplot() + geom_jitter(aes(y=mse, x=dts, color=an), height=0)
  pdf('output/mse.pdf') 
  print(p)
  dev.off()
}


