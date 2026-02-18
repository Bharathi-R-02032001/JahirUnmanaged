@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Interface'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_Travel_Mn as select from zrj_travel_m
composition [0..*] of Zi_Booking_Mn as _booking 
association [0..1] to /DMO/I_Agency as _agency on $projection.AgencyId = _agency.AgencyID
association [0..1] to /DMO/I_Customer as _customer on $projection.CustomerId = _customer.CustomerID
association [1..1] to I_Currency as _currency on $projection.CurrencyCode = _currency.Currency
association [0..1] to /DMO/I_Overall_Status_VH as _status on $projection.overallstatus = _status.OverallStatus
{
    key travel_id as TravelId,
    agency_id as AgencyId,
    customer_id as CustomerId,
    begin_date as BeginDate,
    end_date as EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode' 
    booking_fee as BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'     
    total_price as TotalPrice,
    currency_code as CurrencyCode,
    description as Description,
    //status as Status,
    ovr_status as overallstatus,
    @Semantics.user.createdBy: true
    createdby as Createdby,
    @Semantics.systemDateTime.createdAt: true
    createdat as Createdat,
    @Semantics.user.lastChangedBy: true
    lastchangedby as Lastchangedby,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    lastchangedat as Lastchangedat,
    //Assocations
    _agency,
    _customer,  
    _currency,
    _status,
    _booking 
}
