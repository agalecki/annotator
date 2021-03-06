fOpts <- function(fname, tracef, attrs){ 
 # Checks elements of tracef  (by default) empty list 
  fun <- tracef[["fun"]]
  if (is.null(fun)) fun <- attrs[["fun"]]
 
  ids <- tracef[["id"]]
  if (is.null(ids)) ids <- attrs[["id"]]
  
  modifyEnv <- tracef[["modifyEnv"]]
  if (is.null(modifyEnv)) modifyEnv <- attrs[["modifyEnv"]]
 
  asList <- tracef[["asList"]]
  if (is.null(asList)) asList <- attrs[["asList"]]
 
  list(ids = ids, fun = fun, modifyEnv = modifyEnv, asList = asList)
}

fNames <- function(fname){

  cnms <- if (nrow(.traceRmap)) as.character(.traceRmap[nrow(.traceRmap), c("fTree")]) else  character(0)

 
  cNms <- if (length(cnms)) unlist(strsplit(cnms, "->", fixed = TRUE))  else character(0)

  mtch <- match(fname, rev(cNms))
  mtch <- length(cNms) + 1 - mtch
  if (is.na(mtch)) mtch <- 0
  cNms <- if (mtch)  cNms[1:mtch]  else c(cNms, fname)
  paste(cNms, collapse = "->")
}

.traceRdump <- function(i, fnm, whr, idx){
  first <- if (i) FALSE else TRUE
  store <- TRUE
  auto  <- FALSE
 
  # Based on fnm, whr create exprc
  funx <- fanno_extractx (fnm, where = whr)
  bfunx <- body(funx)
  bfx_call <- coerce_bf_to_bcall(bfunx) # bracketed call
  exprc <- as.character(coerce_bcall_to_exprvList(bfx_call))
 
  # Create id from idx and i
  elen <- length(exprc)
  nx    <- ceiling(log10(elen))
  x10 <- 10 ^ nx
  if (first) {
       id <-  paste(replicate(nx, "0"), collapse ="")
       id <-  paste(idx , id, sep =".") # auxiliary
       eic <- "{"
       } else  {
       id <- as.character(idx + i/x10)
       # eic <- if (i == elen) exprc[i] else character()
       eic <- exprc[i]
      }
   
  .traceRfunctionEnv <- new.env()
  .traceRfunctionEnv <- parent.frame()
  
  # .functionLabel -> fname
  #fn    <- exists(".functionLabel", envir = .traceRfunctionEnv)
  ## fnm   <- suppressMessages(stringr::word(.functionLabel ,1, sep ="@"))      # May 2018 to extract function name (check, if needed)
  # Returns character with function name
  # fname <- if (fn) eval(expression(.functionLabel), envir = .traceRfunctionEnv) else "."
  fname <- paste("[", whr, "]", fnm, sep ="");
 
  traceR <- options()$traceR  # By default is an empty list with different attraibutes
  tracef <- traceR[[fname]]   # NULL by default
  attrs <- attributes(traceR) # named list (fun, asList, prefix, mapVars, mapPrint) with traceR attributes. 
  
  # fopts is a list (ids = NULL, fun, modifyEnv = NULL, asList = FALSE)
  fopts <- fOpts(fname, tracef, attrs)  # Returns options specific for function fname

  prefix <- attr(traceR, "prefix")      # e_
  select <- id %in% fopts$ids || is.null(fopts$ids)
  
  if (!select || (is.list(tracef) && !length(tracef))) return()

  # Cumulate names (-> used to collapse names)
  fNms <- fNames(fname)

  recno <- nrow(.traceRmap) + 1  # increase recno  in .traceRmap dataset
  lbl <- if (length(eic)) eic else ""     # length?  lbl to eic?
  
  Nmsall <- names(.traceRfunctionEnv)
  NmsAllb <- ifelse(Nmsall %in% c(".traceR", ".envInfo") , FALSE, TRUE) # Remove 
  Nms <- Nmsall[NmsAllb]
  olength <- sapply(Nms, length)
  omode   <- sapply(Nms, mode)
  oclass  <- sapply(as.list(Nms), function(el) class(el)[1])
  oNms <- paste (Nms, collapse =", ")
  message("    - onames: ", oNms)
                    
  if (!is.null(fopts$modifyEnv)){
    modifyEnv <- fopts$modifyEnv
    res <- new.env()
    res <- modifyEnv(.traceRfunctionEnv)
    .traceRfunctionEnv <- res
  }
  nms <- ls(.traceRfunctionEnv)

  .envInfo <- list(recno = recno, 
                   line_no = i,
                   eic = lbl,
                   fnm = fnm,
                   whr = whr,
                   idx = idx,
                   onms = Nms,
                   #olen = olength,
                   #omode = omode,
                   #oclass1 = oclass,
                   msg = paste("Environment created by .traceRdump"))
  assign(".envInfo", .envInfo, .traceRfunctionEnv)
  
  elist <- if (fopts$asList) {
     if (length(nms)) mget(nms, .traceRfunctionEnv) else list()
  } else {
    if (length(nms)) .traceRfunctionEnv else emptyenv()
  }  
  xname <- if (length(nms) && store) paste(prefix, recno, sep = "") else ""

  if (nchar(xname)) {
    assign(xname, elist)
    Store(list = xname)
  }
  
  tmp <- data.frame(recno = recno,  fLbl = fname, id = id, idLbl =lbl, 
  fTree = fNms, env = xname, nObj = length(nms), nObjAll = length(Nms), store = store, 
   first = first, auto= auto, stringsAsFactors = FALSE)
  assign(".traceRmap", rbind(.traceRmap, tmp), envir= .GlobalEnv)
}
