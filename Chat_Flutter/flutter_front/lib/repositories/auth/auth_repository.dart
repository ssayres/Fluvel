
import 'package:flutter_front/models/models.dart';
import 'package:flutter_front/models/requests/requests.dart';
import 'package:flutter_front/models/user_model.dart';
import 'package:flutter_front/repositories/auth/base_auth_repository.dart';

class AuthRepository extends BaseAuthRepository{
  @override

  Future<AppResponse<AuthUser?>> register(RegisterRequest request){
    // TODO: implement login
    throw UnimplementedError();
  }
  @override
  Future<AppResponse<AuthUser?>> login(LoginRequest request){
    throw UnimplementedError();
  }
  @override
  Future<AppResponse<UserEntity?>> loginwithToken(){
    throw UnimplementedError();
  }
  @override
  Future<AppResponse> logout(){
    throw UnimplementedError();
  }

}