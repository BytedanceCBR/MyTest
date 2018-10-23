//
//  TTPhotoDetailAdNewCollectionViewCell.m
//  Article
//
//  Created by ranny_90 on 2017/4/11.
//
//

#import "TTPhotoDetailAdNewCollectionViewCell.h"
#import "TTAdManager.h"

#define DEFUALTPORTITIMAGEHEIGHT 180
#define DEFALTLANSCAPEIMAGEWIDTH 345
#define DEFALTLANSCAPEIMAGEHEIGHT 180

@interface TTPhotoDetailAdNormalView ()

@property(nonatomic, strong) TTPhotoDetailAdModel *detailModel;

@property (nonatomic, strong) UIImage *image;

@end

@implementation TTPhotoDetailAdNormalView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleLabel = [[SSThemedLabel alloc] init];
        //这块什么意思
        self.titleLabel.autoresizingMask = UIViewAutoresizingNone;
        self.titleLabel.textColor = [UIColor colorWithHexString:@"e8e8e8"];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        self.titleLabel.numberOfLines = 2;
        [self addSubview:self.titleLabel];
        
        
        self.imageScrollView= [[TTShowImageView alloc] init];
        self.imageScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imageScrollView];
        
        self.imageScrollView.userInteractionEnabled = NO;
    }
    return self;
}


-(void)configureDetailModel:(TTPhotoDetailAdModel *)detailModel WithAdImage:(UIImage *)adImage{
    
    if (!detailModel || !detailModel.image_recom) {
        
        //怎样处理这里的容错---------
    }
    
    self.detailModel = detailModel;

    [self.imageScrollView resetZoom];
    if (adImage) {
        self.imageScrollView.image = adImage;
        self.image = adImage;
    }
    
    if (self.detailModel.image_recom.title) {
        self.titleLabel.text = self.detailModel.image_recom.title;
    }
    else {
        self.titleLabel.text = @"";
    }
    
    [self updateFrame];
}


-(CGSize)updateFrame{
    
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        
        self.titleLabel.preferredMaxLayoutWidth = SSScreenWidth - 30;
        
        CGFloat titleLabelWidth = SSScreenWidth - 30;
        CGSize textViewSize = [self.titleLabel sizeThatFits:CGSizeMake(titleLabelWidth, FLT_MAX)];
        CGFloat titleLabelHeight = textViewSize.height + 3;
        self.titleLabel.frame = CGRectMake(15, 0, titleLabelWidth, titleLabelHeight);
        
        CGFloat imageViewwidth = SSScreenWidth - 30;
        CGFloat imageViewHeight = DEFUALTPORTITIMAGEHEIGHT;
        CGFloat originY = CGRectGetMaxY(self.titleLabel.frame) + 4;
        CGFloat orginX = 15;
        //此处需要进一步确定image的宽高
        if (self.image && self.image.size.width > 0) {
            
            imageViewHeight = imageViewwidth * (self.image.size.height/self.image.size.width);
        }
        
        self.imageScrollView.frame = CGRectMake(orginX, originY, imageViewwidth, imageViewHeight);
        
        
        CGFloat viewWidth = SSScreenWidth;
        CGFloat viewHeight = CGRectGetHeight(self.titleLabel.frame) + 4 + CGRectGetHeight(self.imageScrollView.frame);
        return CGSizeMake(viewWidth, viewHeight);
    }
    
    //横屏的情况
    else {
        
        
        CGFloat imageViewWidth = DEFALTLANSCAPEIMAGEWIDTH;
        CGFloat imageViewHeight = DEFALTLANSCAPEIMAGEHEIGHT;
        
        if (self.image && self.image.size.width > 0 && self.image.size.height > 0) {
            
            imageViewHeight = (SSScreenHeight - 30) * (self.image.size.height/self.image.size.width);
            if (self.image.size.height > 0) {
                imageViewWidth = imageViewHeight * (self.image.size.width/self.image.size.height);
            }
        }
        
        CGFloat titleLabelWidth = imageViewWidth;
        CGSize textViewSize = [self.titleLabel sizeThatFits:CGSizeMake(titleLabelWidth, FLT_MAX)];
        CGFloat titleLabelHeight = textViewSize.height;
        CGFloat titlelabelOriginX = 0;
        CGFloat titlelabelOriginY = 0;
        
        CGFloat imageVieworginX = 0;
        CGFloat imageVieworginY = CGRectGetMaxY(self.titleLabel.frame) + 4;
        
        CGFloat wholeNeedHeight = 79 + titleLabelHeight + 4 + imageViewHeight;
        if (wholeNeedHeight <= SSScreenHeight) {
            
            self.titleLabel.frame = CGRectMake(titlelabelOriginX, titlelabelOriginY, titleLabelWidth, titleLabelHeight);
            self.imageScrollView.frame = CGRectMake(imageVieworginX, imageVieworginY, imageViewWidth, imageViewHeight);
        }
        
        else {
            
            imageViewHeight = SSScreenHeight - 79 - 15 - 45;
            imageViewWidth = DEFALTLANSCAPEIMAGEWIDTH;
            
            if (self.image && self.image.size.height > 0 && self.image.size.width > 0) {
                imageViewWidth = imageViewHeight * (self.image.size.width/self.image.size.height);
            }
            
            titleLabelWidth = imageViewWidth;
            textViewSize = [self.titleLabel sizeThatFits:CGSizeMake(titleLabelWidth, FLT_MAX)];
            titleLabelHeight = textViewSize.height;
            titlelabelOriginX = 0;
            titlelabelOriginY = 0;
            self.titleLabel.frame = CGRectMake(0, 0, titleLabelWidth, titleLabelHeight);
            
            imageVieworginX = 0;
            imageVieworginY = CGRectGetMaxY(self.titleLabel.frame) + 4;
            self.imageScrollView.frame = CGRectMake(imageVieworginX, imageVieworginY, imageViewWidth, imageViewHeight);
        }
        
        CGFloat viewWidth = CGRectGetWidth(self.titleLabel.frame);
        CGFloat viewHeight = CGRectGetHeight(self.titleLabel.frame) + 4 + CGRectGetHeight(self.imageScrollView.frame);
        
        return CGSizeMake(viewWidth, viewHeight);
    }

}


