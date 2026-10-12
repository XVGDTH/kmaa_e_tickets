import 'package:kmaa_e_tickets/mon-app/transport/reseau_transport.dart';

final CompagnieReseau rahimo = CompagnieReseau(
  routesParVille: {
    'ouagadougou': [
      RouteOption(
        destination: 'Bobo-Dioulasso',
        gares: [
          const DepartGare(
            quartier: 'Gare Rahimo Kalgondin (Prestige)',
            horaires: ['10h30', '14h30', '23h30'],
            prixTicket: 8000,
            dureeMax: '5h30',
            telephone: '64 86 37 55',
            adresse: 'Rue 30.73, Kalgondin',
          ),
          const DepartGare(
            quartier: 'Gare Rahimo Tanghin (Classic)',
            horaires: ['10h00', '12h30', '14h30', '23h30'],
            prixTicket: 7500,
            dureeMax: '5h30',
            telephone: '07 21 03 73',
            adresse: 'Tanghin, Ouagadougou',
          ),
          const DepartGare(
            quartier: 'Gare Rahimo Pissy (Escale)',
            horaires: ['10h00', '12h30', '14h30', '23h30'],
            prixTicket: 7500,
            dureeMax: '5h30',
            telephone: '07 21 03 73',
            adresse: 'Pissy, Ouagadougou',
          ),
        ],
      ),
    ],
    'bobo-dioulasso': [
      RouteOption(
        destination: 'Ouagadougou',
        gares: [
          const DepartGare(
            quartier: 'Gare Rahimo Boulevard (Bobo)',
            horaires: ['10h30', '12h30', '14h30', '23h00', '23h55'],
            prixTicket: 7500,
            dureeMax: '5h30',
            telephone: '64 86 37 56',
            adresse: 'Boulevard de la Révolution',
          ),
        ],
      ),
      RouteOption(
        destination: 'Banfora',
        gares: [
          const DepartGare(
            quartier: 'Gare Rahimo Boulevard (Bobo)',
            horaires: ['06h00', '08h30', '12h30', '15h30', '18h00', '20h30'],
            prixTicket: 1500,
            dureeMax: '1h30',
            telephone: '64 86 37 58',
          ),
        ],
      ),
    ],
  },
  tarifsInternational: {
    'abidjan': 60000,
    // TODO: Bouaké, Yamoussoukro, Lomé — prix non communiqués pour Rahimo.
  },
);
