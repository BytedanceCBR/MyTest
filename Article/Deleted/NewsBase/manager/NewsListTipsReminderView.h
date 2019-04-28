//
//  NewsListTipsReminderView.h
//  Article
//
//  Created by chenren on 10/07/2017.
//
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"
#import "SSThemed.h"

typedef NS_ENUM(NSUInteger, NewsListTipsReminderViewType)
{
    NewsListTipsReminderViewTypeAuto = 0,
    NewsListTipsReminderViewTypeShowOnce = 1,
    NewsListTipsReminderViewTypeStick = 2,
};

typedef NS_ENUM(NSUInteger, NewsListTipsReminderViewColor)
{
    NewsListTipsReminderViewTypeBlue = 0,
    NewsListTipsReminderViewTypeBlack = 1,
};

@protocol NewsListTipsReminderProtocol<NSObject>
@required
- (void)pullAndRefresh;
@end

typedef void (^NewsListTipsReminderViewActionBlock)(BOOL finished);

@interface NewsListTipsReminderView : SSViewBase

@property (nonatomic, assign, readonly) NewsListTipsReminderViewType type;
@property (nonatomic, assign, readonly) BOOL isShowing;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, weak) id delegate;
@property (nonatomic, copy) NewsListTipsReminderViewActionBlock appearActionBlock;
@property (nonatomic, copy) NewsListTipsReminderViewActionBlock disappearActionBlock;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL isInBackground;
@property (nonatomic, copy) NSString *categoryID;

- (id)initWithFrame:(CGRect)frame andType:(NewsListTipsReminderViewType)type andColor:(NewsListTipsReminderViewColor)color;
- (id)initWithSize:(CGSize)size andType:(NewsListTipsReminderViewType)type andColor:(NewsListTipsReminderViewColor)color;
- (void)show:(BOOL)isFirstTime;
- (void)disappear;
- (void)hide;
- (void)refreshAndHide;

@end
