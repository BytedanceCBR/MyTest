//
//  TTPhotoSingleSearchWordCell.m
//  Article
//
//  Created by 邱鑫玥 on 2017/4/1.
//
//

#import "TTPhotoSingleSearchWordCell.h"
#import "TTImageView.h"
#import "TTDeviceHelper.h"
#import "TTDeviceUIUtils.h"
#import "UIColor+TTThemeExtension.h"
#import "TTPhotoSearchWordModel.h"

NS_INLINE CGFloat SearchWordPicPadding(){
    return 2.f;
}

NS_INLINE CGFloat SearchWordArrowSize(){
    return [TTDeviceUIUtils tt_newPadding:12.f];
}

NS_INLINE CGFloat SearchWordArrowPadding(){
    return [TTDeviceUIUtils tt_newPadding:9.5f];
}

NS_INLINE CGFloat SearchWordNumFontSize(){
    return [TTDeviceUIUtils tt_newFontSize:17.f];
}

NS_INLINE CGFloat SearchWordAddImageSize(){
    return [TTDeviceUIUtils tt_newPadding:12.f];
}

NS_INLINE CGFloat SearchWordAddImageAndNumPadding(){
    return [TTDeviceUIUtils tt_newPadding:2.f];
}

static CGFloat const kImageSideRatio  = 0.654f;
static CGFloat const kLabelTopPadding = 6.0f;

#define _IS_iPad          ([TTDeviceHelper isPadDevice])
#define _IS_iPhone6_OR_6P_OR_X ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice])

NS_INLINE CGFloat TextFontSize() {
    if (_IS_iPhone6_OR_6P_OR_X) {
        return 14.0f;
    } else if (_IS_iPad) {
        return 18.0f;
    }
    return 12.0f;
}

@interface TTPhotoSingleSearchWordCell()

@property (nonatomic, strong) TTImageView *imgView1;
@property (nonatomic, strong) TTImageView *imgView2;
@property (nonatomic, strong) TTImageView *imgView3;
@property (nonatomic, strong) UIView      *maskView;
@property (nonatomic, strong) UIImageView *addImageView;
@property (nonatomic, strong) UILabel     *searchNumLabel;
@property (nonatomic, strong) TTImageView *arrowImg;
@property (nonatomic, strong) UILabel     *titleLbl;

@end


@implementation TTPhotoSingleSearchWordCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imgView1 = [[TTImageView alloc] initWithFrame:CGRectZero];
        _imgView1.enableNightCover = NO;
        _imgView1.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _imgView1.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_imgView1];
        
        _imgView2 = [[TTImageView alloc] initWithFrame:CGRectZero];
        _imgView2.enableNightCover = NO;
        _imgView2.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _imgView2.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_imgView2];
        
        _imgView3 = [[TTImageView alloc] initWithFrame:CGRectZero];
        _imgView3.enableNightCover = NO;
        _imgView3.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _imgView3.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_imgView3];
        
        _maskView = [[UIView alloc]initWithFrame:CGRectZero];
        _maskView.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground15];
        [_imgView3 addSubview:_maskView];
        
        _addImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"details_add_icon"]];
        _addImageView.backgroundColor = [UIColor clearColor];
        _addImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_maskView addSubview:_addImageView];
        
        _searchNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _searchNumLabel.font = [UIFont boldSystemFontOfSize:SearchWordNumFontSize()];
        _searchNumLabel.textColor = [UIColor tt_defaultColorForKey:kColorText8];
        _searchNumLabel.numberOfLines = 1;
        _searchNumLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_maskView addSubview:_searchNumLabel];
        
        // Title Label
        _titleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLbl.font = [UIFont systemFontOfSize:TextFontSize()];
        _titleLbl.textColor = [UIColor tt_defaultColorForKey:[TTDeviceHelper isPadDevice] ? kColorText8 : kColorText9];
        _titleLbl.numberOfLines = 2;
        _titleLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_titleLbl];
        
        // arrowImg
        _arrowImg = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, SearchWordArrowSize(), SearchWordArrowSize())];
        [_arrowImg setImage:[UIImage imageNamed:@"arrow_white"]];
        _arrowImg.enableNightCover = NO;
        _arrowImg.imageContentMode = TTImageViewContentModeScaleAspectFill;
        [self.contentView addSubview:_arrowImg];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _imgView1.imageView.image = nil;
    _imgView2.imageView.image = nil;
    _imgView3.imageView.image = nil;
    _searchNumLabel.text = @"";
    _titleLbl.text = @"";
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat cellWidth = CGRectGetWidth(self.contentView.frame);
    CGFloat halfCellWidth = cellWidth / 2;
    
    _imgView1.frame = CGRectMake(0, 0, halfCellWidth - SearchWordPicPadding(), cellWidth * kImageSideRatio);
    _imgView2.frame = CGRectMake(halfCellWidth, 0, halfCellWidth, (cellWidth * kImageSideRatio - SearchWordPicPadding()) / 2.0);
    _imgView3.frame = CGRectMake(halfCellWidth, (cellWidth * kImageSideRatio + SearchWordPicPadding()) / 2.0, halfCellWidth, (cellWidth * kImageSideRatio - SearchWordPicPadding()) / 2.0);
    
    _maskView.frame = _imgView3.bounds;
    
    _addImageView.frame = CGRectMake(0, 0, SearchWordAddImageSize(), SearchWordAddImageSize());
    _addImageView.centerY = _maskView.centerY;
    
    [_searchNumLabel sizeToFit];
    _searchNumLabel.width = MIN(_searchNumLabel.width, _imgView3.width - _addImageView.width - SearchWordAddImageAndNumPadding());
    _searchNumLabel.centerY = _maskView.centerY;
    
    CGFloat containerWidth = _addImageView.width + SearchWordAddImageAndNumPadding() + _searchNumLabel.width;
    _addImageView.left = _maskView.centerX - containerWidth / 2.f;
    _searchNumLabel.left = _addImageView.right + SearchWordAddImageAndNumPadding();
    
    _titleLbl.frame = CGRectMake(CGRectGetMinX(_imgView1.frame) + 8, CGRectGetMaxY(_imgView1.frame) + kLabelTopPadding, cellWidth - 8.0f - 3.0f - SearchWordArrowSize() - SearchWordArrowPadding(), 0);
    [_titleLbl sizeToFit];
    
    _arrowImg.left = _titleLbl.right + SearchWordArrowPadding();
    _arrowImg.centerY = _titleLbl.centerY;
}

- (void)setSearchWordItem:(TTPhotoSearchWordModel *)searchWordItem{
    _searchWordItem = searchWordItem;
    NSArray *images = _searchWordItem.imageList;
    if([images count] >= 3){
        TTImageInfosModel * imgInfoModel1 = [[TTImageInfosModel alloc] initWithDictionary:images[0]];
        [_imgView1 setImageWithModel:imgInfoModel1 placeholderImage:nil];
        TTImageInfosModel * imgInfoModel2 = [[TTImageInfosModel alloc] initWithDictionary:images[1]];
        [_imgView2 setImageWithModel:imgInfoModel2 placeholderImage:nil];
        TTImageInfosModel * imgInfoModel3 = [[TTImageInfosModel alloc] initWithDictionary:images[2]];
        [_imgView3 setImageWithModel:imgInfoModel3 placeholderImage:nil];
    }
    
    _titleLbl.text = _searchWordItem.title;
    
    NSString *searchnum = [NSString stringWithFormat:@"%ld", _searchWordItem.searchNum];
    _searchNumLabel.text = searchnum;
    
    [self setNeedsLayout];
}

@end
