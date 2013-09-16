//
//  DetailViewController.h
//  MU Bus Tracking
//
//  Created by Jake Gregg on 9/15/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
