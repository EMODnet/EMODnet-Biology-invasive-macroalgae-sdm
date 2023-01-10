rm(list=ls())

devtools::install_github("marlonecobos/kuenm")
install.packages('raster')
install.packages('dplyr')
install.packages('BiodiversityR')

library(kuenm)
library(raster)
library(dplyr)
library(BiodiversityR)

#### WORKING DIRECTORY ####
setwd("D:/Proyectos/EMODNET/data")

# Load, filter, downsample and save Undaria pinnatifida occurrences
load("./occurrences.Rda")

Undaria.raw <- occurrences %>% filter(name=="Undaria")
Undaria <- data.frame(ensemble.spatialThin(Undaria.raw[,c("longitude","latitude")], thin.km = 9.2,
                                             runs = 50, silent = FALSE, verbose = FALSE,
                                             return.notRetained = FALSE))

presences <- kuenm_occsplit(Undaria, train.proportion=0.75, save=FALSE)
presences[[1]]$species <- "Undaria"
presences[[1]]<- presences[[1]][,c(3,1,2)]
presences[[2]]$species <- "Undaria"
presences[[2]]<- presences[[2]][,c(3,1,2)]
presences[[3]]$species <- "Undaria"
presences[[3]]<- presences[[3]][,c(3,1,2)]

dir.create("./analysis/kuenm_Undaria", recursive = TRUE)
write.csv(presences[[1]],
          file="./analysis/kuenm_Undaria/Undaria_joint.csv", row.names=FALSE, quote=F)
write.csv(presences[[2]],
          file="./analysis/kuenm_Undaria/Undaria_train.csv", row.names=FALSE, quote=F)
write.csv(presences[[3]],
          file="./analysis/kuenm_Undaria/Undaria_test.csv", row.names=FALSE, quote=F)

# Create sets of variables with a minimum of 5 variables by group
vs <- kuenm_varcomb(var.dir = './derived_data/env/hist',
                    out.dir = './analysis/kuenm_Undaria/M_variables', min.number = 5,
                    in.format = 'ascii', out.format = 'ascii')

# A total of 29 sets of variables resulted from combinations of 7 variables will be written
# Variables with information to be used as arguments
occ_joint <- "./analysis/kuenm_Undaria/Undaria_joint.csv"
occ_tra <- "./analysis/kuenm_Undaria/Undaria_train.csv"
M_var_dir <- "./analysis/kuenm_Undaria/M_variables"
batch_cal <- "./analysis/kuenm_Undaria/Candidate_models"
out_dir <- "./analysis/kuenm_Undaria/Candidate_Models"
reg_mult <- c(seq(0.1, 1, 0.2))
f_clas <- "all"
args <- NULL
maxent_path <- "D:/Proyectos/EMODNET/2_Maxent_3_4_1/maxent"
wait <- FALSE
run <- TRUE
kuenm_cal(occ.joint = occ_joint, occ.tra = occ_tra, M.var.dir = M_var_dir, batch = batch_cal,
          out.dir = out_dir, reg.mult = reg_mult, f.clas = f_clas, args = args,
          maxent.path = maxent_path, wait = wait, run = run)
# A maxent batch file for creating 4495 calibration models has been written

# Models evaluation
#help(kuenm_ceval)
occ_test <- "./analysis/kuenm_Undaria/Undaria_test.csv"
out_eval <- "./analysis/kuenm_Undaria/Calibration_results"
threshold <- 10
rand_percent <- 50
iterations <- 10
kept <- TRUE
selection <- "AICc"
paral_proc <- FALSE
cal_eval <- kuenm_ceval(path = out_dir, occ.joint = occ_joint, occ.tra = occ_tra, occ.test = occ_test, batch = batch_cal,
                        out.eval = out_eval, threshold = threshold, rand.percent = rand_percent, iterations = iterations,
                        kept = kept, selection = selection, parallel.proc = paral_proc)

# Create final models
# Create G_variables (projected variables) folder sets to match M_variables sets
g_vs <- kuenm_varcomb(var.dir = './derived_data/env/RCP85',
                      out.dir = './analysis/kuenm_Undaria/G_variables', min.number = 5,
                      in.format = 'ascii', out.format = 'ascii')

# Move to a subfolder to met te required format for the function kuen_mod
g_dir <- list.files("./analysis/kuenm_Undaria/G_variables", full.names = TRUE)
for (i in 1:length(g_dir)) {
  files <-  list.files(g_dir[i], full.names = TRUE)
  files2 <- list.files(g_dir[i])
  dir.create(paste(g_dir[i], "RCP85", sep="/"))
  a <- g_dir[i]
  for (j in 1:length(files)) {
    file.rename(from = files[j], to = paste(a,"RCP85", files2[j], sep = "/"))
  }
  rm(files, files2, a)
}


#help(kuenm_mod)
batch_fin <- "Final_models"
mod_dir <- "./analysis/kuenm_Undaria/Final_Models"
rep_n <- 10
rep_type <- "Bootstrap"
jackknife <- TRUE
out_format <- "logistic"
project <- TRUE
G_var_dir <- "./analysis/kuenm_Undaria/G_variables"
ext_type <- "all"
write_mess <- TRUE
write_clamp <- TRUE
wait1 <- FALSE
run1 <- TRUE
args <- NULL
kuenm_mod(occ.joint = occ_joint, M.var.dir = M_var_dir, out.eval = out_eval,
          batch = batch_fin, rep.n = rep_n, rep.type = rep_type,
          jackknife = jackknife, out.dir = mod_dir, out.format = out_format,
          project = project, G.var.dir = G_var_dir, ext.type = ext_type,
          write.mess = write_mess, write.clamp = write_clamp,
          maxent.path = maxent_path, args = args, wait = wait1, run = run1)


# Final model evaluation
# help(kuenm_feval)
occ_ind <- "./analysis/kuenm_Undaria/Undaria_test.csv"
replicates <- TRUE
out_feval <- "./analysis/kuenm_Undaria/Final_Models_evaluation"
# Most of the variables used here as arguments were already created for previous functions
fin_eval <- kuenm_feval(path = mod_dir, occ.joint = occ_tra, occ.ind = occ_ind,
                        replicates = replicates, out.eval = out_feval,
                        threshold = threshold, rand.percent = rand_percent,
                        iterations = iterations, parallel.proc = paral_proc)


