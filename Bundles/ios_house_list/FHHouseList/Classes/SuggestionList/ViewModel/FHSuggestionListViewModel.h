//
//  FHSuggestionListViewModel.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import "FHHouseListAPI.h"
#import "FHSuggestionListModel.h"
#import "FHSuggestionListViewController.h"
#import "FHBaseCollectionView.h"
#import "HMSegmentedControl.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHSuggestionListViewModel : NSObject

@property (nonatomic, assign)     FHHouseType       houseType;
@property (nonatomic, assign)   NSInteger       associatedCount;
@property (nonatomic, weak) HMSegmentedControl *segmentControl;
@property(nonatomic , assign) NSInteger currentTabIndex;
-(instancetype)initWithController:(FHSuggestionListViewController *)viewController;
-(void)initCollectionView:(FHBaseCollectionView *) collectionView;
-(void)textFieldShouldReturn:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
