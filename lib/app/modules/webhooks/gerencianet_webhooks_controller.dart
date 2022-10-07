import 'dart:convert';
import 'package:projeto_missoes_api/app/core/gerencianet/pix/gerencianet_pix.dart';
import 'package:projeto_missoes_api/app/modules/webhooks/view_models/gerencianet_callback_view_model.dart';
import 'package:projeto_missoes_api/app/service/order_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'gerencianet_webhooks_controller.g.dart';

class GerencianetWebhooksController {
  final _orderService = OrderService(); // Rota de configuração do Webhook, usada pela GerenciaNet para verificar se o serviço é realmente válido

  @Route.post('/register')
  Future<Response> register(Request request) async {
    await GerencianetPix().registerWebHook();
    return Response.ok(
      jsonEncode({}),
      headers: {'content-type': 'application/json'},
    );
  }

  // https://www.youtube.com/watch?v=yJL9X981ewk&list=PLEXr-WZRgPjw5zVjR5YP3mB7cI9pfWmd7&index=6 => 8 minutos
  @Route.post('/')
  Future<Response> find(Request request) async {
    return Response(
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  @Route.post('/pix')
  Future<Response> webhookPaymentCallback(Request request) async {
    try {
      final callback = GerencianetCallbackViewModel.fromJson(await request.readAsString());

      await _orderService.confirmPayment(callback.pix.map((p) => p.transactionId));

      return Response.ok(jsonEncode({}), headers: {
        'content-type': 'application/json',
      });
    } catch (e, s) {
      print(e);
      print(s);
      return Response.internalServerError();
    }
  }

  Router get router => _$GerencianetWebhooksControllerRouter(this);
}
