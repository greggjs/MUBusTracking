//
//  SidebarViewController.m
//  MU Bus Tracking
//
//  Created by Jake Gregg on 9/16/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "SidebarViewController.h"

@implementation SidebarViewController
@synthesize sidebarDelegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Put init params here...
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.sidebarDelegate respondsToSelector:@selector(lastSelectedIndexPathForSidebarViewController:)]) {
        NSIndexPath *indexPath = [self.sidebarDelegate lastSelectedIndexPathForSidebarViewController:self];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.textColor = [UIColor redColor];
    cell.backgroundColor = [UIColor clearColor];
    
    UIImage *image;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat:@"All Routes"];
            break;
        case 1:
            cell.textLabel.text = @"U1: Campus Core";
            image = [UIImage imageNamed:@"bus_orange.png"];
            break;
        case 2:
            cell.textLabel.text = @"U2: Park & Ride";
            image = [UIImage imageNamed:@"bus_red.png"];
            break;
        case 3:
            cell.textLabel.text = @"U3: Tollgate Loop";
            image = [UIImage imageNamed:@"bus_purple1.png"];
            break;
        case 4:
            cell.textLabel.text = @"U4: City Loop";
            image = [UIImage imageNamed:@"bus_green.png"];
            break;
        case 5:
            cell.textLabel.text = @"U5: Level 27 Express";
            image = [UIImage imageNamed:@"bus_yellow.png"];
            break;
        case 6:
            cell.textLabel.text = @"U6: Level 27 After Hours";
            image = [UIImage imageNamed:@"bus_blue.png"];
            break;
        default:
            image = [UIImage imageNamed:@"bus_red.png"];
            break;
    }
    cell.imageView.image = image;

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.title;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sidebarDelegate) {
        NSString *title = [[NSString alloc]init];
        switch(indexPath.row) {
            case 0:
                title = @"myMetro";
                break;
            case 1:
                title = @"Campus Core";
                break;
            case 2:
                title = @"Park & Ride";
                break;
            case 3:
                title = @"Tollgate Loop";
                break;
            case 4:
                title = @"City Loop";
                break;
            case 5:
                title = @"Level 27 Express";
                break;
            case 6:
                title = @"Level 27 After Hours";
                break;
            default:
                break;
        }
        NSObject *object = [NSString stringWithFormat:title, indexPath.row];
        [self.sidebarDelegate sidebarViewController:self didSelectObject:object atIndexPath:indexPath];
    }
}

@end
