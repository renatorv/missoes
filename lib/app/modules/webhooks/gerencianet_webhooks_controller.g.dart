// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gerencianet_webhooks_controller.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$GerencianetWebhooksControllerRouter(
    GerencianetWebhooksController service) {
  final router = Router();
  router.add(
    'POST',
    r'/register',
    service.register,
  );
  router.add(
    'POST',
    r'/',
    service.find,
  );
  router.add(
    'POST',
    r'/pix',
    service.webhookPaymentCallback,
  );
  return router;
}