@end


@interface TTPhotoDetailAdCreativeView ()

@property(nonatomic, strong) TTPhotoDetailAdModel *detailModel;

@property (nonatomic, strong) UIImage *image;

@end

@implementation TTPhotoDetailAdCreativeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleLabel = [[SSThemedLabel alloc] init];
        //这块什么意思
        self.titleLabel.autoresizingMask = UIViewAutoresizingNone;
        self.titleLabel.textColor = [UIColor colorWithHexString:@"e8e8e8"];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        self.titleLabel.numberOfLines = 2;
        [self addSubview:self.titleLabel];
        
        
        self.imageScrollView= [[TTShowImageView alloc] init];
        self.imageScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imageScrollView];
        self.imageScrollView.userInteractionEnabled = NO;
        
        self.creativeTitleLabel = [[SSThemedLabel alloc] init];
        self.creativeTitleLabel.autoresizingMask = UIViewAutoresizingNone;
        self.creativeTitleLabel.textColor = [UIColor colorWithHexString:@"e8e8e8"];
        self.creativeTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.creativeTitleLabel.font = [UIFont systemFontOfSize:14.0f];
        self.creativeTitleLabel.numberOfLines = 1;
        self.creativeTitleLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
        [self addSubview:self.creativeTitleLabel];
        
        
        self.creativeButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        self.creativeButton.backgroundColor = [UIColor clearColor];
        //self.creativeButton.titleColorThemeKey = kColorText6;
        //self.creativeButton.borderColorThemeKey = kColorText6;
        self.creativeButton.titleLabel.font = [UIFont systemFontOfSize:14.];
        self.creativeButton.layer.cornerRadius = 6;
        self.creativeButton.layer.masksToBounds = YES;
        self.creativeButton.layer.borderWidth = 1;
        self.creativeButton.layer.borderColor = [UIColor colorWithHexString:@"2A90D7"].CGColor;
        self.creativeButton.enableHighlightAnim = YES;
        [self.creativeButton setTitleColor:[UIColor colorWithHexString:@"2A90D7"] forState:UIControlStateNormal];
        
        
        self.creativeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.creativeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self addSubview:self.creativeButton];
        [self.creativeButton addTarget:self action:@selector(clickButtonWithAdModel:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

-(void)clickButtonWithAdModel:(id)sender{
    
    if (!self.detailModel || !self.detailModel.image_recom) {
        return;
    }
    
     [TTAdManageInstance photoAlbum_adCreativeButtonClickWithModel:self.detailModel WithResponder:self];
}

-(void)configureDetailModel:(TTPhotoDetailAdModel *)detailModel WithAdImage:(UIImage *)adImage{
    if (!detailModel || !detailModel.image_recom) {
        
        //怎样处理这里的容错---------
    }
    
    self.detailModel = detailModel;
    
    [self.imageScrollView resetZoom];
    if (adImage) {
        self.imageScrollView.image = adImage;
        self.image = adImage;
    }
    
    if (self.detailModel.image_recom.title) {
        self.titleLabel.text = self.detailModel.image_recom.title;
    }
    else {
        self.titleLabel.text = @"";
    }
    
    if (self.detailModel.image_recom.adActionType == TTPhotoDetailAdActionType_App && !isEmptyString(self.detailModel.image_recom.app_name)) {
        self.creativeTitleLabel.text = self.detailModel.image_recom.app_name;
    }
    else {
        self.creativeTitleLabel.text = self.detailModel.image_recom.source;
    }
    
    if (!self.creativeTitleLabel.text) {
        self.creativeTitleLabel.text = @"";
    }
    
    if (self.detailModel.image_recom.button_text) {
        self.creativeButton.titleLabel.text = self.detailModel.image_recom.button_text;
        [self.creativeButton setTitle:self.detailModel.image_recom.button_text forState:UIControlStateNormal];
        self.creativeButton.hidden = NO;
    }
    else {
        
        if ([self.detailModel.image_recom.type isEqualToString:@"app"]) {
            
            [self.creativeButton setTitle:@"立即下载" forState:UIControlStateNormal];
            self.creativeButton.hidden = NO;
        }
        
        else if ([self.detailModel.image_recom.type isEqualToString:@"action"]){
            
            [self.creativeButton setTitle:@"电话拨打" forState:UIControlStateNormal];
            self.creativeButton.hidden = NO;
        }
        
        else {
            [self.creativeButton setTitle:@"" forState:UIControlStateNormal];
            self.creativeButton.hidden = YES;
        }
    }
    
    [self updateFrame];
}

-(CGSize)updateFrame{
    
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        
        self.titleLabel.preferredMaxLayoutWidth = SSScreenWidth - 30;
        CGFloat titleLabelWidth = SSScreenWidth - 30;
        CGSize textViewSize = [self.titleLabel sizeThatFits:CGSizeMake(titleLabelWidth, FLT_MAX)];
        CGFloat titleLabelHeight = textViewSize.height + 3;
        CGFloat titleLabelOriginX = 15;
        CGFloat titleLabelOriginY = 0;
        
        self.titleLabel.frame = CGRectMake(titleLabelOriginX, titleLabelOriginY, titleLabelWidth, titleLabelHeight);
        
        //此处需要进一步确定image的宽高
        CGFloat imageScrollViewOriginY = CGRectGetMaxY(self.titleLabel.frame) + 4;
        CGFloat imageScrollViewOriginX = 15;
        CGFloat imageViewwidth = SSScreenWidth - 30;
        CGFloat imageViewHeight = DEFUALTPORTITIMAGEHEIGHT;
        if (self.image && self.image.size.width > 0) {
            imageViewHeight = imageViewwidth * (self.image.size.height/self.image.size.width);
        }
        
        self.imageScrollView.frame = CGRectMake(imageScrollViewOriginX, imageScrollViewOriginY, imageViewwidth , imageViewHeight);
        
        UILabel *widthLabel = [[UILabel alloc] init];
        widthLabel.text = self.creativeButton.currentTitle;
        widthLabel.font =  [UIFont systemFontOfSize:14.];
        widthLabel.numberOfLines = 1;
        
        CGSize widthLabelSize = [widthLabel sizeThatFits:CGSizeMake(FLT_MAX, 17)];
        NSInteger widthLabelWidth = (widthLabelSize.width + 15) > 100? 100 : ((NSInteger)(widthLabelSize.width + 15));
        
        CGFloat creativeButtonOriginX = SSScreenWidth - 15 - widthLabelWidth;
        CGFloat creativeButtonOriginY = CGRectGetMaxY(self.imageScrollView.frame) + 12;
        CGFloat creativeButtonWidth = widthLabelWidth;
        CGFloat creativeButtonHeight = 29;
        self.creativeButton.frame = CGRectMake(creativeButtonOriginX, creativeButtonOriginY, creativeButtonWidth, creativeButtonHeight);
        
        
        CGFloat creativeTitleOriginX = 15;
        CGFloat creativeTitleOriginY = CGRectGetMaxY(self.imageScrollView.frame) + 20;
        CGFloat creativeTitleWidth = CGRectGetMinX(self.creativeButton.frame) - 15 - 15;
        CGFloat creativeTitleHeight = 17;
        self.creativeTitleLabel.frame = CGRectMake(creativeTitleOriginX, creativeTitleOriginY, creativeTitleWidth, creativeTitleHeight);
        self.creativeTitleLabel.center = CGPointMake(self.creativeTitleLabel.center.x, self.creativeButton.center.y);
        
        
        CGFloat viewWidth = SSScreenWidth;
        CGFloat viewHeight = CGRectGetHeight(self.titleLabel.frame) + 4 + CGRectGetHeight(self.imageScrollView.frame) + 12 + CGRectGetHeight(self.creativeButton.frame);
        
        return CGSizeMake(viewWidth, viewHeight);
    }
    
    else {
        
        CGFloat imageViewHeight = DEFALTLANSCAPEIMAGEHEIGHT;
        CGFloat imageViewWidth = DEFALTLANSCAPEIMAGEWIDTH;
        
        if (self.image && self.image.size.width > 0 && self.image.size.height > 0) {
            imageViewHeight = (SSScreenHeight - 30) * (self.image.size.height/self.image.size.width);
            imageViewWidth = imageViewHeight * (self.image.size.width/self.image.size.height);
            
        }
        
        CGFloat titleLabelWidth = imageViewWidth;
        CGSize textViewSize = [self.titleLabel sizeThatFits:CGSizeMake(titleLabelWidth, FLT_MAX)];
        CGFloat titleLabelHeight = textViewSize.height;
        CGFloat titlLabelOriginX = 0;
        CGFloat titlLabelOriginY = 0;
        
        CGFloat imageVieworginX = 0;
        CGFloat imageVieworginY = CGRectGetMaxY(self.titleLabel.frame) + 4;
        
        CGFloat wholeNeedHeight = 79 + titleLabelHeight + 4 + imageViewHeight + 12 + 29;
        if (wholeNeedHeight <= SSScreenHeight) {

            self.titleLabel.frame = CGRectMake(titlLabelOriginX, titlLabelOriginY, titleLabelWidth, titleLabelHeight);
            self.imageScrollView.frame = CGRectMake(imageVieworginX, imageVieworginY, imageViewWidth, imageViewHeight);
        }
        else {
            imageViewHeight = SSScreenHeight - 79 - 45 - 12 - 29 - 15;
            imageViewWidth = DEFALTLANSCAPEIMAGEWIDTH;
            
            if (self.image && self.image.size.height > 0 && self.image.size.width > 0) {
                imageViewWidth = imageViewHeight * (self.image.size.width/self.image.size.height);
            }
            
            titleLabelWidth = imageViewWidth;
            textViewSize = [self.titleLabel sizeThatFits:CGSizeMake(titleLabelWidth, FLT_MAX)];
            titleLabelHeight = textViewSize.height;
            titlLabelOriginX = 0;
            titlLabelOriginY = 0;
            self.titleLabel.frame = CGRectMake(titlLabelOriginX, titlLabelOriginY, titleLabelWidth, titleLabelHeight);
            
            imageVieworginX = 0;
            imageVieworginY = CGRectGetMaxY(self.titleLabel.frame) + 4;
            self.imageScrollView.frame = CGRectMake(imageVieworginX, imageVieworginY, imageViewWidth, imageViewHeight);
        }
        
        UILabel *widthLabel = [[UILabel alloc] init];
        widthLabel.text = self.creativeButton.currentTitle;
        widthLabel.font =  [UIFont systemFontOfSize:14.];
        widthLabel.numberOfLines = 1;
        CGSize widthLabelSize = [widthLabel sizeThatFits:CGSizeMake(FLT_MAX, 17)];
        NSInteger widthLabelWidth = (widthLabelSize.width + 15) > 100? 100 : ((NSInteger)(widthLabelSize.width + 15));
        
        CGFloat creativeButtonOriginX = CGRectGetWidth(self.imageScrollView.frame) - widthLabelWidth;
        CGFloat creativeButtonOriginY = CGRectGetMaxY(self.imageScrollView.frame) + 12;
        CGFloat creativeButtonWidth = widthLabelWidth;
        CGFloat creativeButtonHeight = 29;
        self.creativeButton.frame = CGRectMake(creativeButtonOriginX ,creativeButtonOriginY, creativeButtonWidth, creativeButtonHeight);
        
        CGFloat creativeTitleOriginX = 0;
        CGFloat creativeTitleOriginY = CGRectGetMaxY(self.imageScrollView.frame) + 20;
        CGFloat creativeTitleWidth = CGRectGetMinX(self.creativeButton.frame) - 15 - 15;
        CGFloat creativeTitleHeight = 17;
        self.creativeTitleLabel.frame = CGRectMake(creativeTitleOriginX, creativeTitleOriginY, creativeTitleWidth, creativeTitleHeight);
        self.creativeTitleLabel.center = CGPointMake(self.creativeTitleLabel.center.x, self.creativeButton.center.y);
        
        CGFloat viewWidth = CGRectGetWidth(self.titleLabel.frame);
        CGFloat viewHeight = CGRectGetHeight(self.titleLabel.frame) + 4 + CGRectGetHeight(self.imageScrollView.frame) + 12 + CGRectGetHeight(self.creativeButton.frame);
        
        return CGSizeMake(viewWidth, viewHeight);
    }
}


@end

@interface TTPhotoDetailAdContainView ()

@property (nonatomic,strong)TTPhotoDetailAdNormalView *adNormalView;

@property (nonatomic,strong)TTPhotoDetailAdCreativeView *adCreativeView;


@property (nonatomic, strong) TTPhotoDetailAdModel *detailModel;

@end

@implementation TTPhotoDetailAdContainView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.adNormalView = [[TTPhotoDetailAdNormalView alloc] init];
        self.adCreativeView = [[TTPhotoDetailAdCreativeView alloc] init];
        self.userInteractionEnabled = YES;
        
        UIGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapActionFired:)];
        [self addGestureRecognizer:tapGesture];
        
    }
    return self;
}

