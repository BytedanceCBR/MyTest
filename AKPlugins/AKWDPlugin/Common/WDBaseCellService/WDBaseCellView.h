//
//  WDBaseCellView.h
//  wenda
//
//  Created by xuzichao on 2017/2/8.
//

#import "SSThemed.h"

@class WDBaseCell;

@interface WDBaseCellView : SSViewBase

@property(nonatomic, weak)WDBaseCell *cell;
@property(nonatomic, copy)NSString *reuseIdentifier;
@property (nonatomic, assign) BOOL hideBottomLine;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier;

- (void)refreshUI;
    
- (void)refreshWithData:(id)data;
    
- (id)cellData;
    
- (void)fontSizeChanged;
    
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
- (void)willDisplaying:(UIView *)listView;
- (void)didEndDisplaying:(UIView *)listView;
- (void)didSelected:(id)data apiParam:(NSString *)apiParam;
    
+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(NSInteger)listType;

- (void)willDisplay;


@end
