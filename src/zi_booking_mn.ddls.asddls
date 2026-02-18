@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Details - Interface'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Zi_Booking_Mn as select from zrj_book_m
composition [0..*] of Zi_Bookingsupp_Mn as _Bookingsuppl
association to parent ZI_Travel_Mn as _travel
on $projection.TravelId = _travel.TravelId
association [1..1] to /DMO/I_Carrier as _carrier
on $projection.CarrierId = _carrier.AirlineID
association [1..1] to /DMO/I_Customer as _Customer
on $projection.CustomerId = _Customer.CustomerID
association [1..1] to /DMO/I_Connection as _connection
on $projection.ConnectionId = _connection.ConnectionID and 
   $projection.CarrierId    = _connection.AirlineID
association [1..1] to /DMO/I_Booking_Status_VH as _booking_status
on $projection.booking_status = _booking_status.BookingStatus
{
    key travel_id as TravelId,
    key booking_id as BookingId,
    booking_date as BookingDate,
    customer_id as CustomerId,
    carrier_id as CarrierId,
    connection_id as ConnectionId,
    flight_date as FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    flight_price as FlightPrice,
    currency_code as CurrencyCode,
    booking_status as booking_status,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    last_changed_at as lastchnagedat,
    //Assocations
    _carrier,
    _Customer,
    _connection,
    _booking_status,
    _travel,
    _Bookingsuppl
}
