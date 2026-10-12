import 'package:kmaa_e_tickets/mon-app/transport/reseau_transport.dart';

final CompagnieReseau staf = CompagnieReseau(
  routesParVille: {
    'ouagadougou': [
      RouteOption(
        destination: "Fada N'Gourma",
        gares: [
          const DepartGare(
            quartier: 'Gare de Gounghin',
            horaires: ['06h00', '12h00', '14h30'],
            prixTicket: 5000,
            dureeMax: '3h00',
            telephone: '25 40 77 77',
          ),
        ],
      ),
      RouteOption(
        destination: 'Bobo-Dioulasso',
        gares: [
          const DepartGare(
            quartier: 'Gare de Gounghin',
            horaires: [
              '05h00',
              '07h00',
              '09h00',
              '11h00',
              '13h00',
              '15h00',
              '17h00',
              '19h00',
              '21h00',
            ],
            prixTicket: 7000,
            dureeMax: '5h30',
            telephone: '25 40 77 77',
          ),
        ],
      ),
      RouteOption(
        destination: 'Cinkansé',
        gares: [
          const DepartGare(
            quartier: 'Gare de Gounghin',
            horaires: ['07h00', '13h00'],
            prixTicket: 6000,
            dureeMax: '2h30',
            telephone: '25 40 77 77',
          ),
        ],
      ),
      RouteOption(
        destination: 'Gaoua',
        gares: [
          const DepartGare(
            quartier: 'Gare de Gounghin',
            horaires: [
              '06h00',
              '07h00',
              '10h00',
              '12h00',
              '13h00',
              '14h00',
              '15h00',
              '17h00',
            ],
            prixTicket: 8500,
            dureeMax: '5h00',
            telephone: '25 40 77 77',
          ),
        ],
      ),
      RouteOption(
        destination: 'Kampti',
        gares: [
          const DepartGare(
            quartier: 'Gare de Gounghin',
            horaires: ['06h00', '10h00', '14h00', '15h00', '17h00'],
            prixTicket: 9000,
            dureeMax: '5h30',
            telephone: '25 40 77 77',
          ),
        ],
      ),
      RouteOption(
        destination: 'Ouahigouya',
        gares: [
          const DepartGare(
            quartier: 'Gare de Larlé',
            horaires: [
              '05h00',
              '07h00',
              '09h00',
              '11h00',
              '13h00',
              '15h00',
              '17h00',
              '19h00',
              '21h00',
            ],
            prixTicket: 3500,
            dureeMax: '2h30',
            telephone: '70 73 93 22',
          ),
        ],
      ),
      RouteOption(
        destination: 'Gourcy',
        gares: [
          const DepartGare(
            quartier: 'Gare de Larlé',
            horaires: ['06h00', '10h30', '15h00'],
            prixTicket: 3000,
            dureeMax: '2h00',
            telephone: '70 73 93 22',
          ),
        ],
      ),
      RouteOption(
        destination: 'Yako',
        gares: [
          const DepartGare(
            quartier: 'Gare de Larlé',
            horaires: ['06h00', '10h30', '15h00'],
            prixTicket: 2500,
            dureeMax: '1h45',
            telephone: '70 73 93 22',
          ),
        ],
      ),
      RouteOption(
        destination: 'Boussé',
        gares: [
          const DepartGare(
            quartier: 'Gare de Larlé',
            horaires: ['06h00', '10h30', '15h00'],
            prixTicket: 2000,
            dureeMax: '1h15',
            telephone: '70 73 93 22',
          ),
        ],
      ),
    ],
  },
);
