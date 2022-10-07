import 'package:projeto_missoes_api/app/core/gerencianet/pix/gerencianet_pix.dart';
import 'package:projeto_missoes_api/app/repositories/order_repository.dart';
import 'package:projeto_missoes_api/app/repositories/product_repository.dart';
import 'package:projeto_missoes_api/app/repositories/user_repository.dart';
import 'package:projeto_missoes_api/app/view_models/order_view_model.dart';

import '../core/gerencianet/pix/models/qr_code_gerencianet_model.dart';

class OrderService {
  final _orderRepository = OrderRepository();
  final _userRepository = UserRepository();
  final _productRepository = ProductRepository();
  final _gerencianetPix = GerencianetPix();

  Future<QrCodeGerencianetModel> createOrder(OrderViewModel order) async {
    final orderId = await _orderRepository.save(order);

    return await _createBilling(orderId, order);
  }

  Future<QrCodeGerencianetModel> _createBilling(int orderId, OrderViewModel order) async {
    // Buscar dados completos do usuário
    final user = await _userRepository.findById(order.userId);

    //Pegar valor total do itens da compra
    var totalValue = 0.0;
    for (final item in order.items) {
      final product = await _productRepository.findById(item.productId);
      totalValue += item.quantity * product.price;
    }

    final value = totalValue;
    final cpf = order.cpf;
    final name = user.name;

    final billing = await _gerencianetPix.generateBilling(value, cpf, name, orderId);

    // Importante!!!!
    // Atualizar o pedido com o código do pagamento da GerenciaNet
    // https://www.youtube.com/watch?v=7UXJitOsrYM&list=PLEXr-WZRgPjw5zVjR5YP3mB7cI9pfWmd7&index=8 => 34 minutos

    await _orderRepository.updateTransactionId(orderId, billing.transactionId);

    return _gerencianetPix.getQrCode(billing.locationId);
  }

  Future<void> confirmPayment(Iterable<String> transactions) async {
    //https://www.youtube.com/watch?v=yJL9X981ewk&list=PLEXr-WZRgPjw5zVjR5YP3mB7cI9pfWmd7&index=7
    // Mais validações
    for (final transaction in transactions) {
      _orderRepository.confirmPaymentByTransactionId(transaction);
    }
  }
}
