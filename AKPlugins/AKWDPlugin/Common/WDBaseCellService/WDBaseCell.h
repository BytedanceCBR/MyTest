//
//  WDBaseCell.h
//  wenda
//
//  Created by xuzichao on 2017/2/8.
//

#import <UIKit/UIKit.h>
#import <TTThemed/SSThemed.h>

@class WDBaseCellView;

@protocol  WDBaseCellDelegate <NSObject>

@optional

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(NSInteger)listType;

+ (Class)cellViewClass;

@property (nonatomic,strong)WDBaseCellView *cellView;

@property (nonatomic,weak)UITableView *tableView;

@property (nonatomic, strong) NSIndexPath *indexPath;


- (void)refreshUI;

- (void)refreshWithData:(id)data;

- (id)cellData;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

- (void)willDisplay;

- (void)willAppear;

- (void)willDisappear;

- (void)didDisappear;

- (void)didAppear;

- (void)didSelected:(id)data apiParam:(NSString *)apiParam;

- (CGFloat)paddingTopBottomForCellView;

- (CGFloat)paddingForCellView;

@end

@interface WDBaseCell :  UITableViewCell <WDBaseCellDelegate>


@property (nonatomic,strong)WDBaseCellView *cellView;

@property (nonatomic,weak)UITableView *tableView;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end
