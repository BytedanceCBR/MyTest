//
//  TTArticlePicView.m
//  Article
//
//  Created by 杨心雨 on 16/8/22.
//
//

#import "TTArticlePicView.h"
#import "TTArticleCellConst.h"
#import "TTArticleCellHelper.h"
#import "TTImageInfosModel.h"
#import "TTImageView+TrafficSave.h"
#import "NetworkUtilities.h"
#import "SSUserSettingManager.h"
#import "TTDeviceHelper.h"
#import "Comment.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "TTUserSettings/TTUserSettingsManager+NetworkTraffic.h"
#import "TTAdFeedModel.h"
#import "Article+TTADComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"
#import "TTAnimatedImageView.h"

/// 图片(视频)控件
@implementation TTArticlePicView
/// 框架
- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    if (oldFrame.size.width != self.frame.size.width || oldFrame.size.height != self.frame.size.height) {
        [self layoutPics];
    }
}

/** 初始化单个图片(视频)视图 */
- (nonnull TTImageView *)initalizeImageView {
    TTImageView *imageView = [[TTImageView alloc] init];
    imageView.backgroundColorThemeKey = kPicViewBackgroundColor();
    imageView.imageContentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    return imageView;
}

- (nonnull TTImageView *)initalizeImageView4Gif {
    TTImageView *imageView;
    if ([SSCommonLogic articleFLAnimatedImageViewEnabled]) {
        imageView = [[TTAnimatedImageView alloc] init];
    } else {
        imageView = [[TTImageView alloc] init];
    }
    imageView.backgroundColorThemeKey = kPicViewBackgroundColor();
    imageView.imageContentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    return imageView;
}

/// 图片(视频)控件样式
- (void)setStyle:(TTArticlePicViewStyle)style {
    TTArticlePicViewStyle oldStyle = _style;
    _style = style;
    if (_style != oldStyle) {
        switch (_style) {
            case TTArticlePicViewStyleNone:
                NSLog(@"error: TTArticlePicView style set error");
                break;
            case TTArticlePicViewStyleRight:
            case TTArticlePicViewStyleLarge:
            case TTArticlePicViewStyleLeftSmall:
                self.picView2.hidden = YES;
                self.picView3.hidden = YES;
                break;
            case TTArticlePicViewStyleTriple:
            case TTArticlePicViewStyleLeftLarge:
            case TTArticlePicViewStyleRightLarge:
                self.picView2.hidden = NO;
                self.picView3.hidden = NO;
        }
        [self layoutPics];
    }
}

/// 是否隐藏信息视图(默认为false)
- (void)setHiddenMessage:(BOOL)hiddenMessage {
    _hiddenMessage = hiddenMessage;
    self.messageBackgroundView.hidden = _hiddenMessage;
}

/**
 图片(视频)控件初始化方法
 
 - parameter style: 图片(视频)控件样式
 
 - returns: 图片(视频)控件实例
 */
- (instancetype)initWithStyle:(TTArticlePicViewStyle)style {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.style = style;
        _picView1 = [self initalizeImageView4Gif];
        _picView2 = [self initalizeImageView];
        _picView3 = [self initalizeImageView];
        
        _messageBackgroundView = [[SSThemedImageView alloc] init];
        _messageBackgroundView.imageName = @"feed_pic_bg_four_corner";
        _messageBackgroundView.frame = CGRectMake(0, 0, 0, kPicMessageViewHeight());
        [self addSubview:_messageBackgroundView];
        
        _messageView = [[SSThemedLabel alloc] init];
        _messageView.font = [UIFont tt_fontOfSize:kPicMessageViewFontSize()];
        _messageView.textColorThemeKey = kPicMessageViewTextColor();
        _messageView.textAlignment = NSTextAlignmentCenter;
        [_messageBackgroundView addSubview:_messageView];
        
        _messageImageView = [[SSThemedImageView alloc] init];
        [_messageBackgroundView addSubview:_messageImageView];
        
        _playStyleBackgroundView = [[SSThemedView alloc] init];
        _playStyleBackgroundView.backgroundColorThemeKey = kColorText6;
        _playStyleBackgroundView.alpha = 0.7;
        _playStyleBackgroundView.layer.cornerRadius = 10;
        _playStyleBackgroundView.hidden = YES;
        [self addSubview:_playStyleBackgroundView];
        
        _playStyleLabel = [[SSThemedLabel alloc] init];
        _playStyleLabel.font = [UIFont tt_fontOfSize:kPicMessageViewFontSize()];
        _playStyleLabel.textColorThemeKey = kPicMessageViewTextColor();
        _playStyleLabel.textAlignment = NSTextAlignmentCenter;
        [_playStyleBackgroundView addSubview:_playStyleLabel];
    }
    return self;
}

