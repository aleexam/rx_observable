# rx_observable

A lightweight, boilerplate-free reactive state management solution for Flutter.

Similar to LiveData, MobX, Cubit, RxDart, but without code generation or complex setup. Built on top of Flutter's `ChangeNotifier` and Dart's `StreamController`.

## Features

- 💪 Simple and intuitive API
- 🚫 No code generation required
- 🧩 Custom observer widgets and seamless integration with Flutter default widgets (StreamBuilder, ChangeNotifierBuilder, etc)
- 🔄 Sync (ChangeNotifier-based) and Async (StreamController-based) observables
- 🔌 Easy resource management with RxSubsMixin

## Installation

```yaml
dependencies:
  rx_observable: ^0.6.9
```

## Basic Usage

### Creating Observables

```dart
    // Multiple ways to create observables, all equivalent
    var text1 = "Hello".obs;               // Extension method
    var text2 = Observable("Hello");       // Constructor
    var text3 = ObservableString("Hello"); // Type-specific constructor
    var text4 = Obs("Hello");              // Short alias
    
    // Create read-only observables
    var readOnly = "Hello".obsReadOnly;    // Can't be modified from outside
    var readOnly2 = ObservableReadOnly("Hello");    // Or like this
    
    // Create async observables (StreamController-based)
    var asyncText = ObservableAsync("Hello");          // Constructor
    var asyncText2 = ObservableAsyncReadOnly("Hello"); // Can't be modified from outside
    var asyncText3 = "Hello".obsA;                     // Extension method
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
      builder: (context, value) {
        return Text(value);
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
    var firstName = Observable("Mister");
    var lastName = ObservableAsync("Twister")
    var age = ObservableReadOnly(25)
    
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
      
      // This will automatically dispose all registered resources
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

### Computed Observables

Create observables that depend on other observables:

```dart
    final firstName = "John".obs;
    final lastName = "Doe".obs;
    
    // Create a computed observable that updates when dependencies change
    final fullName = (() => "${firstName.value} ${lastName.value}")
        .compute([firstName, lastName]);
```

### Working with States Pattern

Similar to BLoC pattern states, but with less boilerplate. There are two approaches:

#### 1. Immutable States (Recommended)

Use immutable state objects and replace the entire state when something changes:

```dart
    // Define state types
    abstract class UiState {}
    class LoadingState extends UiState {}
    class LoadedState extends UiState {
      final List<Contact> contacts;
      LoadedState({required this.contacts});
    }
    class ErrorState extends UiState {
      final String message;
      ErrorState({required this.message});
    }
    
    // ViewModel with immutable state management
    class ContactsViewModel with RxSubsMixin implements IDisposable {
      // State observable
      final state = Observable<UiState>(LoadingState());
      
      ContactsViewModel() {
        regs([state]);
        loadContacts();
      }
      
      Future<void> loadContacts() async {
        try {
          state.value = LoadingState();
          // Load contacts from repository
          final contacts = await contactsRepository.getContacts();
          // Create a new immutable state with the loaded data
          state.value = LoadedState(contacts: contacts);
        } catch (e) {
          state.value = ErrorState(message: e.toString());
        }
      }
    }
```

#### 2. States with Embedded Observables (You can try)

You can also use observables inside state objects, but this requires careful handling, so use it at your own risk:

```dart
    
    // State with embedded observable
    class LoadedState extends UiState {
      final ObservableReadOnly<List<Contact>> contacts;
      
      LoadedState({required this.contacts});
    }
    
    // ViewModel with reactive state components
    class ContactsViewModel with RxSubsMixin implements IDisposable {
      // State observable
      final state = Observable<UiState>(LoadingState());
      
      // Private observable list - only modified inside ViewModel
      final _contacts = Observable<List<Contact>>([]);
      
      ContactsViewModel() {
        // Register all observables for auto-disposal
        regs([state, _contacts]);
        loadContacts();
      }
      
      Future<void> loadContacts() async {
        try {
          state.value = LoadingState();
          // Load contacts from repository
          final contacts = await contactsRepository.getContacts();
          _contacts.value = contacts;
          // Pass the observable to the state
          state.value = LoadedState(contacts: _contacts.map((list) => List.unmodifiable(list)));
        } catch (e) {
          state.value = ErrorState(message: e.toString());
        }
      }
    }
```

**⚠️ Warning**: When using observables inside states, be aware of potential concurrent access issues:
- Only update observable values from inside the ViewModel
- Consider using `List.unmodifiable()` for collections to prevent modification (assume that items in list immutable)
- Never modify state values or items of list from outside the ViewModel
- Always dispose observables properly (use RxSubsMixin)

Using the state in UI:

```dart
    Observer(viewModel.state, (state) {
      switch (state) {
        case LoadingState():
          return const CircularProgressIndicator();
        case LoadedState():
          return Observer(state.contacts, (contacts) {
            if (contacts.isEmpty) {
              return const Text('No contacts found');
            }
            return ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) => ContactTile(contacts[index]),
            );
          });
        case ErrorState():
          return Text('Error: ${state.message}');
      }
    });
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
Handling final late reactive variables can be challenging for example.

BLoC has too much boilerplate and involves too much effort to manage the entire state. 
It requires refreshing the whole state just to change a single value.

GetX (or Get), on the other hand, includes too many features inside, bugs, complicated core.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 