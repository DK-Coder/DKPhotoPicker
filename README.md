# DKPhotoPicker
获取相册照片的封装库

## 功能及简介
* 可以快速调起相册预览
* 可以自定义UI中的导航栏颜色、文字颜色等，匹配你的APP颜色
* 在照片列表中点击某一张可以进行预览，现版本只支持图片的缩放，后续更新移动操作

## demo预览
![效果图](https://github.com/DK-Coder/photoRepository/blob/master/DKPhotoPicker_1.gif)

## 使用方法
将DKPhotoPicker文件夹拖入项目中即可使用

## 方法介绍
	/**
 	  *  调用选择照片
 	  * @param controller 显示的控制器
	  * @param naviColor 导航栏颜色
	  * @param titleColor 导航栏文字颜色
	  * @param type 筛选的类型，就是在相册列表中显示的媒体类型，如果是照片，就只会显示照片
	  * @param count 最大可以选择照片的数量
	  * @param block 选择完成后回调的照片
	  */
	+ (void)showPhotoPickerOnController:(UIViewController * _Nonnull)controller
                 	 navigationBarColor:(UIColor * _Nullable)naviColor
	                         titleColor:(UIColor * _Nullable)titleColor
	                          mediaType:(DKPhotoDisplayMediaType)type
	                      maxPhotoCount:(NSUInteger)count
	                           complete:(photoChooseCompleteBlock _Nullable)block;

## 下个版本预告：
* 更新图片预览时的移动操作
