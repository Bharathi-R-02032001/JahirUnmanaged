@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Details Projcetion View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BOOKING_MN as projection on Zi_Booking_Mn
{
    key TravelId,
    key BookingId,
    BookingDate,
    @ObjectModel.text.element: [ 'Customer_Name' ]
    CustomerId,
    _Customer.LastName as Customer_Name,
    @ObjectModel.text.element: [ 'Carrier_Name' ]
    CarrierId,
    _carrier.Name as Carrier_Name,
    ConnectionId,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    booking_status,
    lastchnagedat,
    /* Associations */
    _Bookingsuppl : redirected to composition child Zc_BOOKINGSUPP_MN,
    _booking_status,
    _carrier,
    _connection,
    _Customer,
    _travel : redirected to parent ZC_Travel_mn
}
