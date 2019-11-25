//
//  FHEditUserBaseCell.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/5/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHEditUserBaseCellDelegate <NSObject>

@optional
- (void)changeHomePageAuth:(BOOL)isOpen;

@end

@interface FHEditUserBaseCell : UITableViewCell

@property(nonatomic , weak) id<FHEditUserBaseCellDelegate> delegate;

- (void)updateCell:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
