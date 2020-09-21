//
//  PreviewController.h
//  Image Hunter
//
//  Created by Jonatan Yde on 09/02/13.
//  Copyright (c) 2013 Codeninja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILazyImageView.h"
#import "Communicator.h"

@interface PreviewController : UIViewController <UIScrollViewDelegate,MessageDelegate>
{
    NSString *imageUrl;
    Communicator *com;
}
//@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewPane;
@property (retain, nonatomic) NSString *imageUrl;
@property (retain, nonatomic) UIActivityIndicatorView *spinner;
@end
