//
//  ExploreFeedMomentCellView.m
//  Article
//
//  Created by Chen Hong on 15/1/15.
//
//

#import "ExploreFeedMomentCellView.h"
#import "SSImageView.h"
#import "SSThemed.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreEmbedListMomentModel.h"
#import "SSAppPageManager.h"
#import "SSAvatarView.h"
#import "TTTAttributedLabel.h"
#import "ExploreCellHelper.h"
#import "NewsUserSettingManager.h"
#import "SSImageView+TrafficSave.h"
#import "ExploreArticleTitleRightPicCellView.h"

#define kAvatarViewLeft        kCellLeftPadding
#define kAvatarViewTop         20
#define kAvatarViewW           95//57
#define kAvatarViewH           62//57
#define kAvatarViewRightPad    12
#define kTextTopGap            0.0f
#define kTextBottomPad         20.0f
#define kLimitedNumOfLines      3

#define kMaxPicNum              3

@interface ExploreFeedMomentCellView ()
@property (nonatomic, strong) ExploreEmbedListMomentModel *momentModel;
@property (nonatomic, strong) SSThemedLabel               *userNameLabel;
@property (nonatomic, strong) UILabel               *textLabel;
@property (nonatomic, strong) SSThemedView                *bottomLineView;
@property (nonatomic, strong) NSMutableArray              *imageViewArray;
@end


@implementation ExploreFeedMomentCellView

+ (CGFloat)nameFontSize {
    if ([SSCommon isScreenWidthLarge320]) {
        return 11;
    } else {
        return 10;
    }
}

+ (CGFloat)textFontSize {
    return [NewsUserSettingManager fontSizeFromNormalSize:15.0 isWidescreen:[SSCommon isScreenWidthLarge320]];
}

+ (CGFloat)textLineHeight {
    if ([SSCommon isScreenWidthLarge320]) {
        return [NewsUserSettingManager fontSizeFromNormalSize:24.0 isWidescreen:NO];
    } else {
        return [NewsUserSettingManager fontSizeFromNormalSize:19.0 isWidescreen:NO];
    }
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreEmbedListMomentModel class]]) {
        ExploreEmbedListMomentModel *momentData = (ExploreEmbedListMomentModel *)data;

        if (momentData) {
            CGFloat height = cellTopPadding() + cellBottomPadding() + [self nameFontSize] + cellPaddingY();

            //CGFloat textH = sizeOfContentWithNumberOfLines(momentData.text, w, [UIFont systemFontOfSize:kTextLabelFontSize], kLimitedNumOfLines).height;
            
            NSMutableAttributedString *attributedString = [ExploreCellHelper attributedStringWithString:momentData.text fontSize:[self textFontSize] lineHeight:[self textLineHeight]];
            
            CGFloat w;
            CGFloat picH = 0;
            
            // 三图
            if (momentData.listImgModels.count >=3 ) {
                w = width - kCellLeftPadding*2;
                CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(w, [self textLineHeight]*kLimitedNumOfLines) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                
                CGFloat textH = ceil(rect.size.height);
                
                CGSize picSize = [ExploreCellHelper resizablePicSizeByWidth:width];
                height += textH + cellPaddingY() + picSize.height;
            }
            // 右图
            else if (momentData.listImgModels.count > 0) {
                CGSize picSize = [ExploreArticleTitleRightPicCellView picSizeWithCellWidth:width];
                w = width - kCellLeftPadding*2 - picSize.width - kAvatarViewRightPad;
                picH = picSize.height;
                
                CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(w, [self textLineHeight]*kLimitedNumOfLines) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                
                CGFloat textH = ceil(rect.size.height);
                
                if (textH < picH) {
                    textH = picH;
                }
                
                height += textH;
            }
            // 无图
            else {
                w = width - kCellLeftPadding*2;
                
                CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(w, [self textLineHeight]*kLimitedNumOfLines) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                
                CGFloat textH = ceil(rect.size.height);
                
                height += textH;
            }
            
            return height;
        }
    }
    
    return 0.f;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageViewArray = [NSMutableArray arrayWithCapacity:3];
        
        for (int i = 0; i < kMaxPicNum; ++i) {
            SSImageView *imageView = [[SSImageView alloc] initWithFrame:CGRectZero];
            imageView.imageContentMode = SSImageViewContentModeScaleAspectFill;
            imageView.layer.borderWidth = [SSCommon ssOnePixel];
            imageView.borderColors = SSThemedColors(@"eeeeee", @"303030");
            imageView.hidden = YES;
            [self addSubview:imageView];
            
            [self.imageViewArray addObject:imageView];
        }
        
        CGFloat x                        = kCellLeftPadding;
        CGFloat w                        = frame.size.width - kCellLeftPadding*2;

        CGFloat textFontSize = [[self class] textFontSize];
        CGFloat textLineHeight = [[self class] textLineHeight];
        
        self.userNameLabel               = [[SSThemedLabel alloc] initWithFrame:CGRectMake(x, cellTopPadding(), w, textLineHeight)];
        _userNameLabel.font              = [UIFont systemFontOfSize:[[self class] nameFontSize]];
        _userNameLabel.backgroundColor   = [UIColor clearColor];
        _userNameLabel.textColorThemeKey = kColorText3;
        [self addSubview:_userNameLabel];

        self.textLabel                   = [[UILabel alloc] initWithFrame:CGRectMake(x, _userNameLabel.bottom + kTextTopGap, w, textLineHeight)];
        _textLabel.font                  = [UIFont systemFontOfSize:textFontSize];
        _textLabel.backgroundColor       = [UIColor clearColor];
        _textLabel.numberOfLines         = kLimitedNumOfLines;
        _textLabel.lineBreakMode         = NSLineBreakByTruncatingTail;
        [self addSubview:_textLabel];

        self.bottomLineView              = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_bottomLineView];
        
        [self reloadThemeUI];
    }
    return self;
}