// MARK: LayoutSubviews / UpdateSubviews
/** 图片(视频)控件布局 */
- (void)layoutPics {
    CGSize picSize = [TTArticleCellHelper resizablePicSize:self.width];
    self.messageBackgroundView.imageName = @"feed_pic_bg_four_corner";
    switch (self.style) {
        case TTArticlePicViewStyleNone:
            break;
        case TTArticlePicViewStyleRight:
            if (self.isVideo && isEmptyString(self.messageView.text)) {
                self.messageBackgroundView.imageName = @"feed_pic_bg_circle";
            } else {
                self.messageBackgroundView.imageName = @"feed_pic_bg_two_corner";
            }
            self.picView1.frame = CGRectMake(0, 0, self.width, self.height);
            break;
        case TTArticlePicViewStyleLarge:
            if (self.isVideo) {
                self.messageBackgroundView.imageName = nil;
            }
            self.picView1.layer.borderWidth = 0;
            self.picView1.frame = CGRectMake(0, 0, self.width, self.height);
            break;
        case TTArticlePicViewStyleTriple:
            self.picView1.frame = CGRectMake(0, 0, picSize.width, picSize.height);
            self.picView2.frame = CGRectMake(picSize.width + kPicViewPaddingInner(), 0, picSize.width, picSize.height);
            self.picView3.frame = CGRectMake(picSize.width * 2 + kPicViewPaddingInner() * 2, 0, picSize.width, picSize.height);
            break;
        case TTArticlePicViewStyleLeftLarge:
            self.picView1.frame = CGRectMake(0, 0, self.width - picSize.width - kPicViewPaddingInner(), picSize.height * 2 + kPicViewPaddingInner());
            self.picView2.frame = CGRectMake(self.width - picSize.width, 0, picSize.width, picSize.height);
            self.picView3.frame = CGRectMake(self.width - picSize.width, picSize.height + kPicViewPaddingInner(), picSize.width, picSize.height);
            break;
        case TTArticlePicViewStyleRightLarge:
            self.picView1.frame = CGRectMake(0, 0, picSize.width, picSize.height);
            self.picView2.frame = CGRectMake(picSize.width + kPicViewPaddingInner(), 0, self.width - picSize.width - kPicViewPaddingInner(), picSize.height * 2 + kPicViewPaddingInner());
            self.picView3.frame = CGRectMake(0, picSize.height + kPicViewPaddingInner(), picSize.width, picSize.height);
            break;
        case TTArticlePicViewStyleLeftSmall:
            self.picView1.layer.borderWidth = 0;//小图不需要描边
            self.picView1.frame = CGRectMake(0, 0, self.width, self.height);
            break;
    }
    
    if (!self.playStyleBackgroundView.hidden) {
        self.playStyleBackgroundView.width = 62;
        self.playStyleBackgroundView.height = 20;
        self.playStyleBackgroundView.right = self.width - kPicMessageViewPaddingRight();
        self.playStyleBackgroundView.bottom = self.height - kPicMessageViewPaddingBottom();
        
        [self.playStyleLabel sizeToFit];
        self.playStyleLabel.centerX = self.playStyleBackgroundView.width / 2;
        self.playStyleLabel.centerY = self.playStyleBackgroundView.height / 2;
    }
    // 如果显示信息视图，则重新布局信息视图
    if (!self.messageBackgroundView.hidden) {
        // 如果是多图，则不显示图片
        if (!self.messageImageView.hidden) {
            NSString *imageName = self.isVideo ? @"feed_play_icon_small" : @"picture_group_icon";
            self.messageImageView.image = [UIImage imageNamed:imageName];
            [self.messageImageView sizeToFit];
            self.messageImageView.frame = CGRectIntegral(self.messageImageView.frame);
            if (!isEmptyString(self.messageView.text)) {
                self.messageImageView.left = kPicMessageViewPaddingHorizontal();
                self.messageImageView.centerY = self.messageBackgroundView.height / 2;
                [self.messageView sizeToFit];
                self.messageView.frame = CGRectIntegral(self.messageView.frame);
                self.messageView.left = self.messageImageView.right + kPicMessageViewPaddingImageToLabel();
                self.messageView.centerY = self.messageImageView.centerY;
                self.messageBackgroundView.width = self.messageView.right + kPicMessageViewPaddingHorizontal();
            } else {
                self.messageBackgroundView.width = kPicMessageViewHeight();
                self.messageImageView.centerX = self.messageBackgroundView.width / 2;
                self.messageImageView.centerY = self.messageBackgroundView.height / 2;
            }
            self.messageBackgroundView.bottom = self.height - kPicMessageViewPaddingBottom();
            if (self.playStyleBackgroundView.hidden) {
                if (self.style == TTArticlePicViewStyleRight) {
                    if (isEmptyString(self.messageView.text) && self.isVideo) {
                        self.messageBackgroundView.bottom = self.height - 8;
                        self.messageBackgroundView.right = self.width - 8;
                        self.messageImageView.right = self.messageBackgroundView.width;
                    } else {
                        self.messageBackgroundView.right = self.width - kPicMessageViewPaddingRightVideo();
                    }
                } else {
                    self.messageBackgroundView.right = self.width - kPicMessageViewPaddingRightPhoto();
                }
            } else {
                self.messageBackgroundView.right = self.playStyleBackgroundView.left - 10;
            }
        } else if (!isEmptyString(self.messageView.text)) {
            if (self.isVideo && self.playButton && !self.playButton.hidden) {
                [self insertSubview:self.messageBackgroundView aboveSubview:self.playButton];
                self.messageBackgroundView.width = kPicMessageViewWidth();
                [self.messageView sizeToFit];
                self.messageView.frame = CGRectIntegral(self.messageView.frame);
                self.messageView.centerX = self.messageBackgroundView.width / 2;
                self.messageView.centerY = self.messageBackgroundView.height / 2;
                self.messageBackgroundView.backgroundColor = [UIColor clearColor];
                self.messageBackgroundView.centerX = self.width / 2;
                self.messageBackgroundView.bottom = self.height / 2 + 30;
            } else {
                self.messageBackgroundView.width = kPicMessageViewWidth();
                [self.messageView sizeToFit];
                self.messageView.frame = CGRectIntegral(self.messageView.frame);
                self.messageView.centerX = self.messageBackgroundView.width / 2;
                self.messageView.centerY = self.messageBackgroundView.height / 2;
                self.messageBackgroundView.bottom = self.height - kPicMessageViewPaddingBottom();
                if (self.playStyleBackgroundView.hidden) {
                    if (self.style == TTArticlePicViewStyleRight) {
                        self.messageBackgroundView.right = self.width - kPicMessageViewPaddingRightVideo();
                    } else {
                        self.messageBackgroundView.right = self.width - kPicMessageViewPaddingRightPhoto();
                    }
                } else {
                    self.messageBackgroundView.right = self.playStyleBackgroundView.left - 10;
                }
            }
        } else {
            self.messageBackgroundView.hidden = YES;
        }
    }
}
    
