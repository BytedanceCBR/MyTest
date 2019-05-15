//
//  ExploreCollectionCellView.m
//  Article
//
//  Created by 王双华 on 16/9/23.
//
//

#import "ExploreCollectionCellView.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Book.h"
#import "SSThemed.h"
#import "TTImageView.h"
#import "TTUISettingHelper.h"
#import "UIViewAdditions.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreCollectionBookCellModel.h"
#import "TTRoute.h"

#define kBookCellTitleLabelMaxLine      1
#define kBookCellDescriLabelMaxLine     1

#define kBookCellSlideShowMoreLabelMaxLine   1
#define kBookCellSlideShowMoreImageWidth     14
#define kBookCellSlideShowMoreImageHeight    14
#define kBookCellSlideShowMoreLineHeight     (2 * [TTDeviceHelper ssOnePixel])

#define kBookCellClickShowMoreImageWidth    65
#define kBookCellClickShowMoreImageHeight   43
#define kBookCellCilckShowMoreImageBottomPadding    6

//图片距离cell顶部的间距
static inline CGFloat bookCellPicTopPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 20.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 15.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 15.f;
    } else {
        return 15.f;
    }
}

//图片宽度
static inline CGFloat bookCellPicWidth() {
    if ([TTDeviceHelper isPadDevice]) {
        return 113.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 97.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 87.f;
    } else {
        return 75.f;
    }
}

//图片高度
static inline CGFloat bookCellPicHeight() {
    return  ceil(bookCellPicWidth() * 4 / 3);
}

//书名的字体
static inline CGFloat bookCellTitleLabelFontSize(){
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 18.f;
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 14.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 14.f;
    } else {
        fontSize = 14.f;
    }
    return fontSize;
}

//描述的字体
static inline CGFloat bookCellDescriLabelFontSize(){
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 14.f;
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 11.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 11.f;
    } else {
        fontSize = 11.f;
    }
    return fontSize;
}

//图片与标题的间距
static inline CGFloat bookCellBottomPaddingToPicForTitleLabel(){
    CGFloat padding = 0;
    if([TTDeviceHelper isPadDevice]){
        padding = 10.f;
    }else if ([TTDeviceHelper is736Screen]) {
        padding = 8.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        padding = 8.f;
    } else {
        padding = 8.f;
    }
    return padding;
}

//描述Label时候标题下面的间距
static inline CGFloat bookCellBottomPaddingToTitleForDescriLabel(){
    CGFloat padding = 0;
    if ([TTDeviceHelper isPadDevice]) {
        padding = 8.f;
    } else if ([TTDeviceHelper is736Screen]) {
        padding = 6.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        padding = 6.f;
    } else {
        padding = 6.f;
    }
    return padding;
}

//描述Label底部距离cell底部间距距
static inline CGFloat bookCellDescriLabelBottomPadding(){
    CGFloat padding = 0;
    if ([TTDeviceHelper isPadDevice]) {
        padding = 21.f;
    } else if ([TTDeviceHelper is736Screen]) {
        padding = 16.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        padding = 16.f;
    } else {
        padding = 16.f;
    }
    return padding;
}

//cell高度
static inline CGFloat bookCellHeight() {
    CGFloat height = 0;
    //图片顶部
    height += bookCellPicTopPadding();
    //图片高度
    height += bookCellPicHeight();
    //图片底部与标题间距
    height += bookCellBottomPaddingToPicForTitleLabel();
    //标题高度
    height += bookCellTitleLabelFontSize();
    //标题底部与描述间距
    height += bookCellBottomPaddingToTitleForDescriLabel();
    //描述高度
    height += bookCellDescriLabelFontSize();
    //描述底部
    height += bookCellDescriLabelBottomPadding();
    return height;
}

#pragma mark - ExploreCollectionBookCell

@interface ExploreCollectionBookCell : UICollectionViewCell
@property (nonatomic, strong) TTImageView   *coverImageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *descriLabel;
@property (nonatomic, strong) TTImageInfosModel *imageInfoModel;

- (void)setupDataSourceWithModel:(ExploreCollectionBookCellModel *)model;
@end

