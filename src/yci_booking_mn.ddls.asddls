@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Approver Projection'
@Metadata.ignorePropagatedAnnotations: true
@UI : {  headerInfo: {
    typeName: 'Bookings',
    typeNamePlural: 'Bookings',
    title.iconUrl: 'sap-icon://flight',
    typeImageUrl: 'sap-icon://flight',
    title: {
        type: #STANDARD,
        label: 'Bookings - Airlines',
        value: 'BookingId'
    } } }
@Search.searchable: true
define view entity yci_booking_mn
  as projection on Zi_Booking_Mn
{
      @UI.hidden: true
  key TravelId,
      @UI.facet: [{ purpose: #STANDARD ,
                        type: #IDENTIFICATION_REFERENCE,
                        id: 'ID1' , position: 10
                        , label: 'Bookings' } ]
      @UI : { lineItem: [{ position: 10 , label: 'Booking ID' }],
         identification: [{ position: 10  }] }
      @Search.defaultSearchElement: true
  key BookingId,
      @UI : { lineItem: [{ position: 20 , label: 'Booking Date' }],
          identification: [{ position: 20  }] }
      BookingDate,
      @UI : { lineItem: [{ position: 30 , label: 'Customer ID' }],
         identification: [{ position: 30  }] }
      @Consumption.valueHelpDefinition:
      [{ entity : { element: 'CustomerID' , name: '/DMO/I_Customer' } }]

      @ObjectModel.text.element: [ 'Customer_Name' ]
      CustomerId,

      _Customer.LastName as Customer_Name,
      @ObjectModel.text.element: [ 'Carrier_Name' ]
      @UI : { lineItem: [{ position: 40 , label: 'Carrier ID' }],
      identification: [{ position: 40  }] }
      @Consumption.valueHelpDefinition:
      [{ entity : { element: 'AirlineID' , name: '/DMO/I_Carrier' } }]
      CarrierId,
      _carrier.Name      as Carrier_Name,
      @UI : { lineItem: [{ position: 60 , label: 'Flight Date' }],
         identification: [{ position: 60  }] }
      @Consumption.valueHelpDefinition:
      [{ entity : { element: 'FlightDate' , name: '/DMO/I_Flight' } ,
      additionalBinding: [{ element: 'FlightDate' , localElement: 'FlightDate' } ,
                       { element: 'AirlineID' , localElement: 'CarrierID' } ,
                       { element: 'CurrencyCode' , localElement: 'CurrencyCode' } ,
                       { element: 'Price' , localElement: 'FlightPrice' } ] } ]

      ConnectionId,
      @UI : { lineItem: [{ position: 70 , label: 'Flight Price' }],
      identification: [{ position: 70  }] }
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI : { lineItem: [{ position: 80 , label: 'Currency Code' }],
      identification: [{ position: 80  }] }
      @Consumption.valueHelpDefinition:
      [{ entity : { element: 'Currency' , name: 'I_Currency' } }]
      FlightPrice,
      CurrencyCode,
      @UI : { lineItem: [{ position: 90 , label: 'Booking Status' }],
      identification: [{ position: 90  }] }
      @Consumption.valueHelpDefinition:
      [{ entity : { element: 'BookingStatus' , name: '/DMO/I_Booking_Status_VH' } }]
      booking_status,
      lastchnagedat,
      /* Associations */
      _Bookingsuppl,
      _booking_status,
      _carrier,
      _connection,
      _Customer,
      _travel : redirected to parent YCI_TRAVEL_MN
}
