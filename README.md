# file-system
## 简介
本项目是一个裸机程序，功能是实现一个FAT12文件系统

该项目的成功运行需要在虚拟机挂载两个镜像文件，目前在```bin```目录下的可以直接使用
 - file-system.img 是启动程序，里面保存的是一些控制代码，例如文件的生成与读写等
 - a.img 是文件系统本身，即内部保存了写入的数据（当时瞎命的名，忽略）
 
在虚拟机上挂载这两个软盘之后，直接启动即可使用（虚拟机配置请见本文档后面）。

至于目前支持哪些命令，请看代码注释。

## 编译
环境是linux 64bit

请安装nasm用于编译

直接执行```sh command.sh```即可生成上文中的两个镜像，就能愉快地使用了（虽然很难用）

以下内容是我之前在做课设的时候与同组同学交流时写的

-----------------------------------------------------------

#file-system
请每个人装一个vmware虚拟机，用来测试我们的成果。

##需要的工具：
nasm: 用来编译汇编语言

##本地配置开发环境：
###导入项目
```git clone https://git.coding.net/rag/file-system.git```  
生成的file-system目录即为工作目录

##在本地测试成果
###生成映像文件
----------------------
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
