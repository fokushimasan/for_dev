import '../../../../presentation/dependencies/dependencies.dart';
import '../../../../validation/dependencies/dependencies.dart';
import '../../../../validation/validators/validators.dart';
import '../../../builders/builders.dart';

IValidation makeLoginValidation() {
  return ValidationComposite(validations: makeLoginValidations());
}

List<IFieldValidation> makeLoginValidations() {
  return [
    ...ValidationBuilder.field('email').required().email().build(),
    ...ValidationBuilder.field('password').required().build(),
  ];
}