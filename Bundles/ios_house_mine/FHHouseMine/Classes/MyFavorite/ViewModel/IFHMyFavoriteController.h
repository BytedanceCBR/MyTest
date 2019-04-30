//
//  IFHMyFavoriteController.h
//  FHHouseMessage
//
//  Created by leo on 2019/4/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class FHErrorView;
@protocol IFHMyFavoriteController <NSObject>
@property (nonatomic, strong) FHErrorView *emptyView;
@property(nonatomic , strong) NSMutableDictionary *tracerDict;
@property(nonatomic , assign) BOOL hasValidateData;
-(void)bindTableView:(UITableView*)tableView;
@end

NS_ASSUME_NONNULL_END
