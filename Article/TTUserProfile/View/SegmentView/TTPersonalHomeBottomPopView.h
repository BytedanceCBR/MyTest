//
//  TTPersonalHomeBottomPopView.h
//  Article
//
//  Created by wangdi on 2017/3/27.
//
//

#import "SSThemed.h"
#import "TTPersonalHomeUserInfoResponseModel.h"
#import "TTRoute.h"
#import <TTURLUtils.h>
@interface TTPersonalHomeBottomPopView : SSThemedView

- (void)showFromPoint:(CGPoint)point superView:(UIView *)superView dataSource:(NSArray<TTPersonalHomeUserInfoDataBottomItemResponseModel *> *)dataSource;

@end