/**
 图片(视频)控件更新
 
 - parameter orderedData: orderedData数据
 */
- (void)updatePics:(ExploreOrderedData *)orderedData {
    Article *article = [orderedData article];
    Comment *comment = [orderedData comment];
    if (article || comment) {
        switch (self.style) {
            case TTArticlePicViewStyleNone:
                NSLog(@"error: TTArticlePicView style set error");
                break;
            case TTArticlePicViewStyleRight:
            {
                TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:[article middleImageDict]];
            
                [self.picView1 setImageWithModelInTrafficSaveMode:model placeholderImage:nil];
            }
                break;
            case TTArticlePicViewStyleLarge:
            {
                NSDictionary *imageInfo;
                if ([[article listGroupImgDicts] count] > 0 && [[article gallaryFlag] isEqual:@1]) {
                    imageInfo = [[article listGroupImgDicts] firstObject];
                } else {
                    imageInfo = [orderedData listLargeImageDict];
                }
                TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:imageInfo];
                [self.picView1 setImageWithModelInTrafficSaveMode:model placeholderImage:nil];
            }
                break;
            case TTArticlePicViewStyleTriple:
            case TTArticlePicViewStyleLeftLarge:
            case TTArticlePicViewStyleRightLarge:
            {
                NSArray<NSDictionary *>* pics = [article listGroupImgDicts];
                if ([pics count] > 2) {
                    [self.picView1 setImageWithModelInTrafficSaveMode:[[TTImageInfosModel alloc] initWithDictionary:pics[0]] placeholderImage:nil];
                    [self.picView2 setImageWithModelInTrafficSaveMode:[[TTImageInfosModel alloc] initWithDictionary:pics[1]] placeholderImage:nil];
                    [self.picView3 setImageWithModelInTrafficSaveMode:[[TTImageInfosModel alloc] initWithDictionary:pics[2]] placeholderImage:nil];
                }
                else{
                    [self.picView1 setImageWithModelInTrafficSaveMode:nil placeholderImage:nil];
                    [self.picView2 setImageWithModelInTrafficSaveMode:nil placeholderImage:nil];
                    [self.picView3 setImageWithModelInTrafficSaveMode:nil placeholderImage:nil];
                }
            }
                break;
            case TTArticlePicViewStyleLeftSmall:
            {
                if (article) {
                    TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:[article middleImageDict]];
                    UIImage *image = [UIImage imageNamed:@"default_feed_share_icon"];
                    [self.picView1 setImageWithModelInTrafficSaveMode:model placeholderImage:image];
                }
                else if (comment){
                    TTImageInfosModel *model= [[TTImageInfosModel alloc] initWithURL:[comment articleImageUrl]];
                    UIImage *image = [UIImage imageNamed:@"default_feed_share_icon"];
                    [self.picView1 setImageWithModelInTrafficSaveMode:model placeholderImage:image];
                }
            }
        }
        if (!self.hiddenMessage) {
            self.messageBackgroundView.hidden = NO;
            self.messageImageView.hidden = NO;
            if ([[article hasVideo] boolValue] == YES) {
                self.isVideo = YES;
                //如果列表上展示了播放按钮，那么右下角的信息里不需要有播放icon
                self.messageImageView.hidden = [orderedData isListShowPlayVideoButton];
                if ([article videoDuration]) {
                    NSInteger durationTime = [[article videoDuration] integerValue];
                    if (durationTime > 0) {
                        NSInteger minute = durationTime / 60;
                        NSInteger second = durationTime % 60;
                        self.messageView.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minute, (long)second];
                    } else {
                        self.messageView.text = nil;
                    }
                } else {
                    self.messageView.text = nil;
                }
            } else {
                self.isVideo = NO;
                self.messageBackgroundView.hidden = NO;
                self.messageImageView.hidden = NO;
                if ([article isGroupGallery]) {
                    /**
                     1.组图频道，图片右下角显示「x图」，不显示组图标记；无论wifi还是移动；
                     2.非组图频道，图片右下角显示「组图标记」+「x图」；无论wifi还是移动；
                     3.「图片标记」和「图片数量」在图片数量大于1的时候才显示，小于或等于1时不显示。
                     4.只要列表页显示了图片，右下角就显示对应的标记，跟图片是大图、三图、单图没关系。
                     */
                    if (orderedData.gallaryStyle != 1) {
                        self.messageImageView.hidden = YES;
                    }
                    if ([[article gallaryImageCount] integerValue] > 1) {
                        self.messageView.text = [NSString stringWithFormat:@"%ld张", [[article gallaryImageCount] integerValue]];
                    } else {
                        self.messageBackgroundView.hidden = YES;
                    }
                } else {
                    /**
                     1.wifi 或者「移动网络+最佳效果」时，图片右下角不显示「x图」；
                     2.「移动网络+智能下图/极省流量」时，且文章的图片数量大于1，图片右下角显示「x图」；
                     */
                    if (TTNetworkWifiConnected() || [TTUserSettingsManager networkTrafficSetting] == TTNetworkTrafficOptimum) {
                        self.messageBackgroundView.hidden = YES;
                    } else {
                        if ([[article gallaryImageCount] integerValue] > 1) {
                            self.messageView.text = [NSString stringWithFormat:@"%ld图", [[article gallaryImageCount] integerValue]];
                            self.messageImageView.hidden = YES;
                        } else {
                            self.messageBackgroundView.hidden = YES;
                        }
                    }
                }
            }
        }
    }
    
    /*
     满足以下条件：
     1、大图
     2、视频
     3、非视频频道的视频cell 
     4、广告按钮在视频封面下面
     5、内容是全屏视频
     此时、在视频封面右下角显示“全屏视频”文案
     */
    self.playStyleBackgroundView.hidden = YES;
    if (self.style == TTArticlePicViewStyleLarge &&
        [[article hasVideo] boolValue] == YES &&
        orderedData.videoStyle != ExploreOrderedDataVideoStyle8 &&
        [orderedData isAdButtonUnderPic] &&
        [orderedData.raw_ad isFullScreenVideoStyle]) {
        self.playStyleBackgroundView.hidden = NO;
        self.playStyleLabel.text = @"全屏视频";
    }
    [self layoutPics];
}

