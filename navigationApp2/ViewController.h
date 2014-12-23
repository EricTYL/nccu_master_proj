//
//  ViewController.h
//  navigationApp2
//
//  Created by juston1 on 2014/9/21.
//  Copyright (c) 2014年 juston1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESTBeacon.h"

typedef enum : int
{
    ESTScanTypeBluetooth,
    ESTScanTypeBeacon
    
} ESTScanType;

@interface ViewController : UIViewController
@property (nonatomic,strong) NSString *holdPositionX;
@property (nonatomic,strong) NSString *holdPositionY;
@property (nonatomic,strong) NSString *firstPositionID;

#pragma Methods
/*
 * Selected beacon is returned on given completion handler.
 */
- (id)initWithScanType:(ESTScanType)scanType completion:(void (^)(ESTBeacon *))completion;
- (id)initWithBeacon:(ESTBeacon *)beacon;

@end
