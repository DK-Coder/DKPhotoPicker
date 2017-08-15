//
//  ImageAndTextTableViewCell.m
//  DKPhotoPicker
//
//  Created by NSLog on 2017/8/10.
//  Copyright © 2017年 DK-Coder. All rights reserved.
//

#import "ImageAndTextTableViewCell.h"

@interface ImageAndTextTableViewCell ()
{
    
}
@property (nonatomic, strong) UILabel *photoNumberLabel;
@property (nonatomic, strong) UIImageView *rightIndicatorImageView;
@end


@implementation ImageAndTextTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat widthForCell    = CGRectGetWidth(self.contentView.frame);
    CGFloat heightForCell   = CGRectGetHeight(self.contentView.frame);
    // 布局封面imageview
    self.coverImageView.frame = CGRectMake(0.f, 0.f, heightForCell, heightForCell);
    // 布局相册名称label
    CGFloat widthForAlbumNameLabel = [self.albumNameLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, heightForCell)].width;
    self.albumNameLabel.frame = CGRectMake(CGRectGetMaxX(self.coverImageView.frame) + 10.f, 0.f, widthForAlbumNameLabel, heightForCell);
    // 布局照片数量label
    self.photoNumberLabel.frame = CGRectMake(CGRectGetMaxX(self.albumNameLabel.frame) + 10.f, 0.f, 50.f, heightForCell);
    // 布局右边指示器
    CGFloat widthForRightIndicator = heightForCell / 2.f;
    self.rightIndicatorImageView.frame = CGRectMake(widthForCell - widthForRightIndicator - 10.f, (heightForCell - widthForRightIndicator) / 2.f, widthForRightIndicator, widthForRightIndicator);
}

#pragma mark - getter
- (UIImageView *)coverImageView
{
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
        [self.contentView addSubview:_coverImageView];
    }
    return _coverImageView;
}

- (UILabel *)albumNameLabel
{
    if (!_albumNameLabel) {
        _albumNameLabel = [[UILabel alloc] init];
        _albumNameLabel.font = [UIFont boldSystemFontOfSize:16.f];
        [self.contentView addSubview:_albumNameLabel];
    }
    return _albumNameLabel;
}

- (UILabel *)photoNumberLabel
{
    if (!_photoNumberLabel) {
        _photoNumberLabel = [[UILabel alloc] init];
        _photoNumberLabel.textColor = [UIColor grayColor];
        _photoNumberLabel.font = [UIFont systemFontOfSize:16.f];
        [self.contentView addSubview:_photoNumberLabel];
    }
    return _photoNumberLabel;
}

- (UIImageView *)rightIndicatorImageView
{
    if (!_rightIndicatorImageView) {
        _rightIndicatorImageView = [[UIImageView alloc] init];
        _rightIndicatorImageView.image = [UIImage imageNamed:@"images.bundle/arrow_right"];
        [self.contentView addSubview:_rightIndicatorImageView];
    }
    return _rightIndicatorImageView;
}

#pragma mark - setter
- (void)setPhotoNumberInAlbum:(NSInteger)photoNumberInAlbum
{
    _photoNumberInAlbum = photoNumberInAlbum;
    
    self.photoNumberLabel.text = [NSString stringWithFormat:@"(%ld)", photoNumberInAlbum];
}
@end
