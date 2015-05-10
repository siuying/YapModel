# YapModel

YapModel is a DSL for working with [YapDatabase](https://github.com/yaptv/YapDatabase).
The syntax is borrowed from Ruby on Rails and inspired by [ObjectiveRecord](https://github.com/mneorr/ObjectiveRecord).

## Prerequisite

You'll need to understand [how YapDatabase works](https://github.com/yaptv/YapDatabase/wiki) before using this library.

## Synopsis

Define your class with DSL:

```objective-c
@interface Car : YapModelObject
@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign) NSUInteger year;
@property (nonatomic, assign) CGFloat price;

// create an index named "CarYearIndex"
@index(Car, CarYearIndex, @"year": @(YapDatabaseSecondaryIndexTypeInteger));

// create a view named "CarByYear"
@view(Car, CarByYear, @"group": @"year", @"sort": @"year");

// create relationships
@hasMany(Driver, carsKey, cars, YDB_DeleteDestinationIfSourceDeleted);

@end
```

And when the app initialize, setup the database:

```objective-c
YapDatabase* database = ... // create the database
[YapModel setupDatabase:database];
```

### Create / Save / Delete

```objective-c
[connection readWriteTransaction:^(YapDatabaseReadWriteTransaction* transaction){
    Person* john = [Person create];
    john.name = @"John";
    [john saveWithTransaction:transaction];
    [john deleteWithTransaction:transaction];

    [Person create:@{
      @"name": @"John",
      @"age": @12,
      @"member": @NO
    } withTransaction:transaction];
}];
```

### Finders

```objective-c
[connection readWriteTransaction:^(YapDatabaseReadWriteTransaction* transaction){
  // Find all objects
  NSArray* people = [Person allWithTransaction:transaction];

  // Get an object by key
  Person* john = [Person find:@"uuid" withTransaction:transaction];

  // Iterate with all objects and find the object matching the filter
  NSArray* people = [Person where:^BOOL(Person* person) {
      return person.age < 30;
  } withTransaction:transaction];

  // Find using Secondary Index
  Person *johnDoe = [Person findWithIndex:@"idx"
                                    query:[YapDatabaseQuery queryWithFormat:@"WHERE name == ? AND surname == ?", @"John", @"Doe"]
                          withTransaction:transaction];
}];

```

### Aggregation

```objective-c
[connection readWriteTransaction:^(YapDatabaseReadWriteTransaction* transaction){
  // count all Person entities
  NSUInteger personCount = [Person countWithTransaction:transaction];

  // count people named John
  NSUInteger johnCount = [Person countWithIndex:@"index"
                                          query:[YapDatabaseQuery queryWithFormat:@"WHERE name = 'John'"]
                                withTransaction:transaction];
}];
```

### Indexes

Create simple index:

```objective-c
@interface Car : YapModelObject
@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign) CGFloat price;
@property (nonatomic, assign) NSInteger year;

// text index
@indexText(Car, CarNameIndex, @"name");

// integer index
@indexInteger(Car, CarAgeIndex, @"year");

// real number index
@indexReal(Car, CarPriceIndex, @"price");

// index with multiple fields
@indexInteger(Car, CarAgeMemberIndex, @"year", @"price");

// index with multiple fields and type
@index(Car, CarAgePriceIndex, @"year": @(YapDatabaseSecondaryIndexTypeInteger), @"price": @(YapDatabaseSecondaryIndexTypeReal));

@end
```

### Views

Create simple view:

```objective-c
@interface Car : YapModelObject
@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign) CGFloat price;
@property (nonatomic, assign) NSInteger year;

// define a view by grouping and sorting using name
@view(Car, CarByName, @"group": @"name", @"sort": @"name");

// define a view by grouping and sorting using name (reverse sort)
@view(Car, CarByName, @"group": @"name", @"sort": @"-name");

// or you can use multiple sorting / grouping fields
@view(Car, CarByYear, @"group": @[@"year"], @"sort": @[@"year", @"name"]);

// sort by year in descending order, then by name
@view(Car, CarByYear, @"group": @[@"year"], @"sort": @[@"-year", @"name"]);

@end
```

### Relationship

Configure relationship:

```objective-c
@interface Driver : YapModelObject
@property (nonatomic, strong) NSString* name;

// Has many.
// Add a NSArray* property "cars", and setup yapDatabaseRelationshipEdges to return proper edges
@hasMany(Driver, carsKey, cars, YDB_DeleteDestinationIfSourceDeleted);

// Has one.
// add a NSString* property "companyKey", and setup yapDatabaseRelationshipEdges to return proper edges
@hasOne(Driver, licenseKey, license, YDB_DeleteDestinationIfSourceDeleted);

// Belongs to
// add a NSString* property "companyKey", and setup yapDatabaseRelationshipEdges to return proper edges
@belongsTo(Driver, companyKey, company, YDB_DeleteDestinationIfSourceDeleted);

// Has one file
// add a NSString* property "pictureFilePath", and setup yapDatabaseRelationshipEdges to return proper edges
@hasOneFile(Driver, pictureFilePath, picture, YDB_DeleteDestinationIfSourceDeleted);

@end
```

## NSCoding

YapModel include [AutoCoding](https://github.com/nicklockwood/AutoCoding) for automatic NSCoding. This should just work but you
should check [AutoCoding](https://github.com/nicklockwood/AutoCoding) to understand how it work, and override the NSCoding/NSCopying methods if needed.

## License

MIT License.