@implementation ExploreCollectionBookCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTThemeManagerThemeModeChangedNotification object:nil];
}

- (TTImageView *)coverImageView{
    if(!_coverImageView){
        _coverImageView = [[TTImageView alloc] initWithFrame:CGRectZero];
        _coverImageView.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _coverImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _coverImageView.borderColorThemeKey = kColorLine1;
        [self.contentView addSubview:_coverImageView];
    }
    return _coverImageView;
}

- (SSThemedLabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _titleLabel.numberOfLines = kBookCellTitleLabelMaxLine;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.font = [UIFont systemFontOfSize:bookCellTitleLabelFontSize()];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (SSThemedLabel *)descriLabel{
    if(!_descriLabel){
        _descriLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _descriLabel.textColorThemeKey = kColorText3;
        _descriLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _descriLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _descriLabel.numberOfLines = kBookCellDescriLabelMaxLine;
        _descriLabel.font = [UIFont systemFontOfSize:bookCellDescriLabelFontSize()];
        [self.contentView addSubview:_descriLabel];
    }
    return _descriLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tt_themeChanged:)
                                                     name:TTThemeManagerThemeModeChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)tt_themeChanged:(NSNotification *)notification
{
    [self.coverImageView setImageWithModel:_imageInfoModel];
    
    self.coverImageView.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    self.titleLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    self.descriLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.coverImageView.imageView.image = nil;
    self.titleLabel.text = @"";
    self.descriLabel.text = @"";
    self.imageInfoModel = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat y = 0;
    y += bookCellPicTopPadding();
    self.coverImageView.frame = CGRectMake(0, y, bookCellPicWidth(), bookCellPicHeight());
    y += bookCellPicHeight() + bookCellBottomPaddingToPicForTitleLabel();
    self.titleLabel.frame = CGRectMake(0, y, bookCellPicWidth(), bookCellTitleLabelFontSize());
    y += bookCellTitleLabelFontSize() + bookCellBottomPaddingToTitleForDescriLabel();
    self.descriLabel.frame = CGRectMake(0, y, bookCellPicWidth(), bookCellDescriLabelFontSize());
}

- (void)setupDataSourceWithModel:(ExploreCollectionBookCellModel *)model
{
    self.imageInfoModel = [model imageModel];
    [self tt_themeChanged:nil];
    self.titleLabel.text = [model title];
    self.descriLabel.text = [model desc];
    [self setNeedsLayout];
}

@end

#pragma mark - ExploreCollectionBookClickShowMoreCell

@interface ExploreCollectionBookClickShowMoreCell : UICollectionViewCell
@property (nonatomic, strong) TTImageView *clickImageView;
@property (nonatomic, strong) SSThemedLabel *clickTitleLabel;
@property (nonatomic, strong) SSThemedImageView *clickArrowImageView;
@property (nonatomic, strong) SSThemedButton *clickButton;
@property (nonatomic, strong) TTImageInfosModel *imageInfoModel;
@property (nonatomic, strong) TTImageInfosModel *nightImageInfoModel;
@property (nonatomic, retain) NSString *showMoreUrl;
@property (nonatomic, retain) NSString *cardId;

- (void)setupDataSourceWithModel:(ExploreCollectionBookCellModel *)model withCardID:(NSString *)cardID;
@end

@implementation ExploreCollectionBookClickShowMoreCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTThemeManagerThemeModeChangedNotification object:nil];
}

- (TTImageView *)clickImageView{
    if(!_clickImageView){
        _clickImageView = [[TTImageView alloc] initWithFrame:CGRectZero];
        _clickImageView.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _clickImageView.enableNightCover = NO;
        [self.contentView addSubview:_clickImageView];
    }
    return _clickImageView;
}

- (SSThemedLabel *)clickTitleLabel{
    if(!_clickTitleLabel){
        _clickTitleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _clickTitleLabel.textColorThemeKey = kColorText1;
        _clickTitleLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _clickTitleLabel.numberOfLines = kBookCellTitleLabelMaxLine;
        _clickTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _clickTitleLabel.textAlignment = NSTextAlignmentLeft;
        _clickTitleLabel.font = [UIFont systemFontOfSize:bookCellTitleLabelFontSize()];
        [self.contentView addSubview:_clickTitleLabel];
    }
    return _clickTitleLabel;
}

