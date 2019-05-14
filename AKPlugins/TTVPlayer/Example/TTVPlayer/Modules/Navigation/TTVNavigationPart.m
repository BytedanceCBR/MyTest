//
//  TTVNavigationPart.m
//  TTVPlayer
//
//  Created by lisa on 2019/2/1.
//

#import "TTVNavigationPart.h"
#import "TTVPlayer.h"
#import "UIImage+TTVHelper.h"

@interface TTVNavigationPart ()

#pragma mark - custom UI
// set UI
@property (nonatomic) TTVPlayerLayoutVerticalAlign verticalAlignOnNormal;   // 垂直对齐， 默认是顶对齐
@property (nonatomic) TTVPlayerLayoutVerticalAlign verticalAlignOnFull;     // 垂直对齐， 默认是顶对齐

// back
@property (nonatomic, copy) NSString * defaultBackImageNameOnNormal;
@property (nonatomic, copy) NSString * defaultBackImageNameOnFull;

// title
@property (nonatomic)       NSInteger  titleNumberOfLinesOnNormal;
@property (nonatomic)       NSInteger  titleNumberOfLinesOnFull;

@property (nonatomic)       CGFloat    titleFontSizeOnNormal;
@property (nonatomic)       CGFloat    titleFontSizeOnFull;

@property (nonatomic, copy) NSString * titleFontColorString;

@property (nonatomic)       BOOL       showAnimationEnabled;
@property (nonatomic) CGFloat    barHeightOnNormal;
@property (nonatomic) CGFloat    barHeightOnFull;

@property (nonatomic, copy) NSString *backgroundColorString; // 背景图颜色
@property (nonatomic, copy) NSString *backgroundImageName;   // 背景图名字


@end

@implementation TTVNavigationPart

@synthesize playerStore, player, customBundle;
@synthesize titleFontColorString = _titleFontColorString;

#pragma mark - TTVReduxStateObserver

- (void)stateDidChangedToNew:(TTVPlayerState *)newState lastState:(TTVPlayerState *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store {
    
    if ((newState.controlViewState.isAllSubcontrolShowedFirstTime != lastState.controlViewState.isAllSubcontrolShowedFirstTime && newState.controlViewState.isAllSubcontrolShowedFirstTime) ||
        newState.fullScreenState.isFullScreen != lastState.fullScreenState.isFullScreen ||
        ![newState.videoTitle isEqualToString:lastState.videoTitle]) {
//        self.navigationBar.height = newState.fullScreenState.isFullScreen?self.barHeightOnFull:self.barHeightOnNormal;
        
        UIFont * labelFont;
        if (@available(iOS 8.2, *)) {
            labelFont = [UIFont systemFontOfSize:[TTVPlayerUtility tt_fontSize:newState.fullScreenState.isFullScreen?self.titleFontSizeOnFull:self.titleFontSizeOnNormal] weight:UIFontWeightMedium];
        } else {
            // Fallback on earlier versions
            labelFont = [UIFont systemFontOfSize:[TTVPlayerUtility tt_fontSize:newState.fullScreenState.isFullScreen?self.titleFontSizeOnFull:self.titleFontSizeOnNormal]];
        }
        newState.fullScreenState.isFullScreen ? labelFont : [TTVPlayerUtility ttv_distinctTitleFont];
        
        if (newState.fullScreenState.isFullScreen) {
            self.navigationBar.defaultTitleLable.font = labelFont;
            if (self.navigationBar.defaultTitleHasShadow) {
                self.navigationBar.defaultTitleLable.attributedText = [[self class] attributedVideoTitleFromString:newState.videoTitle fontSize:self.titleFontSizeOnNormal];
            }
            else {
                self.navigationBar.defaultTitleLable.text = newState.videoTitle;
            }        self.navigationBar.verticalAlign = self.verticalAlignOnFull;
            [self.navigationBar.defaultBackButton setImage:[self defaultBackImageOnFull] forState:UIControlStateNormal];
            self.navigationBar.defaultTitleLable.numberOfLines = self.titleNumberOfLinesOnFull;
            
        } else {
            self.navigationBar.defaultTitleLable.text = nil;
            self.navigationBar.defaultTitleLable.font = labelFont;
            if (self.navigationBar.defaultTitleHasShadow) {
                self.navigationBar.defaultTitleLable.attributedText = [[self class] attributedVideoTitleFromString:newState.videoTitle fontSize:self.titleFontSizeOnNormal];
                
            }
            else {
                self.navigationBar.defaultTitleLable.text = newState.videoTitle;
            }
            self.navigationBar.verticalAlign = self.verticalAlignOnNormal;
            [self.navigationBar.defaultBackButton setImage:[self defaultBackImageOnNormal] forState:UIControlStateNormal];
            self.navigationBar.defaultTitleLable.numberOfLines = self.titleNumberOfLinesOnNormal;
        }
        
    }
    
    // 动画
    //    if (self.showAnimationEnabled) {
    //        if (self.controlViewShowed != state.controlViewState.isShowed) {
    //            self.controlViewShowed = state.controlViewState.isShowed;
    //            // 动画
    //            CGFloat newHeight = self.controlViewShowed ? self.bottomToolBarHeightOnNormal : 0;
    //            self.navigationBar.layer.bounds = CGRectMake(self.bottomToolBar.left, self.bottomToolBar.top, self.bottomToolBar.width, newHeight);
    //        }
    //    }
}


- (void)subscribedStoreSuccess:(TTVReduxStore *)store {
    
}

- (TTVPlayerState *)state {
    return (TTVPlayerState *)self.playerStore.state;
}
#pragma mark - action


#pragma mark - TTVPlayerPartProtocol
- (UIView *)viewForKey:(NSUInteger)key {
    if (key == TTVPlayerPartControlKey_NavigationBar) {
        return self.navigationBar;
    }
    if (key == TTVPlayerPartControlKey_Title) {
        return self.navigationBar.defaultTitleLable;
    }
    if (key == TTVPlayerPartControlKey_Back) {
        return self.navigationBar.defaultBackButton;
    }
    return nil;
}

- (TTVPlayerPartKey)key {
    return TTVPlayerPartKey_Navigation;
}

- (void)customPartControlForKey:(TTVPlayerPartControlKey)key withConfig:(NSDictionary *)dict {
    if (key == TTVPlayerPartControlKey_NavigationBar) {
        self.backgroundColorString = dict[@"BackgroundColor"];
        self.backgroundImageName = dict[@"BackgroundImage"];
        self.verticalAlignOnNormal = [dict[@"VerticalAlignOnNormal"] integerValue];
        self.verticalAlignOnFull = [dict[@"VerticalAlignOnFull"] integerValue];
        self.showAnimationEnabled = [dict[@"ShowAnimationEnabled"] boolValue];
        self.navigationBar.height = 130;//self.barHeightOnNormal; // TODO 默认
    }
    else if (key == TTVPlayerPartControlKey_Title){
        self.titleNumberOfLinesOnNormal = [dict[@"NumberOfLinesOnNormal"] integerValue];
        self.titleNumberOfLinesOnFull = [dict[@"NumberOfLinesOnFull"] integerValue];
        self.titleFontSizeOnNormal = [dict[@"FontSizeOnNormal"] floatValue];
        self.titleFontSizeOnFull = [dict[@"FontSizeOnFull"] floatValue];
        self.titleFontColorString = dict[@"FontColor"];
        self.navigationBar.defaultTitleHasShadow = [dict[@"FontShadowEnable"] boolValue];
    }
    else if (key == TTVPlayerPartControlKey_Back) {
        self.defaultBackImageNameOnNormal = dict[@"ImageOnNormal"];
        self.defaultBackImageNameOnFull = dict[@"ImageOnFull"];
    }
}

#pragma mark -
+ (NSAttributedString *)attributedVideoTitleFromString:(NSString *)text fontSize:(CGFloat)fontSize {
    if (isEmptyString(text)) return nil;
    
    UIFont *textFont = [self ttv_distinctTitleFont:fontSize];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 2.0f;
    shadow.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.54f];
    shadow.shadowOffset = CGSizeZero;
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByCharWrapping; // 解决折行问题
    paragraph.lineHeightMultiple = 1.4 * textFont.pointSize / textFont.lineHeight; // 行间距为字体的1.4倍
    
    NSDictionary *attributes = @{NSFontAttributeName           : textFont,
                                 NSShadowAttributeName         : shadow,
                                 NSParagraphStyleAttributeName : paragraph,
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

+ (UIFont *)ttv_distinctTitleFont:(CGFloat)fontSize {
    if ([TTDeviceHelper is667Screen]) {
        fontSize = fontSize+1;
    } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice] || [TTDeviceHelper isIPhoneXSeries]) {
        fontSize = fontSize+2;
    }
    
    return [UIFont fontWithName:@"PingFangSC-Semibold" size:fontSize] ?: [UIFont systemFontOfSize:fontSize];
}

