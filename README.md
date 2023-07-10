# DetectFakeLocation
iOS检测虚拟位置，比如使用Xcode模拟位置、使用爱思助手模拟位置等


# iOS 虚拟定位原理与预防

## 背景

说到虚拟定位，常有印象都是安卓上的分身软件甚至系统自带的位置穿越（笔者曾经使用过ZUK Z2系统自带的位置穿越），会认为iOS上虚拟定位比较困难。笔者没调研之前也是这么认为，之前已知的虚拟定位是使用Xcode添加GPX文件，编辑经纬度，从而实现虚拟定位。但是这种操作也只有熟悉iOS开发的人才能操作，而且需要mac电脑，故而笔者印象中也是iOS上虚拟定位比较困难。

<!--more-->

然而经过调研之后，笔者发现，iOS的虚拟定位没有那么困难，甚至相比于安卓更简单。下面就来介绍一下iOS中几种虚拟定位的方法。

## 虚拟定位的几种办法及原理

笔者调研后，发现iOS上面虚拟定位大致可有4中情况：
- 使用Xcode通过GPX文件虚拟定位
- 使用爱思助手中的虚拟定位功能直接虚拟定位
- 通过外接设备，比如蓝牙和手机连接，发送虚拟定位数据来虚拟定位
- 越狱设备中通过hook定位方法，来虚拟定位

下面就来一个个分析实践：

### 使用Xcode通过GPX文件虚拟定位

使用Xcode通过GPX文件虚拟定位，iOS开发一般比较熟悉，操作步骤是：

新创建一个iOS项目，然后添加文件，选择创建GPX文件

