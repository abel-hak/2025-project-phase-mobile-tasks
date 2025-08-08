import 'package:mockito/annotations.dart';
import 'package:product_app/features/auth/domain/usecases/sign_in.dart';
import 'package:product_app/features/auth/domain/usecases/sign_out.dart';
import 'package:product_app/features/auth/domain/usecases/sign_up.dart';

@GenerateMocks([
  SignUp,
  SignIn,
  SignOut,
])
void main() {}
