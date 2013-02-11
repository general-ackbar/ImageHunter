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


- (IBAction)performSearch:(UIButton *)sender;


@end
