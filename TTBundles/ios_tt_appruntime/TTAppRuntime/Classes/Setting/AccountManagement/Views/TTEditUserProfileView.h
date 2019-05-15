//
//  TTEditUserProfileView.h
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import <Foundation/Foundation.h>
#import "SSThemed.h"
#import "SSViewBase.h"




@class TTEditUserProfileView;
@protocol TTEditUserProfileViewDelegate <NSObject>
- (void)editUserProfileView:(TTEditUserProfileView *)aView goBack:(id)sender;
@end

@interface TTEditUserProfileView : SSViewBase
@property (nonatomic, weak) id<TTEditUserProfileViewDelegate> delegate;
@property (nonatomic, strong, readonly) SSThemedTableView *tableView;

- (void)reloadData;
@end