![wecom20210804-151237.png](https://inews.gtimg.com/newsapp_ls/0/13846925548/0.png)


编辑其中内容，把`lat`、`lon`改为要模拟的经纬度，如下：

``` Objective-C

<wpt lat="31.2416" lon="121.333">
         <name>Shanghai</name>
    </wpt>
</gpx>

```

然后选择`Product` -> `Scheme` -> `Edit Scheme`，选中`Options` tab，勾选`Allow Location Simulation`，然后运行即可虚拟定位

![wecom20210804-152202.png](https://inews.gtimg.com/newsapp_ls/0/13846939343/0.png)

**注意：** 通常情况下，使用Xcode运行虚拟定位，运行停止后，经纬度会恢复成原来的。但是当运行了项目，然后直接拔掉数据线(是运行状态下拔掉)，手机的经纬度就会一直是模拟的经纬度，想要恢复需要重启手机或者等待2～5天自动恢复。

**原理：** 调用iOS设备中的`com.apple.dt.simulatelocation`服务，[`com.apple.dt.simulatelocation`服务是苹果在Xcode 6、iOS 8.0之后提供的为设备模拟GPS位置的调试功能，原理是通过usb获取设备句柄后开启设备内的服务("`com.apple.dt.simulatelocation`")，再通过固定坐标或GPX文件进行位置模拟。](https://zhuanlan.zhihu.com/p/46572309)

### 使用爱思助手中的虚拟定位功能直接虚拟定位

这个方法最是简单，笔者之前不知道有这种方法，下载一个爱思助手，打开，连接手机到电脑，选择`工具箱`tab下的`虚拟定位`

![wecom20210804-142320@2x.png](https://inews.gtimg.com/newsapp_ls/0/13846970127/0.png)

然后输入要定位的位置搜索，点击修改定位即可

![wecom20210804-142450@2x.png](https://inews.gtimg.com/newsapp_ls/0/13846970132/0.png)

**注意：** 这种虚拟定位的方法，真的是简单。就目前而言，笔者尝试后发现`钉钉`、`企业微信`，均没有对此类方法检测处理。

**原理：** 通过[libimobiledevice](https://github.com/libimobiledevice/libimobiledevice)的service模块开启com.apple.dt.simulatelocation服务，然后实现脱离通过Xcode来模拟定位。[libimobiledevice](https://github.com/libimobiledevice/libimobiledevice)是开源的跨平台调用iOS协议的库。

### 通过外接设备，发送虚拟定位数据来虚拟定位

通过外接设备，发送虚拟定位这个方法笔者之前完全都没了解到，不得不说，真的是双击666，人民智慧无限强大，其中代表是位移精灵。笔者没有购买外设，所以也没办法尝试，但是可以附上一个视频，供大家参考：

视频链接：https://haokan.baidu.com/v?pd=wisenatural&vid=17675944846390412165


**原理：** 通过MFi（Made For iOS）认证厂商，可以获得MFI Accessory Interface Specification文档，其中提供了很多隐藏功能，包含时间通讯、音乐数据通讯、定位功能等等。其中定位功能的使用只需要照着文档，按照协议格式发送对应位置数据，即可。[MFI Accessory Interface Specification](https://usermanual.wiki/Document/MFiAccessoryInterfaceSpecificationR18NoRestriction.1631705096.pdf)地址见：https://usermanual.wiki/Document/MFiAccessoryInterfaceSpecificationR18NoRestriction.1631705096.pdf

文档中搜索`Locaiton`即可看到定位相关信息，如下：

![wecom20210804-165553.png](https://inews.gtimg.com/newsapp_ls/0/13847282969/0.png)


### 越狱设备中通过hook定位方法，来虚拟定位

越狱设备虚拟定位，是越狱之后使用具备虚拟定位功能的越狱插件。在上帝模式下，越狱插件可以随意劫持系统函数。比如：[GPS定位管家，能够管理每个iOS应用的GPS位置。](http://article.docway.net/details?id=60d5e03bcbb464046e3508b6)。

**原理：** 越狱后，通过注入库，hook了CLLocationManager中的定位代理方法，从而篡改正常定位信息。


总结如下：

![wecom20210804-171650.png](https://inews.gtimg.com/newsapp_ls/0/13847379681/0.png)

## 虚拟定位几种方法的检测

作为开发，知道了有哪些虚拟定位的，还不够，还需要知道怎么这些虚拟定位的方法怎么解决。尤其是OA应用和游戏应用的开发，需要特别注意。下面就来一步步看下：

### 使用Xcode通过GPX文件虚拟定位的检测 和 使用爱思助手中的虚拟定位功能直接虚拟定位的检测

使用Xcode通过GPX虚拟定位和使用爱思助手虚拟定位的，其最终的原理是一样的，都是通过调用com.apple.simulatelocation服务，从而实现虚拟定位。

笔者统计了一下，网上说的验证方式大致有两种：
- 根据特征值判断
  - 定位的精度：虚拟定位的经纬度的精度不如真实定位的精度高，所以可以通过定位经纬度的精度来判断
  - 定位的海拔值和海拔精度：虚拟定位的海拔值为0，海拔垂直精度为-1；所以可以通过这两个值来判断
  - 定位回调调用次数：虚拟定位的回调只会调用一次，而真实定位的会多次触发；所以可以通过触发次数来判断
  - 函数响应时间：虚拟定位的响应是立马返回，而真实的不会；所以可以通过响应时间判断
- 根据`CLLocation`的私有属性`_internal`中的type来判断

上面是笔者总结的网上给出的检测方案，下面来实践，看事实是否如上所描述，下面笔者采用的是使用爱思助手虚拟经纬度的方法来模拟。
**强烈注意：**使用第三方地图的定位和系统定位回对下面对方法也有影响！！！笔者这里吃了很大的亏，好家伙。

#### 根据特征值判断

1. 定位的精度
    获取经纬度的精度，不能使用"%f"来直接格式化，因为格式化字符串默认“%f”，默认保留到小数点后第6位，对比不出来差异。
    代码如下：
    
    ``` ObjectiveC
      /// 定位经纬度的精度
      /// @param location 定位Item
      - (void)testLocationAccuracy:(CLLocation *)location {
        NSString *longitudeStr = [NSString stringWithFormat:@"%@", 
        							@(location.coordinate.longitude)];
        // NSString *longitudeStr = [[NSDecimalNumber numberWithDouble:
        	location.coordinate.longitude] stringValue]; // 这种方法取到的是17位
        NSString *lastPartLongitudeStr = [[longitudeStr
        				 	componentsSeparatedByString:@"."] lastObject];

        NSString *latitudeStr = [NSString stringWithFormat:@"%@", @(location.coordinate.latitude)];
        NSString *lastPartLatitudeStr = [[latitudeStr 
        					componentsSeparatedByString:@"."] lastObject];

        NSLog(@"定位精度的 longitude位数：%d, latitude位数：%d", 
        	lastPartLongitudeStr.length, lastPartLatitudeStr.length);
      }
    ```

    使用正常定位时，结果如下：
    ``` ObjectiveC
    定位精度的 longitude位数：13, latitude位数：14
    ```

    使用爱思助手搜索`虹桥火车站地铁站`，自动定位到经纬度是6位，输入框中最多可输入小数点后8位，开启虚拟定位后，结果如下：
    ``` ObjectiveC
    定位精度的 longitude位数：13, latitude位数：14
    ```

    笔者这里测试了很久，由于小数精度的问题，笔者换了好几种方式，最终结论是使用此方法无法判断。虽然爱思助手设置的经纬度有个数限制，但是最终定位出来的经纬度和定位出来的并不相同，且由于小数精度问题，无法准确判断。故而此方法行不通。
    

2. 定位的海拔值和海拔精度
    通过altitude和verticalAccuracy来判断，CLLocation的altitude的属性表示海拔。verticalAccuracy的属性来判断海拔的精确度。海拔数值可能会有verticalAccuracy大小的误差，当verticalAccuracy为负值时，表示不能获取海拔高度。 

    代码如下：
    
    ``` ObjectiveC
      /// 定位海拔、海拔垂直精度
      /// @param location 定位Item
      - (void)testLocationAltitudeAccuracy:(CLLocation *)location {
          NSLog(@"海拔高度：%f", location.altitude);
          NSLog(@"海拔垂直精度：%f", location.verticalAccuracy);
      }
    ```

    使用正常定位时，结果如下：

    ``` ObjectiveC
    海拔高度：9.224902
    海拔垂直精度：16.078646
    ```

    使用爱思助手开启定位后，结果如下：
    ``` ObjectiveC
    海拔高度：0.000000
    海拔垂直精度：-1.000000
    ```

    从上面可以看出，正常定位和模拟定位的海拔和海拔垂直精度是不同的，故而可以用来区分。但是真正的海拔高度为0的地方会不会被误杀，需要纳入考虑，待测试验证。

3. 定位回调调用次数
    笔者在定位类中，声明一个回调次数的属性，在调用开始定位的方法中赋值为0，回调成功的方法中每次都加1，且打印出结果。
    大致代码如下：
    
    ``` ObjectiveC

    @TestLocationManager()

    @property (nonatomic, assign) NSInteger callbackCount;

    @end

    @implementation TestLocationManager()

    - (void)startLocation {
        self.callbackCount = 0;
    }

    - (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager 
    		didUpdateLocation:(BMKLocation * _Nullable)location 
    					orError:(NSError * _Nullable)error
    {
      self.callbackCount += 1;
      NSLog(@"百度地图单次定位回调次数: %ld", self.callbackCount);
    }

    - (void)locationManager:(CLLocationManager *)manager
    		didUpdateLocations:(NSArray<CLLocation *> *)locations {
      self.callbackCount += 1;
      NSLog(@"系统定位单次定位回调次数: %ld", self.callbackCount);
    }

    @end

    ```

    使用正常定位时，结果如下：
    ``` ObjectiveC
    百度地图单次定位回调次数: 1
    系统定位单次定位回调次数: 1
    系统定位单次定位回调次数: 2
    ```

    使用爱思助手模拟定位时，结果如下：
    ``` ObjectiveC
    百度地图单次定位回调次数: 1
    系统定位单次定位回调次数: 1
    ```

    笔者这边测试出来的结果，使用第三方地图定位时虚拟定位和正常定位的回调次数没有区别，故而，使用第三方地图定位时此方法也行不通。使用系统定位时，虚拟定位和正常定位的回调次数不同，<font color="red">故而理论上使用系统定位时可以用此方法区分；但是使用这个判断的准确度并不高，因为系统定位偶尔也会只回调一次，而且，假如使用回调来判断，如何区分回调结束，是一个问题，比如笔者写了一个延时0.5s后，来查看回调次数；所以建议可以用作参考，但是不建议作为判断依据</font>

4. 函数响应时间
   笔者在定位类中，声明一个开始时间的属性，在开始调用定位的方法调用，然后定位结果的回调里取到结束时间，最后得出的时间差即是响应时间。
   代码大致如下：
    
    ``` ObjectiveC

    @TestLocationManager()

    @property (nonatomic, strong) NSDate *locateBeginDate;

    @end

    @implementation TestLocationManager()

    - (void)startLocation {
        self.locateBeginDate = [NSDate date];
    }

    - (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager 
    			didUpdateLocation:(BMKLocation * _Nullable)location 
    						orError:(NSError * _Nullable)error
    {
      NSDate *locateEndDate = [NSDate date];
      NSTimeInterval gap = [locateEndDate timeIntervalSinceDate:
      						self.locateBeginDate];
      NSLog(@"单次定位时间：%lf", gap);
    }

    @end

    ```

    使用正常定位时，结果如下：
    ``` ObjectiveC
    单次定位时间：0.332915
    ```

    使用爱思助手模拟定位时，结果如下：
    ``` ObjectiveC
    单次定位时间：0.298709
    ```
    
    根据笔者测试出的结果，定位的间隔网络好的时候并没有明显差距，无法用固定的值区分，故而此方法也行不通。

#### 根据`CLLocation`的私有属性`_internal`中的type来判断

参考[iOS防黑产虚假定位检测技术](https://cloud.tencent.com/developer/article/1800531)，按照文章描述，定位对象`CLLocation`中有一个私有属性`type`，在不同定位来源的情况下，值是不同的。

|  值  | 所表示的意义  |  备注  |
|  ----  | ----  | ----  |
| 0  | unknown |  应用程序生成的定位数据，一般在越狱设备下，通过虚拟定位程序来生成。 |
| 1 | gps |  GPS生成的定位数据  |
| 2 | nmea |    |
| 3 | accessory |  蓝牙等外部设备模拟定位生成的定位数据  |
| 4 | wifi |  WIFI定位生成的数据  |
| 5 | skyhook |  WIFI定位生成的数据  |
| 6 | cell |  手机基站定位生成的数据  |
| 7 | lac |  LAC生成的定位数据  |
| 8 | mcc |    |
| 9 | gpscoarse |    |
| 10 | pipeline |    |
| 11 | max |    |

笔者验证步骤如下：
在定位成功的回调中，判断`CLLocation`的type属性。

``` ObjectiveC

- (void)testLocationIntervalProperty:(CLLocation *)location {
    NSString *type = [location valueForKey:@"type"];
    NSLog(@"定位来源类型：%@", type);
    return;
    // 如果想要看location的全部属性，可以通过下面的方法
    unsigned int intervalCount;
    objc_property_t *properties = class_copyPropertyList([location class],
    											 &intervalCount);
    for (unsigned int y = 0; y < intervalCount; y++) {
        objc_property_t property = properties[y];
        NSString *propertyName = [[NSString alloc] initWithCString:
        							property_getName(property)];
        if ([propertyName containsString:@"type"]) {
            id propetyValue = [location valueForKey:propertyName];
            
            NSLog(@"属性名称：%@, 属性信息：%@", propertyName, propetyValue);
        }
        else {
//            NSLog(@"属性名称：%@", propertyName);
        }
    }
}

```

正常定位时，Wi-Fi打开时，结果为4；Wi-Fi关闭时，结果为6；结果如下：

``` ObjectiveC
// Wi-Fi打开时，结果为4；Wi-Fi关闭时，结果为6；移动网络也关闭时，结果为6；
// 但是网络不好时，结果为1；
定位来源类型：4
```

使用虚拟定位时，结果如下：

``` ObjectiveC
定位来源类型：1
```

但是，当使用第三方地图定位时，不论是虚拟定位，还是正常定位，结果如下：

``` ObjectiveC
定位来源类型：0
```

笔者这边对比结果如下：使用系统定位时，正常网络下虚拟定位和正常定位结果不同，但是网络不好时，定位来源类型都是1，故而区分不准确；使用第三方系统定位时，虚拟定位和正常定位结果相同，无法区分。


### 通过外接设备，发送虚拟定位数据来虚拟定位的检测

这种虚拟定位的笔者没有设备实践，但通过网上的资料，可以看出外接设备是通过蓝牙和手机连接，故而笔者推测，也可以根据`CLLocation`的私有属性`_internal`中的type来判断。因为type=3的定义是蓝牙等外部设备模拟定位生成的定位数据，所以这种虚拟定位应该可以通过此type值区分。


### 越狱设备中通过hook定位方法，来虚拟定位的检测

这种方法，笔者目前调研到的有两种，一种是直接针对越狱设备，判断出iPhone已越狱，就提示，从而避免；另外一种是判断代理方法是否被hook，以及代理方法被hook的实现是否在APP中。

方法一：判断设备是否已越狱，参考[用代码判断iOS 系统是否越狱的方法](https://www.huaweicloud.com/articles/7c6b8027253c4a97196d359840f638d9.html)

判断设备已越狱有下面几种方法
1. 判断常见越狱文件，维护一份常见越狱文件，判断其中一个存在，则说明已越狱

   ``` Swift

    /// 根据白名单判断设备是否已越狱
    /// - Returns: true-已越狱；false-未越狱
    class func isJailedDevice() -> Bool {
        let jailPaths = ["/Applications/Cydia.app", 
        				"/Library/MobileSubstrate/MobileSubstrate.dylib", 
        				"/bin/bash", 
       				"/usr/sbin/sshd",
         				"/etc/apt"]
        var isJailDevice = false
        for item in jailPaths {
            if FileManager.default.fileExists(atPath: item) {
                isJailDevice = true
                break
            }
        }
        return isJailDevice
    }

   ```

2. 判断cydia的URL Scheme，通过识别手机是否安装了Cydia.app，来判断是否已越狱。

    ``` Swift

    /// 根据cydia scheme能否打开判断是否已越狱
    /// - Returns: true-已越狱；false-未越狱
    class func isJailedDevice() -> Bool {
        let cydiaSchemeStr = "cydia://"
        if let url = URL(string: cydiaSchemeStr),
           UIApplication.shared.canOpenURL(url) {
            return true
        }
        else {
            return false
        }
    }

    ```
3. 根据能否读取系统所有应用来判断，已越狱的设备可以读取，未越狱的设备不可以
    
    ``` Swift
    /// 根据能否获取到所有应用来判断是否越狱
    /// - Returns: true-已越狱；false-未越狱
    class func isJailedDevice() -> Bool {
        let appPathStr = "/User/Applications"
        if FileManager.default.fileExists(atPath: appPathStr) {
            do {
                let appList = 
                try FileManager.default.contentsOfDirectory(atPath: 
                appPathStr)
                if appList.count > 0 {
                    return true
                }
                else {
                    return false
                }
            } catch {
                return false
            }
        }
        else {
            return false
        }
    }
    ```

方法二判断代理方法是否被hook，以及hook的实现是否在app中，参考[iOS上虚拟定位检测的探究](http://devliubo.com/2016/2016-12-23-iOS%E4%B8%8A%E8%99%9A%E6%8B%9F%E5%AE%9A%E4%BD%8D%E6%A3%80%E6%B5%8B%E7%9A%84%E6%8E%A2%E7%A9%B6.html)

注入dylib方法的实现虚拟定位，大部分会利用MethodSwizzling去hook定位方法的目标函数，method被替换的新implemention所在的module，不会与原始implemention所在的module一致。越狱插件的方式新implemention所在的module通常是插件本身的dylib；对ipa砸壳做动态库注入的方式，新implemention所在的module通常是被注入 的dylib。——来自http://devliubo.com/2016/2016-12-23-iOS%E4%B8%8A%E8%99%9A%E6%8B%9F%E5%AE%9A%E4%BD%8D%E6%A3%80%E6%B5%8B%E7%9A%84%E6%8E%A2%E7%A9%B6.html

实践：

代码如下：

``` ObjectiveC

#import <objc/runtime.h>
#import <dlfcn.h>

static void logMethodInfo(const char *className, const char *sel)
{
    Dl_info info;
    IMP imp = class_getMethodImplementation(objc_getClass(className),
    											sel_registerName(sel));
    if(dladdr(imp,&info)) {
        NSLog(@"method %s %s:", className, sel);
        NSLog(@"dli_fname:%s",info.dli_fname);
        NSLog(@"dli_sname:%s",info.dli_sname);
        NSLog(@"dli_fbase:%p",info.dli_fbase);
        NSLog(@"dli_saddr:%p",info.dli_saddr);
    } else {
        NSLog(@"error: can't find that symbol.");
    }
}

```

比如，笔者这里验证使用如下，笔者的项目中对UIView的`layoutSubviews`做了`MethodSwizzling`，而`viewDidLayoutSubviews`方法没有，对比如下：

``` ObjectiveC

- (void)testViewDidLayoutSubviews {
    const char *className = object_getClassName([UIView new]);
    SEL selector = @selector(viewDidLayoutSubviews);
    const char *selName = sel_getName(selector);
    logMethodInfo(className, selName);
}

- (void)testLayoutSubviews {
    const char *className = object_getClassName([UIView new]);
    SEL selector = @selector(layoutSubviews);
    const char *selName = sel_getName(selector);
    logMethodInfo(className, selName);
}

```

结果对比：

![wecom20210805-085332@2x.png](https://inews.gtimg.com/newsapp_ls/0/13849141373/0.png)

![wecom20210805-103558@2x.png](https://inews.gtimg.com/newsapp_ls/0/13849414536/0.png)

从上面的结果对比，发现未使用`MethodSwizzling`方法的`dli_fname`为`/usr/lib/libobjc.A.dylib`，`dli_sname`
为`_objc_msgForward`；而使用了`MethodSwizzling`方法的`dli_fname`为`/private/var/containers/Bundle/Application/0106942C-7D3F-45A9-BB1B-2C0FBD994744/xxx.app/xxx`，`dli_sname`为`-[UIView(MSCorner)ms_layoutSubviews]`，可以看出，从`dli_sname`可以判断方法是否被hook过，从`dli_fname`可以知道方法的implemention是否在项目的module中。（笔者手头没有越狱的手机，也没有做过砸壳注入，大家如果有兴趣可以验证一下试试。）

## 总结

笔者验证的结果，通过特征值中的海拔和海拔精度可以判断出使用爱思助手或者 Xcode 模拟定位，通过 type 可以区分不同定位来源。为了准确，笔者通过海拔、海拔精度、type 三个字段结合起来判断。

笔者写了一个检测的代码，仓库地址如下：https://github.com/mokong/DetectFakeLocation

原理是：使用`swizzlemethod` hook了`CLLocationManager`的`startUpdatingLocation`方法，以及`CLLocationManagerDelegate`的`locationManager:didUpdateLocations:`方法，然后检测越狱、海拔和海拔精度、定位类型，根据这几个方面判断是否是虚拟定位。

![ios_虚拟定位的方法.png](https://inews.gtimg.com/newsapp_ls/0/13851091768/0.png)


## 参考

- [iOS 虚拟定位监测](http://article.docway.net/details?id=60d5e03bcbb464046e3508b6)
- [苹果虚拟定位技术原理和检测](https://www.jianshu.com/p/7c213781c4b8)
- [免越狱虚拟定位外挂的调试小记与检测方案 | B1nGzL 著](https://zhuanlan.zhihu.com/p/46572309)
- [iOS防黑产虚假定位检测技术](https://cloud.tencent.com/developer/article/1800531)
- [iOS实现虚拟定位的多种玩法](https://juejin.cn/post/6844903975624376333)
- [iOS 识别虚拟定位调研](https://juejin.cn/post/6982907103631376420)
- [iOS上虚拟定位检测的探究](http://devliubo.com/2016/2016-12-23-iOS%E4%B8%8A%E8%99%9A%E6%8B%9F%E5%AE%9A%E4%BD%8D%E6%A3%80%E6%B5%8B%E7%9A%84%E6%8E%A2%E7%A9%B6.html)
