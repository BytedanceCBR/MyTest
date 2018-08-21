//
//  ExploreWidgetEmptyView.h
//  Article
//
//  Created by Zhang Leonardo on 14-10-13.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ExploreWidgetEmptyViewType)
{
    ExploreWidgetEmptyViewTypeLoading = 0,
    ExploreWidgetEmptyViewTypeError = 1,
};


@interface ExploreWidgetEmptyView : UIView

@property(nonatomic, retain, readonly)UIButton * actionButton;
@property(nonatomic, assign, readonly)ExploreWidgetEmptyViewType emptyType;

+ (CGFloat)heightForView;

- (void)refreshType:(ExploreWidgetEmptyViewType)type;

@end
