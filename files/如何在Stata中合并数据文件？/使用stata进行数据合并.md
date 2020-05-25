# 如何在stata中合并数据文件呢？
> 作者：江小白  
> 邮箱：jieresearch@163.com

我们在使用stata进行数据分析时，可能涉及多个数据文档的合并操作；或者同时使用不同数据集中的多个变量，这都需要我们进行文档间不同变量的归并。  
例如，我们需要使用CFPS(中国家庭追踪调查)数据库进行实证分析，而申请拿到的原始数据中包含成人数据库，儿童数据库，家庭关系库等多个数据集，我们需要的变量分散在这些数据集中，此时就需要将不同数据库中的不同变量放到一起；再譬如我们需要CFPS多期的调查数据构建多期面板，这又需要我们把多期的数据合并到一起...

在stata中就为我们提供了`merge` ，`append` 等命令以实现多个数据文件的**横向合并**或**纵向合并**。

--- 
## **merge** 命令

`merge`和 `append` 都是stata自带的数据处理命令，为了了解命令的使用，我们可以使用help 命令
 
```
help merge
```

通过帮助命令我们可以观察到如下语句格式

>通过关键变量进行1对1合并  
>merge  1:1  varlist  using  filename    
> 
>通过关键变量进行多对1合并  
> merge m:1 varlist using filename
> 
> 通过关键变量进行1对多合并  
 >merge 1:m varlist using filename 
 >
 >通过关键变量进行多对多合并  
 > merge m:m varlist using filename 
 > 
 > 通过观测数进行1对1合并  
 > merge 1:1 _n using filename 

利用帮助文件的示例演示*1对1*的数据合并如何操作
 
 ```stata
 webuse autosize
list
webuse autoexpense
list

/*Perform 1:1 match merge*/
webuse autosize
merge 1:1 make using http://www.stata-press.com/data/r15/autoexpense
list
```

通过`list`命令，我们可以观察到 autosize 和 autoexpense 的数据详情

autosize 数据
| make	| weight |	length	|
| :----- | :--: | -------: |			
 | Toyota   Celica |	2,410	|  174	|
|  BMW 320i	 | 2,650	| 177	|
|  Cad. Seville	| 4,290	| 204	|
| Pont Grand Prix |	3,210 |	201	|
| Datsun 210	|  2,020	| 165 |	
| Plym. Arrow	| 3,260	| 170	|


autoexpense 数据
 | make      |          price  |   mpg	|
| :----- | :--: | -------: |		
| Toyota Celica   |     5,899  |   18	|
| BMW 320i     |       9,735   |   25	|
| Cad. Seville   |    15,906  |  21	 |
|  Pont. Grand Prix   |  5,222  |   19	|
| Datsun 210     |     4,589   |   35	|

根据数据中的make变量，进行 1对1 的合并,在`merge`合并中我们需要定义 master 数据集和 using 数据集，相当于我们对于数据集定义主从关系，我们将 autosize 数据集作为master，然后 using autoexpense 数据集1对1合并，那么可以得到如下合并结果：


![](https://imgkr.cn-bj.ufileos.com/c9efbe2b-f6f9-4865-b2c2-409365a4e641.png)

使用 merge 后，stata会给出数据 match 的结果，如下表：这个结果告诉我们，两个数据集中有5个观测变量成功 match(用_merge==3表示这类变量)，有1个观测变量 not matched，而且这个匹配失败的变量来自master 数据集 (用_merge==1表示这类变量)。




**数据match结果**
| Result             |            # of obs.|
| :----- | :--: | 	
| not matched          |                1|
|   from master        |   1  (_merge==1) |
| from using           |   0  (_merge==2) |
| matched              |  5  (_merge==3)|
 
 在数据处理过程中可以在匹配后删除我们不需要的not matched 的样本，例如：`drop if merge==1`可以直接删除master数据集中未匹配的样本。
 
---- 
 
此外，`merge` 命令还提供了诸多的选择项（option）内容，比较常用的有：

1. ` keepusing(varlist)`:保留数据集中特定变量
2. `generate(newvar)`:使用新的变量名称标记merge结果，默认为merge
3. `nogenerate` :不生成merge变量
4. `update`: 用using数据集中的值替代master数据集中相同变量的缺失值
5. `replace `:用using数据集中的值替代master数据集中相同变量的非缺失值
6. ` force  `:允许字符型和数值型变量之间不匹配

-----
示例中还提供了1:m，m:1,以及多个选择项使用的例子（我们一般很少用到m:m合并），其操作与解读与1:1的合并类似

```
   
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

```
----
----
## **append** 命令

如果需要实现数据的纵向合并，我们使用`append`命令
```
help append
```
`append`的语句格式如下  
>append using filename [filename ...] [, options]

使用示例数据演示合并
```
/*Setup*/
webuse even
list
webuse odd
list

append using http://www.stata-press.com/data/r15/even
list

```
even数据集
| number | even |
| :--: | 	:--: | 	
|    6  |  12 |
|    7  |  14 |
|    8  |  16 |

odd 数据集

| number |  odd |
| :--: | :--: | 	
|      1  |   1 |
|      2  |  3 |
|      3  |  5 |
|      4  |  7 |
|      5  |  9 |
   
合并结果

| number |  odd |  even |   
| :--: | :--: | :--: |
|      1  |   1  | . |
|      2   |  3   | . |
|      3   |  5   |  .|
|      4   |   7   | . |
|      5   |  9   |  .|
|      6   | . |  12 |
|      7   | . |  14 |
|      8   | .  | 16 |

`append`命令也带有 `keep` `nolabel` `force`等选择项，使用方法与`merge`
大同小异

----
这些操作可以帮助我们在stata中实现数据的横向与纵向合并。例如在CFPS数据集中，可以根据追踪调查所标记的个人ID（pid）和家庭ID（fid）等变量从相应数据库中提取我们所需的变量进行合并；也可以根据调查年份合并我们所需的面板...

在实际中可以根据数据的结构特点和研究需求选择合适的操作命令，用stata进行数据集的合并你学会了吗？

