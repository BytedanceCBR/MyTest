//
//  FHIMFavoriteSharePageViewModel1.h
//  FHHouseMessage
//
//  Created by leo on 2019/4/29.
//

#import "FHIMFavoriteViewViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHIMFavoriteSharePageViewSelected <NSObject>

-(void)onItemSelected:(id)vm;

@end

@interface FHIMFavoriteSharePageViewModel1 : FHIMFavoriteViewViewModel
@property (nonatomic, weak) id<FHIMFavoriteSharePageViewSelected> selectedListener;
- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHMyFavoriteViewController *)viewController type:(FHHouseType)type;
-(void)cleanSelects;
-(NSArray*)selectedItems;
@end

NS_ASSUME_NONNULL_END
