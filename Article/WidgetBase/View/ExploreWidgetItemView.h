//
//  ExploreWidgetItemView.h
//  Article
//
//  Created by Zhang Leonardo on 14-10-11.
//
//

#import <UIKit/UIKit.h>
#import <NotificationCenter/NCWidgetTypes.h>
#import "ExploreWidgetItemModel.h"

@protocol ExploreWidgetItemViewDelegate;

@interface ExploreWidgetItemView : UIView

@property(nonatomic, weak)NSObject<ExploreWidgetItemViewDelegate> * delegate;
@property(nonatomic, retain, readonly)ExploreWidgetItemModel * model;


+ (CGFloat)heightForModel:(ExploreWidgetItemModel *)model;
+ (CGFloat)preferredInitHeight;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (void)refreshWithModel:(ExploreWidgetItemModel *)model widgetDisplayMode:(NCWidgetDisplayMode)mode;
#pragma clang diagnostic pop

@end

@protocol ExploreWidgetItemViewDelegate

- (void)itemView:(ExploreWidgetItemView *)itemView urlStr:(NSString *)url;
@end