#pragma mark - getter & setter

- (TTVPlayerNavigationBar *)navigationBar {
    if (!_navigationBar) {
        _navigationBar = [[TTVPlayerNavigationBar alloc] initWithFrame:CGRectZero];
    }
    return _navigationBar;
}

- (UIImage *)defaultBackImageOnNormal {
    if (!isEmptyString(self.defaultBackImageNameOnNormal)) {
        return [UIImage imageNamed:self.defaultBackImageNameOnNormal inBundle:self.customBundle compatibleWithTraitCollection:nil];
    }
    return [UIImage ttv_ImageNamed:@"player_back"];
}

- (UIImage *)defaultBackImageOnFull {
    if (!isEmptyString(self.defaultBackImageNameOnFull)) {
        return [UIImage imageNamed:self.defaultBackImageNameOnFull inBundle:self.customBundle compatibleWithTraitCollection:nil];
    }
    return [UIImage ttv_ImageNamed:@"player_back"];
}

- (NSString *)titleFontColorString {
    if (isEmptyString(_titleFontColorString)) {
        _titleFontColorString = @"0xffffff";
    }
    return _titleFontColorString;
}

- (void)setTitleFontColorString:(NSString *)titleFontColorString {
    _titleFontColorString = [titleFontColorString copy];
    self.navigationBar.defaultTitleLable.textColor = [TTVPlayerUtility colorWithHexString:self.titleFontColorString];
}

- (CGFloat)titleFontSizeOnNormal {
    if (_titleFontSizeOnNormal <= 0) {
        _titleFontSizeOnNormal = 17.0;
    }
    return _titleFontSizeOnNormal;
}
- (CGFloat)titleFontSizeOnFull {
    if (_titleFontSizeOnFull <= 0) {
        _titleFontSizeOnFull = 17.0;
    }
    return _titleFontSizeOnFull;
}

- (void)setBackgroundColorString:(NSString *)backgroundColorString {
    _backgroundColorString = backgroundColorString;
    if (!isEmptyString(_backgroundColorString)) {
        self.navigationBar.backgroundColor = [TTVPlayerUtility colorWithHexString:_backgroundColorString];
    }
}
- (void)setBackgroundImageName:(NSString *)backgroundImageName {
    _backgroundImageName = backgroundImageName;
    if (!isEmptyString(_backgroundImageName)) {
        UIImage * image = [UIImage imageNamed:_backgroundImageName inBundle:self.customBundle compatibleWithTraitCollection:nil];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
        [self.navigationBar.backgroundImageView setImage:image];
    }
}

@end
