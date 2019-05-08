//
//  FHBaseTableViewCell.h
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHBaseTableViewCell : UITableViewCell

@property(nonatomic , assign , getter=isHead) BOOL head;
@property(nonatomic , assign , getter=isTail) BOOL tail;

+(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
