//
//  FHFastQAViewModel.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/6/18.
//

#import "FHFastQAViewModel.h"
#import "FHFastQAGuessQuestionView.h"
#import "FHFastQAViewController.h"

@interface FHFastQAViewModel ()<FHFastQAGuessQuestionViewDelegate,UIScrollViewDelegate>

@end

@implementation FHFastQAViewModel


-(void)requestData
{
    
}

-(void)submit
{
    
}

-(void)selectView:(FHFastQAGuessQuestionView *)view atIndex:(NSInteger)index
{
    
}

#pragma mark - scrollview delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.isTracking) {

        [self.viewController.view endEditing:YES];
    }
}

@end