/**
 AD 图片(视频)控件更新
 
 - parameter orderedData: orderedData数据
 */
- (void)updateADPics:(ExploreOrderedData *)orderedData {
    id<TTAdFeedModel> adModel = orderedData.adModel;
    switch (self.style) {
        case TTArticlePicViewStyleRight: {
            TTImageInfosModel *model = [adModel imageModel];
            if (!model) {
                model = orderedData.article.listMiddleImageModel;
            }
            //广告图片不持久化
            [self.picView1 setImageWithModel:model placeholderImage:nil];
            break;
        }
        case TTArticlePicViewStyleLarge:
        {
        TTImageInfosModel *model = [adModel imageModel];
        if (!model) {
            model = orderedData.article.listLargeImageModel;
        }
        //广告图片不持久化
        [self.picView1 setImageWithModel:model placeholderImage:nil];
        }
            break;
        case TTArticlePicViewStyleTriple:
        {
        NSArray<NSDictionary *>* pics = orderedData.article.listGroupImgDicts;
        if ([pics count] > 2) {
            [self.picView1 setImageWithModelInTrafficSaveMode:[[TTImageInfosModel alloc] initWithDictionary:pics[0]] placeholderImage:nil];
            [self.picView2 setImageWithModelInTrafficSaveMode:[[TTImageInfosModel alloc] initWithDictionary:pics[1]] placeholderImage:nil];
            [self.picView3 setImageWithModelInTrafficSaveMode:[[TTImageInfosModel alloc] initWithDictionary:pics[2]] placeholderImage:nil];
        } else {
            [self.picView1 setImageWithModelInTrafficSaveMode:nil placeholderImage:nil];
            [self.picView2 setImageWithModelInTrafficSaveMode:nil placeholderImage:nil];
            [self.picView3 setImageWithModelInTrafficSaveMode:nil placeholderImage:nil];
        }
        }
            break;
        default:
        {
        [self.picView1 setImageWithModelInTrafficSaveMode:nil placeholderImage:nil];
        [self.picView2 setImageWithModelInTrafficSaveMode:nil placeholderImage:nil];
        [self.picView3 setImageWithModelInTrafficSaveMode:nil placeholderImage:nil];
        }
            break;
    }
    self.messageBackgroundView.hidden = YES;
    self.playStyleBackgroundView.hidden = YES;
    [self layoutPics];
}

- (TTImageView *)animationFromView
{
    return self.picView1;
}

@end
