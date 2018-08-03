//
//  TTXiguaLiveLayoutBase.h
//  Article
//
//  Created by lipeilun on 2017/12/1.
//

#import <Foundation/Foundation.h>
#import "ExploreOrderedData+TTBusiness.h"

@interface TTXiguaLiveLayoutBase : NSObject
@property (nonatomic, assign) BOOL needTopPadding;
@property (nonatomic, assign) CGRect topSeparatorFrame;
@property (nonatomic, assign) BOOL needBottomPadding;
@property (nonatomic, assign) CGRect bottomSeparatorFrame;

@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, assign) BOOL avatarViewHidden;
@property (nonatomic, assign) CGRect avatarViewFrame;
@property (nonatomic, assign) BOOL showVerifyIcon;
@property (nonatomic, copy) NSString *userAuthInfo;

@property (nonatomic, assign) CGRect nameLabelFrame;
@property (nonatomic, copy) NSString *nameLabelThemePath;
@property (nonatomic, assign) CGRect descLabelFrame;
@property (nonatomic, copy) NSString *descLabelThemePath;
@property (nonatomic, copy) NSString *descLabelStr;

@property (nonatomic, assign) CGRect contentFrame;
@property (nonatomic, assign) CGRect largePicFrame;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, assign) BOOL dislikeButtonHidden;
@property (nonatomic, assign) CGSize dislikeButtonSize;
@property (nonatomic, assign) CGFloat dislikeButtonLeft;
@property (nonatomic, assign) CGFloat dislikeButtonCenterY;

@property (nonatomic, assign) CGFloat contentFontSize;
@property (nonatomic, assign) CGFloat contentLines;
@property (nonatomic, copy) NSAttributedString *contentAttributedStr;
//直播组件
//@property (nonatomic, assign) CGRect avatarViewFrame;
//@property (nonatomic, assign) CGRect avatarViewFrame;
//@property (nonatomic, assign) CGRect avatarViewFrame;
//@property (nonatomic, assign) CGRect avatarViewFrame;
- (void)refreshComponentsLayoutWithData:(ExploreOrderedData *)orderData width:(CGFloat)width;
@end
