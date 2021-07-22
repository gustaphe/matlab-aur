# MATLAB Arch Linux 打包脚本 

[English](README.md)

此处提供了供Arch Linux使用的MATLAB打包脚本。它还会打包MATLAB的python engine API。前者存放在`matlab`软件包中，后者则是`python-matlabengine`。

**警告** 通常来说你需要按照下文的方法自己获得MATLAB的离线安装程序。MATLAB的用户协议中禁止未授权的分发。

## 建议

-   MATLAB包很大。如果你只在你自己的电脑上装，你可以不压缩这个包，例如这样：`PKGEXT=".pkg.tar" makepkg`。这样可以节约压缩又解压的时间。
-   在打包MATLAB的离线安装程序时也可以不压缩。只需要在PKGBUILD中的source部分修改对应文件的名字即可。
-   如果你在建立自己的软件源，最好权衡一下你的带宽和存储──部分安装的包至少需要8GB，而全部安装大约要12GB。
-   如果你的英特尔显卡不支持硬件加速，设置环境变量`MATLAB_INTEL_OVERRIDE='yes'`。

## 安装要求

除了需要的那些依赖，这些文件需要你手动提供：

* `matlab.fik`: 写有file installation key的文本文件
* `matlab.lic`: 许可文件
* `matlab.tar.zst`: 离线安装程序

然后在PKGBUILD文件同一层的目录下执行`makepkg -s`。构建通常要花很多时间。

### File Installation Key和许可文件

[这个网页](https://www.mathworks.com/help/install/ug/install-using-a-file-installation-key.html)有关于如何获取这些文件的官方指南。

File installation key指明了特定版本Matlab的安装，而许可文件则授权Matlab与对应的工具箱的安装。

-   进入[许可中心](https://www.mathworks.com/licensecenter)
-   在`install and activate`处选择（或建立）一个许可。
    -   如果其中没有许可，这是因为你是第一次使用你的组织的许可。点击`manual activation`，在`Host ID`处输入你的网卡的MAC地址，`username`一节则要填写你在Arch上使用Matlab的用户的用户名。
-   选择“download the license file and the file installation key”
-   把下载下来的文件放进PKGBUILD文件同一层的目录，并将名字改为`matlab.lic`。
-   复制file installation key并存在一个文本文件里。

如果你将在你的组织的网络中分发Matlab而不是只供自己使用，上面下载的许可将是无效的。当Matlab识别到失效的许可证，就根本不会启动。

一个解决办法是打包时删掉你的许可证。即取消对`PKGBUILD`文件`build()`函数最后几行的注释。这样当终端用户第一次打开他们的matlab，识别到缺少许可证，就会打开Matlab的激活程序，引导用户完成激活。

当然，无论怎么做，在安装后（或任何时候）运行`activate_matlab.sh`都能够进入激活程序。程序会在用户的主目录下建立他们的许可证。

### 离线安装包

-   下载[官方安装包](https://www.mathworks.com/downloads)。
-   解压并运行安装包。
-   登录并接受许可后，选择`高级选项 -> 我想只下载而不安装`。
-   设置下载路径为一个名字为`matlab`的空目录。
-   选择你需要下载的内容，并修改PKGBUILD。（如果你想要全部安装，就什么都不需要改）
-   下载后，在有`matlab`文件夹的目录下执行`tar -I zstd -cvf matlab.tar.zst matlab`来生成离线安装包。

你的组织有时候也会提供离线安装包。但是你要确保这些文件包含正确的权限，因为zip等压缩程序通常不会保留权限设置，或是在windows下下载而不具有unix权限。

### 传输大文件

可以用split和cat来分割与合并大文件。有些分区格式（如FAT32）不能存储较大的文件：

* **分割**: `split --bytes 3G --numeric-suffixes=0 matlab.tar.zst matlab.tar.zst.`
* **合并**: `cat matlab.tar.zst.* > matlab.tar.zst`

### 模块

Matlab有很多[模块](https://www.mathworks.com/products.html)。通常都是不需要或者你的许可证不提供的。检查`PKGBUILD`并适当地选择需要的模块。
