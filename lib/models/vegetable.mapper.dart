// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'vegetable.dart';

class HarvestStateMapper extends EnumMapper<HarvestState> {
  HarvestStateMapper._();

  static HarvestStateMapper? _instance;
  static HarvestStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HarvestStateMapper._());
    }
    return _instance!;
  }

  static HarvestState fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  HarvestState decode(dynamic value) {
    switch (value) {
      case r'scarce':
        return HarvestState.scarce;
      case r'enough':
        return HarvestState.enough;
      case r'plenty':
        return HarvestState.plenty;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(HarvestState self) {
    switch (self) {
      case HarvestState.scarce:
        return r'scarce';
      case HarvestState.enough:
        return r'enough';
      case HarvestState.plenty:
        return r'plenty';
    }
  }
}

extension HarvestStateMapperExtension on HarvestState {
  String toValue() {
    HarvestStateMapper.ensureInitialized();
    return MapperContainer.globals.toValue<HarvestState>(this) as String;
  }
}

class HarvestStateTranslationMapper
    extends ClassMapperBase<HarvestStateTranslation> {
  HarvestStateTranslationMapper._();

  static HarvestStateTranslationMapper? _instance;
  static HarvestStateTranslationMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = HarvestStateTranslationMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'HarvestStateTranslation';

  static String _$scarce(HarvestStateTranslation v) => v.scarce;
  static const Field<HarvestStateTranslation, String> _f$scarce = Field(
    'scarce',
    _$scarce,
  );
  static String _$enough(HarvestStateTranslation v) => v.enough;
  static const Field<HarvestStateTranslation, String> _f$enough = Field(
    'enough',
    _$enough,
  );
  static String _$plenty(HarvestStateTranslation v) => v.plenty;
  static const Field<HarvestStateTranslation, String> _f$plenty = Field(
    'plenty',
    _$plenty,
  );

  @override
  final MappableFields<HarvestStateTranslation> fields = const {
    #scarce: _f$scarce,
    #enough: _f$enough,
    #plenty: _f$plenty,
  };

  static HarvestStateTranslation _instantiate(DecodingData data) {
    return HarvestStateTranslation(
      scarce: data.dec(_f$scarce),
      enough: data.dec(_f$enough),
      plenty: data.dec(_f$plenty),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static HarvestStateTranslation fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HarvestStateTranslation>(map);
  }

  static HarvestStateTranslation fromJson(String json) {
    return ensureInitialized().decodeJson<HarvestStateTranslation>(json);
  }
}

mixin HarvestStateTranslationMappable {
  String toJson() {
    return HarvestStateTranslationMapper.ensureInitialized()
        .encodeJson<HarvestStateTranslation>(this as HarvestStateTranslation);
  }

  Map<String, dynamic> toMap() {
    return HarvestStateTranslationMapper.ensureInitialized()
        .encodeMap<HarvestStateTranslation>(this as HarvestStateTranslation);
  }

  HarvestStateTranslationCopyWith<
    HarvestStateTranslation,
    HarvestStateTranslation,
    HarvestStateTranslation
  >
  get copyWith =>
      _HarvestStateTranslationCopyWithImpl<
        HarvestStateTranslation,
        HarvestStateTranslation
      >(this as HarvestStateTranslation, $identity, $identity);
  @override
  String toString() {
    return HarvestStateTranslationMapper.ensureInitialized().stringifyValue(
      this as HarvestStateTranslation,
    );
  }

  @override
  bool operator ==(Object other) {
    return HarvestStateTranslationMapper.ensureInitialized().equalsValue(
      this as HarvestStateTranslation,
      other,
    );
  }

  @override
  int get hashCode {
    return HarvestStateTranslationMapper.ensureInitialized().hashValue(
      this as HarvestStateTranslation,
    );
  }
}

extension HarvestStateTranslationValueCopy<$R, $Out>
    on ObjectCopyWith<$R, HarvestStateTranslation, $Out> {
  HarvestStateTranslationCopyWith<$R, HarvestStateTranslation, $Out>
  get $asHarvestStateTranslation => $base.as(
    (v, t, t2) => _HarvestStateTranslationCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class HarvestStateTranslationCopyWith<
  $R,
  $In extends HarvestStateTranslation,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? scarce, String? enough, String? plenty});
  HarvestStateTranslationCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _HarvestStateTranslationCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, HarvestStateTranslation, $Out>
    implements
        HarvestStateTranslationCopyWith<$R, HarvestStateTranslation, $Out> {
  _HarvestStateTranslationCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HarvestStateTranslation> $mapper =
      HarvestStateTranslationMapper.ensureInitialized();
  @override
  $R call({String? scarce, String? enough, String? plenty}) => $apply(
    FieldCopyWithData({
      if (scarce != null) #scarce: scarce,
      if (enough != null) #enough: enough,
      if (plenty != null) #plenty: plenty,
    }),
  );
  @override
  HarvestStateTranslation $make(CopyWithData data) => HarvestStateTranslation(
    scarce: data.get(#scarce, or: $value.scarce),
    enough: data.get(#enough, or: $value.enough),
    plenty: data.get(#plenty, or: $value.plenty),
  );

  @override
  HarvestStateTranslationCopyWith<$R2, HarvestStateTranslation, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _HarvestStateTranslationCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TranslationMapper extends ClassMapperBase<Translation> {
  TranslationMapper._();

  static TranslationMapper? _instance;
  static TranslationMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TranslationMapper._());
      HarvestStateTranslationMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Translation';

  static String _$name(Translation v) => v.name;
  static const Field<Translation, String> _f$name = Field('name', _$name);
  static HarvestStateTranslation _$harvestState(Translation v) =>
      v.harvestState;
  static const Field<Translation, HarvestStateTranslation> _f$harvestState =
      Field('harvestState', _$harvestState);

  @override
  final MappableFields<Translation> fields = const {
    #name: _f$name,
    #harvestState: _f$harvestState,
  };

  static Translation _instantiate(DecodingData data) {
    return Translation(
      name: data.dec(_f$name),
      harvestState: data.dec(_f$harvestState),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Translation fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Translation>(map);
  }

  static Translation fromJson(String json) {
    return ensureInitialized().decodeJson<Translation>(json);
  }
}

mixin TranslationMappable {
  String toJson() {
    return TranslationMapper.ensureInitialized().encodeJson<Translation>(
      this as Translation,
    );
  }

  Map<String, dynamic> toMap() {
    return TranslationMapper.ensureInitialized().encodeMap<Translation>(
      this as Translation,
    );
  }

  TranslationCopyWith<Translation, Translation, Translation> get copyWith =>
      _TranslationCopyWithImpl<Translation, Translation>(
        this as Translation,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TranslationMapper.ensureInitialized().stringifyValue(
      this as Translation,
    );
  }

  @override
  bool operator ==(Object other) {
    return TranslationMapper.ensureInitialized().equalsValue(
      this as Translation,
      other,
    );
  }

  @override
  int get hashCode {
    return TranslationMapper.ensureInitialized().hashValue(this as Translation);
  }
}

extension TranslationValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Translation, $Out> {
  TranslationCopyWith<$R, Translation, $Out> get $asTranslation =>
      $base.as((v, t, t2) => _TranslationCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TranslationCopyWith<$R, $In extends Translation, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  HarvestStateTranslationCopyWith<
    $R,
    HarvestStateTranslation,
    HarvestStateTranslation
  >
  get harvestState;
  $R call({String? name, HarvestStateTranslation? harvestState});
  TranslationCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TranslationCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Translation, $Out>
    implements TranslationCopyWith<$R, Translation, $Out> {
  _TranslationCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Translation> $mapper =
      TranslationMapper.ensureInitialized();
  @override
  HarvestStateTranslationCopyWith<
    $R,
    HarvestStateTranslation,
    HarvestStateTranslation
  >
  get harvestState =>
      $value.harvestState.copyWith.$chain((v) => call(harvestState: v));
  @override
  $R call({String? name, HarvestStateTranslation? harvestState}) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (harvestState != null) #harvestState: harvestState,
    }),
  );
  @override
  Translation $make(CopyWithData data) => Translation(
    name: data.get(#name, or: $value.name),
    harvestState: data.get(#harvestState, or: $value.harvestState),
  );

  @override
  TranslationCopyWith<$R2, Translation, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TranslationCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class VegetableTranslationsMapper
    extends ClassMapperBase<VegetableTranslations> {
  VegetableTranslationsMapper._();

  static VegetableTranslationsMapper? _instance;
  static VegetableTranslationsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = VegetableTranslationsMapper._());
      TranslationMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'VegetableTranslations';

  static Translation _$en(VegetableTranslations v) => v.en;
  static const Field<VegetableTranslations, Translation> _f$en = Field(
    'en',
    _$en,
  );
  static Translation _$nl(VegetableTranslations v) => v.nl;
  static const Field<VegetableTranslations, Translation> _f$nl = Field(
    'nl',
    _$nl,
  );
  static Translation _$fr(VegetableTranslations v) => v.fr;
  static const Field<VegetableTranslations, Translation> _f$fr = Field(
    'fr',
    _$fr,
  );
  static Translation _$de(VegetableTranslations v) => v.de;
  static const Field<VegetableTranslations, Translation> _f$de = Field(
    'de',
    _$de,
  );

  @override
  final MappableFields<VegetableTranslations> fields = const {
    #en: _f$en,
    #nl: _f$nl,
    #fr: _f$fr,
    #de: _f$de,
  };

  static VegetableTranslations _instantiate(DecodingData data) {
    return VegetableTranslations(
      en: data.dec(_f$en),
      nl: data.dec(_f$nl),
      fr: data.dec(_f$fr),
      de: data.dec(_f$de),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static VegetableTranslations fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<VegetableTranslations>(map);
  }

  static VegetableTranslations fromJson(String json) {
    return ensureInitialized().decodeJson<VegetableTranslations>(json);
  }
}

mixin VegetableTranslationsMappable {
  String toJson() {
    return VegetableTranslationsMapper.ensureInitialized()
        .encodeJson<VegetableTranslations>(this as VegetableTranslations);
  }

  Map<String, dynamic> toMap() {
    return VegetableTranslationsMapper.ensureInitialized()
        .encodeMap<VegetableTranslations>(this as VegetableTranslations);
  }

  VegetableTranslationsCopyWith<
    VegetableTranslations,
    VegetableTranslations,
    VegetableTranslations
  >
  get copyWith =>
      _VegetableTranslationsCopyWithImpl<
        VegetableTranslations,
        VegetableTranslations
      >(this as VegetableTranslations, $identity, $identity);
  @override
  String toString() {
    return VegetableTranslationsMapper.ensureInitialized().stringifyValue(
      this as VegetableTranslations,
    );
  }

  @override
  bool operator ==(Object other) {
    return VegetableTranslationsMapper.ensureInitialized().equalsValue(
      this as VegetableTranslations,
      other,
    );
  }

  @override
  int get hashCode {
    return VegetableTranslationsMapper.ensureInitialized().hashValue(
      this as VegetableTranslations,
    );
  }
}

extension VegetableTranslationsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, VegetableTranslations, $Out> {
  VegetableTranslationsCopyWith<$R, VegetableTranslations, $Out>
  get $asVegetableTranslations => $base.as(
    (v, t, t2) => _VegetableTranslationsCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class VegetableTranslationsCopyWith<
  $R,
  $In extends VegetableTranslations,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  TranslationCopyWith<$R, Translation, Translation> get en;
  TranslationCopyWith<$R, Translation, Translation> get nl;
  TranslationCopyWith<$R, Translation, Translation> get fr;
  TranslationCopyWith<$R, Translation, Translation> get de;
  $R call({Translation? en, Translation? nl, Translation? fr, Translation? de});
  VegetableTranslationsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _VegetableTranslationsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, VegetableTranslations, $Out>
    implements VegetableTranslationsCopyWith<$R, VegetableTranslations, $Out> {
  _VegetableTranslationsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<VegetableTranslations> $mapper =
      VegetableTranslationsMapper.ensureInitialized();
  @override
  TranslationCopyWith<$R, Translation, Translation> get en =>
      $value.en.copyWith.$chain((v) => call(en: v));
  @override
  TranslationCopyWith<$R, Translation, Translation> get nl =>
      $value.nl.copyWith.$chain((v) => call(nl: v));
  @override
  TranslationCopyWith<$R, Translation, Translation> get fr =>
      $value.fr.copyWith.$chain((v) => call(fr: v));
  @override
  TranslationCopyWith<$R, Translation, Translation> get de =>
      $value.de.copyWith.$chain((v) => call(de: v));
  @override
  $R call({
    Translation? en,
    Translation? nl,
    Translation? fr,
    Translation? de,
  }) => $apply(
    FieldCopyWithData({
      if (en != null) #en: en,
      if (nl != null) #nl: nl,
      if (fr != null) #fr: fr,
      if (de != null) #de: de,
    }),
  );
  @override
  VegetableTranslations $make(CopyWithData data) => VegetableTranslations(
    en: data.get(#en, or: $value.en),
    nl: data.get(#nl, or: $value.nl),
    fr: data.get(#fr, or: $value.fr),
    de: data.get(#de, or: $value.de),
  );

  @override
  VegetableTranslationsCopyWith<$R2, VegetableTranslations, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _VegetableTranslationsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class VegetableMapper extends ClassMapperBase<Vegetable> {
  VegetableMapper._();

  static VegetableMapper? _instance;
  static VegetableMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = VegetableMapper._());
      HarvestStateMapper.ensureInitialized();
      VegetableTranslationsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Vegetable';

  static String _$name(Vegetable v) => v.name;
  static const Field<Vegetable, String> _f$name = Field('name', _$name);
  static DateTime _$createdAt(Vegetable v) => v.createdAt;
  static const Field<Vegetable, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
  );
  static DateTime _$updatedAt(Vegetable v) => v.updatedAt;
  static const Field<Vegetable, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
  );
  static HarvestState _$harvestState(Vegetable v) => v.harvestState;
  static const Field<Vegetable, HarvestState> _f$harvestState = Field(
    'harvestState',
    _$harvestState,
  );
  static VegetableTranslations _$translations(Vegetable v) => v.translations;
  static const Field<Vegetable, VegetableTranslations> _f$translations = Field(
    'translations',
    _$translations,
  );

  @override
  final MappableFields<Vegetable> fields = const {
    #name: _f$name,
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #harvestState: _f$harvestState,
    #translations: _f$translations,
  };

  static Vegetable _instantiate(DecodingData data) {
    return Vegetable(
      name: data.dec(_f$name),
      createdAt: data.dec(_f$createdAt),
      updatedAt: data.dec(_f$updatedAt),
      harvestState: data.dec(_f$harvestState),
      translations: data.dec(_f$translations),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Vegetable fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Vegetable>(map);
  }

  static Vegetable fromJson(String json) {
    return ensureInitialized().decodeJson<Vegetable>(json);
  }
}

mixin VegetableMappable {
  String toJson() {
    return VegetableMapper.ensureInitialized().encodeJson<Vegetable>(
      this as Vegetable,
    );
  }

  Map<String, dynamic> toMap() {
    return VegetableMapper.ensureInitialized().encodeMap<Vegetable>(
      this as Vegetable,
    );
  }

  VegetableCopyWith<Vegetable, Vegetable, Vegetable> get copyWith =>
      _VegetableCopyWithImpl<Vegetable, Vegetable>(
        this as Vegetable,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return VegetableMapper.ensureInitialized().stringifyValue(
      this as Vegetable,
    );
  }

  @override
  bool operator ==(Object other) {
    return VegetableMapper.ensureInitialized().equalsValue(
      this as Vegetable,
      other,
    );
  }

  @override
  int get hashCode {
    return VegetableMapper.ensureInitialized().hashValue(this as Vegetable);
  }
}

extension VegetableValueCopy<$R, $Out> on ObjectCopyWith<$R, Vegetable, $Out> {
  VegetableCopyWith<$R, Vegetable, $Out> get $asVegetable =>
      $base.as((v, t, t2) => _VegetableCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class VegetableCopyWith<$R, $In extends Vegetable, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  VegetableTranslationsCopyWith<
    $R,
    VegetableTranslations,
    VegetableTranslations
  >
  get translations;
  $R call({
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    HarvestState? harvestState,
    VegetableTranslations? translations,
  });
  VegetableCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _VegetableCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Vegetable, $Out>
    implements VegetableCopyWith<$R, Vegetable, $Out> {
  _VegetableCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Vegetable> $mapper =
      VegetableMapper.ensureInitialized();
  @override
  VegetableTranslationsCopyWith<
    $R,
    VegetableTranslations,
    VegetableTranslations
  >
  get translations =>
      $value.translations.copyWith.$chain((v) => call(translations: v));
  @override
  $R call({
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    HarvestState? harvestState,
    VegetableTranslations? translations,
  }) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (createdAt != null) #createdAt: createdAt,
      if (updatedAt != null) #updatedAt: updatedAt,
      if (harvestState != null) #harvestState: harvestState,
      if (translations != null) #translations: translations,
    }),
  );
  @override
  Vegetable $make(CopyWithData data) => Vegetable(
    name: data.get(#name, or: $value.name),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
    harvestState: data.get(#harvestState, or: $value.harvestState),
    translations: data.get(#translations, or: $value.translations),
  );

  @override
  VegetableCopyWith<$R2, Vegetable, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _VegetableCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

