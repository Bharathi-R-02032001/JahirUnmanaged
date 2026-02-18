@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Approver Projection'
@Metadata.ignorePropagatedAnnotations: true
@UI : {  headerInfo: {
    typeName: 'Travel',
    typeNamePlural: 'Travels',
    title.iconUrl: 'sap-icon://flight',
    typeImageUrl: 'sap-icon://flight',
    title: {
        type: #STANDARD,
        label: 'Travels - Airlines',
        value: 'TravelId'
    } } }
@Search.searchable: true
define root view entity YCI_TRAVEL_MN
  provider contract transactional_query
  as projection on ZI_Travel_Mn
{
      @UI : { lineItem: [{ position: 10 , label: 'Travel ID' } ,
            { type: #FOR_ACTION, dataAction: 'Copytravel' , label: 'Copy Travel' } ] ,
              selectionField: [{ position: 10 }] ,
              identification: [{ position: 10 , label: 'Travel ID'}],
              facet: [{ purpose: #STANDARD ,
                        type: #IDENTIFICATION_REFERENCE,
                        id: 'ID1' ,
                        label: 'Travel' ,
                        position: 10 } ,
                        { id: 'Booking'
                          , purpose: #STANDARD
                          ,  type: #LINEITEM_REFERENCE
                          , targetElement: '_booking' ,
                          label: 'Booking' ,
                          position: 20 } ]

                       }
      @Search.defaultSearchElement: true
  key TravelId,
      @UI : { lineItem: [{ position: 20 , label: 'Agency ID' }],
            identification: [{ position: 10  }] }
      @Consumption.valueHelpDefinition:
       [{ entity : { element: 'AgencyID' , name: '/DMO/I_AGENCY' } }]
      @UI.textArrangement: #TEXT_ONLY
      @ObjectModel.text.element: [ 'AgencyName' ]
      AgencyId,
      _agency.Name       as AgencyName,
      @ObjectModel.text.element: [ 'CustomerName' ]
      @UI :{ lineItem: [{ position: 30  , label: 'Customer ID'  }] ,
       identification: [{ position: 20  }] }
      @Consumption.valueHelpDefinition:
       [{ entity : { element: 'CustomerID' , name: '/DMO/I_Customer' } }]
      CustomerId,
      _customer.LastName as CustomerName,
      @UI :{ lineItem: [{ position: 40 ,  label: 'Begin Date' }] }
      BeginDate,
      @UI :{ lineItem: [{ position: 50 ,  label: 'End Date'  }] }
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI :{ lineItem: [{ position: 60 , label: 'Booking Fee' ,
                    iconUrl: 'sap-icon://suitcase' }] }
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI :{ lineItem: [{ position: 70 , label: 'Total Price'}] ,
      identification: [{ position: 30  }] }
      TotalPrice,
      @UI :{ lineItem: [{ position: 80 , hidden: true }] ,
      identification: [{ position: 40  }] }
      @Consumption.valueHelpDefinition:
      [{ entity : { element: 'Currency' , name: 'I_Currency' } }]
      CurrencyCode,
      @UI :{ lineItem: [{ position: 90 , label: 'Description' } ],
      identification: [{ position: 50  }] }
      Description,
      @UI :{ lineItem: [{ position: 55 , label: 'Status' , importance: #HIGH } ,
             { type: #FOR_ACTION, dataAction: 'accepttravel',label: 'Accept Travel' } ,
             { type: #FOR_ACTION, dataAction: 'rejecttravel',label: 'Reject Travel' } ],
             identification: [{ position: 55 , importance: #HIGH } ,
             { type: #FOR_ACTION, dataAction: 'accepttravel',label: 'Accept Travel' } ,
             { type: #FOR_ACTION, dataAction: 'rejecttravel',label: 'Reject Travel' } ]
              }
      overallstatus,
      @UI :{ lineItem: [{ position: 110 }] }
      Createdby,
      @UI :{ lineItem: [{ position: 120 , hidden: true }] }
      Createdat,
      @UI :{ lineItem: [{ position: 130  , hidden: true }] }
      Lastchangedby,
      @UI :{ lineItem: [{ position: 140 ,
        hidden: true }] }
      Lastchangedat,
      /* Associations */
      _agency,
      _booking : redirected to composition child yci_booking_mn,
      _currency,
      _customer,
      _status
}
