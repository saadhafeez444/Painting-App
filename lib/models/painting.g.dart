// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'painting.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaintingAdapter extends TypeAdapter<Painting> {
  @override
  final int typeId = 1;

  @override
  Painting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Painting(
      title: fields[0] as String,
      artistName: fields[1] as String,
      imagePath: fields[2] as String,
      price: fields[3] as double,
      medium: fields[4] as String,
      creationDate: fields[5] as DateTime,
      description: fields[6] as String,
      category: fields[7] as String,
      reviews: (fields[8] as List?)?.cast<Review>(),
      previousWorkImagePaths: (fields[9] as List).cast<String>(),
      isFavorite: fields[10] as bool,
      isInCart: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Painting obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.artistName)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.medium)
      ..writeByte(5)
      ..write(obj.creationDate)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.reviews)
      ..writeByte(9)
      ..write(obj.previousWorkImagePaths)
      ..writeByte(10)
      ..write(obj.isFavorite)
      ..writeByte(11)
      ..write(obj.isInCart);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaintingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
