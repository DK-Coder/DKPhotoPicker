//
//  PhotoListViewController.m
//  DKPhotoPicker
//
//  Created by NSLog on 2017/8/11.
//  Copyright © 2017年 DK-Coder. All rights reserved.
//

#import "PhotoListViewController.h"
#import <Photos/Photos.h>
#import "PhotoDisplayCollectionViewCell.h"
#import "PhotoInfo.h"
#import "PhotoDisplayViewController.h"

@interface PhotoListViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
                                        PhotoDisplayCollectionViewCellDelegate>
{
    PHAssetCollection *chosenAssetCollection;
}
@property (nonatomic, strong) UIView *bottomToolbarView;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UICollectionView *photoDisplayCollectionView;
@property (nonatomic, strong) UIActivityIndicatorView *progressIndicator;
@property (nonatomic, strong) UILabel *loadingLabel;

@property (nonatomic, strong) NSMutableArray<PhotoInfo *> *photoInfoArray;
@property (nonatomic, strong) NSMutableArray<UIImage *> *chosenPhotosArray;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *photoAssetArray;
@end

@implementation PhotoListViewController

- (instancetype)initWithChosenAssetCollection:(PHAssetCollection *)assetCollection
{
    self = [super init];
    if (self) {
        chosenAssetCollection = assetCollection;
        self.navigationBarTitle = assetCollection.localizedTitle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
    [self toggleShowLoading:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetchPhotoInAlbum];
    });
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.chosenPhotosArray removeAllObjects];
    [self.photoDisplayCollectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)toggleShowLoading:(BOOL)isShow
{
    if (isShow) {
        [self.progressIndicator startAnimating];
        self.loadingLabel.hidden = NO;
    } else {
        [self.progressIndicator stopAnimating];
        self.loadingLabel.hidden = YES;
    }
}

- (void)fetchPhotoInAlbum
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:chosenAssetCollection options:options];
    if (result.count > 0) {
        for (PHAsset *asset in result) {
            if (self.mediaType == DKPhotoDisplayMediaTypePhoto) {
                if (asset.mediaType == PHAssetMediaTypeImage) {
                    PhotoInfo *photo = [[PhotoInfo alloc] init];
                    [self requestImageByAsset:asset targetSize:CGSizeMake(SCREEN_WIDTH * 3, SCREEN_HEIGHT * 3) complete:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
                        photo.image = image;
                        photo.index = self.photoInfoArray.count;
                        
                        
                        if (![self.photoInfoArray containsObject:photo]) {
                            [self.photoInfoArray addObject:photo];
                            [self.photoAssetArray addObject:asset];
                        }
                    }];
                }
            }
        }
    }
    [self.photoDisplayCollectionView reloadData];
    [self toggleShowLoading:NO];
}

- (void)doneButtonPressed
{
    if (self.chooseCompleteBlock) {
        self.chooseCompleteBlock(self.chosenPhotosArray);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateButtonTitleAndState
{
    NSInteger chosenCount = self.chosenPhotosArray.count;
    NSString *buttonTitle;
    if (chosenCount > 0) {
        buttonTitle = [NSString stringWithFormat:@"完成(%ld)", chosenCount];
    } else {
        buttonTitle = @"完成";
    }
    self.doneButton.enabled = chosenCount > 0;
    [self.doneButton setTitle:buttonTitle forState:UIControlStateNormal];
}

#pragma mark - photodisplaycell 代理
- (void)displayCell:(PhotoDisplayCollectionViewCell *)cell didSelected:(BOOL)isSelected indexPath:(NSIndexPath *)indexPath
{
    if (self.chosenPhotosArray.count < self.maxPhotoCount) {
        PhotoInfo *info = self.photoInfoArray[indexPath.row];
        if (isSelected) {
            [self.chosenPhotosArray addObject:info.image];
        } else {
            [self.chosenPhotosArray removeObject:info.image];
        }
        [self updateButtonTitleAndState];
    } else {
        cell.imageChosen = NO;
        NSString *title = [NSString stringWithFormat:@"最多只能选择%ld张图", self.maxPhotoCount];
        [self showAlertWithTitle:title message:nil OKTitle:nil OKHandler:nil cancelTitle:@"知道了" cancelHandle:nil isDestructive:NO];
    }
}

#pragma mark - collectionview 数据源
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoInfoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoDisplayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoDisplayCollectionViewCellIdentifier forIndexPath:indexPath];
    PhotoInfo *info = self.photoInfoArray[indexPath.row];
    cell.displayImageView.image = info.image;
    cell.indexPath = indexPath;
    cell.buttonChosenColor = self.navigationBarBackgroundColor;
    cell.delegate = self;
    cell.imageChosen = [self.chosenPhotosArray containsObject:info.image];
    
    return cell;
}

