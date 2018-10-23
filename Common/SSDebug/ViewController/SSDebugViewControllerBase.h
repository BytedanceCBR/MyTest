//
//  SSDebugViewControllerBase.h
//  Article
//
//  Created by liufeng on 2017/8/14.
//
//

#if INHOUSE

#import "SSViewControllerBase.h"

@class SSThemedTableView;

@interface STTableViewCellItem : NSObject

- (instancetype)initWithTitle:(NSString *)title target:(id)target action:(SEL)action;

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *detail;
//// Cell 点击时的响应事件
@property(nonatomic, weak) id target;
/// action Must have zero argument like someRowClicked {}
@property(nonatomic, assign) SEL action;

@property(nonatomic, strong) id contextInfo;

@property(nonatomic) BOOL switchStyle;
@property(nonatomic) BOOL checked;
@property(nonatomic) SEL  switchAction;

@property(nonatomic) BOOL textFieldStyle;
@property(nonatomic) SEL  textFieldAction;
@property(nonatomic, copy) NSString *textFieldContent;

@property(nonatomic,assign)NSInteger tag;


@end

@interface STTableViewSectionItem : NSObject

- (instancetype)initWithSectionTitle:(NSString *)title items:(NSArray *)items;
- (instancetype)initWithSectionHeaderTitle:(NSString *)title footerTitle:(NSString *)footerTitle items:(NSArray *)items;
@property(nonatomic, copy) NSString *headerTitle;
@property(nonatomic, copy) NSString *footerTitle;
@property(nonatomic, copy) NSArray *items;

@end

@interface UIScrollView (ScrollToBottom)

- (void)scrollToBottomAnimated:(BOOL)animated;

@end

@interface STDebugTextView : UITextView

- (void)appendText:(NSString *)text;

@end

@interface SSDebugViewControllerBase : SSViewControllerBase <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, copy)   NSArray <STTableViewSectionItem *>*dataSource;
@property(nonatomic, strong) SSThemedTableView *tableView;

@end

#endif