- (SSThemedImageView *)clickArrowImageView
{
    if (!_clickArrowImageView) {
        _clickArrowImageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _clickArrowImageView.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _clickArrowImageView.imageName = @"arrow_theme_textpage";
        [self.contentView addSubview:_clickArrowImageView];
    }
    return _clickArrowImageView;
}

- (SSThemedButton *)clickButton
{
    if (!_clickButton) {
        _clickButton = [[SSThemedButton alloc] initWithFrame:CGRectZero];
        _clickButton.backgroundColor = [UIColor clearColor];
        [_clickButton addTarget:self action:@selector(clickShowMore) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_clickButton];
    }
    return _clickButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat y = 0;
    y += bookCellPicTopPadding();
    
    y += (bookCellPicHeight() - (kBookCellClickShowMoreImageHeight + kBookCellCilckShowMoreImageBottomPadding + bookCellTitleLabelFontSize())) / 2;
    y = ceil(y);
    
    CGFloat x = (bookCellPicWidth() - kBookCellClickShowMoreImageWidth) / 2;
    x = ceil(x);
    
    self.clickImageView.frame = CGRectMake(x, y, kBookCellClickShowMoreImageWidth, kBookCellClickShowMoreImageHeight);
    
    y += _clickImageView.height + kBookCellCilckShowMoreImageBottomPadding;
    
    [self.clickArrowImageView sizeToFit];
    [self.clickTitleLabel sizeToFit];
    
    CGFloat width = _clickTitleLabel.width + 3 + _clickArrowImageView.width;
    CGFloat titleX = (bookCellPicWidth() - width) / 2;
    self.clickTitleLabel.frame = CGRectMake(titleX, y, _clickTitleLabel.width, bookCellTitleLabelFontSize());
    
    self.clickArrowImageView.left = self.clickTitleLabel.right + 3;
    self.clickArrowImageView.centerY = self.clickTitleLabel.centerY;
    
    self.clickButton.frame = CGRectMake(0, bookCellPicTopPadding(), bookCellPicWidth(), bookCellPicHeight());
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tt_themeChanged:)
                                                     name:TTThemeManagerThemeModeChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)tt_themeChanged:(NSNotification *)notification
{
    BOOL isDayMode = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay);
    if (self.imageInfoModel && isDayMode) {
        [self.clickImageView setImageWithModel:_imageInfoModel];
    }
    else if (self.nightImageInfoModel && !isDayMode){
        [self.clickImageView setImageWithModel:_nightImageInfoModel];
    }
    else if(self.imageInfoModel) {
        [self.clickImageView setImageWithModel:_imageInfoModel];
    }
    
    self.clickImageView.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    self.clickTitleLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    self.clickArrowImageView.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
}

- (void)clickShowMore
{
    NSString *schemaUrl = self.showMoreUrl;
    if (!isEmptyString(schemaUrl)) {
        wrapperTrackEventWithCustomKeys(@"category", @"enter_click_novel_card", [NSString stringWithFormat:@"%@",self.cardId], nil, nil);
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:schemaUrl]];
    }
}

- (void)setupDataSourceWithModel:(ExploreCollectionBookCellModel *)model withCardID:(NSString *)cardID
{
    self.imageInfoModel = [model imageModel];
    self.nightImageInfoModel = [model nightImageModel];
    [self tt_themeChanged:nil];
    self.clickTitleLabel.text = @"查看更多";
    self.showMoreUrl = [model schemaUrl];
    self.cardId = cardID;
    [self setNeedsLayout];
}

@end

#pragma mark - ExploreCollectionCellView

@interface  ExploreCollectionCellView()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView      *collectionView;
@property (nonatomic, strong) ExploreOrderedData    *orderedData;
@property (nonatomic, strong) Book                  *book;
@property (nonatomic, strong) SSThemedView          *singleLineView;
@property (nonatomic, assign) SerialStyle           style;

