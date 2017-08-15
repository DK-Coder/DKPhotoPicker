//
//  ViewController.m
//  DKPhotoPicker
//
//  Created by NSLog on 2017/8/9.
//  Copyright © 2017年 DK-Coder. All rights reserved.
//

#import "ViewController.h"
#import "DKPhotoPicker.h"

@interface ViewController ()
{
    
}
@property (nonatomic, strong) UIScrollView *imageContainScrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = [UIColor orangeColor];
    button.frame = CGRectMake(20.f, 64.f, 120.f, 50.f);
    [button setTitle:@"从相册中选择" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonPressed:(UIButton *)sender
{
    [DKPhotoPicker showPhotoPickerOnController:self navigationBarColor:nil titleColor:nil mediaType:DKPhotoDisplayMediaTypePhoto maxPhotoCount:9 complete:^(NSArray<UIImage *> * _Nullable photos) {
        if (photos) {
            [self clearAllImageInContainView];
            NSInteger numberPerRow = 4;
            CGFloat padding = 5.f;
            CGFloat width = (CGRectGetWidth(self.view.frame) - (numberPerRow + 1) * padding) / numberPerRow;
            CGFloat height = width * SCREEN_HEIGHT / SCREEN_WIDTH;
            for (NSInteger i = 0, length = photos.count; i < length; i++) {
                UIImage *image = photos[i];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                imageView.frame = CGRectMake(width * (i % numberPerRow) + padding * ((i % numberPerRow) + 1), (height + padding) * (i / numberPerRow), width, height);
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.clipsToBounds = YES;
                [self.imageContainScrollView addSubview:imageView];
                if (i == length - 1) {
                    CGFloat maxY = CGRectGetMaxY(imageView.frame);
                    if (maxY > CGRectGetHeight(self.imageContainScrollView.frame)) {
                        self.imageContainScrollView.contentSize = CGSizeMake(0.f, maxY);
                    }
                }
            }
        }
    }];
}

- (void)clearAllImageInContainView
{
    NSArray *subviews = self.imageContainScrollView.subviews;
    for (UIImageView *imageView in subviews) {
        [imageView removeFromSuperview];
    }
}

- (UIScrollView *)imageContainScrollView
{
    if (!_imageContainScrollView) {
        _imageContainScrollView = [[UIScrollView alloc] init];
        _imageContainScrollView.frame = CGRectMake(0.f, 120, SCREEN_WIDTH, 400.f);
        _imageContainScrollView.backgroundColor = [UIColor clearColor];
        _imageContainScrollView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:_imageContainScrollView];
    }
    return _imageContainScrollView;
}
@end
