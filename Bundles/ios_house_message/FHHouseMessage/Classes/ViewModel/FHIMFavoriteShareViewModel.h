//
//  FHIMFavoriteShareViewModel.h
//  AKCommentPlugin
//
//  Created by leo on 2019/4/28.
//

#import <Foundation/Foundation.h>
#import "FHIMFavoriteSharePageViewModel1.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHIMFavoriteShareViewModel : NSObject<FHIMFavoriteSharePageViewSelected>
@property (nonatomic, strong) NSArray<FHIMFavoriteSharePageViewModel1*>* pageViewModels;
@property (nonatomic, strong) NSArray* selectedItems;
@end

NS_ASSUME_NONNULL_END
