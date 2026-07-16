import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const _sections = [
    _Section(
      number: 1,
      title: 'Objeto y alcance jurídico',
      body:
          'Los presentes Términos y Condiciones (el "Contrato") constituyen un acuerdo legalmente vinculante entre LogiRed y el usuario. Este instrumento regula el acceso y uso de la infraestructura tecnológica, aplicaciones móviles y activos digitales (colectivamente, la "Plataforma") destinados a la intermediación de servicios de logística y transporte en la jurisdicción del Estado de Chiapas, México.',
    ),
    _Section(
      number: 2,
      title: 'Naturaleza de la intermediación y deslinde de responsabilidad',
      body:
          'LogiRed manifiesta expresamente, y el Usuario reconoce, que la Plataforma actúa exclusivamente como un facilitador tecnológico (intermediario) bajo un modelo cliente-servidor. LogiRed no es una empresa de transporte de carga, ni operador logístico, ni prestador de servicios de fletes o mudanzas. La relación contractual del servicio de transporte se perfecciona de manera autónoma e independiente entre el Cliente y el Conductor Tercero Independiente. No existe relación de subordinación, agencia, sociedad o vínculo laboral entre LogiRed y los prestadores del servicio.',
    ),
    _Section(
      number: 3,
      title: 'Exención de responsabilidad y garantías (disclaimer)',
      body:
          'El acceso a la Plataforma se proporciona "tal cual" (as-is) y "según disponibilidad". LogiRed no garantiza la infalibilidad de sus sistemas ni la disponibilidad ininterrumpida de la red. Bajo ninguna circunstancia LogiRed será responsable por actos, omisiones, daños emergentes, lucro cesante, menoscabo de la carga, incidentes de tránsito, o cualquier conducta ilícita perpetrada por terceros (conductores o clientes) durante la ejecución de los servicios intermediados. El riesgo derivado del uso de la Plataforma recae exclusivamente en el Usuario.',
    ),
    _Section(
      number: 4,
      title: 'Cláusula de indemnidad',
      body:
          'El Usuario se obliga de manera irrevocable a indemnizar, defender y sacar en paz y a salvo a LogiRed, sus filiales, accionistas, directivos, empleados y agentes ante cualquier reclamación, demanda, litigio, gasto (incluyendo honorarios legales razonables) o responsabilidad civil, penal o administrativa que surja como consecuencia del uso indebido de la Plataforma, el incumplimiento de este Contrato o la violación de derechos de terceros.',
    ),
    _Section(
      number: 5,
      title: 'Validación de identidad y cumplimiento normativo',
      body:
          'La activación de perfiles está sujeta a procesos de diligencia debida (KYC). LogiRed se reserva el derecho de suspender unilateralmente cualquier cuenta que contravenga las leyes de tránsito del Estado de Chiapas o que sea utilizada para el transporte de materiales peligrosos, ilícitos o prohibidos por la normativa federal mexicana.',
    ),
    _Section(
      number: 6,
      title: 'Condiciones económicas y operativas',
      body:
          'Las transacciones financieras son gestionadas exclusivamente mediante la pasarela Stripe bajo protocolos de cifrado bancario. El Conductor reconoce y acepta una tasa de servicio del 5% en favor de LogiRed por concepto de licenciamiento y uso de infraestructura. Las herramientas de Inteligencia Artificial (Machine Learning y LLM) proporcionan estimaciones y resúmenes con carácter informativo; la decisión final sobre la tarifa y la selección del transportista es responsabilidad absoluta de las partes.',
    ),
    _Section(
      number: 7,
      title: 'Jurisdicción y ley aplicable',
      body:
          'Este Contrato se rige por las leyes vigentes de los Estados Unidos Mexicanos y el Código Civil del Estado de Chiapas. Para cualquier controversia no resuelta mediante mediación, las partes se someten irrevocablemente a la jurisdicción de los tribunales competentes en la ciudad de Tuxtla Gutiérrez, Chiapas, renunciando a cualquier otro fuero por razón de domicilio presente o futuro.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Términos y condiciones',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_sections.length, (i) {
                final s = _sections[i];
                return Padding(
                  padding: EdgeInsets.only(top: i > 0 ? 20 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${s.number}. ${s.title}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.body,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.55,
                            ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section {
  final int number;
  final String title;
  final String body;
  const _Section(
      {required this.number, required this.title, required this.body});
}
