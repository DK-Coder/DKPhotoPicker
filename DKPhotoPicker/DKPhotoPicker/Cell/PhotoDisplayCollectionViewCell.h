//
//  PhotoDisplayCollectionViewCell.h
//  DKPhotoPicker
//
//  Created by NSLog on 2017/8/12.
//  Copyright © 2017年 DK-Coder. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoDisplayCollectionViewCell;
@protocol PhotoDisplayCollectionViewCellDelegate <NSObject>

@optional
- (void)displayCell:(PhotoDisplayCollectionViewCell *)cell didSelected:(BOOL)isSelected indexPath:(NSIndexPath *)indexPath;

@end

static NSString *kPhotoDisplayCollectionViewCellIdentifier = @"kPhotoDisplayCollectionViewCellIdentifier";

@interface PhotoDisplayCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *displayImageView;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) id<PhotoDisplayCollectionViewCellDelegate> delegate;

@property (nonatomic, getter=isImageChosen) BOOL imageChosen;

@property (nonatomic, strong) UIColor *buttonChosenColor;
@end
