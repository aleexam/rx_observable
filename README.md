Simple reactive variables and widgets.
Similar to Livedata/observable/mobx, but without code generation and without complicated boilerplate.
Based on ChangeNotifier and StreamController (ObservableSync and ObservableAsync)

Ideal to use with MVVM like patterns.

## Features

Create reactive variables, listen them, update UI.

## Usage

Just define var like this:

```dart
  var text = "Hello".obs;
```

And use Observer widget to subscribe for changes:

```dart
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          /// Use Observer widget directly to update UI with values
          Observer(text, (v) => Text(v)),
          /// Use extensions which creates same observer widget
          text.observer((v) => Text(v)),
          /// Use big builder version
          Observer.builder(
              observable: text,
              builder: (context, v) {
                return Text(v);
              }
          )
        ],
      ),
    );
```

Update value like this:

```dart
  text.value = "GoodBye";
```

Listen like ChangeNotifier, or like this:

```dart
    text.listen((v) {
        print("New value is $v");
    });
```

Dispose like this:

```dart
  text.dispose();
```

You can also use ObservableAsync, this implementation shares same interface, but based
on StreamController, and also implements StreamController.

```dart
  var test1 = ObservableAsync(25);
  var test2 = 25.obsA;

  /// ObservableAsync should be disposed mandatory (its StreamController based).
  test1.dispose();
  test2.dispose();
```

## Additional information

More examples:

```dart

    // Listen for 2 or 3 observables in Observer
    Observer3(
        observable: text,
        observable2: text2,
        observable3: text3,
        builder: (context, v1, v2, v3) {
          return Text("$v1 $v2 $v3");
        }
    ),

    // All constructors gives the same result
    var test1 = Observable(25);
    var test2 = Observable<int>(25);
    var test3 = Obs(25);
    var test4 = 25.obs;
    var test5 = ObservableInt(25);
    var test6 = ObservableReadOnly(25); /// You can only read this value
    
    test1.listen((v) {
      if (kDebugMode) { print(v); }
    });
    
    /// Listen observable without UI updating
    /// Also see ObservableConsumer widget to get both
    var widgetListener = ObservableListener(
      observable: test1,
        listener: (v, context) {
          if (kDebugMode) { print(v); }
        },
        child: const SizedBox(),
    );
```
Also check RxSubsMixin, for easy dispose of your reactive variables, subscriptions, streams within your viewModel/bloc/store/repository/etc.

## Use with state concept

You can use this approach with states concept, just use Observable as state var and pass immutable states inside it. 
```dart
/// Create some viewModel/Bloc-like class, with easy dispose mixin and disposable interface
class ViewModelExample with RxSubsMixin implements IDisposable {

  /// Define state reactive var, to listen state. Just as Bloc pattern do.
  Observable<T> state = LoadingState();

  /// Simple example var. You can mix state concept with simple vars or not, it's you to decide
  var title = "Hello".obs;
  
  ViewModelExample() {
    /// Auto-dispose of these vars
    regs([state, title, _contactsList]);
  }
  
  void loadContacts() {
    var contactsImmutable = ...
    /// ...do some magic to get your async data from anywhere
    /// Then pass it's value to state as pointer, since it's not simple type.
    state.value = LoadedState(contacts: contactsImmutable);
  }
}
```

You actually can use reactive vars inside state, at your own risk.

To minimize cons, just follow this simple rule: never change the values of state from outside the ViewModel, 
and always close your reactive variables (use RxSubsMixin to help with that). This way you’ll avoid any problems:

```dart
/// Create some viewModel/Bloc-like class, with easy dispose mixin and disposable interface
class ViewModelExample with RxSubsMixin implements IDisposable {

  /// Define state reactive var, to listen state. Just as Bloc pattern do.
  Observable<T> state = LoadingState();

  /// Simple example var. You can mix state concept with simple vars or not, it's you to decide
  var title = "Hello".obs;
  
  /// Here is magic. Define private var for some list for example here. It will used in state.
  final _contactsList = Observable<List<Contact>>([]);
  
  ViewModelExample() {
    /// Auto-dispose of these vars
    regs([state, title, _contactsList]);
  }_contactsList
  
  void loadContacts() {
    /// ...do some magic to get your async data from anywhere
    /// Then pass it's value to state as pointer, since it's not simple type.
    /// You can map _contactsList to List.unmodifiable here to be safe from concurrent modification
    /// Like this: state.value = LoadedState(contacts: _contactsList.map((e) => List.unmodifiable(e));
    state.value = LoadedState(contacts: _contactsList);
  }
}

/// The state it self. Whola! You have state with reactive var inside it.
/// because real value is inside ViewModelExample, and in state you have only link to it.
/// Some problems might occur because of concurrent access to list, just make sure you change your data only inside ViewModel.
class LoadedState extends BaseState {
  final ObservableReadOnly<List<Contact>> contacts;

  LoadedState({required this.contacts});
}

```

Basic UI example of using with these states:

```dart
var vm = context.read<ViewModelExample>();
Observer(vm.state, (vmState) {
        switch (vmState) {
          case LoadingState():
            return const LoadingWidget();
          case LoadedState():
            return Observer(vmState.contacts, (vmContacts) {
              if (vmContacts.isEmpty) {
                return EmptyWidget();
              } else {
                return ListWidget(vmContacts);
            });
          case ErrorState():
            return ErrorWidget();
        }
      })

```

## Experimental features
Just wrap widget in Observe widget, and it automatically will listen all observables you used

```dart

    var title = "hello".obs;

    ...
  
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          /// Use Observe widget without need to pass any value
          Observe(() => Text(title.value)),
        ],
      ),
    );
```

Important! Make sure to not update observables in widget build code, it will lead to endless loop.
Also notice, that for nested context (like builder, etc) fields will not be tracked.
You can manually track fields using field.observe() inside Observe() widget.

## Why is this better than mobX, BLoc, getX?

MobX's weakness lies in code generation. It can cause issues during development due to the complexity of store realisation in some cases. 
Handling final late reactive variables can be challenging for example.

BLoC has too much boilerplate and involves too much effort to manage the entire state. 
It requires refreshing the whole state just to change a single value.

GetX (or Get), on the other hand, includes too many features inside, bugs, complicated core.
