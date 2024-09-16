import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_bloc_app/weather/cubit/cubit/weather_cubit.dart';
import 'package:weather_bloc_app/settings/view/setting_page.dart';
import 'package:weather_bloc_app/weather/widgets/success_weather.dart';

import '../../search/view/search_page.dart';
import '../widgets/empty_weather.dart';
import '../widgets/failure_weather.dart';
import '../widgets/loading_weather.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).push<void>(SettingPage.route()),
            icon: const Icon(Icons.settings_sharp),
          ),
        ],
      ),
      body: Center(
        child: BlocBuilder<WeatherCubit, WeatherState>(
          builder: (context, state) {
            return switch (state.status) {
              WeatherStatus.initial => const EmptyWeather(),
              WeatherStatus.loading => const LoadingWeather(),
              WeatherStatus.failure => const FailureWeather(),
              WeatherStatus.success => SuccessWeather(
                  weather: state.weather,
                  units: state.temperatureUnits,
                  onUpdate: () => context.read<WeatherCubit>().refreshWeather(),
                ),
            };
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final city = await Navigator.of(context).push(SearchPage.route());
          if (!context.mounted) return;
          await context.read<WeatherCubit>().fetchWeather(city);
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
