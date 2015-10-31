//
//  DataManagement.h
//  Accounts List
//
//  Created by Anton Pomozov on 22.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#ifndef DataManagement_h
#define DataManagement_h

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    TableChangeInsert = 1,
    TableChangeDelete = 2,
    TableChangeMove   = 3,
    TableChangeUpdate = 4
} TableChangeType;

@protocol DataSource <NSObject>

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
- (NSArray *)sectionIndexTitles;

@end

@protocol DataPresenter <NSObject>

@property (nonatomic, strong) NSBlockOperation *updateOperation;

- (void)reloadData;
- (void)willChangeContent;
- (void)didChangeSectionatIndex:(NSUInteger)sectionIndex
                  forChangeType:(TableChangeType)type;
- (void)didChangeObject:(id)anObject
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(TableChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath;
- (void)didChangeContent;

@end

@protocol DataPresenterDelegate <NSObject>

@property (nonatomic, strong) id <DataPresenter> presenter;

@end

@protocol DataSourceDelegate <NSObject>

@property (strong, nonatomic) id <DataSource, DataPresenterDelegate> dataSource;

@end

NS_ASSUME_NONNULL_END

#endif /* DataManagement_h */
