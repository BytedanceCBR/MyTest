//
//  InterfaceController.m
//  News WatchKit Extension
//
//  Created by yuxin on 5/26/15.
//
//

#import "InterfaceController.h"
#import "TTWatchItemModel.h"
#import "AlertInterfaceController.h"
#import "TTWatchConnectPhoneManager.h"
#import "TTWatchMacroDefine.h"

@interface InterfaceController()

@property(nonatomic,strong) TTWatchItemModel * itemModel;
@property(nonatomic,strong) NSURLSessionDataTask *dataTask;
@property(nonatomic,strong) NSData *imageData;

@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self setTitle:@"爱看"];
    
    if([context isKindOfClass:[TTWatchItemModel class]]){
        self.itemModel = (TTWatchItemModel *)context;
        
        [self.titleLb setText:self.itemModel.title];
        [self.commentLb setText:[NSString stringWithFormat:@"评论:%@",[self.itemModel.commentCount stringValue]]];
        
        [self.timerLb setDate:[NSDate dateWithTimeIntervalSince1970:[self.itemModel.beHotTime integerValue]]];
        [self.timerLb start];
        
        if (self.itemModel.abstract.length > 0) {
            [self.contentLb setText:self.itemModel.abstract];
        }
        else{
            [self.contentLb setText:self.itemModel.title];
        }
        if(!isEmptyString(self.itemModel.imageURLString)){
            [self.articleImage setRelativeHeight:0.6 withAdjustment:0];
            [self refreshImage];
        }
        else{
            [self.articleImage sizeToFitHeight];
        }
    }
}

- (void)refreshImage{
    if(isEmptyString(self.itemModel.imageURLString)){
        return;
    }
    if(!self.imageData && (!_dataTask || _dataTask.state != NSURLSessionTaskStateRunning)){
         WeakSelf;
        _dataTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:[self.itemModel imageURLString]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            StrongSelf;
            if(!error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.articleImage setBackgroundImageData:data];
                    self.imageData = data;
                });
            }
        }];
        [_dataTask resume];
    }
    else if(self.imageData){
        [self.articleImage setBackgroundImageData:self.imageData];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self refreshImage];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)openParentApp:(id)sender {
    NSString * schemaUrl = [NSString stringWithFormat:@"sslocal://detail?groupid=%@",[self.itemModel.uniqueID stringValue]];
    [[TTWatchConnectPhoneManager sharedInstance] openParentApplication:@{@"url":schemaUrl} reply:^(NSError *error) {
        if (!error){
            [self presentControllerWithName:@"AlertInterfaceController" context:nil];
        }
    }];
}
@end



