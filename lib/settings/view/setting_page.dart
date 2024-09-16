import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_bloc_app/weather/cubit/cubit/weather_cubit.dart';
import 'package:weather_bloc_app/weather/models/models.dart';

class SettingPage extends StatelessWidget {
  const SettingPage._();

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const SettingPage._(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: ListView(
        children: [
          BlocBuilder<WeatherCubit, WeatherState>(
            buildWhen: (previous, current) {
              return previous.temperatureUnits != current.temperatureUnits;
            },
            builder: (context, state) {
              return ListTile(
                title: const Text('Temperature Units'),
                isThreeLine: true,
                subtitle: const Text(
                  'Use metric measurements for temperature units.',
                ),
                trailing: Switch(
                  value: state.temperatureUnits.isCelsius,
                  onChanged: (_) => context.read<WeatherCubit>().toggleUnits(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
