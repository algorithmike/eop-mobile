import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GQLClient extends StatelessWidget {
  final Widget child;
  const GQLClient({Key key, this.child}) : super(key: key);

  @override
  build(BuildContext context) {
    final HttpLink httpLink = HttpLink(
      'https://eop-backend-evtm3.ondigitalocean.app/backend/',
    );

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: httpLink,
        // The default store is the InMemoryStore, which does NOT persist to disk
        cache: GraphQLCache(),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: child,
    );
  }
}
