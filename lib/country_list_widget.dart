import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'country_widget.dart';

final storage = new FlutterSecureStorage();

class CountryListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(document: gql('''
           query {
            countries {
              id
              name
              capital
              votes {
                id
              }
              postedBy {
                username
              }
            }
          }
        '''),
      ),
      builder: (
        QueryResult result, {
        Future<QueryResult<Object?>> Function(FetchMoreOptions)? fetchMore,
        Future<QueryResult<Object?>?> Function()? refetch,
      }) {
        if (result.hasException) {
          return Text('Error al cargar los países');
        }

        if (result.isLoading) {
          return CircularProgressIndicator();
        }

        final countries = result.data!['countries'] as List<dynamic>;

        return ListView.builder(
          itemCount: countries.length,
          itemBuilder: (context, index) {
            final country = countries[index] as Map<String, dynamic>;

            return CountryWidget(
              id: int.parse(country['id']), // Convertir id a entero
              name: country['name'],
              capital: country['capital'],
              postedBy: country['postedBy'] != null ? country['postedBy']['username'] : 'Unknown',
              votes: country['votes'].length,              
            );
          },
        );
      },
    );
  }
}
