import 'package:kmaa_e_tickets/mon-app/transport/reseau_transport.dart';

final CompagnieReseau tsr = CompagnieReseau(
  routesParVille: {
    'ouagadougou': [
      RouteOption(
        destination: 'Bobo-Dioulasso',
        gares: [
          const DepartGare(
            quartier: 'Gare de Wemtenga',
            horaires: [
              '06h00',
              '07h20',
              '08h20',
              '09h20',
              '10h20',
              '12h20',
              '13h20',
              '14h20',
              '16h00',
              '17h20',
              '19h20',
              '22h00',
            ],
            prixTicket: 7000,
            dureeMax: '5h30',
            telephone: '72 04 86 45',
          ),
        ],
      ),
      RouteOption(
        destination: 'Gaoua',
        gares: [
          const DepartGare(
            quartier: 'Gare de Wemtenga',
            horaires: [
              '07h00',
              '08h00',
              '09h00',
              '10h20',
              '13h20',
              '15h00',
              '17h00',
            ],
            prixTicket: 8000,
            dureeMax: '5h00',
            telephone: '72 04 86 45',
          ),
        ],
      ),
      RouteOption(
        destination: 'Manga',
        gares: [
          const DepartGare(
            quartier: "Gare de Paglayiri (Patte d'Oie)",
            horaires: ['06h00', '10h00', '13h00', '17h30'],
            prixTicket: 1500,
            dureeMax: '1h30',
            telephone: '72 90 97 31',
          ),
        ],
      ),
      RouteOption(
        destination: 'Zabré',
        gares: [
          const DepartGare(
            quartier: "Gare de Paglayiri (Patte d'Oie)",
            horaires: ['07h00', '11h00', '16h00', '18h00'],
            prixTicket: 2000,
            dureeMax: '2h00',
            telephone: '72 90 97 31',
          ),
        ],
      ),
      RouteOption(
        destination: 'Léo',
        gares: [
          const DepartGare(
            quartier: "Gare de Paglayiri (Patte d'Oie)",
            horaires: ['07h20', '09h20', '11h20', '12h50', '14h20', '16h20'],
            prixTicket: 3000,
            dureeMax: '2h30',
            telephone: '72 90 97 31',
          ),
        ],
      ),
      RouteOption(
        destination: 'Diapaga',
        gares: [
          const DepartGare(
            quartier: "Gare de l'Est",
            horaires: ['06h00', '08h00'],
            prixTicket: 5000,
            dureeMax: '4h30',
            telephone: '70 25 31 38',
          ),
        ],
      ),
      RouteOption(
        destination: 'Kongoussi',
        gares: [
          const DepartGare(
            quartier: 'Gare de Wemtenga',
            horaires: ['06h30', '08h00', '11h00', '13h00', '15h00', '17h00'],
            prixTicket: 3000,
            dureeMax: '2h00',
            telephone: '70 25 31 38',
          ),
        ],
      ),
      RouteOption(
        destination: 'Dori',
        gares: [
          const DepartGare(
            quartier: 'Gare de Wemtenga',
            horaires: ['05h30', '06h00', '08h00', '12h00', '14h00'],
            prixTicket: 6000,
            dureeMax: '3h30',
            telephone: '70 25 31 38',
          ),
        ],
      ),
      RouteOption(
        destination: 'Dédougou',
        gares: [
          const DepartGare(
            quartier: 'Gare de Wemtenga',
            horaires: ['07h00', '14h30'],
            prixTicket: 5000,
            dureeMax: '3h00',
            telephone: '70 25 31 38',
          ),
        ],
      ),
      RouteOption(
        destination: 'Koudougou',
        gares: [
          const DepartGare(
            quartier: 'Gare de Wemtenga',
            horaires: [
              '06h00',
              '08h30',
              '09h30',
              '11h30',
              '13h30',
              '15h30',
              '17h30',
            ],
            prixTicket: 2500,
            dureeMax: '2h00',
            telephone: '70 25 31 38',
          ),
        ],
      ),
    ],
    'bobo-dioulasso': [
      RouteOption(
        destination: 'Banfora',
        gares: [
          const DepartGare(
            quartier: 'Gare de Bobo',
            horaires: ['07h30', '08h00', '10h30', '15h30', '16h00', '18h00'],
            prixTicket: 2500,
            dureeMax: '1h30',
            telephone: '70 70 52 32',
          ),
        ],
      ),
    ],
    "fada n'gourma": [
      RouteOption(
        destination: 'Bobo-Dioulasso',
        gares: [
          const DepartGare(
            quartier: "Gare de Fada N'Gourma",
            horaires: ['06h00'],
            prixTicket: 11000,
            dureeMax: '8h00',
            telephone: '53 16 49 01',
          ),
        ],
      ),
      RouteOption(
        destination: 'Kaya',
        gares: [
          const DepartGare(
            quartier: "Gare de Fada N'Gourma",
            horaires: ['16h00'],
            prixTicket: 7000,
            dureeMax: '4h00',
            telephone: '53 16 49 01',
          ),
        ],
      ),
      RouteOption(
        destination: 'Koupéla',
        gares: [
          const DepartGare(
            quartier: "Gare de Fada N'Gourma",
            horaires: ['06h00'],
            prixTicket: 2000,
            dureeMax: '1h30',
            telephone: '53 16 49 01',
          ),
        ],
      ),
      RouteOption(
        destination: 'Ouagadougou',
        gares: [
          const DepartGare(
            quartier: "Gare de Fada N'Gourma",
            horaires: ['13h30'],
            prixTicket: 5000,
            dureeMax: '3h00',
            telephone: '53 16 49 01',
          ),
        ],
      ),
      RouteOption(
        destination: 'Ouahigouya',
        gares: [
          const DepartGare(
            quartier: "Gare de Fada N'Gourma",
            horaires: ['08h00'],
            prixTicket: 8000,
            dureeMax: '6h00',
            telephone: '53 16 49 01',
          ),
        ],
      ),
      RouteOption(
        destination: 'Kongoussi',
        gares: [
          const DepartGare(
            quartier: "Gare de Fada N'Gourma",
            horaires: ['08h00'],
            prixTicket: 8000,
            dureeMax: '5h00',
            telephone: '53 16 49 01',
          ),
        ],
      ),
      RouteOption(
        destination: 'Tenkodogo',
        gares: [
          const DepartGare(
            quartier: "Gare de Fada N'Gourma",
            horaires: ['16h00'],
            prixTicket: 3500,
            dureeMax: '2h30',
            telephone: '53 16 49 01',
          ),
        ],
      ),
    ],
  },
);
