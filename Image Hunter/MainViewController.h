//
//  MainViewController.h
//  Image Hunter
//
//  Created by Jonatan Yde on 07/02/13.
//  Copyright (c) 2013 Codeninja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController 
@property (weak, nonatomic) IBOutlet UITextField *SearchTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchTypeSegments;
@property (weak, nonatomic) IBOutlet UISwitch *searchSafeSwitch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UISwitch *searchClassicSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchSizeSegments;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchColorSegments;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchFormatSegments;




- (IBAction)performSearch:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;


@end
