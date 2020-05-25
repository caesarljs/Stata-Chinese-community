

clear all 
cd: "C:\Users\Administrator\Desktop"

help merge  

webuse autosize
list
webuse autoexpense
list

/*进行 1:1 merge*/
webuse autosize
merge 1:1 make using http://www.stata-press.com/data/r15/autoexpense
list

    
/*进行 1:1  merge, 并保留匹配变量*/
webuse autosize, clear
merge 1:1 make using http://www.stata-press.com/data/r15/autoexpense, ///
keep(match) nogen
list


/* Setup */
webuse dollars, clear
list
webuse sforce
list
/*与 sforce 进行 m:1  merge */
merge m:1 region using http://www.stata-press.com/data/r15/dollars
list


/*Setup*/
webuse overlap1, clear
list, sepby(id)
webuse overlap2
list

/*进行 m:1  merge, 带update选项*/
webuse overlap1
merge m:1 id using http://www.stata-press.com/data/r15/overlap2 ///
    update
list

    
/*进行 m:1  merge, 带update replace选项*/
webuse overlap1, clear
merge m:1 id using http://www.stata-press.com/data/r15/overlap2 ///
    update  replace
list

/*进行 1:m  merge, 带update replace选项*/
webuse overlap2, clear
merge 1:m id using http://www.stata-press.com/data/r15/overlap1 /// 
   update replace
list

  
/*按样本进行顺序合并*/
webuse sforce, clear
list
merge 1:1 _n using http://www.stata-press.com/data/r15/dollars
list


*************************

/*Setup*/
webuse even
list
webuse odd
list

append using http://www.stata-press.com/data/r15/even
list


/*Setup*/
sysuse auto, clear
keep if foreign == 0
save domestic
sysuse auto, clear
keep if foreign == 1
keep make price mpg rep78 foreign

 /*Append domestic car data to the end of the foreign car data and only keep
    variables make, price, mpg, rep78, and foreign from domestic car data
        . append using domestic, keep(make price mpg rep78 foreign)*/

 /*List the results*/
list




