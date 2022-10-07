import 'dart:async';
import 'dart:convert';
import 'package:projeto_missoes_api/app/core/exceptions/email_already_registered.dart';
import 'package:projeto_missoes_api/app/core/exceptions/user_not_found_exception.dart';
import 'package:projeto_missoes_api/app/repositories/user_repository.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../entities/user.dart';

part 'auth_controller.g.dart';

class AuthController {
  final _userRepository = UserRepository();

  @Route.post('/')
  Future<Response> login(Request request) async {
    final jsonRq = jsonDecode(await request.readAsString());

    try {
      final user =
          await _userRepository.login(jsonRq['email'], jsonRq['password']);

      return Response.ok(
        user.toJson(),
        headers: {'content-type': 'application/json'},
      );
    } on UserNotFoundException catch (e, s) {
      print(e);
      print(s);
      return Response(
        403,
        headers: {'content-type': 'application/json'},
      );
    } catch (e, s) {
      print(e);
      print(s);
      return Response.internalServerError();
    }
  }

  @Route.post('/register')
  Future<Response> register(Request request) async {
    try {
      //Converter o request que chegou
      final userRequest = User.fromJson(await request.readAsString());
      await _userRepository.save(userRequest);

      //Sucesso
      return Response(
        200,
        headers: {'content-type': 'application/json'},
      );
    } on EmailAlreadyRegistered catch (e, s) {
      print(e);
      print(s);
      return Response(
        400,
        body: jsonEncode(
          {'error': 'E-mail já cadastrado!'},
        ),
        headers: {'content-type': 'application/json'},
      );
    } catch (e, s) {
      print(e);
      print(s);
      return Response.internalServerError();
    }
  }

  Router get router => _$AuthControllerRouter(this);
}
