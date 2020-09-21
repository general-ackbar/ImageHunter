//
//  ImageRowType.h
//  Image Hunter
//
//  Created by Jonatan Yde on 23/05/16.
//  Copyright © 2016 Codeninja. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface ImageRowType : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceLabel* rowDescription;
@property (weak, nonatomic) IBOutlet WKInterfaceImage* rowImage;


@end
