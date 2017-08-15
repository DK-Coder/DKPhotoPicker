//
//  PhotoDisplayCollectionViewCell.m
//  DKPhotoPicker
//
//  Created by NSLog on 2017/8/12.
//  Copyright © 2017年 DK-Coder. All rights reserved.
//

#import "PhotoDisplayCollectionViewCell.h"
#import "UIImage+ColorExtension.h"

@interface PhotoDisplayCollectionViewCell ()
{
    CGFloat minScale;
    CGFloat maxScale;
}
@property (nonatomic, strong) UIButton *chooseButton;
// 图片缩放相关
@property (nonatomic) CGFloat totalScale;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
// 图片移动相关
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic) CGPoint lastPoint;
@end


@implementation PhotoDisplayCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds= YES;
        
        self.totalScale = 1.f;
        
        minScale = 1.f;
        maxScale = 4.f;
    }
    return self;
}

- (void)chooseButtonPressed
{
    self.chooseButton.selected = !self.chooseButton.isSelected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(displayCell:didSelected:indexPath:)]) {
        [self.delegate displayCell:self didSelected:self.chooseButton.isSelected indexPath:self.indexPath];
    }
}

- (void)pinchGestureAction:(UIPinchGestureRecognizer *)recognizer
{
    CGFloat scale = recognizer.scale;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (scale > 1.f) {
            CGPoint startPoint = [recognizer locationInView:self.contentView];
            startPoint = [self.contentView convertPoint:startPoint toView:self.displayImageView];
            self.displayImageView.layer.position = startPoint;
            self.displayImageView.layer.anchorPoint = CGPointMake(startPoint.x / CGRectGetWidth(self.displayImageView.bounds), startPoint.y / CGRectGetHeight(self.displayImageView.bounds));
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.displayImageView.transform = CGAffineTransformScale(self.displayImageView.transform, recognizer.scale, recognizer.scale);
        self.totalScale *= scale;
        recognizer.scale = 1;
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.totalScale > maxScale) {
            self.totalScale = maxScale;
            [self imageViewTransformAnimationWithScale:maxScale];
        } else if (self.totalScale < minScale) {
            self.totalScale = minScale;
            self.displayImageView.layer.position = self.contentView.center;
            self.displayImageView.layer.anchorPoint = CGPointMake(.5f, .5f);
            [self imageViewTransformAnimationWithScale:minScale];
        }
    }
}

- (void)panGestureAction:(UIPanGestureRecognizer *)recognizer
{
//    if (self.totalScale == 1) {
//        return;
//    }
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.lastPoint = [recognizer locationInView:self.contentView];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [recognizer locationInView:self.contentView];
        
        CGRect frame = self.displayImageView.frame;
        frame.origin.x -= (self.lastPoint.x - point.x);
        frame.origin.y -= (self.lastPoint.y - point.y);
        self.displayImageView.frame = frame;
        
        self.lastPoint = point;
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGRect frame = self.displayImageView.frame;
        
        if (frame.origin.x > 0) {
            frame.origin.x = 0;
        }
        if (frame.origin.y > 0) {
            frame.origin.y = 0;
        }
        if (frame.origin.x < ([UIScreen mainScreen].bounds.size.width - CGRectGetWidth(self.displayImageView.frame))) {
            frame.origin.x = ([UIScreen mainScreen].bounds.size.width - CGRectGetWidth(self.displayImageView.frame));
        }
        if (frame.origin.y < ([UIScreen mainScreen].bounds.size.height - CGRectGetHeight(self.displayImageView.frame))) {
            frame.origin.y = ([UIScreen mainScreen].bounds.size.height - CGRectGetHeight(self.displayImageView.frame));
        }
        
        [self imageViewFrameAnimationWithFrame:frame];
    }
}

- (void)imageViewTransformAnimationWithScale:(CGFloat)scale
{
    [UIView animateWithDuration:.3f animations:^{
        self.displayImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)imageViewFrameAnimationWithFrame:(CGRect)frame
{
    [UIView animateWithDuration:.3f animations:^{
        self.displayImageView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - getter
- (UIImageView *)displayImageView
{
    if (!_displayImageView) {
        _displayImageView = [[UIImageView alloc] init];
        CGFloat blankInBothSide = 0.f;
        CGFloat widthForImageView = CGRectGetWidth(self.contentView.bounds) - blankInBothSide * 2;
        CGFloat heightForImageView = CGRectGetHeight(self.contentView.bounds) - blankInBothSide * 2;
        _displayImageView.frame = CGRectMake(blankInBothSide, blankInBothSide, widthForImageView, heightForImageView);
        _displayImageView.contentMode = UIViewContentModeScaleAspectFill;
        _displayImageView.clipsToBounds = YES;
        [self.contentView addSubview:_displayImageView];
        
        _displayImageView.userInteractionEnabled = YES;
        [_displayImageView addGestureRecognizer:self.pinchGesture];
//        [_displayImageView addGestureRecognizer:self.panGesture];
    }
    return _displayImageView;
}

- (UIButton *)chooseButton
{
    if (!_chooseButton) {
        _chooseButton = [[UIButton alloc] init];
        CGFloat widthForButton = 30.f;
        _chooseButton.frame = CGRectMake(CGRectGetMaxX(self.displayImageView.frame) - widthForButton - 2.5f, 5.f, widthForButton, widthForButton);
        [_chooseButton setImage:[UIImage imageNamed:@"images.bundle/OK"] forState:UIControlStateNormal];
        
        [_chooseButton setImage:[UIImage imageNamed:@"images.bundle/OK_Filled"] forState:UIControlStateSelected];
        [_chooseButton addTarget:self action:@selector(chooseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_chooseButton];
    }
    return _chooseButton;
}

#pragma mark - setter
- (void)setImageChosen:(BOOL)imageChosen
{
    _imageChosen = imageChosen;
    
    self.chooseButton.selected = imageChosen;
}

- (void)setButtonChosenColor:(UIColor *)buttonChosenColor
{
    _buttonChosenColor = buttonChosenColor;
    
    if (buttonChosenColor != [UIColor whiteColor]) {
        UIImage *image = [UIImage imageNamed:@"images.bundle/OK_Filled"];
        [self.chooseButton setImage:[image imageWithColor:buttonChosenColor] forState:UIControlStateSelected];
    }
}

- (UIPinchGestureRecognizer *)pinchGesture
{
    if (!_pinchGesture) {
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureAction:)];
    }
    return _pinchGesture;
}

- (UIPanGestureRecognizer *)panGesture
{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    }
    return _panGesture;
}
@end