- (void)updatePic
{
    int i = 0;
    for (; i < kMaxPicNum && i < self.momentModel.listImgModels.count; ++i) {
        SSImageInfosModel * model = self.momentModel.listImgModels[i];
        SSImageView *imageView = self.imageViewArray[i];
        imageView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground2];
        [imageView setImageWithModelInTrafficSaveMode:model placeholderImage:nil];
        imageView.hidden = NO;
    }
    
    for (; i < self.imageViewArray.count; ++i) {
        SSImageView *imageView = self.imageViewArray[i];
        imageView.hidden = YES;
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];

    [self updatePic];
    
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    self.textLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    
    [self updateTextLabel];
}

- (void)fontSizeChanged {
    [self updateTextLabel];
}

- (void)refreshUI {
    CGFloat y = cellTopPadding();
    CGFloat w;
    
    
    NSMutableAttributedString *attributedString = [ExploreCellHelper attributedStringWithString:self.momentModel.text fontSize:[[self class] textFontSize] lineHeight:[[self class] textLineHeight]];
    
    // 三图
    if (self.momentModel.listImgModels.count >= 3) {
        w = self.width - kCellLeftPadding * 2;
        CGRect textRect = [attributedString boundingRectWithSize:CGSizeMake(w, [[self class] textLineHeight] * kLimitedNumOfLines) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        self.textLabel.frame = CGRectMake(kCellLeftPadding, y, w, ceil(textRect.size.height));
        
        y = self.textLabel.bottom + cellPaddingY();
        
        CGSize picSize = [ExploreCellHelper resizablePicSizeByWidth:self.width];
        CGFloat x = kCellLeftPadding;
        
        for (int i = 0; i < 3; ++i) {
            SSImageView *imageView = self.imageViewArray[i];
            imageView.frame = CGRectMake(x, y, picSize.width, picSize.height);
            x += picSize.width + cellGroupPicPaddingX();
        }
        
        y += picSize.height + cellPaddingY();
    }
    // 右图
    else if (self.momentModel.listImgModels.count > 0) {
        CGSize picSize = [ExploreArticleTitleRightPicCellView picSizeWithCellWidth:self.width];
        w = self.width - kCellLeftPadding*2 - picSize.width - kAvatarViewRightPad;
        
        CGRect textRect = [attributedString boundingRectWithSize:CGSizeMake(w, [[self class] textLineHeight] * kLimitedNumOfLines) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        self.textLabel.frame = CGRectMake(kCellLeftPadding, y, w, ceil(textRect.size.height));
        
        SSImageView *imageView = self.imageViewArray[0];
        imageView.frame = CGRectMake(self.width - kCellRightPadding - picSize.width, y + 2, picSize.width, picSize.height);
        
        if (textRect.size.height < picSize.height) {
            self.textLabel.centerY = imageView.centerY;
            y = imageView.bottom + cellPaddingY();
        } else {
            imageView.centerY = self.textLabel.centerY;
            y = self.textLabel.bottom + cellPaddingY();
        }
    }
    // 无图
    else {
        w = self.width - kCellLeftPadding * 2;
        CGRect textRect = [attributedString boundingRectWithSize:CGSizeMake(w, [[self class] textLineHeight] * kLimitedNumOfLines) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        self.textLabel.frame = CGRectMake(kCellLeftPadding, y, w, ceil(textRect.size.height));
        
        y = self.textLabel.bottom + cellPaddingY();
    }
    
    _userNameLabel.frame = CGRectMake(kCellLeftPadding, y, self.width, [[self class] nameFontSize]);
    
    _bottomLineView.frame = CGRectMake(kCellLeftPadding, self.height - [SSCommon ssOnePixel], self.width - kCellLeftPadding * 2, [SSCommon ssOnePixel]);
    
    _bottomLineView.hidden = self.hideBottomLine;
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[ExploreEmbedListMomentModel class]]) {
        self.momentModel = data;
    } else {
        self.momentModel = nil;
    }

    [self updateTextLabel];

    [self updatePic];
    
    double time = [self.momentModel.behotTime doubleValue];
    NSTimeInterval midnightInterval = [[ExploreCellHelper sharedInstance] midInterval];
    
    NSString *publishTime =  [NSString stringWithFormat:@"%@", midnightInterval > 0 ?
                              [SSCommon customtimeStringSince1970:time midnightInterval:midnightInterval] :
                              [SSCommon customtimeStringSince1970:time]];
    
    if (isEmptyString(publishTime)) {
        publishTime = @"";
    }
    
    _userNameLabel.text = [NSString stringWithFormat:@"%@  %@", _momentModel.userName, publishTime];
}

- (void)updateTextLabel {
    NSMutableAttributedString *attributedString = [ExploreCellHelper attributedStringWithString:self.momentModel.text fontSize:[[self class] textFontSize] lineHeight:[[self class] textLineHeight]];
    
    self.textLabel.attributedText = attributedString;
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (id)cellData {
    return self.momentModel;
}

- (void)viewDidTapped {
    if (self.isCardSubCellView) {
        ssTrackEvent(@"card", [NSString stringWithFormat:@"click_post_%ld", self.cardSubCellIndex]);
    }
    
    if (!isEmptyString(self.momentModel.openUrl)) {
        NSURL * openURL = [SSCommon URLWithURLString:self.momentModel.openUrl];
        [[SSAppPageManager sharedManager] openURL:openURL baseCondition:nil];
    }

    
//    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
//    [dict setValue:@"talk_detail" forKey:@"tag"];
//    [dict setValue:[NSString stringWithFormat:@"click_%@", self.momentModel.categoryID] forKey:@"label"];
//    [dict setValue:self.momentModel.uniqueID forKey:@"value"];
//    
//    NSDictionary *umengDict = [self buildClickEvent:dict];
//    [SSTracker eventData:umengDict];
    
//    if (!isEmptyString(self.momentModel.openUrl)) {
//        NSMutableDictionary *baseCondition = [NSMutableDictionary dictionary];
////        [baseCondition setValue:self.momentModel.uniqueID forKey:@"talk_id"];
//        [[SSAppPageManager sharedManager] openURL:[SSCommon URLWithURLString:self.momentModel.openUrl] baseCondition:baseCondition];
//    }
}

@end
