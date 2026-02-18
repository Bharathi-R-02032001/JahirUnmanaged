CLASS lhc__Booking_supplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS Calctotprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _Booking_supplement~Calctotprice.

ENDCLASS.

CLASS lhc__Booking_supplement IMPLEMENTATION.

  METHOD Calctotprice.

    DATA: it_travel TYPE STANDARD TABLE OF yi_travel_tech_m WITH UNIQUE HASHED KEY key COMPONENTS TravelId.

    it_travel =  CORRESPONDING #(  keys DISCARDING DUPLICATES MAPPING TravelId = TravelId ).
    MODIFY ENTITIES OF ZI_Travel_Mn IN LOCAL MODE
     ENTITY _travels
     EXECUTE recalcTotPrice
     FROM CORRESPONDING #( it_travel ).

  ENDMETHOD.

ENDCLASS.
