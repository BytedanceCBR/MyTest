//
//  TTPhotoDetailAdCollectionCell.m
//  Article
//
//  Created by yin on 16/8/2.
//
//

#import "TTPhotoDetailAdCollectionCell.h"
#import <objc/runtime.h>
#import "TTAdManager.h"

@interface TTPhotoDetailAdCellNextView ()

@property (nonatomic, copy) TTPhotoAdCellClickBlock block;

@end

@implementation TTPhotoDetailAdCellNextView

-(instancetype)initWithFrame:(CGRect)frame clickBlock:(void (^)(void))block
{
    self = [super initWithFrame: frame];
    if (self) {
        self.block = block;
        self.backgroundColor = [UIColor clearColor];
        
        
        UILabel* textLabel= [[UILabel alloc] init];
        textLabel.text = @"浏览相关图集";
        textLabel.numberOfLines = textLabel.text.length;
        textLabel.font = [UIFont systemFontOfSize:12.0f];
        textLabel.textColor = [UIColor whiteColor];
        [self addSubview:textLabel];
        
        
        WeakSelf;
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wself).offset(38);
            make.top.equalTo(wself).offset(4);
            make.height.equalTo(@12);
            make.width.equalTo(@76);
            
            //            make.centerY.equalTo(wself);
            //            make.left.equalTo(wself).offset(14);
        }];
        
        UIImageView* arrImage = [[UIImageView alloc] init];
        arrImage.image = [UIImage imageNamed:@"arrow_ad_imgdetails"];
        [self addSubview:arrImage];
        [arrImage mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(wself).offset(12);
            make.top.equalTo(wself).offset(16);
            make.height.equalTo(@10);
            make.width.equalTo(@110);
            
            //            make.left.equalTo(textLabel.mas_right);
            //            make.centerY.equalTo(textLabel);
        }];
        
//        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOn:)];
//        [self addGestureRecognizer:tap];
        
    }
    return self;
}

-(void)tapOn:(UITapGestureRecognizer*)tap
{
    if (self.block) {
        self.block();
    }
}



@end

@interface TTPhotoDetailAdCollectionCell()

@property(nonatomic, strong) TTShowImageView *imageScrollView;

@end

@implementation TTPhotoDetailAdCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageScrollView = [[TTShowImageView alloc] initWithFrame:self.contentView.bounds];
        self.imageScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageScrollView.centerY = self.contentView.centerY;
        self.imageScrollView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.imageScrollView];
        
        
        
    }
    return self;
}

- (void)prepareForReuse {
    self.imageScrollView.left = 0;
}

-(void)refreshWithData:(id)data WithContainView:(UIView *)containView WithCollectionView:(UICollectionView *)collectionView WithIndexPath:(NSIndexPath *)indexPath WithImageScrollViewDelegate:(id<TTShowImageViewDelegate>)delegate WithRefreshBlock:(TTPhotoDetailCellBlock)block{
    
    TTPhotoDetailAdModel *photoModel = nil;
    if (data && [data isKindOfClass:[TTPhotoDetailAdModel class]]) {
        photoModel = data;
    }
    else {
        photoModel = [TTAdManageInstance photoAlbum_AdModel];
    }
    
    [self configurePhotoAdView];
    
    if (delegate && [delegate conformsToProtocol:@protocol(TTShowImageViewDelegate)]) {
        
        self.imageScrollView.delegate = delegate;
        
    }
}

- (void)ScrollViewDidScrollView:(UIScrollView *)scrollView ScrollDirection:(TTPhotoDetailCellScrollDirection)scrollDirection WithScrollPersent:(CGFloat)persent WithContainView:(UIView *)containView WithScrollBlock:(TTPhotoDetailCellBlock)block{
    
    if (scrollDirection == TTPhotoDetailCellScrollDirection_Front) {
        [self refreshBlackOpaqueWithPersent: - persent];
        [self refreshRightDistanceWithPersent:1- fabs(persent)];
    }
    else if (scrollDirection == TTPhotoDetailCellScrollDirection_Current){
        
        [self refreshBlackOpaqueWithPersent: 1 - fabs(persent)];
        if (persent > 0) {
            [self refreshRightDistanceWithPersent:fabs(persent)];
        }
    }
    else if (scrollDirection == TTPhotoDetailCellScrollDirection_BackFoward){
        [self refreshBlackOpaqueWithPersent: persent];
        [self refreshRightDistanceWithPersent:0];
    }
}

-(void)configurePhotoAdView{
    
    //每次刷新cell都重置image的zoom
    [self.imageScrollView resetZoom];
    if ([TTAdManageInstance photoAlbum_hasAd]) {
        self.imageScrollView.image = [TTAdManageInstance photoAlbum_getAdImage];
    }
}

//-(void)setData:(TTPhotoDetailAdModel*)dict
//{
//    //每次刷新cell都重置image的zoom
//    [self.imageScrollView resetZoom];
//    if ([TTAdManageInstance photoAlbum_hasAd]) {
//        self.imageScrollView.image = [TTAdManageInstance photoAlbum_getAdImage];
//    }
//}

- (void)refreshBlackOpaqueWithPersent:(CGFloat)persent
{
    if (persent > 1) {
        persent = 1;
    }
    else if (persent < 0) {
        persent = 0;
    }
    self.alpha = 0.8 * persent + 0.2;
}

- (void)refreshRightDistanceWithPersent:(CGFloat)persent
{
    if (persent > 1) {
        persent = 1;
    }
    else if (persent < 0) {
        persent = 0;
    }
    
    self.imageScrollView.right = self.contentView.right - 20 * persent;
}

@end
