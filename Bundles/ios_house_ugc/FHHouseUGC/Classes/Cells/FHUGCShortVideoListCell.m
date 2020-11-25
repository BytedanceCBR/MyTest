//
//  FHUGCShortVideoListCell.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/11/24.
//

#import "FHUGCShortVideoListCell.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "UIViewAdditions.h"
#import "FHUGCCellHelper.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCFeedDetailJumpManager.h"
@interface FHUGCShortVideoListCell ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UIButton *rightBtn;
@property (weak, nonatomic) UICollectionView *mainCollection;
@property (strong,nonatomic) NSMutableArray *datas;
@property(nonatomic, strong) FHFeedUGCCellModel *currentModel;
@property(nonatomic, strong) FHUGCFeedDetailJumpManager *detailJumpManager;
@end

@implementation FHUGCShortVideoListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        self.detailJumpManager = [[FHUGCFeedDetailJumpManager alloc] init];
    }
    return self;
}


- (void)setupUI {
    
    self.titleLabel.top =  20;
    self.titleLabel.left =  20;
    self.titleLabel.height = 22;
    self.titleLabel.width = 100;
    
    self.rightBtn.top = 20;
    self.rightBtn.right = self.right -30;
    self.rightBtn.height = 22;
    self.rightBtn.width = 80;
    [self.rightBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.rightBtn.imageView.frame.size.width, 0, self.rightBtn.imageView.frame.size.width)];
    [self.rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, self.rightBtn.titleLabel.bounds.size.width, 0, - self.rightBtn.titleLabel.bounds.size.width)];
    
    self.mainCollection.top = self.titleLabel.bottom + 10;
    self.mainCollection.left = 15;
    self.mainCollection.width = [UIScreen mainScreen].bounds.size.width - 15;
    self.mainCollection.height = 270;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.font = [UIFont themeFontSemibold:16];
        titleLabel.text = @"精彩小视频";
        titleLabel.textColor = [UIColor themeGray1];
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return  _titleLabel;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        UIButton *rightBtn = [[UIButton alloc] init];
        rightBtn.imageView.contentMode = UIViewContentModeCenter;
        [rightBtn setTitle:@"查看更多" forState:UIControlStateNormal];
        [rightBtn setImage:[UIImage imageNamed:@"detail_question_right_arror"] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont themeFontRegular:14];
        [rightBtn addTarget:self action:@selector(gotoMore) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:rightBtn];
        _rightBtn = rightBtn;
    }
    return _rightBtn;
}
 
- (UICollectionView *)mainCollection {
    if (!_mainCollection) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 5;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        NSString *identifier = NSStringFromClass([FHUGCShortVideoListCollectionCell class]);
        UICollectionView *mainCollection = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        mainCollection.delegate  = self;
        mainCollection.dataSource = self;
        mainCollection.backgroundColor = [UIColor clearColor];
        mainCollection.showsVerticalScrollIndicator = NO;
        [mainCollection registerClass:[FHUGCShortVideoListCollectionCell class] forCellWithReuseIdentifier:identifier];
        [self.contentView addSubview:mainCollection];
        _mainCollection = mainCollection;
    }
    return _mainCollection;;
}

- (void)gotoMore {
    if (self.datas.count > 0 ) {
        FHFeedUGCCellModel *currentVideo = self.datas[0];
        [self.detailJumpManager jumpToSmallVideoDetail:currentVideo otherVideos:nil showComment:NO enterType:@"feed_content_blank" extraDic:nil isShowCurrentVideo:NO];
    }
}

