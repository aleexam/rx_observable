# rx_observable

A lightweight, boilerplate-free reactive variables for Flutter.
Can be used as standalone state management solution, 
or can be integrated in any other existing state management lib.

Similar to LiveData, MobX, Cubit, RxDart, but without code generation or complex setup. 
Built on top of Flutter's `ChangeNotifier` and Dart's `StreamController`.

## Features

- 💪 Simple and intuitive API
- 🚫 No code generation required
- 🧩 Custom observer widgets and seamless integration with Flutter default widgets (StreamBuilder, ChangeNotifierBuilder, etc)
- 🔄 Sync (ChangeNotifier-based) and Async (StreamController-based) observables
- 🔌 Easy resource management with RxSubsMixin

## Installation

```yaml
dependencies:
  rx_observable: ^0.7.2
```

## Basic Usage

### Creating Observables

```dart
    var text = "Hello".obs;    // Extension method
    var text2 = Obs("Hello");  // Constructor
```

### Listening to Changes

```dart
    // Just subscribe in Stream-like style, even for ChangeNotifier version
    text.listen((value) {
      print("New value is $value");
    });
    
    // Update value
    text.value = "Goodbye";
    // or shorthand
    text.v = "Goodbye";
    
    
    // Don't forget to dispose (use RxSubsMixin to simplify it)
    text.dispose();
```

### Using with Widgets

```dart
    // Simple observer with value-only builder
    Observer(text, (value) => Text(value))
    
    // Extension method for same result
    text.observer((value) => Text(value))
    
    // Full builder with BuildContext
    Observer.builder(
      observable: text,
      builder: (context, textValue) {
        return Text(textValue);
      }
    )
    
    // Observe multiple values
    Observer2(
      observable: firstName,
      observable2: lastName,
      builder: (context, first, last) {
        return Text("$first $last");
      }
    )
    
    /// Since all observable types shares the same interface,
    /// you can use them all in same widgets
    var firstName = Observable("Mister"); // Or Obs("Mister");
    var lastName = ObservableAsync("Twister") // Or ObsA("Twister");
    var age = ObservableReadOnly(25) // Or ObsRead(25);
    
    // Three values
    Observer3(
      observable: firstName,
      observable2: lastName,
      observable3: age,
      builder: (context, first, last, age) {
        return Text("$first $last, $age years old");
      }
    )
    
    // Observe without updating UI (listener only)
    ObservableListener(
      observable: text,
      listener: (value, context) {
        print("Value changed: $value");
      },
      child: const SizedBox(),
    )
    
    // Both observe and listen
    ObservableConsumer(
      observable: text,
      listener: (value, context) {
        print("Value changed: $value");
      },
      builder: (context, value) {
        return Text(value);
      }
    )
```

### Other constructors
```dart
    // Multiple ways to create observables, all equivalent
    var text = "Hello".obs;                // Extension method
    var text2 = Observable("Hello");       // Constructor
    var text3 = ObservableString("Hello"); // Type-specific constructor
    var text4 = Obs("Hello");              // Short alias
    
    // Create read-only observables
    var readOnly = "Hello".obsReadOnly;             // Can't be modified from outside
    var readOnly2 = ObservableReadOnly("Hello");    // Or like this
    
    // Create async observables (StreamController-based)
    var asyncText = ObservableAsync("Hello");          // Constructor
    var asyncText2 = ObservableAsyncReadOnly("Hello"); // Can't be modified from outside
    var asyncText3 = "Hello".obsA;                     // Extension method


    /// Works with nullable types of course
    var nText = Observable<String?>(null);
    var nText2 = ObsNString(null);
```

### Resource Management

Use `RxSubsMixin` to easily manage your observables, subscriptions, and other disposable resources:

```dart
    class MyViewModel with RxSubsMixin implements IDisposable {
      final text = "Hello".obs;
      final count = 0.obs;
      
      MyViewModel() {
        // Register multiple observables for auto-disposal
        regs([text, count]);
        
        // Listen to changes
        final subscription = text.listen((value) {
          print("Text changed: $value");
        });
        
        // Register subscription for auto-cancellation
        regSub(subscription);
      }
      
      // super.dispose will automatically dispose all registered resources
      // No need to override it in real code, showed here only for clarification
      @override
      void dispose() {
        super.dispose();
      }
    }
```

For StatefulWidgets, use `RxSubsStateMixin`:

```dart
    class MyWidget extends StatefulWidget {
      @override
      State<MyWidget> createState() => _MyWidgetState();
    }
    
    class _MyWidgetState extends State<MyWidget> with RxSubsStateMixin {
      final text = "Hello".obs;
      
      @override
      void initState() {
        super.initState();
        regs([text]);
      }
      
      // dispose() is automatically overridden to clean up resources
    }
```

You can wrap unsupported for auto-disposal by default classes in DisposableAdapter 
and still dispose them automatically:

```dart
    var client = HttpClient();
    reg(DisposableAdapter(() => client.close()));
```

### Computed and Group Observables

Create observables that depend on other observables:

```dart
    final firstName = "John".obs;
    final age = 25.obs;
    
    // Create a computed observable that updates when dependencies change
    var userInfo = 
      [firstName, age].compute(() => "${firstName.value}, ${age.value}");

    /// Listen to computed value
    userInfo.listen((info) {
      print(info); /// Prints "John, 25"
    }, preFire: true);


    /// Create a group of observables. Difference from computed, is that no value stored
    /// And you don't need to specify compute function
    var group = [firstName, age].group();
    group.listener(() {
        /// Do something
    });


    /// Don't forget to properly dispose
    userInfo.dispose();
    group.dispose(); 
```

## Experimental Features

### Implicit Observation

The `Observe` widget automatically tracks all observables used within its builder function:

```dart
    final name = "John".obs;
    final age = 30.obs;
    
    // Both name and age will be observed without explicitly passing them
    Observe(() => Text("${name.value} is ${age.value} years old"))
```

This approach not well tested and have some limitations, described in code, so again, use at your own risk.


## Why is this better than mobX, BLoc, getX?

MobX's weakness lies in code generation. It can cause issues during development due to the complexity of store realisation in some cases.

BLoC has too much boilerplate and involves too much effort to manage the entire state. 
It requires refreshing the whole state just to change a single value.

GetX (or Get), on the other hand, includes too many features inside, bugs, complicated core.

Anyway, this lib can be used in any other state management lib, adding convenient reactive fields and widgets to use with it.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 