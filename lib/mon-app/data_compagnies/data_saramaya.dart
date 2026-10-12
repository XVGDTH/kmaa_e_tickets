import 'package:kmaa_e_tickets/mon-app/transport/reseau_transport.dart';

final CompagnieReseau saramaya = CompagnieReseau(
  routesParVille: {
    'ouagadougou': [
      RouteOption(
        destination: 'Bobo-Dioulasso',
        gares: [
          const DepartGare(
            quartier: 'Gare de Gounghin',
            horaires: [
              '08h30',
              '09h30',
              '10h30',
              '12h30',
              '14h30',
              '18h30',
              '22h30',
              '23h45',
            ],
            prixTicket: 6500,
            dureeMax: '5h30',
            telephone: '60 81 86 86',
          ),
          const DepartGare(
            quartier: 'Gare Charles de Gaulle',
            horaires: [
              '08h30',
              '09h30',
              '10h30',
              '12h30',
              '14h30',
              '18h30',
              '22h30',
              '23h45',
            ],
            prixTicket: 6500,
            dureeMax: '5h30',
            telephone: '60 94 22 22',
          ),
          const DepartGare(
            quartier: 'Gare de Dassasgho',
            horaires: ['07h45', '08h45', '11h45', '13h45', '17h30', '21h45'],
            prixTicket: 6500,
            dureeMax: '5h30',
            telephone: '60 94 21 21',
          ),
        ],
      ),
      RouteOption(
        destination: 'Ouahigouya',
        gares: [
          const DepartGare(
            quartier: 'Escale Tampouy',
            horaires: ['06h00', '10h00', '14h00', '16h00'],
            prixTicket: 3500,
            dureeMax: '2h30',
            telephone: '03 93 25 25',
          ),
        ],
      ),
      RouteOption(
        destination: 'Yako',
        gares: [
          const DepartGare(
            quartier: 'Escale Tampouy',
            horaires: ['06h00', '10h00', '14h00', '16h00'],
            prixTicket: 2500,
            dureeMax: '1h30',
            telephone: '03 93 25 25',
          ),
        ],
      ),
      RouteOption(
        destination: 'Gourcy',
        gares: [
          const DepartGare(
            quartier: 'Escale Tampouy',
            horaires: ['06h00', '10h00', '14h00', '16h00'],
            prixTicket: 3000,
            dureeMax: '2h00',
            telephone: '03 93 25 25',
          ),
        ],
      ),
      RouteOption(
        destination: 'Koudougou',
        gares: [
          const DepartGare(
            quartier: 'Gare de Gounghin',
            horaires: ['06h00', '08h00', '12h00', '14h00', '18h00'],
            prixTicket: 2500,
            dureeMax: '2h00',
            telephone: '50 97 74 74',
          ),
        ],
      ),
    ],
    'bobo-dioulasso': [
      RouteOption(
        destination: 'Ouagadougou',
        gares: [
          const DepartGare(
            quartier: 'Gare de Tounouma',
            horaires: [
              '07h30',
              '09h00',
              '10h30',
              '12h30',
              '14h30',
              '18h30',
              '22h30',
              '23h45',
            ],
            prixTicket: 6500,
            dureeMax: '5h30',
            telephone: '60 81 89 89',
            adresse: 'Bd Félix Houphouët-Boigny, Tounouma',
          ),
        ],
      ),
    ],
  },
);