-(void)backgroundTapActionFired:(UITapGestureRecognizer *)tap{
    
    [TTAdManageInstance photoAlbum_adImageClickWithResponder:self];

}

-(void)configureADPhotoViewWithModel:(TTPhotoDetailAdModel *)adModel WithImage:(UIImage *)adImage{
    
    if (!adModel || !adModel.image_recom) {
        if (self.adNormalView.superview) {
            [self.adNormalView removeFromSuperview];
        }
        if (self.adCreativeView.superview) {
            [self.adCreativeView removeFromSuperview];
        }
    }
    
    _detailModel = adModel;
    
    if (self.detailModel.image_recom.type && ([self.detailModel.image_recom.type isEqualToString:@"app"] || [self.detailModel.image_recom.type isEqualToString:@"action"]) ) {
        
        if (self.adNormalView.superview) {
            [self.adNormalView removeFromSuperview];
        }
        
        if (!self.adCreativeView.superview) {
            [self addSubview:self.adCreativeView];
        }
        
        [self.adCreativeView configureDetailModel:adModel WithAdImage:adImage];
    }
    
    else {

        if (self.adCreativeView.superview) {
            [self.adCreativeView removeFromSuperview];
        }
        
        if (!self.adNormalView.superview) {
            [self addSubview:self.adNormalView];
        }
        
        [self.adNormalView configureDetailModel:adModel WithAdImage:adImage];
        
    }
    [self updateFrame];
}

