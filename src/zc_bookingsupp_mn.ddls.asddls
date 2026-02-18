@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplemetry Projcetion View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity Zc_BOOKINGSUPP_MN as projection on Zi_Bookingsupp_Mn
{
    key TravelId,
    key BookingId,
    key BookingSupplementId,
    SupplementId,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    CurrencyCode,
    LastChangedAt,
    /* Associations */
    _Booking : redirected to parent ZC_BOOKING_MN,
    _supplement,
    _supplementText,
    _Travel : redirected to ZC_Travel_mn 
}