@end


@implementation ExploreCollectionCellView

static NSString * const bookCellIdentifier = @"ExploreCollectionBookCell";
static NSString * const clickShowMoreCellIdentifier = @"ExploreShowClickMoreBookCellIdentifier";

- (void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        if ([orderedData.originalData isKindOfClass:[Book class]]) {
            return ceil(bookCellHeight());
        }
    }
    return 0.f;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 15;
        layout.minimumLineSpacing = 15;
        layout.headerReferenceSize = CGSizeMake(15, 0);
        layout.footerReferenceSize = CGSizeMake(15, 0);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _collectionView.scrollsToTop = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[ExploreCollectionBookCell class] forCellWithReuseIdentifier:bookCellIdentifier];
        [_collectionView registerClass:[ExploreCollectionBookClickShowMoreCell class] forCellWithReuseIdentifier:clickShowMoreCellIdentifier];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (SSThemedView *)singleLineView{
    if (!_singleLineView){
        SSThemedView *lineView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        lineView.backgroundColorThemeKey = kColorLine1;
        _singleLineView = lineView;
        [self addSubview:_singleLineView];
    }
    return _singleLineView;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    _collectionView.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
}

- (void)refreshUI {
    self.collectionView.frame = self.bounds;
    self.singleLineView.hidden = self.style == SerialStyleHasMoreCell;
    self.singleLineView.frame = CGRectMake(15, self.collectionView.bottom - 0.5, self.width - 30, 0.5);
    [self reloadThemeUI];
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
        return;
    }
    if ([self.orderedData.originalData isKindOfClass:[Book class]]) {
        self.book = (Book *)self.orderedData.originalData;
    }
    else {
        self.book = nil;
        return;
    }
    self.style = self.orderedData.book.serialStyle.integerValue;
    [self refreshUI];
    [self.collectionView reloadData];
}

- (id)cellData {
    return self.orderedData;
}

#pragma UICollectionViewDelegate
//展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger more = self.style == SerialStyleHasMoreCell ? 1:0;
    return self.book.bookList.count + more;
}

//展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = nil;
    ExploreCollectionBookCellModel *cellModel = nil;
    if (indexPath.row < [self.book.bookList count]) {
        cellIdentifier = bookCellIdentifier;
        cellModel = self.book.bookListModels[indexPath.row];
    }
    else if (indexPath.row == [self.book.bookList count] && self.style == SerialStyleHasMoreCell){
        cellIdentifier = clickShowMoreCellIdentifier;
        cellModel = self.book.moreInfoModel;
    }
    NSAssert(!isEmptyString(cellIdentifier), @"reuseIdentifier must not be nil");
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if ([cell isKindOfClass:[ExploreCollectionBookCell class]]) {
        [(ExploreCollectionBookCell *)cell setupDataSourceWithModel:cellModel];
    }
    else if ([cell isKindOfClass:[ExploreCollectionBookClickShowMoreCell class]]) {
        [(ExploreCollectionBookClickShowMoreCell *)cell setupDataSourceWithModel:cellModel withCardID:self.cardId];
    }
    NSAssert(cell, @"UICollectionCell must not be nil");
    return cell!=nil ? cell : [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
}
#pragma mark --UICollectionViewDelegateFlowLayout

//每个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.book.bookList count] || self.style == SerialStyleHasMoreCell) {
        return CGSizeMake(bookCellPicWidth(), bookCellHeight());
    }
    return CGSizeZero;
}

#pragma mark --UICollectionViewDelegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ExploreCollectionBookCellModel *cellModel = nil;
    if (indexPath.row < [self.book.bookList count]) {
        cellModel = self.book.bookListModels[indexPath.row];
    }
    NSString *schemaUrl = [cellModel schemaUrl];
    if (!isEmptyString(schemaUrl)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:schemaUrl]];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.book.bookList count]) {
        return YES;
    }
    else if (indexPath.row == self.book.bookList.count){
        return NO;
    }
    return NO;
}

@end
