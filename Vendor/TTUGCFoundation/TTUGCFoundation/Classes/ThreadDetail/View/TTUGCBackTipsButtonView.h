//
//  TTUGCBackTipsButtonView.h
//  TTUGCFoundation
//
//  Created by jinqiushi on 2018/2/1.
//

#import <SSWebViewBackButtonView.h>

@interface TTUGCBackTipsButtonView : SSWebViewBackButtonView

@property(nonatomic, strong) UILabel *tipLabel;

- (void)setTipsCount:(NSInteger)count;

- (NSInteger)getBadgeNumber;

@end
