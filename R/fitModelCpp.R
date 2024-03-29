
fitModelCpp <- function(
    type,
    eqnfile,
    data,
    restrictions,
    covData,
    predStructure,
    predType, # c("c," f", "r")
    transformedParameters,
    corProbit = TRUE,
    hyperprior,
    n.iter = 20000,
    n.burnin = 2000,
    n.thin = 5,
    n.chains = 3,
    dic = FALSE,
    ppp = 0,
    modelfilename,
    parEstFile,
    posteriorFile,
    autojags = NULL,
    call = NULL,
    cores = 1
) {
  if (missing(restrictions)) restrictions <- NULL
  if (missing(covData)) covData <- NULL
  if (missing(transformedParameters)) transformedParameters <- NULL
  if (missing(predStructure)) predStructure <- NULL
  if (missing(predType)) predType <- NULL

  ################## parse EQN file
  mpt.res <- readEQN(eqnfile, restrictions = restrictions, parse = TRUE)
  # mpt <- parseEQN(tab)
  # mpt.res <- parseRestrictions(mpt, restrictions)
  thetaUnique <- colnames(mpt.res$a)
  S <- length(thetaUnique)
  ################## merge EQN (compatibiltiy with betaMPT, traitMPT)
  mergedTree <- thetaHandling(
    mergeBranches(mpt.res$Table),
    restrictions
  )$mergedTree

  data <- readData(data, mpt = mpt.res)
  N <- nrow(data)
  covData <- covDataRead(covData, N)

  if (type == "betaMPT") {
    shape <- check.hyperprior(hyperprior$shape, thetaUnique, label = "shape")
    rate <- check.hyperprior(hyperprior$rate, thetaUnique, label = "rate")
    hyperprior <- list(
      alpha = check.hyperprior(paste0("dgamma(", shape, ",", rate, ")"),
        thetaUnique,
        label = "alpha"
      ),
      beta = check.hyperprior(paste0("dgamma(", shape, ",", rate, ")"),
        thetaUnique,
        label = "beta"
      )
    )
  } else if (type == "simpleMPT") {
    alpha <- check.hyperprior(hyperprior$alpha, thetaUnique, label = "alpha")
    beta <- check.hyperprior(hyperprior$beta, thetaUnique, label = "beta")
    hyperprior <- list(alpha = alpha, beta = beta)
  }


  time0 <- Sys.time()
  # cat("MCMC sampling started at ", format(time0), "\n")

  mcmc.list <- list()



  simBetaMPT <- function(idx) {
    sim <- betampt(
      M = ceiling((n.iter - n.burnin) / n.thin),
      L = ceiling(n.burnin / n.thin),
      nthin = n.thin,
      H = as.matrix(data),
      a = mpt.res$a, b = mpt.res$b,
      c = mpt.res$c, map = mpt.res$map,
      shape = shape, rate = rate
    )
    if (S > 1) {
      colnames(sim$mean) <- paste0("mean[", 1:S, "]")
      colnames(sim$sd) <- paste0("sd[", 1:S, "]")
      colnames(sim$alph) <- paste0("alph[", 1:S, "]")
      colnames(sim$bet) <- paste0("bet[", 1:S, "]")
    }
    tnames <- outer(1:S, paste0(",", 1:N), paste0)
    tt <- matrix(
      sim$theta,
      nrow = ceiling((n.iter - n.burnin) / n.thin),
      ncol = S * N,
      dimnames = list(NULL, paste0("theta[", c(t(tnames)), "]"))
    )
    tmp <- with(sim, cbind(mean, sd, alph, bet, tt))
    if (S == 1) {
      colnames(tmp)[1:4] <- c("mean", "sd", "alph", "bet")
    }

    # return
    mcmc(tmp, start = n.burnin + 1L, thin = n.thin)
  }

  simSimpleMPT <- function(idx) {
    sim <- simplempt(
      M = ceiling((n.iter - n.burnin) / n.thin),
      L = ceiling(n.burnin / n.thin),
      nthin = n.thin,
      H = as.matrix(data),
      a = mpt.res$a, b = mpt.res$b,
      c = mpt.res$c, map = mpt.res$map,
      alpha = alpha, beta = beta
    )
    means <- apply(sim$theta, c(1, 3), mean)
    sds <- apply(sim$theta, c(1, 3), sd)
    if (S == 1) {
      colnames(means) <- c("mean")
      colnames(sds) <- c("sd")
    } else {
      colnames(means) <- paste0("mean[", 1:S, "]")
      colnames(sds) <- paste0("sd[", 1:S, "]")
    }

    tnames <- outer(1:S, paste0(",", 1:N), paste0)
    tt <- matrix(
      sim$theta,
      nrow = ceiling((n.iter - n.burnin) / n.thin),
      ncol = S * N,
      dimnames = list(NULL, paste0("theta[", c(t(tnames)), "]"))
    )
    tmp <- with(sim, cbind(means, sds, tt))

    # return
    mcmc(tmp, start = n.burnin + 1L, thin = n.thin)
  }


  if (cores > 1) {
    ncpu <- min(detectCores(), n.chains)
    cl <- makeCluster(ncpu)
    clusterExport(cl, c(
      "simBetaMPT", "simSimpleMPT",
      "n.iter", "data", "mpt.res", "S",
      "N", "n.burnin", "n.thin"
    ), envir = environment())
    if (type == "betaMPT") {
      clusterExport(cl, c("shape", "rate"), envir = environment())
      mcmc.list <- parLapply(cl, 1:n.chains, simBetaMPT)
    } else if (type == "simpleMPT") {
      clusterExport(cl, c("alpha", "beta"), envir = environment())
      mcmc.list <- parLapply(cl, 1:n.chains, simSimpleMPT)
    }
    stopCluster(cl)
  } else {
    if (type == "betaMPT") {
      mcmc.list <- lapply(1:n.chains, simBetaMPT)
    } else if (type == "simpleMPT") {
      mcmc.list <- lapply(1:n.chains, simSimpleMPT)
    }
  }
  mcmc.list <- as.mcmc.list(mcmc.list)


  time1 <- Sys.time()
  # cat("MCMC sampling finished at", format(time1), "\n  ")
  # print(time1-time0)

  # store details about model:
  mptInfo <- list(
    model = type,
    thetaNames = data.frame(
      Parameter = colnames(mpt.res$a),
      theta = 1:ncol(mpt.res$a),
      stringsAsFactors = FALSE
    ),
    thetaUnique = thetaUnique,
    thetaFixed = NULL,
    MPT = c(mpt.res, as.list(mergedTree)),
    eqnfile = eqnfile,
    data = data,
    restrictions = restrictions,
    covData = covData,
    corProbit = corProbit,
    predTable = NULL,
    predFactorLevels = NULL,
    predType = NULL,
    transformedParameters = NULL, # transformedPar$transformedParameters,
    hyperprior = hyperprior
  )

  ###############################################################

  # correlation of posterior samples:
  if (!is.null(covData)) {
    sel <- is.numeric(data.frame(covData)[1, ])
    cdat <- as.matrix(covData[, sel, drop = FALSE])
  } else {
    cdat <- NULL
  }
  mcmc.list <- as.mcmc.list(
    lapply(mcmc.list, corSamples,
      covData = cdat, thetaUnique = thetaUnique,
      rho = TRUE, corProbit = corProbit
    )
  )



  # own summary (more stable than runjags)
  mcmc.summ <- summarizeMCMC(mcmc.list)
  summary <- summarizeMPT(
    mcmc = mcmc.list,
    mptInfo = mptInfo,
    summ = mcmc.summ
  )
  summary$dic <- NULL

  # class structure for TreeBUGS
  fittedModel <- list(
    summary = summary,
    mptInfo = mptInfo,
    mcmc.summ = mcmc.summ,
    runjags = list(mcmc = mcmc.list),
    postpred = NULL,
    call = call,
    time = time1 - time0
  )
  class(fittedModel) <- type

  # if(ppp>0){
  #   cat("\nComputing posterior-predictive p-values....\n")
  #   postPred <- PPP(fittedModel, M=ppp,
  #                   nCPU=length(mcmc.list))
  #   fittedModel$postpred <- postPred[c("freq.exp", "freq.pred", "freq.obs")]
  #   try(
  #     fittedModel$summary$fitStatistics <- list(
  #       "overall"=c(
  #         "T1.observed"=mean(postPred$T1.obs),
  #         "T1.predicted"=mean(postPred$T1.pred),
  #         "p.T1"=postPred$T1.p,
  #         "T2.observed"=mean(postPred$T2.obs),
  #         "T2.predicted"=mean(postPred$T2.pred),
  #         "p.T2"=postPred$T2.p,
  #         "ind.T1.obs"=postPred$ind.T1.obs,
  #         "ind.T1.pred"=postPred$ind.T1.pred,
  #         "ind.T1.p"=postPred$ind.T1.p
  #       ))
  #   )
  # }
  fittedModel <- addPPP(fittedModel, M = ppp)

  # write results to file
  writeSummary(fittedModel, parEstFile)
  if (!missing(posteriorFile) && !is.null(posteriorFile)) {
    try(save(fittedModel, file = posteriorFile))
  }
  gc(verbose = FALSE)

  fittedModel
}
