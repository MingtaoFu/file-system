#file-system
**这是我们的私有仓库，在课设结束前，请不要给别人看。**  
请尽量使用linux或OSX系统，windows我不会搞。  
请每个人装一个vmware虚拟机，用来测试我们的成果。

##需要的工具：
nasm: 用来编译汇编语言

##本地配置开发环境：
###导入项目
```git clone https://git.coding.net/rag/file-system.git```  
生成的file-system目录即为工作目录

###提交代码
请使用git，熟悉git请参见廖雪峰的教程。  
**除非你的代码确实可以执行，否则绝不要轻易提交。除非你另开了分支，但我们的小项目还是不要这么复杂。**

##在本地测试成果
###生成映像文件
----------------------
----该段内容作废-----

只需在linux/OSX系统下，执行```sudo sh command.sh```即可（请先在当前目录下创建一个名为“U”的文件夹）。  
command.sh的内容
nasm ipl10.asm -o ipl10.img  //生成img
nasm -f bin -o haribote.bin haribote.asm  //生成执行程序haribote.bin
//以下步骤将bin文件放到img中
mount ipl10.img U   //插入软盘，软盘对应于U文件夹
cp haribote.bin U   //把bin拷进去
umount U    //拔出软盘
这个sh文件写得比较粗糙，容易出错，如果执行时出现了error，请重新执行（warning就无所谓）。  
执行完成请看一下U文件夹，因为最后执行了拔出软盘的操作，最后U文件夹应该是空的，如果最后发现还有东西，请删除它并重新执行sh命令。  

-----------------------------------
----更新于2016-05-27-----
此次更新将文件目录以及构建方式全部改变。构建方式改为

```
sh command.sh
```

不需要sudo，成果文件在bin目录下

-----------------------------------

###在vmware中创建虚拟机（配置一台虚拟电脑）
打开vmware player  
1. ```create a new virtual machine```  
2. ```I will install the operating system later```  
3. 选择操作系统: ```Other```->```MS-DOS```  
4. Virtual Machine Name: 随意  
5. Disk Size: 默认即可。选择```Store virtual disk as a single file```  
6. 完成创建
7. 找到刚才创建的虚拟机，```Edit virtual machine settings```
8. 在device中将Hard Disk移除（我们只需要一个软盘，即img映像）
9. 添加一个Floppy Drive（软盘），```use a floppy img```，指向我们生成的img文件
10. 完成设置
11. 启动虚拟机，即可看到我们的成果。
12. 以后我们每次更新img，只需重启虚拟机即可看到效果  

**我在coding项目的```文件```中传了一个示例映像文件，大家可以测试一下，成功则说明虚拟机配置正确。**
