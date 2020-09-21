//
//  GalleryController.h
//  Image Hunter
//
//  Created by Jonatan Yde on 19/05/16.
//  Copyright © 2016 Codeninja. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import "ImageInfo.h"
#import "ImageRowType.h"

@interface GalleryController : WKInterfaceController
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *imageTable;

@end
