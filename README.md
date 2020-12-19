# minio [下载地址](https://github.com/1247748612/flutter-minio/releases)

> 基于flutter实现的minio客户端
> 使用的flutter sdk为1.22.5版本

## 预览图
![https://res.cloudinary.com/dengqing/image/upload/v1608269631/minio/1_fxdg0m.png](https://res.cloudinary.com/dengqing/image/upload/v1608269631/minio/1_fxdg0m.png)
![https://res.cloudinary.com/dengqing/image/upload/v1608269632/minio/2_weej3f.png](https://res.cloudinary.com/dengqing/image/upload/v1608269632/minio/2_weej3f.png)
![https://res.cloudinary.com/dengqing/image/upload/v1608269631/minio/3_io9alz.png](https://res.cloudinary.com/dengqing/image/upload/v1608269631/minio/3_io9alz.png)
![https://res.cloudinary.com/dengqing/image/upload/v1608269632/minio/4_jveukf.png](https://res.cloudinary.com/dengqing/image/upload/v1608269632/minio/4_jveukf.png)
![https://res.cloudinary.com/dengqing/image/upload/v1608269632/minio/5_lrsnm7.png](https://res.cloudinary.com/dengqing/image/upload/v1608269632/minio/5_lrsnm7.png)
![https://res.cloudinary.com/dengqing/image/upload/v1608269632/minio/6_npeusu.png](https://res.cloudinary.com/dengqing/image/upload/v1608269632/minio/6_npeusu.png)
![https://res.cloudinary.com/dengqing/image/upload/v1608269633/minio/7_mt7sg2.png](https://res.cloudinary.com/dengqing/image/upload/v1608269633/minio/7_mt7sg2.png)
### 项目初衷

我是很久之前阅读过[此书籍]("https://book.flutterchina.club/")，也只看到滚动widget那块。最近突然想学习一些其他东西。刚好之前曾经用react-native试着写个app的minio客户端。但官方的[sdk](https://docs.minio.io/cn/javascript-client-quickstart-guide.html)无法在react-native运行，采用其他方案但不理想后面就放弃了。所以现在就打算用flutter实现minio客户端，顺便学习flutter。

### 注意
此项目为练手项目，文件目录和代码规范都未了解，就是粗糙的实现了功能，具体的实现思路也是依靠一些前端知识去完成的。虽然如此但我认为如果只需要用到下载的功能此项目还是可以使用的。


### 具体实现

- 实现了绝大多数web端有的功能，等到官方[sdk](https://docs.minio.io/cn/javascript-client-quickstart-guide.html)出现可能会去重新实现 [web端公共体验地址](https://play.min.io/minio/)
- 采用rxdart做状态管理 (因为之前有使用过rxjs所以)
- 采用sqflite作为下载记录存储
- 项目有借鉴其他源码，也有直接copy修改的

### 未能实现

- 因sdk限制无法完成上传进度监听的功能，导致没有去实现上传记录页
- 因sdk限制无法使用中文，会成为乱码。导致所有文件含有中文的都不可下载预览，但是可以把中文名文件上传

### 总结

我并没有完整的看过flutter和dart的文档，是边写边学，遇见了问题就百度谷歌查询的。flutter的widget相当于前端的组件写页面还是比较简单，但widget实在太多了，并不知道哪个场景下上面widget是最适合的。并且我觉得flutter项目要想写好，还得有原生的基础才能更容易理解flutter，一些常用的底层都是android和ios实现的。