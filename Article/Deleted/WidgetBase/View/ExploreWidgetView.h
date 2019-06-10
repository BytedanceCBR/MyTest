//
//  ExploreWidgetView.h
//  Article
//
//  Created by Zhang Leonardo on 14-10-11.
//
//

#import <UIKit/UIKit.h>
#import <NotificationCenter/NCWidgetTypes.h>
#import "ExploreWidgetEmptyView.h"

@protocol ExploreWidgetViewDelegate;

@interface ExploreWidgetView : UIView

@property(nonatomic, weak)id<ExploreWidgetViewDelegate> deleagte;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (void)refreshWithModels:(NSArray *)models widgetDisplayMode:(NCWidgetDisplayMode)mode maxCellCount:(NSInteger)maxCellCount;
#pragma clang diagnostic pop
- (void)refreshEmptyView:(ExploreWidgetEmptyViewType)type;
- (void)showOpenHostAppButton:(BOOL)show;

+ (CGFloat)heightForModels:(NSArray *)array;
+ (NSInteger)maxModelCountForHeightLimit:(CGFloat)heightLimit models:(NSArray *)models fixedHeight:(CGFloat *)fixedHeight;
+ (CGFloat)preferredInitHeight;

@end

@protocol ExploreWidgetViewDelegate <NSObject>

- (void)widgetViewClickErrorEmptyButtn:(ExploreWidgetView *)widgetView;
- (void)widgetView:(ExploreWidgetView *)widgetView openURL:(NSString *)urlStr;

@end
