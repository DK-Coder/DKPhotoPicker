//
//  BaseViewController.h
//  DKPhotoPicker
//
//  Created by NSLog on 2017/8/11.
//  Copyright © 2017年 DK-Coder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+ColorExtension.h"

@protocol BaseViewControllerProtocol <NSObject>

@optional
- (void)didClickOnBackButton;

@end

typedef NS_ENUM(NSUInteger, DKPhotoDisplayMediaType) {
    DKPhotoDisplayMediaTypePhoto = 0
};

typedef void(^photoChooseCompleteBlock)(NSArray<UIImage *> * _Nullable photos);

#define weakifySelf() weakify(self, weakSelf)
#define weakify(object, objectName) __weak typeof(object) objectName = object
#define strongify(object, objectName) __strong typeof(object) objectName = object
#define strongifySelf() strongify(weakSelf, strongSelf)

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define rgba(r, g, b, a) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a]
#define rgb(r, g, b) rgba(r, g, b, 1.f)

@class PHAsset;
@interface BaseViewController : UIViewController <BaseViewControllerProtocol>

/**
 *  自定义导航栏颜色，默认rgb为51，204，255
 */
@property (nonnull, nonatomic, strong) UIColor *navigationBarBackgroundColor;

/**
 *  自定义导航栏标题，默认为相册的名称
 */
@property (nonnull, nonatomic, copy) NSString *navigationBarTitle;

/**
 *  自定义标题颜色，默认为白色
 */
@property (nonnull, nonatomic, strong) UIColor *titleColor;

/**
 *
 */
@property (nonnull, nonatomic, strong) UIView *navigationBarView;

/**
 *  相册中支持的类型，目前只支持照片
 */
@property (nonatomic) DKPhotoDisplayMediaType mediaType;

/**
 *  最多可选择的照片数量
 */
@property (nonatomic) NSUInteger maxPhotoCount;

@property (nullable, nonatomic, copy) photoChooseCompleteBlock chooseCompleteBlock;


- (void)showAlertWithTitle:(NSString * _Nonnull)title
                   message:(NSString * _Nullable)message
                   OKTitle:(NSString * _Nullable)okTitle
                 OKHandler:(void (^ _Nullable)(UIAlertAction * _Nullable))OKHandler
               cancelTitle:(NSString * _Nonnull)cancelTitle
              cancelHandle:(void (^ _Nullable)(UIAlertAction * _Nullable))cancelHandler
             isDestructive:(BOOL)isDestructive;

- (void)requestImageByAsset:(PHAsset * _Nonnull)asset
                 targetSize:(CGSize)size
                   complete:(void (^ _Nullable)(UIImage * _Nullable image, NSDictionary * _Nullable info))resultHandler;
@end