-(void)setImageScrollViewDelegate:(id)delegate{
    
    if (delegate) {
        if (self.adNormalView.superview) {
            self.adNormalView.imageScrollView.delegate = delegate;
        }
        else if (self.adCreativeView.superview){
            self.adCreativeView.imageScrollView.delegate = delegate;
        }
    }
}

//frame更新有待确定
-(CGSize)updateFrame{
    
    CGSize innerViewSize = CGSizeMake(0, 0);
    if (self.adNormalView.superview) {
        innerViewSize = [self.adNormalView updateFrame];
        self.adNormalView.frame = CGRectMake(0, 0, innerViewSize.width, innerViewSize.height);
    }
    
    else {
        innerViewSize = [self.adCreativeView updateFrame];
        self.adCreativeView.frame = CGRectMake(0, 0, innerViewSize.width, innerViewSize.height);
    }
    
    return innerViewSize;
}


@end

@interface TTPhotoDetailAdNewCollectionViewCell ()

@property (nonatomic, strong) TTPhotoDetailAdModel *detailModel;

@end

@implementation TTPhotoDetailAdNewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.containView = [[TTPhotoDetailAdContainView alloc] init];
        [self.contentView addSubview:self.containView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object: nil];
        
    }
    return self;
}


-(void)refreshWithData:(id)data WithContainView:(UIView *)containView WithCollectionView:(UICollectionView *)collectionView WithIndexPath:(NSIndexPath *)indexPath WithImageScrollViewDelegate:(id<TTShowImageViewDelegate>)delegate WithRefreshBlock:(TTPhotoDetailCellBlock)block{
    
    TTPhotoDetailAdModel *photoAdModel = nil;
    if (data && [data isKindOfClass:[TTPhotoDetailAdModel class]]) {
        photoAdModel = (TTPhotoDetailAdModel *)data;
    }
    else {
        photoAdModel = [TTAdManageInstance photoAlbum_AdModel];
    }
    
    UIImage *photoAdImage = [TTAdManageInstance photoAlbum_getAdImage];
    [self configureADPhotoViewWithModel:photoAdModel WithImage:photoAdImage];
    
    if (delegate && [delegate conformsToProtocol:@protocol(TTShowImageViewDelegate)]) {
        [self setImageScrollViewDelegate:delegate];
    }
}

