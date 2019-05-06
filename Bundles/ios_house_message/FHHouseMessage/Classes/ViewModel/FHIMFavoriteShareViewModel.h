//
//  FHIMFavoriteShareViewModel.h
//  AKCommentPlugin
//
//  Created by leo on 2019/4/28.
//

#import <Foundation/Foundation.h>
#import "FHIMFavoriteSharePageViewModel1.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHIMFavoriteShareViewModel : NSObject<FHIMFavoriteSharePageViewSelected, UIScrollViewDelegate>
@property (nonatomic, strong) NSArray<FHIMFavoriteSharePageViewModel1*>* pageViewModels;
@property (nonatomic, strong) NSArray* selectedItems;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, weak) UIViewController* viewController;
@property (nonatomic, copy) NSString* conversactionId;
@property (nonatomic, weak) FHIMFavoriteSharePageViewModel1* currentPageViewModel;
-(void)didPageContentSizeChange:(id)contentSize;
-(void)sendSelectedItemToIM;
@end

NS_ASSUME_NONNULL_END
