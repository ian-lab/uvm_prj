---
title: sha-1模块设计与验证
top: false
cover: false
toc: true
mathjax: true
date: 2023-04-04 11:14:45
password:
summary:
tags:
  - 项目
categories:
  - 项目 
---

## 1、sha-1算法

SHA1是一种密码散列函数，主要适用于数字签名标准里面定义的数字签名算法。对于长度小于2^64位的消息，SHA1会产生一个160位的消息摘要。当接收到消息的时候，这个消息摘要可以用来验证数据的完整性。在传输的过程中，数据很可能会发生变化，那么这时候就会产生不同的消息摘要，

```
sha1算法流程
对于任意长度的明文，SHA1首先对其进行分组，使得每一组的长度为512位，然后对这些明文分组反复重复处理。对于每个明文分组的摘要生成过程如下：
1、将512位的明文分组划分为16个子明文分组，每个子明文分组为32位。
2、申请 A、B、C、D、E 5个32位的链接变量
3、将16份子明文分组扩展为80份。
4、将80份子明文分组共进行4轮运算。
5、将链接变量与初始链接变量进行求和。
6、将新的链接变量作为下一个明文分组的输入重复进行以上操作。
7、最后，5个链接变量的数据就是SHA1摘要。
```

### 1.1 消息填充

对于任意长度的明文，首先需要对明文添加位数，使明文总长度为对 512 取模为 448 位。在明文后的第一个添加位是 1 ，其余都是 0 。然后将原始明文的长度以64位表示，附加于前面已添加过位的明文后，此时的明文长度正好是512位的倍数。明文长度从低位开始填充。

```
原始消息 01100001 01100010 01100011
补1 01100001 01100010 01100011 1
补0 01100001 01100010 01100011 10000000 ... 00000000
补长度 01100001 01100010 01100011 10000000 ... 00000000 00011000
16进制 61626380 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000018
```

### 1.2 分组与扩展

经过添加位数处理的明文，其长度正好为512位的整数倍，然后按512位的长度进行分组（block），可以划分成L份明文分组，用Y0，Y1，……YL-1表示这些明文分组。对于每个512位的明文分组，将其再分成16份子明文分组（sub-block），每份子明文分组为32位，用``M[k](k=0,1,...,15)``表示。之后将这16份子明文分组扩充到80份子明文分组，记为``W[t](t=0,1,...,79)``，扩充的方法如下。
$$
\begin{align}
W_t=&\  M_t,&0<=t<=15\\
W_t=&\ (W_{t-3}\oplus W_{t-8}\oplus W_{t-14}\oplus W_{t-16})<<<1,&16<=t<=79
\end{align}
$$

### 1.3 摘要运算

```
H0 = 0x67452301
H1 = 0xEFCDAB89
H2 = 0x98BADCFE
H3 = 0x10325476
H4 = 0xC3D2E1F0
for i = 1:L
fot t = 1:80
	TEMP = (A<<<5) + ft(B,C,D) + E + Wt + Kt
	E = D
	D = C 
	C = (B<<<30)
	B = A
	A = TEMP
	if t == 80
		H0 += A
		H1 += B
		H2 += C
		H3 += D
		H4 += E
hash = {H0, H1, H2, H3, H4}
<<<为循环左移
```

其中``ft``为逻辑公式，``Kt``为常数
$$
\begin{align}
f_t(B,C,D)=&(B\ \&\ C)\ |\ (\ !B\ \&\ D),&\ 0<<t<=19\\
f_t(B,C,D)=&(B\ \oplus\ C\ \oplus\ D),&\ 20<<t<=39\\
f_t(B,C,D)=&(B\ \&\ C)\ |\ (\ B\ \&\ D)|\ (\ C\ \&\ D),&\ 40<<t<=59\\
f_t(B,C,D)=&(B\ \oplus\ C\ \oplus\ D),&\ 60<<t<=79\\
\end{align}
$$

$$
\begin{align}
K_t=&5A827999 ,&\ 0<=t<=19\\
K_t=&6ED9EBA1 ,&\ 20<=t<=39\\
K_t=&8F1BBCDC ,&\ 40<=t<=59\\
K_t=&CA62C1D6 ,&\ 60<=t<=79\\、
\end{align}
$$

## 2、硬件设计

### 2.1 整体

![image-20230404164751107](https://s2.loli.net/2023/04/04/n6b9AgK5jNBcmMe.png)

| 信号          | 输入/输出 |
| ------------- | --------- |
| clk           | 输入      |
| rst_n         | 输入      |
| data_in[63:0] | 输入      |
| valid_in      | 输入      |
| hash[159:0]   | 输出      |
| valid_out     | 输出      |
| in_ready      | 输出      |

![image-20230404170052801](https://s2.loli.net/2023/04/04/PY8q6kRtJOdvWS3.png)

### 2.2 消息填充

消息填充分为以下几种情况

```
原始消息 1000000 length
原始消息 1000000 00000000 ... length
在最后一组消息传入时进行补1，然后根据消息长度补0或者直接补长度
```



| 信号           | 输入 / 输出 |
| -------------- | ----------- |
| data_in[63:0]  | 输入        |
| valid_in       | 输入        |
| out_ready      | 输入        |
| valid_out      | 输出        |
| data_pad[63:0] | 输出        |
| last_block     | 输出        |

![image-20230404171849015](https://s2.loli.net/2023/04/04/oElxskAVQ4wDyC1.png)

### 2.3 摘要计算

| 信号          | 输入 / 输出 |
| ------------- | ----------- |
| data_in[63:0] | 输入        |
| valid_in      | 输入        |
| last_block    | 输入        |
| in_ready      | 输出        |
| pad_in_ready, | 输出        |
| hash[159:0]   | 输出        |
| valid_out     | 输出        |

![image-20230406162318829](https://s2.loli.net/2023/04/06/oGM7TiabnCvgDXY.png)

## 3、验证

主要验证不同长度的消息能否正常计算摘要信息

```
63、64、65、127、128、129、447、448、449、511、512、513、1023、1024、1025、2014、2048、2049、随机
```



##  4、遇到的报错

```shell
UVM_FATAL /home/tools/synopsys/vcs/vcs-mx/O-2018.09-SP2/etc/uvm-1.2/base/uvm_phase.svh(1493) @ 9200: reporter [PH_TIMEOUT] Default timeout of 9200 hit, indicating a probable testbench issue
添加 -timescale=1ns/1ps 
```
