import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:finject_generator/src/json_schema/injector_Info.dart';
import 'package:source_gen/source_gen.dart';

Map<String, int> knownLibraries = {};
int currentLibraryNumber = 0;

String findName(List<ElementAnnotation> annotations) {
  for (var annotation in annotations) {
    var annotationInfo = annotation.element as ConstructorElement;
    var annotationType = annotationInfo.enclosingElement;
    if (annotationType.name == 'Named') {
      var result = annotation.computeConstantValue();
      return result.getField('name').toStringValue();
    }
  }
  return null;
}

TypeInfo convert(ClassElement element) {
  if (element == null) {
    throw InvalidGenerationSourceError(
        'Unknown type found, no import or something. Find compilation error',
        todo: 'Unknown type found, no import or something. Find compilation error');
  }
  var uriOfClass = element.librarySource.uri;
  var libraryId = 0;
  if (!knownLibraries.containsKey(uriOfClass.path)) {
    currentLibraryNumber++;
    knownLibraries[uriOfClass.path] = currentLibraryNumber;
  }
  libraryId = knownLibraries[uriOfClass.path];

  return TypeInfo(
      uriOfClass.scheme, uriOfClass.path, element.name, 'id$libraryId');
}

ClassElement getType(DartType type) {
  final element = type.element;
  if (element is ClassElement) {
    return element;
  }
  return null;
}

bool hasAnnotation(List<ElementAnnotation> metadata, String type) {
  for (var annotation in metadata) {
    var annotationInfo = annotation.element as ConstructorElement;
    var classInfo = annotationInfo.enclosingElement;
    if (classInfo.name == type) {
      return true;
    }
  }
  return false;
}

class InjectorValidationError extends Error {}
