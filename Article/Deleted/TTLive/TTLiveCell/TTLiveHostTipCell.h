//
//  TTLiveHostTipCell.h
//  Article
//
//  Created by chenjiesheng on 2017/6/9.
//
//

#import <UIKit/UIKit.h>

@class TTLiveMessage;
@interface TTLiveHostTipCell : UITableViewCell

- (void)setupViewWithHost:(TTLiveMessage *)tipMessage;
@end
