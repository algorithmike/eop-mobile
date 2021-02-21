import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:eop_mobile/utils/secureStorage.dart';

class GQLClient extends StatelessWidget {
  final Widget child;
  const GQLClient({Key key, this.child}) : super(key: key);

  @override
  build(BuildContext context) {
    final secureStorage = SecureStorage();
    final HttpLink _httpLink = HttpLink(
      'https://eop-backend-evtm3.ondigitalocean.app/backend/',
    );

    final _authLink = AuthLink(
      getToken: () async {
        String token = await secureStorage.getAuthToken();
        if (token != null) {
          return 'Bearer $token';
        }

        return '';
      },
    );

    Link _link = _authLink.concat(_httpLink);

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: _link,
        cache: GraphQLCache(),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: child,
    );
  }
}
