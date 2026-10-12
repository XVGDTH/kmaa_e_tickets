import 'package:kmaa_e_tickets/mon-app/transport/reseau_transport.dart';

final CompagnieReseau elitis = CompagnieReseau(
  routesParVille: {
    'ouagadougou': [
      RouteOption(
        destination: 'Bobo-Dioulasso',
        gares: [
          const DepartGare(
            quartier: 'Gare Elitis Express (Sanyiri)',
            horaires: ['08h30', '10h30', '14h30', '18h30'],
            prixTicket: 10000,
            dureeMax: '5h00',
            telephone: '70 21 05 21',
          ),
          const DepartGare(
            quartier: 'Escale Elitis Express (Pissy)',
            horaires: ['08h30', '10h30', '14h30', '18h30'],
            prixTicket: 10000,
            dureeMax: '4h45',
            telephone: '70 21 05 21',
          ),
        ],
      ),
    ],
    'bobo-dioulasso': [
      RouteOption(
        destination: 'Ouagadougou',
        gares: [
          const DepartGare(
            quartier: 'Gare Elitis Express (Zone Résidentielle B)',
            horaires: ['08h30', '10h30', '14h30', '18h30'],
            prixTicket: 10000,
            dureeMax: '5h00',
            telephone: '25 40 33 40',
          ),
        ],
      ),
    ],
  },
);
