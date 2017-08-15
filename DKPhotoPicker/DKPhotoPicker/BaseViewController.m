//
//  BaseViewController.m
//  DKPhotoPicker
//
//  Created by NSLog on 2017/8/11.
//  Copyright © 2017年 DK-Coder. All rights reserved.
//

#import "BaseViewController.h"
#import "UIImage+ColorExtension.h"
#import <Photos/Photos.h>
#import "PhotoDisplayViewController.h"

@interface BaseViewController ()
{
    
}
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation BaseViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initParams];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self setupNavigationBarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 对外方法
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message OKTitle:(NSString *)okTitle OKHandler:(void (^)(UIAlertAction * _Nullable))OKHandler cancelTitle:(NSString * _Nonnull)cancelTitle cancelHandle:(void (^)(UIAlertAction * _Nullable))cancelHandler isDestructive:(BOOL)isDestructive
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    // 生成按钮
    UIAlertAction *actionOK;
    if (okTitle && okTitle.length > 0) {
        if (isDestructive) {
            actionOK = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDestructive handler:OKHandler];
        } else {
            actionOK = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:OKHandler];
        }
    }
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:cancelHandler];
    // 添加按钮到alert
    [alert addAction:actionCancel]; // 根据苹果规范，将取消按钮放在左边
    if (actionOK) {
        [alert addAction:actionOK];
    }
    
    // 最后显示该提示框
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 内部方法
- (void)initParams
{
    _titleColor = [UIColor whiteColor];
    _navigationBarBackgroundColor = rgb(51, 204, 255);
}

- (void)setupNavigationBarView
{
    [self.view addSubview:self.navigationBarView];
    [self.navigationBarView addSubview:self.titleLabel];
    if (![self isKindOfClass:[PhotoDisplayViewController class]]) {
        [self.navigationBarView addSubview:self.cancelButton];
    }
    if (self != self.navigationController.viewControllers.firstObject) {
        [self.navigationBarView addSubview:self.backButton];
    }
}

- (void)buttonPressed:(UIButton *)sender
{
    if (sender == self.backButton) {
        if ([self respondsToSelector:@selector(didClickOnBackButton)]) {
            [self didClickOnBackButton];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else if (sender == self.cancelButton) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)requestImageByAsset:(PHAsset *)asset targetSize:(CGSize)size complete:(void (^)(UIImage *_Nullable image, NSDictionary *_Nullable info))resultHandler
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，不缩放；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    option.resizeMode = PHImageRequestOptionsResizeModeFast;//控制照片尺寸
    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    option.synchronous = YES;
    option.networkAccessAllowed = YES;
    
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        resultHandler(result, info);
    }];
}

#pragma mark - getter
- (UIView *)navigationBarView
{
    if (!_navigationBarView) {
        _navigationBarView = [[UIView alloc] init];
        _navigationBarView.frame = CGRectMake(0.f, 0.f, SCREEN_WIDTH, 64.f);
        _navigationBarView.backgroundColor = self.navigationBarBackgroundColor;
    }
    return _navigationBarView;
}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        CGFloat width = 30.f;
        _backButton.frame = CGRectMake(5.f, CGRectGetHeight(self.navigationBarView.frame) - width - 5.f, width, width);
        UIImage *image = [UIImage imageNamed:@"images.bundle/arrow_left"];
        if (self.titleColor != [UIColor whiteColor]) {
            image = [image imageWithColor:self.titleColor];
        }
        [_backButton setImage:image forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        CGFloat width = 260.f;
        CGFloat height = 30.f;
        _titleLabel.frame = CGRectMake((SCREEN_WIDTH - width) / 2, CGRectGetHeight(self.navigationBarView.frame) - height - 5.f, width, height);
        _titleLabel.text = self.navigationBarTitle;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = self.titleColor;
        _titleLabel.font = [UIFont boldSystemFontOfSize:20.f];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _titleLabel;
}

- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        CGFloat width = 45.f;
        CGFloat height = 30.f;
        _cancelButton.frame = CGRectMake(CGRectGetWidth(self.navigationBarView.frame) - width, CGRectGetHeight(self.navigationBarView.frame) - height - 5.f, width, height);
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:self.titleColor forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

#pragma mark - setter
- (void)setNavigationBarBackgroundColor:(UIColor *)navigationBarBackgroundColor
{
    if (navigationBarBackgroundColor) {
        _navigationBarBackgroundColor = navigationBarBackgroundColor;
        
        self.navigationBarView.backgroundColor = navigationBarBackgroundColor;
    }
}

- (void)setNavigationBarTitle:(NSString *)navigationBarTitle
{
    _navigationBarTitle = navigationBarTitle;
    
    self.titleLabel.text = navigationBarTitle;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    if (titleColor) {
        _titleColor = titleColor;
        
        _titleLabel.textColor = titleColor;
        [_cancelButton setTitleColor:titleColor forState:UIControlStateNormal];
    }
}
@end
