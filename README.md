# fanno
For internal use

```
rm(list = ls())
library("devtools")
install_github("agalecki/fanno")
library (fanno)
````

````
 fx <- function(x) x^2
 bfanno_simple(tt)      # error object not found
 bfanno_simple(fx)    
 assign_fanno("fx")
 #bfanno_simple('mean',  where = "namespace:base")
 #bfanno_simple('mean')
 #bfanno_simple('round', where = "namespace:base")
````
