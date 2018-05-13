# fanno
For internal use

## Installation
```
rm(list = ls())
library("devtools")
install_github("agalecki/fanno")
```
## Attach/detach library 
```
options("fannotator")   # NULL at the beginning of R session
library (fanno)
options()$fannotator    # Check 
options(fannotator = "fannotator_traceR")
detach(package:fanno)
````
## Create call/functions for testing

### Simple expressions

```
e2 <- expression(x+y, a+b)
e <- e2                    # <- select
el <- expr_transform(e)
lapply(as.list(el), function(x) cat(as.character(x), sep ="\n"))
```
check_call <- function(cl){
if (is.null(cl)) return (0)

}


coerce_call_to_expressionList  <- function(cl){
## 
if (!length(cl)) return (cl)

if (is.name(cl)) return (list(as.expression(cl)))
if (as.character(cl[1]) != "{") return(list(as.expression(cl)))

cList <- as.list(cl)
if (as.character(cl[1])  == "{" ) cList[[1]] <- NULL

eList <- vector(length(cList), mode= "list")
for (i in seq_along(cList)){
  eList[[i]] <- as.expression(cList[[i]])
}
return (eList)
}

coerce_expressionList_to_call <- function(eList){
curle_brackect_symbol <- as.symbol("{")
cl <- as.symbol("{")
e <- expression()
for (i in seq_along(eList)){
  ei <- eList[[i]]
  e <- c(e, ei)
}
cl <- as.call(c(as.name("{"), e))
return(cl)
}


### Functions

```
f0 <- function(x){}  # length
f1 <- function() pi  # Mode() == "name" 
f1a <- function(){pi}
f2  <- mean
f3 <- function(x) x*2
f4 <- stringr:::word
```
```
cl <- body(f3)
is.call(cl)
is.symbol(cl)
mode(cl)
length (cl)
length(cl) == length(as.list(cl))


cList <- coerce_call_to_expressionList (cl)
cList
mode(cList)
cl
```
### Calls





```
cl <- bf2                  # Select object of mode call
length(cl)
mode(cl)
```


### Annotate expression/body/function

```
options(fannotator ="fannotator_simple")
o <- f1                   # --- select e0, e1, e2, bf1, bf2, bf3, f0,f1,f2
oa1 <- fanno(o)                     
oa2  <- fanno(oa1)
identical(oa1, oa2)      # TRUE
orv <- fanno(oa1, fannotator ="fannotator_revert")
identical(orv, o)        # TRUE

options(fannotator ="fannotator_traceR")
o3  <- fanno(o1)
o4 <- fanno(o3)
identical(o3, o4)      # TRUE

```

### Examine annotated objects

```
finfo(o)     # 

cat(as.character(e), sep="\n")
fanno_assign("o")

```
## fanno_assign
```
tt <- stringr:::word
fanno_assign ("tt")


library(stringr)
ls(asNamespace("stringr"))
fanno_assign(where = "namespace:stringr")
stringr:::word
fanno_assign(where = "namespace:stringr", fannotator = "fanno_revert")

```



## Create function for testing

* Create function fx in .GlobalEnv for testing

```
fx <- function(x) x^2
environment(fx)                
environment(fx) <- .GlobalEnv
str(fx)                               # function(`name`, `args`)
formals(fx)                           # list with formal arguments and values
formalArgs(fx)                        # names of formal arguments
```

 ```
 tt <- fanno_simple(fx)
 fanno_simple(tt)

 fanno_traceR(tt)
```

## Test `funinfoCreate` function

### Create finfo objects

```
library(fanno)
finfo0 <- funinfoCreate(fanno)  # Error: funinfo:fnm argument needs to be a character
finfo1 <- funinfoCreate("fx")   # List  of class: funinfo
finfo2 <- funinfoCreate("ttx")

library(stringr)
finfo3 <- funinfoCreate("word", where = "namespace:stringr")
finfo4 <- funinfoCreate("word", where = "package:stringr")
zzz    <- funinfoCreate("zword", where = "package:stringr")
```
### Check the contents of selected finfo object

```
finfo <- finfo3                 # assign selected finfo object
names(finfo)
finfo[c("fnm","where", "is.found", "is.function","fattrnms")]  
names(attributes(finfo$fun))                 # Note: attribute scrcref preserved in finfo1
```

## Test examples of `ebf_fanno` functions

`ebf_fanno` function takes a function and returns expression representing function body 

```
ebf_simple <- ebfanno_simple("fx")
ebf_traceR <- ebfanno_traceR("fx")
```

```
ebf <- ebf_simple
length(ebf) 
mode(ebf)
```

## Testing fanno function

```
fanno("fx")
fanno("word", where = "namespace:stringr")
fanno("word", where = "namespace:stringr", ebfanno = "ebfanno_traceR")
```



# Older version
```
bfanno_init(fx)         # creates a ist with two elements: options()$fanno and $ebf (expression)  
bfanno_default(fx)                    
fannotate(fx)           # generates annotated function with attributes
fannotatex("fx")
```
```
ls(asNamespace("stringr"))
fanno_bftest(where = "namespace:stringr")

library(stringr)
ls(as.environment("package:stringr"))
fanno(where = "package:stringr")
```


````
 fx <- function(x) x^2
 bfanno_msg1(tt)      # error object not found
 bfanno_msg1(fx)    
 getAnywhere("fx")[["where"]]           # ".GlobalEnv"
 assign_fanno("fx")
 fx
 
 getAnywhere("nlme")[["where"]]         # character(0)
 library(nlme)   
 getAnywhere("nlme")[["where"]]         #"package:nlme"   "namespace:nlme"
 detach(package:nlme)
 getAnywhere("nlme")[["where"]]         # "namespace:nlme"
 
 library(nlme)
 assign_fanno("nlme")                   # Object <0:nlme> not found in  <.GlobalEnv> ... skipped
 assign_fanno_ns("nlme") 
 
 
 assign_fanno("word", where = "namespace:stringr")
 getAnywhere("word")[1]
 stringr::word("A B C", 2)
 
 getAnywhere("print")[["where"]]       # "package:base" "namespace:base"
 assign_fanno("print", where = "package:base")
 getAnywhere("print")[1]
 assign_fanno("print", where = "namespace:base")
 getAnywhere("print")[2]
 print("A B C")

 
````
