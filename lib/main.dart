import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

part 'main.freezed.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flow Demo',
      home: HomePage(),
    ),
  );
}

// MAIN PAGE

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userInfo = useState<UserInfo?>(null);
    return Scaffold(
      backgroundColor:
      userInfo.value == null ? Colors.white : userInfo.value!.favoriteColor,
      appBar: AppBar(title: const Text('Flow')),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: userInfo.value == null
            ? ElevatedButton(
          onPressed: () async {
            userInfo.value =
            await Navigator.of(context).push(OnboardingFlow.route());
          },
          child: const Text('GET STARTED'),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${userInfo.value!.name}!',
              style: const TextStyle(fontSize: 48.0),
            ),
            const SizedBox(height: 48.0),
            Text(
              'So, you are ${userInfo.value!.age} years old and this is your favorite color? Great!',
              style: const TextStyle(fontSize: 32.0),
            ),
          ],
        ),
      ),
    );
  }
}

// FLOW

class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({super.key});

  static Route<UserInfo> route() {
    return MaterialPageRoute(builder: (_) => const OnboardingFlow());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlowBuilder<UserInfo>(
        state: const UserInfo(),
        onGeneratePages: (profile, pages) {
          return [
            const MaterialPage(child: NameForm()),
            if (profile.name != null) const MaterialPage(child: AgeForm()),
            if (profile.age != null) const MaterialPage(child: ColorForm()),
          ];
        },
      ),
    );
  }
}

// FORMS

class NameForm extends HookWidget {
  const NameForm({super.key});

  @override
  Widget build(BuildContext context) {
    final name = useState<String?>(null);
    return Scaffold(
      appBar: AppBar(title: const Text('Name')),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              autofocus: true,
              onChanged: (value) => name.value = value,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              child: const Text('Continue'),
              onPressed: () {
                if (name.value != null && name.value!.isNotEmpty) {
                  context
                      .flow<UserInfo>()
                      .update((info) => info.copyWith(name: name.value));
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class AgeForm extends HookWidget {
  const AgeForm({super.key});

  @override
  Widget build(BuildContext context) {
    final age = useState<int?>(null);
    return Scaffold(
      appBar: AppBar(title: const Text('Age')),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButtonFormField<int>(
              items: List.generate(
                200,
                    (index) => DropdownMenuItem(
                  value: index,
                  child: Text(index.toString()),
                ),
              ),
              onChanged: (value) => age.value = value,
              decoration: const InputDecoration(
                labelText: 'Age',
                hintText: 'How old are you?',
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              child: const Text('Continue'),
              onPressed: () {
                if (age.value != null) {
                  context
                      .flow<UserInfo>()
                      .update((info) => info.copyWith(age: age.value));
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class ColorForm extends HookWidget {
  const ColorForm({super.key});

  @override
  Widget build(BuildContext context) {
    final color = useState<Color>(Colors.amber);
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Color')),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ColorPicker(
              pickerColor: color.value,
              onColorChanged: (value) => color.value = value,
              pickerAreaHeightPercent: 0.8,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              child: const Text('Continue'),
              onPressed: () {
                context.flow<UserInfo>().complete(
                        (info) => info.copyWith(favoriteColor: color.value));
              },
            )
          ],
        ),
      ),
    );
  }
}

// DOMAIN

@freezed
abstract class UserInfo with _$UserInfo {
  const factory UserInfo({
    String? name,
    int? age,
    Color? favoriteColor,
  }) = _UserInfo;
}