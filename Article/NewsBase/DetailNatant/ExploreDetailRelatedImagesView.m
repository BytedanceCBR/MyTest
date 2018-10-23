//
//  ExploreDetailRelatedImagesView.m
//  Article
//
//  Created by 冯靖君 on 15/10/9.
//
//

#import "ExploreDetailRelatedImagesView.h"
#import "ExploreDetailRelatedImagesCollectionViewCell.h"

#import "TTLabelTextHelper.h"
#import "SSAppPageManager.h"
#import "SSTracker.h"

@interface ExploreDetailRelatedImagesCollectionViewHeader : SSThemedView
@property(nonatomic, strong) UILabel *headerLabel;
+ (CGFloat)heightOfImageCollectionViewHeader;
@end

@implementation ExploreDetailRelatedImagesCollectionViewHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _headerLabel = [UILabel new];
        _headerLabel.text = @"相关图集";
        _headerLabel.font = [UIFont systemFontOfSize:[self.class headerLabelFontSize]];
        _headerLabel.numberOfLines = 1;
        [_headerLabel sizeToFit];
        _headerLabel.origin = CGPointMake(kCollectionViewHoriEdegeInsets, kCollectionViewVertEdegeInsets);
        [self addSubview:_headerLabel];
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor clearColor];
    _headerLabel.backgroundColor = [UIColor clearColor];
    _headerLabel.textColor = SSGetThemedColorWithKey(kColorText3);
}

+ (CGFloat)headerLabelFontSize
{
    return 12.f;
}

+ (CGFloat)heightOfImageCollectionViewHeader
{
    CGFloat labelHeight = [TTLabelTextHelper heightOfText:@"相关图集"
                                                 fontSize:[self headerLabelFontSize]
                                                 forWidth:[[UIScreen mainScreen] bounds].size.width
                                            forLineHeight:[self headerLabelFontSize]
                             constraintToMaxNumberOfLines:1
                                          firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    return kCollectionViewVertEdegeInsets + labelHeight + kHeaderBottomMargin;
}

@end

@interface ExploreDetailRelatedImagesCollectionViewReusableHeader : UICollectionReusableView
@property(nonatomic, strong) ExploreDetailRelatedImagesCollectionViewHeader *header;
@end

@implementation ExploreDetailRelatedImagesCollectionViewReusableHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _header = [[ExploreDetailRelatedImagesCollectionViewHeader alloc] initWithFrame:frame];
        [self addSubview:_header];
    }
    return self;
}

@end

@interface ExploreDetailRelatedImagesView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property(nonatomic, copy) NSString *groupID;
@property(nonatomic, strong) NSArray<Article *> *articles;
@end

@implementation ExploreDetailRelatedImagesView
{
    CGFloat imageWidth;
    CGFloat imageHeight;
    NSString *cellIdentifier;
    NSString *headerIdentifier;
}

- (instancetype)initWithWidth:(CGFloat)width groupID:(NSString *)groupID articles:(NSArray *)articleArray
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        _groupID = groupID;
        _articles = articleArray;
        [self configConstants];
        self.height = [self heightOfImageCollectionViewWithArticleArray:_articles];
        [self buildCollectionView];
        [self reloadThemeUI];
    }
    return self;
}

- (void)configConstants
{
    imageWidth = (self.width - kCollectionViewHoriEdegeInsets*2 - kCollectionViewCellHoriSpace)/2;
    CGFloat aspect =  0.6f;
    SSImageInfosModel *imageInfoModel = [[_articles firstObject] listMiddleImageModel];
    if (imageInfoModel.width && imageInfoModel.height) {
        aspect = MIN(imageInfoModel.height / imageInfoModel.width, aspect);
    }
    imageHeight = imageWidth * aspect;
    cellIdentifier = @"imageCollectionViewCellIdentifier";
    headerIdentifier = @"imageCollectionViewHeaderIdentifier";
}

#pragma mark - CollectionView

- (void)buildCollectionView
{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = kCollectionViewCellHoriSpace;
    layout.minimumLineSpacing = kCollectionViewCellVertSpace;
    layout.sectionInset = UIEdgeInsetsMake(0, kCollectionViewHoriEdegeInsets, kCollectionViewVertEdegeInsets, kCollectionViewHoriEdegeInsets);
    layout.headerReferenceSize = CGSizeMake(self.width - kCollectionViewHoriEdegeInsets*2, [ExploreDetailRelatedImagesCollectionViewHeader heightOfImageCollectionViewHeader]);
    
    _imageCollectionView = [[UICollectionView alloc] initWithFrame:self.frame
                                              collectionViewLayout:layout];
    _imageCollectionView.dataSource = self;
    _imageCollectionView.delegate = self;
    _imageCollectionView.allowsSelection = YES;
    _imageCollectionView.allowsMultipleSelection = NO;
    _imageCollectionView.scrollEnabled = NO;
    [_imageCollectionView registerClass:[ExploreDetailRelatedImagesCollectionViewCell class]
             forCellWithReuseIdentifier:cellIdentifier];
    [_imageCollectionView registerClass:[ExploreDetailRelatedImagesCollectionViewReusableHeader class]
             forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                    withReuseIdentifier:headerIdentifier];
    _imageCollectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:_imageCollectionView];
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor clearColor];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth = imageWidth;
    CGFloat itemHeight = [ExploreDetailRelatedImagesCollectionCellView heightOfCollectionCellItemWithArticle:_articles[indexPath.row] imageSize:CGSizeMake(imageWidth, imageHeight)];
    return CGSizeMake(itemWidth, itemHeight);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _articles.count/2 * 2;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                              withReuseIdentifier:headerIdentifier
                                                     forIndexPath:indexPath];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ExploreDetailRelatedImagesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell.cellView updateCellViewWithArticle:_articles[indexPath.row]];
    [cell.cellView layoutCellViewWithImageSize:CGSizeMake(imageWidth, imageHeight)];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //定位到url
    Article *article = _articles[indexPath.row];
    NSString *openUrl = article.openURL;
    if (isEmptyString(openUrl)) {
        openUrl = [NSString stringWithFormat:@"sslocal://detail?groupid=%@", article.uniqueID];
    }
    
    if ([[SSAppPageManager sharedManager] canOpenURL:[NSURL URLWithString:openUrl]]) {
        [[SSAppPageManager sharedManager] openURL:[NSURL URLWithString:openUrl]];
    }
    
    [SSTracker event:@"detail"
               label:@"click_related_gallery"
               value:_groupID
            extValue:nil
           extValue2:nil];
}

#pragma mark - Helper

- (CGFloat)heightOfImageCollectionViewWithArticleArray:(NSArray *)articleArray
{
    NSInteger numberOfRows = articleArray.count / 2;
    return [ExploreDetailRelatedImagesCollectionCellView heightOfCollectionCellItemWithArticle:[articleArray firstObject] imageSize:CGSizeMake(imageWidth, imageHeight)] *numberOfRows + kCollectionViewCellVertSpace * (numberOfRows - 1) + [ExploreDetailRelatedImagesCollectionViewHeader heightOfImageCollectionViewHeader] + kCollectionViewVertEdegeInsets;
}

- (CGFloat)heightOfCollectionViewHeader
{
    return [ExploreDetailRelatedImagesCollectionViewHeader heightOfImageCollectionViewHeader];
}

@end
