import 'package:kmaa_e_tickets/mon-app/transport/reseau_transport.dart';

final CompagnieReseau ctrof = CompagnieReseau(
  routesParVille: {
    'bobo-dioulasso': [
      RouteOption(
        destination: 'Ouagadougou',
        gares: [
          const DepartGare(
            quartier: 'Gare CTROF Bobo-Dioulasso 1',
            horaires: [
              '06h45',
              '09h15',
              '12h15',
              '16h15',
              '18h15',
              '22h30',
              '23h00',
            ],
            prixTicket: 7000,
            dureeMax: '5h30',
            telephone: 'Guichet 51 02 60 60',
          ),
          const DepartGare(
            quartier: 'Gare CTROF Bobo-Dioulasso 2',
            horaires: [
              '06h45',
              '09h15',
              '12h15',
              '16h15',
              '18h15',
              '22h30',
              '23h00',
            ],
            prixTicket: 7000,
            dureeMax: '5h30',
            telephone: 'Guichet 51 50 12 12',
          ),
        ],
      ),
    ],
  },
);
