import 'package:kmaa_e_tickets/mon-app/transport/reseau_transport.dart';

final CompagnieReseau rakieta = CompagnieReseau(
  routesParVille: {
    'ouagadougou': [
      RouteOption(
        destination: 'Bobo-Dioulasso',
        gares: [
          const DepartGare(
            quartier: 'Escale Pissy',
            horaires: [
              '05h30',
              '07h30',
              '08h30',
              '09h30',
              '10h30',
              '13h30',
              '14h30',
              '17h00',
              '18h00',
              '19h00',
            ],
            prixTicket: 7500,
            dureeMax: '5h30',
            telephone: '73 42 00 28',
            adresse:
                'Sur le goudron du terrain omnisports de Pissy, vers la Sonabhy, juste après le CMA de Pissy, à droite',
          ),
          const DepartGare(
            quartier: 'Escale ZAD',
            horaires: [
              '05h30',
              '07h30',
              '08h30',
              '09h30',
              '10h30',
              '13h30',
              '14h30',
              '17h00',
              '18h00',
              '19h00',
            ],
            prixTicket: 7500,
            dureeMax: '5h30',
            telephone: '73 42 00 71',
            adresse:
                "Après la pédiatrie vers Ouaga 2000, au feu après la Maison Artisanale, à droite puis à gauche",
          ),
          const DepartGare(
            quartier: 'Escale Saaba',
            horaires: [
              '05h30',
              '07h30',
              '08h30',
              '09h30',
              '10h30',
              '13h30',
              '14h30',
              '17h00',
              '18h00',
              '19h00',
            ],
            prixTicket: 7500,
            dureeMax: '5h30',
            telephone: '70 32 81 22',
            adresse:
                'Du jardin triangle vers la station OTAME, 200 m après la station Shell, à droite',
          ),
        ],
      ),
      RouteOption(
        destination: 'Banfora',
        gares: [
          const DepartGare(
            quartier: 'Escale Pissy',
            horaires: ['12h30', '18h00', '20h00'],
            prixTicket: 9000,
            dureeMax: '4h00',
            telephone: '73 42 00 28',
          ),
          const DepartGare(
            quartier: 'Escale ZAD',
            horaires: ['12h30', '18h00', '20h00'],
            prixTicket: 9000,
            dureeMax: '4h00',
            telephone: '73 42 00 71',
          ),
          const DepartGare(
            quartier: 'Escale Saaba',
            horaires: ['12h30', '18h00', '20h00'],
            prixTicket: 9000,
            dureeMax: '4h00',
            telephone: '70 32 81 22',
          ),
        ],
      ),
      RouteOption(
        destination: 'Niangoloko',
        gares: [
          const DepartGare(
            quartier: 'Escale Pissy',
            horaires: ['06h30', '07h30', '08h30', '09h30', '10h30', '20h00'],
            prixTicket: 9500,
            dureeMax: '4h30',
            telephone: '73 42 00 28',
          ),
          const DepartGare(
            quartier: 'Escale ZAD',
            horaires: ['06h30', '07h30', '08h30', '09h30', '10h30', '20h00'],
            prixTicket: 9500,
            dureeMax: '4h30',
            telephone: '73 42 00 71',
          ),
          const DepartGare(
            quartier: 'Escale Saaba',
            horaires: ['06h30', '07h30', '08h30', '09h30', '10h30', '20h00'],
            prixTicket: 9500,
            dureeMax: '4h30',
            telephone: '70 32 81 22',
          ),
        ],
      ),
      RouteOption(
        destination: 'Pô',
        gares: [
          const DepartGare(
            quartier: 'Oscar Yaar - Pô',
            horaires: ['07h00', '10h00', '12h30', '16h30'],
            prixTicket: 2500,
            dureeMax: '2h00',
            telephone: '62 11 61 18',
          ),
          const DepartGare(
            quartier: "Patte d'Oie - Pô",
            horaires: ['07h15', '10h15', '12h45', '16h45'],
            prixTicket: 2500,
            dureeMax: '2h00',
            telephone: '73 42 00 27',
          ),
        ],
      ),
    ],
    'bobo-dioulasso': [
      RouteOption(
        destination: 'Ouagadougou',
        gares: [
          const DepartGare(
            quartier: 'Gare centrale Bobo-Dioulasso',
            horaires: ['07h00', '10h00', '14h00', '18h30', '22h30'],
            prixTicket: 7500,
            dureeMax: '5h30',
            telephone: '77 05 64 64',
          ),
        ],
      ),
      RouteOption(
        destination: 'Banfora',
        gares: [
          const DepartGare(
            quartier: 'Gare centrale Bobo-Dioulasso',
            horaires: [
              '06h00',
              '07h00',
              '08h30',
              '10h15',
              '12h00',
              '13h30',
              '14h00',
              '16h00',
              '16h30',
              '18h00',
              '19h30',
              '21h00',
            ],
            prixTicket: 2500,
            dureeMax: '1h30',
            telephone: '77 05 64 64',
          ),
        ],
      ),
      RouteOption(
        destination: 'Ouahigouya',
        gares: [
          const DepartGare(
            quartier: 'Gare centrale Bobo-Dioulasso',
            horaires: ['14h30'],
            prixTicket: 11000,
            dureeMax: '6h00',
            telephone: '77 05 64 64',
          ),
        ],
      ),
      RouteOption(
        destination: 'Houndé',
        gares: [
          const DepartGare(
            quartier: 'Gare centrale Bobo-Dioulasso',
            horaires: ['14h30'],
            prixTicket: 2500,
            dureeMax: '1h30',
            telephone: '77 05 64 64',
          ),
        ],
      ),
      RouteOption(
        destination: 'Pa',
        gares: [
          const DepartGare(
            quartier: 'Gare centrale Bobo-Dioulasso',
            horaires: ['14h30'],
            prixTicket: 3000,
            dureeMax: '2h00',
            telephone: '77 05 64 64',
          ),
        ],
      ),
      RouteOption(
        destination: 'Dano',
        gares: [
          const DepartGare(
            quartier: 'Gare centrale Bobo-Dioulasso',
            horaires: ['14h30'],
            prixTicket: 3000,
            dureeMax: '2h30',
            telephone: '77 05 64 64',
          ),
        ],
      ),
      RouteOption(
        destination: 'Ouessa',
        gares: [
          const DepartGare(
            quartier: 'Gare centrale Bobo-Dioulasso',
            horaires: ['14h30'],
            prixTicket: 4500,
            dureeMax: '3h00',
            telephone: '77 05 64 64',
          ),
        ],
      ),
      RouteOption(
        destination: 'Hamélé',
        gares: [
          const DepartGare(
            quartier: 'Gare centrale Bobo-Dioulasso',
            horaires: ['14h30'],
            prixTicket: 4500,
            dureeMax: '3h00',
            telephone: '77 05 64 64',
          ),
        ],
      ),
    ],
    'banfora': [
      RouteOption(
        destination: 'Ouagadougou',
        gares: [
          const DepartGare(
            quartier: 'Gare centrale Banfora',
            horaires: ['06h00', '08h15', '12h00', '16h00', '21h00'],
            prixTicket: 9000,
            dureeMax: '4h00',
            telephone: '77 05 64 63',
          ),
        ],
      ),
      RouteOption(
        destination: 'Bobo-Dioulasso',
        gares: [
          const DepartGare(
            quartier: 'Gare centrale Banfora',
            horaires: [
              '06h00',
              '07h00',
              '08h30',
              '10h15',
              '12h00',
              '13h30',
              '14h00',
              '16h00',
              '16h30',
              '18h00',
              '19h30',
              '21h00',
            ],
            prixTicket: 2500,
            dureeMax: '1h30',
            telephone: '77 05 64 63',
          ),
        ],
      ),
    ],
  },
  tarifsInternational: {
    'abidjan': 32500,
    'yamoussoukro': 28500,
    'bouake': 26500,
    'sikasso': 13500,
    'bamako': 20500,
  },
);
