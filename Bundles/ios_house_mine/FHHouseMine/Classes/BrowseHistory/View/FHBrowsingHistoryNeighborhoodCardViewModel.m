//
//  FHBrowsingHistoryNeighborhoodCardViewModel.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHBrowsingHistoryNeighborhoodCardViewModel.h"

@implementation FHBrowsingHistoryNeighborhoodCardViewModel

- (BOOL)isOffShelf {
    return self.model.houseStatus.integerValue == 1;
}


@end
