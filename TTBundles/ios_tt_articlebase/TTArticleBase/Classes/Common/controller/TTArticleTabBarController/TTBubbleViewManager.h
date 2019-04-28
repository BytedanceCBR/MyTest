//
//  TTBubbleViewManager.h
//  Article
//
//  Created by 王双华 on 2017/7/10.
//
//

#import <Foundation/Foundation.h>
#import "TTBubbleViewHeader.h"

@interface TTBubbleViewManager : NSObject

@property(nonatomic, strong, readonly) NSString *field;
@property(nonatomic, strong, readonly) NSString *text;
@property(nonatomic, assign, readonly) NSTimeInterval displayInterval;
@property(nonatomic, assign, readonly) NSTimeInterval autoDismissInterval;
@property(nonatomic, assign, readonly) TTBubbleViewType viewType;
@property(nonatomic, assign) BOOL isValid;
+ (instancetype)shareManager;

- (NSString *)tabbarIdentifier;
- (void)saveShowTips:(NSDictionary *)dict;

- (void)sendTrackForTipsShow;
- (void)sendTrackForTipsActiveClose;
- (void)sendTrackForTipsAutoClose;
- (void)sendTrackForTipsEnterClick;

- (void)setTipHasShow;

+ (BOOL)isViewTypeTimer:(TTBubbleViewType)viewType;
@end

