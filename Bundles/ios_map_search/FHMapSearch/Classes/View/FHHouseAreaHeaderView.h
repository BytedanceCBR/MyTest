//
//  FHHouseAreaHeaderView.h
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import <UIKit/UIKit.h>
#import <FHHouseType.h>

NS_ASSUME_NONNULL_BEGIN
@class FHMapSearchDataListModel;
@interface FHHouseAreaHeaderView : UIControl

-(void)updateWithMode:(FHMapSearchDataListModel *)model houseType:(FHHouseType)houseType;

-(void)hideTopTip:(BOOL)hide;

@end

NS_ASSUME_NONNULL_END
