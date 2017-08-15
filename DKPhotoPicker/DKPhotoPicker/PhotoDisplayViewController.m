//
//  PhotoDisplayViewController.m
//  DKPhotoPicker
//
//  Created by NSLog on 2017/8/12.
//  Copyright © 2017年 DK-Coder. All rights reserved.
//

#import "PhotoDisplayViewController.h"
#import "PhotoDisplayCollectionViewCell.h"
#import "PhotoInfo.h"

@interface PhotoDisplayViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSInteger chosenIndex;
}
@property (nonatomic, strong) UIButton *chooseButton;
@property (nonatomic, strong) UICollectionView *photoDisplayCollectionView;
@property (nonatomic, strong) UIView *bottomToolbarView;
@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) NSArray<PhotoInfo *> *allPhotosArray;
@property (nonatomic, strong) NSMutableArray<UIImage *> *chosenPhotosArray;
@end

@implementation PhotoDisplayViewController

- (instancetype)initWithPhotos:(NSArray *)photos chosenPhotos:(NSArray *)chosens chosenIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        self.allPhotosArray = [NSArray arrayWithArray:photos];
        self.chosenPhotosArray = [NSMutableArray arrayWithArray:chosens];
        
        chosenIndex = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self updateChooseButtonState];

    [self.photoDisplayCollectionView reloadData];
    [self.view bringSubviewToFront:self.navigationBarView];
    
    [self.photoDisplayCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:chosenIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionLeft];
    [self updateDoneButtonTitleAndState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - 内部方法实现
- (void)chooseButtonPressed:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    if (self.chosenPhotosArray.count < self.maxPhotoCount) {
        PhotoInfo *info = self.allPhotosArray[chosenIndex];
        if (sender.isSelected) {
            [self.chosenPhotosArray addObject:info.image];
        } else {
            [self.chosenPhotosArray removeObject:info.image];
        }
        [self updateDoneButtonTitleAndState];
    } else {
        sender.selected = NO;
        NSString *title = [NSString stringWithFormat:@"最多只能选择%ld张图", self.maxPhotoCount];
        [self showAlertWithTitle:title message:nil OKTitle:nil OKHandler:nil cancelTitle:@"知道了" cancelHandle:nil isDestructive:NO];
    }
}

- (void)didClickOnBackButton
{
    if (self.displayCompleteBlock) {
        self.displayCompleteBlock(self.chosenPhotosArray);
    }
}

- (void)doneButtonPressed
{
    if (self.chooseCompleteBlock) {
        self.chooseCompleteBlock(self.chosenPhotosArray);
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (void)toggleShowTopAndBottomViewWithAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:.3f animations:^{
            self.navigationBarView.alpha = !self.navigationBarView.alpha;
            self.bottomToolbarView.alpha = !self.bottomToolbarView.alpha;
        } completion:^(BOOL finished) {
            if (finished) {
                self.navigationBarView.hidden = !self.navigationBarView.isHidden;
                self.bottomToolbarView.hidden = !self.bottomToolbarView.isHidden;
            }
        }];
    } else {
        self.navigationBarView.hidden = !self.navigationBarView.isHidden;
        self.bottomToolbarView.hidden = !self.bottomToolbarView.isHidden;
        self.navigationBarView.alpha = !self.navigationBarView.alpha;
        self.bottomToolbarView.alpha = !self.bottomToolbarView.alpha;
    }
}

- (void)updateDoneButtonTitleAndState
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

- (void)updateChooseButtonState
{
    PhotoInfo *info = self.allPhotosArray[chosenIndex];
    self.chooseButton.selected = [self.chosenPhotosArray containsObject:info.image];
}

#pragma mark - scrollview 代理
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    chosenIndex = offsetX / CGRectGetWidth(scrollView.frame);
    
    [self updateChooseButtonState];
}

#pragma mark - collectionview 数据源
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allPhotosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoDisplayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoDisplayCollectionViewCellIdentifier forIndexPath:indexPath];
    PhotoInfo *info = self.allPhotosArray[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.displayImageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.displayImageView.clipsToBounds = NO;
    cell.displayImageView.image = info.image;
    cell.indexPath = indexPath;
    
    return cell;
}

#pragma mark - collectionview 代理
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self toggleShowTopAndBottomViewWithAnimated:NO];
}

#pragma mark - getter
- (UIButton *)chooseButton
{
    if (!_chooseButton) {
        _chooseButton = [[UIButton alloc] init];
        CGFloat widthForButton = 40.f;
        _chooseButton.frame = CGRectMake(CGRectGetMaxX(self.navigationBarView.frame) - widthForButton - 2.5f, CGRectGetHeight(self.navigationBarView.frame) - widthForButton - 5.f, widthForButton, widthForButton);
        [_chooseButton setImage:[UIImage imageNamed:@"images.bundle/OK"] forState:UIControlStateNormal];
        
        [_chooseButton setImage:[UIImage imageNamed:@"images.bundle/OK_Filled"] forState:UIControlStateSelected];
        [_chooseButton addTarget:self action:@selector(chooseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationBarView addSubview:_chooseButton];
    }
    return _chooseButton;
}

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
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0.f;
        flowLayout.minimumInteritemSpacing = 0.f;
        flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
        
        _photoDisplayCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _photoDisplayCollectionView.frame = CGRectMake(0.f, 0.f, SCREEN_WIDTH, SCREEN_HEIGHT);
        _photoDisplayCollectionView.backgroundColor = [UIColor blackColor];
        _photoDisplayCollectionView.delegate = self;
        _photoDisplayCollectionView.dataSource = self;
        _photoDisplayCollectionView.showsVerticalScrollIndicator = NO;
        _photoDisplayCollectionView.showsHorizontalScrollIndicator = NO;
        _photoDisplayCollectionView.pagingEnabled = YES;
        [_photoDisplayCollectionView registerClass:[PhotoDisplayCollectionViewCell class] forCellWithReuseIdentifier:kPhotoDisplayCollectionViewCellIdentifier];
        [self.view insertSubview:_photoDisplayCollectionView belowSubview:self.bottomToolbarView];
    }
    return _photoDisplayCollectionView;
}
@end
