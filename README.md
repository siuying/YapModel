# YapModel

YapModel is an lightweight ActiveRecord implementation on top of YapDatabase. The syntax is borrowed from Ruby on Rails and inspired by [ObjectiveRecord](https://github.com/mneorr/ObjectiveRecord).

## Synopsis

### Create / Save / Delete

```
Person* john = [Person create];
john.name = @"John";
[john save]
[john delete];

[Person create:@{
  @"name": @"John",
  @"age": @12,
  @"member": @NO
}];
```

## Finders

```
// Find all objects
NSArray* people = [Person all];

// Get an object by key
Person* john = [Person find:@"uuid"];

// Iterate with all objects and find the object matching the filter
NSArray* people = [Person where:^BOOL(Person* person) {
    return person.age < 30;
}];

// Find using secondary Index
Person *johnDoe = [Person findWithIndex:@"idx" 
                                  query:@"WHERE name == ? AND surname == ?", @"John", @"Doe"];

```

### Transaction

```
Person* john = [Person transaction:^{
  Person* john = [Person create:@{@"name": @"Leo"}];
  john.name = @"John";
  [john save];
}];
```

### Aggregation

```
// count all Person entities
NSUInteger personCount = [Person count];

// count people named John
NSUInteger johnCount = [Person countWithIndex:@"index" query:@"WHERE name = 'John'"];
```

## License 

MIT License.