- (void)ScrollViewDidScrollView:(UIScrollView *)scrollView ScrollDirection:(TTPhotoDetailCellScrollDirection)scrollDirection WithScrollPersent:(CGFloat)persent WithContainView:(UIView *)containView WithScrollBlock:(TTPhotoDetailCellBlock)block{
    
    if (scrollDirection == TTPhotoDetailCellScrollDirection_Front) {
        
        [self refreshBlackOpaqueWithPersent: - persent];
        
    }
    else if (scrollDirection == TTPhotoDetailCellScrollDirection_Current){
        
        [self refreshBlackOpaqueWithPersent: 1 - fabs(persent)];
        
    }
    else if (scrollDirection == TTPhotoDetailCellScrollDirection_BackFoward){
        
        [self refreshBlackOpaqueWithPersent: persent];
        
    }
    
}

-(void)configureAdPhotoView{
    
    TTPhotoDetailAdModel *photoAdModel = [TTAdManageInstance photoAlbum_AdModel];
    UIImage *photoAdImage = [TTAdManageInstance photoAlbum_getAdImage];
    [self configureADPhotoViewWithModel:photoAdModel WithImage:photoAdImage];
    
}

-(void)configureADPhotoViewWithModel:(TTPhotoDetailAdModel *)adModel WithImage:(UIImage *)adImage{

    if (!adModel || !adModel.image_recom) {
        if (self.containView.superview) {
            [self.containView removeFromSuperview];
        }
    }
    _detailModel = adModel;
    
    [self.containView configureADPhotoViewWithModel:self.detailModel WithImage:adImage];
    CGSize innerViewSize = [self.containView updateFrame];
    self.containView.frame = CGRectMake(0, 0, innerViewSize.width, innerViewSize.height);

    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        self.containView.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    }
    else {
        
        CGFloat originX = (SSScreenWidth - CGRectGetWidth(self.containView.frame))/2;
        CGFloat originY = 79;
        self.containView.frame = CGRectMake(originX, originY, CGRectGetWidth(self.containView.frame), CGRectGetHeight(self.containView.frame));
        
    }
    
}

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


