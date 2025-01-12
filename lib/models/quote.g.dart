// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetQuoteCollection on Isar {
  IsarCollection<Quote> get quotes => this.collection();
}

const QuoteSchema = CollectionSchema(
  name: r'Quote',
  id: 1459993770030070654,
  properties: {
    r'authorImg': PropertySchema(
      id: 0,
      name: r'authorImg',
      type: IsarType.string,
    ),
    r'authorName': PropertySchema(
      id: 1,
      name: r'authorName',
      type: IsarType.string,
    ),
    r'bookmarkedAt': PropertySchema(
      id: 2,
      name: r'bookmarkedAt',
      type: IsarType.dateTime,
    ),
    r'isBookmarked': PropertySchema(
      id: 3,
      name: r'isBookmarked',
      type: IsarType.bool,
    ),
    r'isRead': PropertySchema(
      id: 4,
      name: r'isRead',
      type: IsarType.bool,
    ),
    r'quote': PropertySchema(
      id: 5,
      name: r'quote',
      type: IsarType.string,
    )
  },
  estimateSize: _quoteEstimateSize,
  serialize: _quoteSerialize,
  deserialize: _quoteDeserialize,
  deserializeProp: _quoteDeserializeProp,
  idName: r'id',
  indexes: {
    r'isBookmarked': IndexSchema(
      id: -5205273177397984230,
      name: r'isBookmarked',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isBookmarked',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'bookmarkedAt': IndexSchema(
      id: 5853294005280127171,
      name: r'bookmarkedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bookmarkedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'author': LinkSchema(
      id: 8804674871060558035,
      name: r'author',
      target: r'Author',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _quoteGetId,
  getLinks: _quoteGetLinks,
  attach: _quoteAttach,
  version: '3.1.0+1',
);

int _quoteEstimateSize(
  Quote object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.authorImg.length * 3;
  bytesCount += 3 + object.authorName.length * 3;
  bytesCount += 3 + object.quote.length * 3;
  return bytesCount;
}

void _quoteSerialize(
  Quote object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.authorImg);
  writer.writeString(offsets[1], object.authorName);
  writer.writeDateTime(offsets[2], object.bookmarkedAt);
  writer.writeBool(offsets[3], object.isBookmarked);
  writer.writeBool(offsets[4], object.isRead);
  writer.writeString(offsets[5], object.quote);
}

Quote _quoteDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Quote(
    bookmarkedAt: reader.readDateTimeOrNull(offsets[2]),
    isBookmarked: reader.readBoolOrNull(offsets[3]) ?? false,
    isRead: reader.readBoolOrNull(offsets[4]) ?? false,
    quote: reader.readStringOrNull(offsets[5]) ?? '',
  );
  object.id = id;
  return object;
}

P _quoteDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 5:
      return (reader.readStringOrNull(offset) ?? '') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _quoteGetId(Quote object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _quoteGetLinks(Quote object) {
  return [object.author];
}

void _quoteAttach(IsarCollection<dynamic> col, Id id, Quote object) {
  object.id = id;
  object.author.attach(col, col.isar.collection<Author>(), r'author', id);
}

extension QuoteQueryWhereSort on QueryBuilder<Quote, Quote, QWhere> {
  QueryBuilder<Quote, Quote, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Quote, Quote, QAfterWhere> anyIsBookmarked() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isBookmarked'),
      );
    });
  }

  QueryBuilder<Quote, Quote, QAfterWhere> anyBookmarkedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'bookmarkedAt'),
      );
    });
  }
}

