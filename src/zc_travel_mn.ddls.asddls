@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Traval Details Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_Travel_mn 
provider contract transactional_query
as projection on ZI_Travel_Mn
{
    key TravelId,
    @ObjectModel.text.element: [ 'AgencyName' ]
    AgencyId,
    _agency.Name as AgencyName,
    @ObjectModel.text.element: [ 'CustomerName' ]
    CustomerId,
    _customer.LastName as CustomerName,
    BeginDate,
    EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalPrice,
    CurrencyCode,
    Description,
    //Status,
    overallstatus as Status,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
    /* Associations */
    _agency,
    _booking : redirected to composition child ZC_BOOKING_MN,
    _currency,
    _customer,
    _status
}
