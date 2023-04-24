测试平台

![image-20230407112859678](https://s2.loli.net/2023/04/07/RVzKpAk6qjwNS2r.png)

测试点

```
读写数据一致
空满信号正常


```

bug

```
读写指针范围没有限制 pointer.
	always@(posedge clk, negedge reset_b)
		begin
		if(~reset_b)
			begin
			binary = 'd0;
			gray = 'd0;
			end	
		else if(op & ~fifo_status)
			binary <= binary + 1; 
		end
```

![Quicker_20230407_154358](https://s2.loli.net/2023/04/08/3pGkuLA8BbH2IRj.png)

![](https://raw.githubusercontent.com/ian-lab/typorapic/master/image-20230408151822959.png)

![](https://raw.githubusercontent.com/ian-lab/typorapic/master/image-20230408151822959.png)

![Quicker_20230407_154358](C:\Users\84308\Desktop\prj_test\Quicker_20230407_154358.png)
