import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logired/core/utils/driver_status.dart';
import 'package:logired/features/driverstatus/presentation/driver_status_screen.dart';

void main() {
  group('DriverStatus.parse', () {
    test('reconoce los cuatro estados de la API', () {
      expect(DriverStatus.parse('pending'), DriverStatus.pending);
      expect(DriverStatus.parse('approved'), DriverStatus.approved);
      expect(DriverStatus.parse('rejected'), DriverStatus.rejected);
      expect(DriverStatus.parse('blocked'), DriverStatus.blocked);
    });

    test('normaliza mayusculas y espacios', () {
      expect(DriverStatus.parse(' BLOCKED '), DriverStatus.blocked);
    });

    test('null, vacio y desconocido caen en el fallback', () {
      // Si el backend aun no manda el campo, el conductor debe seguir
      // trabajando en vez de quedar encerrado.
      expect(DriverStatus.parse(null), DriverStatus.approved);
      expect(DriverStatus.parse(''), DriverStatus.approved);
      expect(DriverStatus.parse('suspended'), DriverStatus.approved);
    });

    test('solo approved conduce y solo rejected puede re-postularse', () {
      expect(DriverStatus.canDrive(DriverStatus.approved), isTrue);
      expect(DriverStatus.canDrive(DriverStatus.pending), isFalse);
      expect(DriverStatus.canDrive(DriverStatus.blocked), isFalse);

      expect(DriverStatus.canReapply(DriverStatus.rejected), isTrue);
      expect(DriverStatus.canReapply(DriverStatus.blocked), isFalse);
    });
  });

  group('DriverStatusScreen', () {
    Widget harness(String status, {String? reason}) => MaterialApp(
          home: DriverStatusScreen(
            status: status,
            reason: reason,
            onRefresh: () async {},
            onReapply: () {},
            onLogout: () {},
          ),
        );

    testWidgets('pending explica la revision y no ofrece re-postular',
        (tester) async {
      await tester.pumpWidget(harness(DriverStatus.pending));
      expect(find.textContaining('revisando tus documentos'), findsOneWidget);
      expect(find.text('Actualizar estado'), findsOneWidget);
      expect(find.text('Volver a enviar documentos'), findsNothing);
    });

    testWidgets('rejected muestra el motivo y deja re-postular',
        (tester) async {
      await tester.pumpWidget(
        harness(DriverStatus.rejected, reason: 'La licencia esta vencida'),
      );
      expect(find.text('Tu solicitud fue rechazada'), findsOneWidget);
      expect(find.text('La licencia esta vencida'), findsOneWidget);
      expect(find.text('Volver a enviar documentos'), findsOneWidget);
    });

    testWidgets('blocked manda a soporte y nunca a re-postular',
        (tester) async {
      await tester.pumpWidget(
        harness(DriverStatus.blocked, reason: 'Uso indebido de la plataforma'),
      );
      expect(find.text('Cuenta suspendida'), findsOneWidget);
      expect(find.text('Uso indebido de la plataforma'), findsOneWidget);
      expect(find.text('Contactar a soporte tecnico'), findsOneWidget);
      expect(find.text('Volver a enviar documentos'), findsNothing);
    });

    testWidgets('siempre deja cerrar sesion para no dejar al usuario atrapado',
        (tester) async {
      for (final status in [
        DriverStatus.pending,
        DriverStatus.rejected,
        DriverStatus.blocked,
      ]) {
        await tester.pumpWidget(harness(status));
        expect(find.text('Cerrar sesion'), findsOneWidget);
      }
    });

    testWidgets('renderiza en pantalla corta sin desbordar', (tester) async {
      // El caso que rompia el Spacer dentro del scroll.
      tester.view.physicalSize = const Size(360, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        harness(DriverStatus.rejected, reason: 'Motivo largo ' * 20),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