#pragma mark - collectionview 代理
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoDisplayViewController *controller = [[PhotoDisplayViewController alloc] initWithPhotos:self.photoInfoArray chosenPhotos:self.chosenPhotosArray chosenIndex:indexPath.row];
    controller.chooseCompleteBlock = self.chooseCompleteBlock;
    controller.mediaType = self.mediaType;
    controller.maxPhotoCount = self.maxPhotoCount;
    controller.displayCompleteBlock = ^(NSArray<UIImage *> *chosen) {
        for (UIImage *image in chosen) {
            if (![self.chosenPhotosArray containsObject:image]) {
                [self.chosenPhotosArray addObject:image];
            }
        }
        [self.photoDisplayCollectionView reloadData];
        [self updateButtonTitleAndState];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - getter
- (UIView *)bottomToolbarView
{
    if (!_bottomToolbarView) {
        _bottomToolbarView = [[UIView alloc] init];
        CGFloat heightForToolbarView = 50.f;
        _bottomToolbarView.frame = CGRectMake(0.f, SCREEN_HEIGHT - heightForToolbarView, SCREEN_WIDTH, heightForToolbarView);
        _bottomToolbarView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_bottomToolbarView];
        
        // 添加控件
        [_bottomToolbarView addSubview:self.doneButton];
    }
    return _bottomToolbarView;
}

- (UIButton *)doneButton
{
    if (!_doneButton) {
        _doneButton = [[UIButton alloc] init];
        CGFloat widthForButton = 90.f;
        CGFloat heightForButton = CGRectGetHeight(_bottomToolbarView.bounds) - 10.f;
        _doneButton.frame = CGRectMake(CGRectGetWidth(_bottomToolbarView.bounds) - widthForButton - 10.f, (CGRectGetHeight(_bottomToolbarView.bounds) - heightForButton) / 2.f, widthForButton, heightForButton);
        _doneButton.enabled = NO;
        _doneButton.layer.cornerRadius = heightForButton / 4.f;
        _doneButton.layer.masksToBounds = YES;
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
        [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [_doneButton setTitleColor:rgb(217, 217, 217) forState:UIControlStateDisabled];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton setBackgroundImage:[UIImage createImageWithColor:rgb(0, 142, 189)] forState:UIControlStateDisabled];
        [_doneButton setBackgroundImage:[UIImage createImageWithColor:rgb(51, 204, 255)] forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (UICollectionView *)photoDisplayCollectionView
{
    if (!_photoDisplayCollectionView) {
        CGFloat gap = 3.f;
        CGFloat widthForItem = SCREEN_WIDTH / 4 - gap;
        CGFloat heightForItem = widthForItem;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.minimumLineSpacing = gap;
        flowLayout.minimumInteritemSpacing = gap;
        flowLayout.itemSize = CGSizeMake(widthForItem, heightForItem);
        
        _photoDisplayCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _photoDisplayCollectionView.frame = CGRectMake(0.f, CGRectGetMaxY(self.navigationBarView.frame), SCREEN_WIDTH, SCREEN_HEIGHT - 64.f - CGRectGetHeight(self.bottomToolbarView.frame));
        _photoDisplayCollectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _photoDisplayCollectionView.delegate = self;
        _photoDisplayCollectionView.dataSource = self;
        [_photoDisplayCollectionView registerClass:[PhotoDisplayCollectionViewCell class] forCellWithReuseIdentifier:kPhotoDisplayCollectionViewCellIdentifier];
        [self.view addSubview:_photoDisplayCollectionView];
    }
    return _photoDisplayCollectionView;
}

- (UIActivityIndicatorView *)progressIndicator
{
    if (!_progressIndicator) {
        _progressIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _progressIndicator.frame = CGRectMake(0.f, 0.f, 20.f, 20.f);
        _progressIndicator.center = self.view.center;
        _progressIndicator.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        [self.view addSubview:_progressIndicator];
    }
    return _progressIndicator;
}

- (UILabel *)loadingLabel
{
    if (!_loadingLabel) {
        _loadingLabel = [[UILabel alloc] init];
        _loadingLabel.frame = CGRectMake(0.f, CGRectGetMaxY(self.progressIndicator.frame) + 10.f, SCREEN_WIDTH, 40.f);
        _loadingLabel.text = @"正在加载……";
        _loadingLabel.textAlignment = NSTextAlignmentCenter;
        _loadingLabel.textColor = [UIColor grayColor];
        _loadingLabel.font = [UIFont systemFontOfSize:16.f];
        [self.view addSubview:_loadingLabel];
    }
    return _loadingLabel;
}

- (NSMutableArray<PhotoInfo *> *)photoInfoArray
{
    if (!_photoInfoArray) {
        _photoInfoArray = [NSMutableArray array];
    }
    return _photoInfoArray;
}

- (NSMutableArray<UIImage *> *)chosenPhotosArray
{
    if (!_chosenPhotosArray) {
        _chosenPhotosArray = [NSMutableArray array];
    }
    return _chosenPhotosArray;
}

- (NSMutableArray<PHAsset *> *)photoAssetArray
{
    if (!_photoAssetArray) {
        _photoAssetArray = [NSMutableArray array];
    }
    return _photoAssetArray;
}
@end
