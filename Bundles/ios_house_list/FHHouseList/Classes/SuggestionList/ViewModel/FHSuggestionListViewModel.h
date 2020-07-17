//
//  FHSuggestionListViewModel.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import "FHSuggestionListViewController.h"
#import "HMSegmentedControl.h"
#import "FHSuggestionCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHSuggestionListViewModel : NSObject

@property (nonatomic, assign)     FHHouseType       houseType;
@property (nonatomic, assign)   NSInteger       associatedCount;
@property (nonatomic, weak)   HMSegmentedControl *segmentControl;
@property (nonatomic, assign) NSInteger currentTabIndex;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) BOOL isTrackerCacheDisabled;

-(instancetype)initWithController:(FHSuggestionListViewController *)viewController;

-(void)initCollectionView:(FHSuggestionCollectionView *) collectionView;

-(void)textFieldShouldReturn:(NSString *)text;

-(void)textFieldTextChange:(NSString *)text;

-(void)updateSubVCTrackStatus;

@end

NS_ASSUME_NONNULL_END