-(void)setImageScrollViewDelegate:(id)delegate{
    if (delegate) {
        [self.containView setImageScrollViewDelegate:delegate];
    }
}

- (void)deviceOrientationDidChangeNotification:(NSNotification *)notification{
    
    self.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    CGSize containViewSize = [self.containView updateFrame];
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        
        CGFloat originX = (SSScreenWidth - CGRectGetWidth(self.containView.frame))/2;
        CGFloat originY = 79;
        self.containView.frame = CGRectMake(originX, originY, containViewSize.width, containViewSize.height);
        
    }
    else {
        
        self.containView.frame = CGRectMake(0, 0, containViewSize.width, containViewSize.height);
        self.containView.center = CGPointMake(SSScreenWidth/2,SSScreenHeight/2);
    }
    
}

-(void)layoutSubviews{
    
    CGSize containViewSize = [self.containView updateFrame];
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        
        CGFloat originX = (SSScreenWidth - CGRectGetWidth(self.containView.frame))/2;
        CGFloat originY = 79;
        self.containView.frame = CGRectMake(originX, originY, containViewSize.width, containViewSize.height);
        
    }
    else {
        
        self.containView.frame = CGRectMake(0, 0, containViewSize.width, containViewSize.height);
        self.containView.center = CGPointMake(SSScreenWidth/2,SSScreenHeight/2);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
