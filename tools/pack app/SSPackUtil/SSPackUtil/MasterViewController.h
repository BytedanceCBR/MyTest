//
//  MasterViewController.h
//  SSPackUtil
//
//  Created by Zhang Leonardo on 14-11-26.
//  Copyright (c) 2014年 leonardo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MasterViewController : NSViewController

@property (weak) IBOutlet NSTableView * channelListView;
@property (weak) IBOutlet NSButton * allCheckButton;
@property (weak) IBOutlet NSButton * allUncheckButton;
@property (weak) IBOutlet NSButton * removeChannelButton;
@property (weak) IBOutlet NSButton * addChannelButton;
@property (weak) IBOutlet NSTextField * addChannelTextField;
@property (weak) IBOutlet NSButton *selectOriginIPAButton;
@property (weak) IBOutlet NSTextField * originIPAPathLabel;
@property (weak) IBOutlet NSTextField * appInfoLabel;
@property (nonatomic, strong) IBOutlet NSTextView * consoleLabel;
@property (weak) IBOutlet NSButton * startButton;

- (IBAction)removeChannelButton:(id)sender;

- (IBAction)checkAllButtonClicked:(id)sender;
- (IBAction)uncheckAllButtonClicked:(id)sender;

- (IBAction)addChannelButtonClicked:(id)sender;
- (IBAction)selectOriginIPAButtonClicked:(id)sender;
- (IBAction)startButtonClicked:(NSButton *)sender;


@end