extension QuoteQueryWhere on QueryBuilder<Quote, Quote, QWhereClause> {
  QueryBuilder<Quote, Quote, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Quote, Quote, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Quote, Quote, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Quote, Quote, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterWhereClause> isBookmarkedEqualTo(
      bool isBookmarked) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isBookmarked',
        value: [isBookmarked],
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterWhereClause> isBookmarkedNotEqualTo(
      bool isBookmarked) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isBookmarked',
              lower: [],
              upper: [isBookmarked],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isBookmarked',
              lower: [isBookmarked],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isBookmarked',
              lower: [isBookmarked],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isBookmarked',
              lower: [],
              upper: [isBookmarked],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Quote, Quote, QAfterWhereClause> bookmarkedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookmarkedAt',
        value: [null],
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterWhereClause> bookmarkedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookmarkedAt',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterWhereClause> bookmarkedAtEqualTo(
      DateTime? bookmarkedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookmarkedAt',
        value: [bookmarkedAt],
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterWhereClause> bookmarkedAtNotEqualTo(
      DateTime? bookmarkedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookmarkedAt',
              lower: [],
              upper: [bookmarkedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookmarkedAt',
              lower: [bookmarkedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookmarkedAt',
              lower: [bookmarkedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookmarkedAt',
              lower: [],
              upper: [bookmarkedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Quote, Quote, QAfterWhereClause> bookmarkedAtGreaterThan(
    DateTime? bookmarkedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookmarkedAt',
        lower: [bookmarkedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterWhereClause> bookmarkedAtLessThan(
    DateTime? bookmarkedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookmarkedAt',
        lower: [],
        upper: [bookmarkedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterWhereClause> bookmarkedAtBetween(
    DateTime? lowerBookmarkedAt,
    DateTime? upperBookmarkedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookmarkedAt',
        lower: [lowerBookmarkedAt],
        includeLower: includeLower,
        upper: [upperBookmarkedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension QuoteQueryFilter on QueryBuilder<Quote, Quote, QFilterCondition> {
  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorImgEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authorImg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorImgGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'authorImg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorImgLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'authorImg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorImgBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'authorImg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorImgStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'authorImg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorImgEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'authorImg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorImgContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'authorImg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorImgMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'authorImg',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorImgIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authorImg',
        value: '',
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorImgIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'authorImg',
        value: '',
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'authorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'authorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'authorName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'authorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'authorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'authorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'authorName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authorName',
        value: '',
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'authorName',
        value: '',
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> bookmarkedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bookmarkedAt',
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> bookmarkedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bookmarkedAt',
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> bookmarkedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookmarkedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> bookmarkedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookmarkedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> bookmarkedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookmarkedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> bookmarkedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookmarkedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> isBookmarkedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBookmarked',
        value: value,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> isReadEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRead',
        value: value,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> quoteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> quoteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> quoteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> quoteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quote',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> quoteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'quote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> quoteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'quote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> quoteContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'quote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> quoteMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'quote',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> quoteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quote',
        value: '',
      ));
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> quoteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'quote',
        value: '',
      ));
    });
  }
}

extension QuoteQueryObject on QueryBuilder<Quote, Quote, QFilterCondition> {}

extension QuoteQueryLinks on QueryBuilder<Quote, Quote, QFilterCondition> {
  QueryBuilder<Quote, Quote, QAfterFilterCondition> author(
      FilterQuery<Author> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'author');
    });
  }

  QueryBuilder<Quote, Quote, QAfterFilterCondition> authorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'author', 0, true, 0, true);
    });
  }
}

extension QuoteQuerySortBy on QueryBuilder<Quote, Quote, QSortBy> {
  QueryBuilder<Quote, Quote, QAfterSortBy> sortByAuthorImg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorImg', Sort.asc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> sortByAuthorImgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorImg', Sort.desc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> sortByAuthorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorName', Sort.asc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> sortByAuthorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorName', Sort.desc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> sortByBookmarkedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookmarkedAt', Sort.asc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> sortByBookmarkedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookmarkedAt', Sort.desc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> sortByIsBookmarked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBookmarked', Sort.asc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> sortByIsBookmarkedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBookmarked', Sort.desc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> sortByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.asc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> sortByIsReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.desc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> sortByQuote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quote', Sort.asc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> sortByQuoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quote', Sort.desc);
    });
  }
}

extension QuoteQuerySortThenBy on QueryBuilder<Quote, Quote, QSortThenBy> {
  QueryBuilder<Quote, Quote, QAfterSortBy> thenByAuthorImg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorImg', Sort.asc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> thenByAuthorImgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorImg', Sort.desc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> thenByAuthorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorName', Sort.asc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> thenByAuthorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorName', Sort.desc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> thenByBookmarkedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookmarkedAt', Sort.asc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> thenByBookmarkedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookmarkedAt', Sort.desc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> thenByIsBookmarked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBookmarked', Sort.asc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> thenByIsBookmarkedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBookmarked', Sort.desc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> thenByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.asc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> thenByIsReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRead', Sort.desc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> thenByQuote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quote', Sort.asc);
    });
  }

  QueryBuilder<Quote, Quote, QAfterSortBy> thenByQuoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quote', Sort.desc);
    });
  }
}

extension QuoteQueryWhereDistinct on QueryBuilder<Quote, Quote, QDistinct> {
  QueryBuilder<Quote, Quote, QDistinct> distinctByAuthorImg(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'authorImg', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Quote, Quote, QDistinct> distinctByAuthorName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'authorName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Quote, Quote, QDistinct> distinctByBookmarkedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookmarkedAt');
    });
  }

  QueryBuilder<Quote, Quote, QDistinct> distinctByIsBookmarked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBookmarked');
    });
  }

  QueryBuilder<Quote, Quote, QDistinct> distinctByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRead');
    });
  }

  QueryBuilder<Quote, Quote, QDistinct> distinctByQuote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quote', caseSensitive: caseSensitive);
    });
  }
}

extension QuoteQueryProperty on QueryBuilder<Quote, Quote, QQueryProperty> {
  QueryBuilder<Quote, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Quote, String, QQueryOperations> authorImgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'authorImg');
    });
  }

  QueryBuilder<Quote, String, QQueryOperations> authorNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'authorName');
    });
  }

  QueryBuilder<Quote, DateTime?, QQueryOperations> bookmarkedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookmarkedAt');
    });
  }

  QueryBuilder<Quote, bool, QQueryOperations> isBookmarkedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBookmarked');
    });
  }

  QueryBuilder<Quote, bool, QQueryOperations> isReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRead');
    });
  }

  QueryBuilder<Quote, String, QQueryOperations> quoteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quote');
    });
  }
}