#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datas.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHUGCShortVideoListCollectionCell *cell;
    NSString *identifier = NSStringFromClass([FHUGCShortVideoListCollectionCell class]);//[self cellIdentifierForEntity:data];
    if (identifier.length > 0) {
          cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        if (indexPath.row < self.datas.count) {
            [cell refreshWithData:self.datas[indexPath.row]];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    FHFeedUGCCellModel *currentVideo = self.datas[indexPath.row];
    NSMutableArray *otherVideos = [self.datas mutableCopy];
    for (int i = 0; i <indexPath.row; i++ ) {
        FHFeedUGCCellModel *videoModel = self.datas[i];
        [otherVideos removeObject:videoModel];
    }
    [otherVideos removeObject:currentVideo];
    [self.detailJumpManager jumpToSmallVideoDetail:currentVideo otherVideos:otherVideos showComment:NO enterType:@"feed_content_blank" extraDic:nil isShowCurrentVideo:YES];
}

// house_show埋点
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(168, 270);
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHFeedUGCCellModel class]] || !data) {
        return;
    }
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    self.datas = [cellModel.videoList mutableCopy];
    [self.mainCollection reloadData];
}

+ (CGFloat)heightForData:(id)data {
    //默认返回cell的默认值44;
    return 342;
}
@end

@interface FHUGCShortVideoListCollectionCell ()
@property(nonatomic, weak) UIImageView *videoImage;
@property(nonatomic, weak) UIView *blackCoverView;
@property(nonatomic, weak) UILabel *titleLabel;
@property(nonatomic, strong) CAGradientLayer *gradientLayer;
@end
@implementation FHUGCShortVideoListCollectionCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    self.videoImage.left = 0;
    self.videoImage.top = 0;
    self.videoImage.width = self.width;
    self.videoImage.height = self.height;
    
    self.blackCoverView.left = 0;
    self.blackCoverView.top = self.height - 64;
    self.blackCoverView.width = self.width;
    self.blackCoverView.height = 64;
    
    self.titleLabel.top = self.blackCoverView.top + 14;
    self.titleLabel.left = 10;
    self.titleLabel.width = self.width - 20;
    self.titleLabel.height = 0;
    
    //背景渐变
    self.gradientLayer = [CAGradientLayer layer];
    _gradientLayer.frame = self.blackCoverView.bounds;
    _gradientLayer.colors = @[(id)[[UIColor blackColor] colorWithAlphaComponent:0].CGColor,
                              (id)[[UIColor blackColor] colorWithAlphaComponent:0.56].CGColor];
    [self.blackCoverView.layer addSublayer:_gradientLayer];
}

- (UIImageView *)videoImage {
    if (!_videoImage) {
        UIImageView *videoImage = [[UIImageView alloc]init];
        videoImage.contentMode = UIViewContentModeScaleAspectFill;
        videoImage.backgroundColor = [UIColor themeGray7];
        videoImage.layer.borderWidth = 0.5;
        videoImage.layer.borderColor = [[UIColor themeGray6] CGColor];
        videoImage.layer.masksToBounds = YES;
        videoImage.layer.cornerRadius = 10;
        [self.contentView addSubview:videoImage];
        _videoImage = videoImage;
    }
    return _videoImage;;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel =  [self LabelWithFont:[UIFont themeFontMedium:14] textColor:[UIColor whiteColor]];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.numberOfLines = 2;
        [self.videoImage addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UIView *)blackCoverView {
    if (!_blackCoverView) {
        UIView *blackCoverView = [[UIView alloc]init];
        [self.videoImage addSubview:blackCoverView];
        _blackCoverView = blackCoverView;
    }
    return _blackCoverView;
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}


- (void)refreshWithData:(id)data {
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    //图片
    if (cellModel.imageList.count > 0) {
        FHFeedContentImageListModel *imageModel = [cellModel.imageList firstObject];
        if (imageModel) {
            NSArray *urls = [FHUGCCellHelper convertToImageUrls:imageModel];
            [self.videoImage bd_setImageWithURLs:urls placeholder:nil options:BDImageRequestDefaultPriority transformer:nil progress:nil completion:nil];
        }else{
            self.videoImage.image = nil;
        }
    }else{
        self.videoImage.image = nil;
    }

    if(isEmptyString(cellModel.content)){
        self.titleLabel.hidden = YES;
        self.titleLabel.text = @"";
    }else{
        self.titleLabel.hidden = NO;
        self.titleLabel.text = cellModel.content;
        CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(self.titleLabel.width, MAXFLOAT)];
        self.titleLabel.top = self.height - 10 - size.height;
        self.titleLabel.height = size.height;
    }
}

@end
