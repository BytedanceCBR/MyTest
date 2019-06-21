//
//  FHFastQAViewModel.h
//  FHHouseFind
//
//  Created by 春晖 on 2019/6/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class FHFastQAViewController;
@class FHFastQATextView;
@class FHFastQAGuessQuestionView;
@class FHFastQAMobileNumberView;
@interface FHFastQAViewModel : NSObject

@property(nonatomic , weak) FHFastQAViewController *viewController;
@property(nonatomic , strong) FHFastQATextView *questionView;
@property(nonatomic , strong) FHFastQAGuessQuestionView *guessView;
@property(nonatomic , strong) FHFastQAMobileNumberView *mobileView;

-(void)requestData;

-(void)submitQuestation;

-(void)addGoDetailLog;

-(void)viewWillAppear;

-(void)viewWillDisappear;

- (void)endTrack;

- (void)startTrack;

- (void)resetStayTime;

-(void)addStayPageLog;

-(void)addQuckAction;

@end

NS_ASSUME_NONNULL_END

