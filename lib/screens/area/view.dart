// area_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/area_service.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';

class AreaView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AreaBloc(AreaService())..add(LoadAreas()),
      child: BlocBuilder<AreaBloc, AreaState>(
        builder: (context, state) {
          if (state is AreaLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is AreaLoaded) {
            return ListView.builder(
              itemCount: state.areas.length,
              itemBuilder: (context, index) {
                final area = state.areas[index];
                return ListTile(
                  title: Text(area.name),
                  subtitle: Text('Governorate: ${area.governorate.name}'),
                );
              },
            );
          } else if (state is AreaError) {
            return Center(child: Text(state.message));
          }
          return Container();
        },
      ),
    );
  }
}
