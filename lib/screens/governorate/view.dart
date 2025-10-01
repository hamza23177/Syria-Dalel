import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/governorate_service.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';

class GovernorateView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GovernorateBloc(GovernorateService())..add(LoadGovernorates()),
      child: BlocBuilder<GovernorateBloc, GovernorateState>(
        builder: (context, state) {
          if (state is GovernorateLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is GovernorateLoaded) {
            return ListView.builder(
              itemCount: state.governorates.length,
              itemBuilder: (context, index) {
                final gov = state.governorates[index];
                return ListTile(
                  title: Text(gov.name),
                );
              },
            );
          } else if (state is GovernorateError) {
            return Center(child: Text(state.message));
          }
          return Container();
        },
      ),
    );
  }
}
