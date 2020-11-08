//
//  FHOldSuggestionItemCell.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/1/3.
//

#import <UIKit/UIKit.h>
#import "FHSuggestionListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHOldSuggestionItemCell : UITableViewCell
@property (strong, nonatomic) FHSuggestionResponseItemModel* model;
@property (nonatomic, copy) NSString *highlightedText;
@property (weak, nonatomic) UIView *sepLine;
@end

NS_ASSUME_NONNULL_END
