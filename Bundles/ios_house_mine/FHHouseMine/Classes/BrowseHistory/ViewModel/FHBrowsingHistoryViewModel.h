//
//  FHBrowsingHistoryViewModel.h
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/12.
//

#import <Foundation/Foundation.h>
#import "FHBrowsingHistoryViewController.h"
#import "FHSuggestionCollectionView.h"

@interface FHBrowsingHistoryViewModel : NSObject

@property (nonatomic, assign) NSInteger currentTabIndex;

-(instancetype)initWithController:(FHBrowsingHistoryViewController *)viewController andCollectionView:(FHSuggestionCollectionView *)collectionView;

@end


