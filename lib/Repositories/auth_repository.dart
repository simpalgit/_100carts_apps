import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:carts_app/Models/state_city_model.dart';
import 'package:carts_app/Models/user_address_model.dart';
import 'package:carts_app/Utils/app_base_api_services.dart';
import 'package:carts_app/Utils/app_exceptions.dart';
import 'package:carts_app/Utils/app_failure.dart';
import 'package:carts_app/Utils/app_network_api_services.dart';
import 'package:carts_app/Utils/remote_urls.dart';

class AuthRepository {
  BaseApiService apiService = NetworkAPIService();

  Future<Either<Failure, dynamic>> loginUser(String mobile, String password) async {
    try {
      var data = json.encode({
        "mobile": mobile,
        "password": password,
      });
      var response = await apiService.loginRegisterApiResponse(
        RemoteUrl.loginUser,
        data,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  Future<Either<Failure, dynamic>> registerUser(dynamic data) async {
    try {
      var response = await apiService.loginRegisterApiResponse(
        RemoteUrl.registerUser,
        data,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  Future<Either<Failure, dynamic>> sendOTP(String mobile) async {
    try {
      var data = json.encode({
        "mobile": mobile,
      });
      var response = await apiService.loginRegisterApiResponse(
        RemoteUrl.sendForgetOTP,
        data,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  Future<Either<Failure, dynamic>> sendOtp({required String passedData}) async {
    try {
      var response = await apiService.loginRegisterApiResponse(
        RemoteUrl.registerSendOTP,
        passedData,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  Future<Either<Failure, dynamic>> forgetPassword(dynamic data) async {
    try {
      var response = await apiService.loginRegisterApiResponse(
        RemoteUrl.changePassword,
        data,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  Future<Either<Failure, dynamic>> changePassword(dynamic data) async {
    try {
      var response = await apiService.getPostApiResponse(
        RemoteUrl.changePassword,
        data,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  Future<Either<Failure, List<UserAddressModel>>> getSavedAddress() async {
    try {
      final response = await apiService.getGetApiResponse(
        RemoteUrl.getUserSavedAddress,
      );
      List<UserAddressModel> addressList = [];
      if (response != null && response['data'] != null) {
        response['data'].forEach((v) {
          addressList.add(UserAddressModel.fromJson(v));
        });
      }
      return Right(addressList);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  Future<Either<Failure, dynamic>> saveAddress(dynamic data) async {
    try {
      var response = await apiService.getPostApiResponse(
        RemoteUrl.addUserSavedAddress,
        data,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  Future<Either<Failure, dynamic>> deleteAddress(String id) async {
    try {
      final response = await apiService.getGetApiResponse(
        "${RemoteUrl.deleteUserSavedAddress}/$id",
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  Future<Either<Failure, dynamic>> sendDeleteOtp() async {
    try {
      final response = await apiService.getGetApiResponse(
        RemoteUrl.deleteSendOTP,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  Future<Either<Failure, dynamic>> deleteAccount(dynamic data) async {
    try {
      var response = await apiService.getPostApiResponse(
        RemoteUrl.deleteAccount,
        data,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  Future<Either<Failure, List<StatesModel>>> getStates() async {
    try {
      final response = await apiService.getGetApiResponse(RemoteUrl.getState);
      List<StatesModel> list = [];
      if (response['data'] != null) {
        response['data'].forEach((v) {
          list.add(StatesModel.fromJson(v));
        });
      }
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  Future<Either<Failure, List<DistrictModel>>> getDistrict({required int stateId}) async {
    try {
      final response = await apiService.getGetApiResponse("${RemoteUrl.getDistrict}$stateId");
      List<DistrictModel> list = [];
      if (response['data'] != null) {
        response['data'].forEach((v) {
          list.add(DistrictModel.fromJson(v));
        });
      }
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  Future<Either<Failure, List<CityModel>>> getCity({required int districtId}) async {
    try {
      final response = await apiService.getGetApiResponse("${RemoteUrl.getCity}$districtId");
      List<CityModel> list = [];
      if (response['data'] != null) {
        response['data'].forEach((v) {
          list.add(CityModel.fromJson(v));
        });
      }
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }
}
