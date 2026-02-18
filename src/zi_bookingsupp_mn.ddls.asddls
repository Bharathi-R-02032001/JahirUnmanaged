@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplementry Interface'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Zi_Bookingsupp_Mn
  as select from zrj_booksupl_m
  association [1..1] to ZI_Travel_Mn          as _Travel         on  $projection.TravelId = _Travel.TravelId
  association        to parent Zi_Booking_Mn  as _Booking        on  $projection.TravelId  = _Booking.TravelId
                                                                 and $projection.BookingId = _Booking.BookingId
  association [1..1] to /DMO/I_Supplement     as _supplement     on  $projection.SupplementId = _supplement.SupplementID
  association [1..1] to /DMO/I_SupplementText as _supplementText on  $projection.SupplementId     = _supplementText.SupplementID
                                                                 and _supplementText.LanguageCode = 'E'

{
@ObjectModel.text.association: '_Travel'
  key travel_id             as TravelId,
@ObjectModel.text.association: '_Booking'
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,
      //assocation
      _supplement,
      _supplementText,
      _Booking,
      _Travel
}
