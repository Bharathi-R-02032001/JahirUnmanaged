CLASS lhc__travels DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR _travels RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _travels RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR _travels RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE _travels.

    METHODS earlynumbering_cba_Booking FOR NUMBERING
      IMPORTING entities FOR CREATE _travels\_Booking.

    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION _travels~accepttravel RESULT result.

    METHODS Copytravel FOR MODIFY
      IMPORTING keys FOR ACTION _travels~Copytravel.

    METHODS recalcTotprice FOR MODIFY
      IMPORTING keys FOR ACTION _travels~recalcTotprice.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION _travels~rejecttravel RESULT result.

    METHODS Calctotprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _travels~Calctotprice.

    METHODS ValidateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR _travels~ValidateCustomer.

ENDCLASS.


CLASS lhc__travels IMPLEMENTATION.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(lt_entities) = entities.

    DELETE lt_entities WHERE TravelId IS NOT INITIAL.

    TRY.

        cl_numberrange_runtime=>number_get( EXPORTING nr_range_nr       = '01'
                                                      object            = '/DMO/TRV_M'
                                                      quantity          = CONV #( lines( lt_entities ) )
                                            IMPORTING number            = DATA(lv_latest_num)
                                                      returncode        = DATA(lv_rc_code)
                                                      returned_quantity = DATA(lv_quty) ).

        DATA(lv_qty) = CONV i( lv_quty * 1000 ).

      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lo_num_range).

        LOOP AT lt_entities INTO DATA(ls_entite).

          APPEND VALUE #( %cid = ls_entite-%cid
                          %key = ls_entite-%key ) TO failed-_travels.

          APPEND VALUE #( %cid = ls_entite-%cid
                          %key = ls_entite-%key
                          %msg = lo_num_range ) TO reported-_travels.

        ENDLOOP.
        RETURN.
    ENDTRY.

    ASSERT lv_qty = ( lines( lt_entities ) * 1000 ).

    DATA(lv_cur_num) = CONV i( lv_latest_num - lv_quty ).

    LOOP AT lt_entities INTO DATA(ls_entities).

      lv_cur_num += 1.

      APPEND VALUE #( %cid     = ls_entities-%cid
                      TravelId = ( lv_cur_num * 1000 ) )
             TO mapped-_travels.

    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.
    DATA lv_max_booking TYPE /dmo/booking_id.

    READ ENTITIES OF ZI_Travel_Mn IN LOCAL MODE
         ENTITY _travels BY \_booking
         FROM CORRESPONDING #( entities )
         LINK DATA(lt_link_data)
         REPORTED DATA(lt_reported)
         FAILED DATA(lt_failed).

    LOOP AT entities INTO DATA(ls_entities)
         GROUP BY ls_entities-TravelId.

      lv_max_booking = REDUCE #( INIT lv_max = CONV /dmo/booking_id( '0' )
                                 FOR  ls_link IN lt_link_data USING KEY entity
                                 WHERE ( source-TravelId = ls_entities-TravelId )
                                 NEXT lv_max = COND /dmo/booking_id(
                                 WHEN lv_max < ls_link-target-BookingId
                                 THEN ls_link-target-BookingId
                                 ELSE lv_max ) ).

      lv_max_booking = REDUCE #( INIT lv_max = lv_max_booking
                             FOR  ls_entity IN entities USING KEY entity
                             WHERE ( travelid = ls_entities-TravelId )
                             FOR ls_booking IN ls_entities-%target
                             NEXT lv_max = COND /dmo/booking_id(
                             WHEN lv_max < ls_booking-BookingId
                             THEN ls_booking-BookingId
                             ELSE lv_max ) ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities>)
           USING KEY entity
           WHERE TravelId = ls_entities-TravelId.

        LOOP AT <lfs_entities>-%target INTO DATA(ls_target).

          APPEND CORRESPONDING #( ls_target ) TO mapped-_booking
                 ASSIGNING FIELD-SYMBOL(<lfs_mapped>).

          IF ls_target-BookingId IS INITIAL.

            lv_max_booking += 10.

            <lfs_mapped>-BookingId = lv_max_booking.

          ENDIF.

        ENDLOOP.

      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.

  METHOD Copytravel.
    DATA : it_travel       TYPE TABLE FOR CREATE ZI_Travel_Mn,
           it_booking      TYPE TABLE FOR CREATE ZI_Travel_Mn\_booking,
           it_bookingsuppl TYPE TABLE FOR CREATE Zi_Booking_Mn\_Bookingsuppl.

    ASSIGN keys[ %cid = ' ' ] TO FIELD-SYMBOL(<lfs_keys>).

    ASSERT <lfs_keys> IS NOT ASSIGNED.

    READ ENTITIES OF ZI_Travel_Mn IN LOCAL MODE
         ENTITY _travels
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travel_r)
         FAILED DATA(lt_failed).

    READ ENTITIES OF zi_travel_mn IN LOCAL MODE
         ENTITY _travels BY \_booking
         ALL FIELDS WITH CORRESPONDING #( lt_travel_r )
         RESULT DATA(lt_booking_r).

    READ ENTITIES OF zi_travel_mn IN LOCAL MODE
         ENTITY _Booking BY \_Bookingsuppl
         ALL FIELDS WITH CORRESPONDING #( lt_booking_r )
         RESULT DATA(lt_bookingsupl_r).

    LOOP AT lt_travel_r ASSIGNING FIELD-SYMBOL(<lfs_travel_r>).

      APPEND VALUE #( %cid  = keys[ KEY entity
                                    TravelId = <lfs_travel_r>-TravelId ]-%cid
                      %data = CORRESPONDING #( <lfs_travel_r> EXCEPT travelid ) )
             TO it_travel ASSIGNING FIELD-SYMBOL(<lfs_travel>).

      <lfs_travel>-BeginDate     = cl_abap_context_info=>get_system_date( ).
      <lfs_travel>-EndDate       = ( cl_abap_context_info=>get_system_date( ) + 30 ).
      <lfs_travel>-OverallStatus = 'O'.

      APPEND VALUE #( %cid_ref = <lfs_travel>-%cid ) TO it_booking
             ASSIGNING FIELD-SYMBOL(<lft_booking>).

      LOOP AT lt_booking_r ASSIGNING FIELD-SYMBOL(<lfs_booking_r>)
           USING KEY entity
           WHERE TravelId = <lfs_travel_r>-TravelId.

        APPEND VALUE #( %cid  = <lfs_travel>-%cid && <lfs_booking_r>-BookingId
                        %data = CORRESPONDING #( <lfs_booking_r> EXCEPT travelid ) )
               TO <lft_booking>-%target ASSIGNING FIELD-SYMBOL(<lfs_booking_n>).

        <lfs_booking_n>-booking_status = 'N'.

        APPEND VALUE #( %cid_ref = <lfs_booking_n>-%cid ) TO it_bookingsuppl
               ASSIGNING FIELD-SYMBOL(<lft_bookingsupp>).

        LOOP AT lt_bookingsupl_r ASSIGNING FIELD-SYMBOL(<lfs_booking_supp_r>)
             USING KEY entity
             WHERE     TravelId  = <lfs_travel_r>-TravelId
                   AND BookingId = <lfs_booking_r>-BookingId.

          APPEND VALUE #( %cid  = <lfs_travel>-%cid && <lfs_booking_r>-BookingId
                       && <lfs_booking_supp_r>-BookingSupplementId
                          %data = CORRESPONDING #( <lfs_booking_supp_r> EXCEPT travelid bookingid  ) )
                 TO <lft_bookingsupp>-%target.

        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_mn IN LOCAL MODE
           ENTITY _travels
           CREATE FIELDS ( AgencyId CustomerId BeginDate EndDate BookingFee TotalPrice
                          CurrencyCode overallstatus Description )
           WITH it_travel
           ENTITY _travels
           CREATE BY \_booking
           FIELDS ( BookingId BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice
                    booking_status  )
           WITH it_booking
           ENTITY _Booking
           CREATE BY \_Bookingsuppl
           FIELDS ( BookingSupplementId SupplementId Price CurrencyCode )
           WITH it_bookingsuppl
           MAPPED DATA(lt_mapped).

    mapped-_travels = lt_mapped-_travels.
  ENDMETHOD.

  METHOD recalcTotprice.
    TYPES : BEGIN OF ty_tot,
              Price TYPE /dmo/total_price,
              curr  TYPE /dmo/currency_code,
            END OF ty_tot.

    DATA : lt_total_amt     TYPE STANDARD TABLE OF ty_tot,
           lv_converted_amt TYPE /dmo/total_price.

    READ ENTITIES OF zi_travel_mn IN LOCAL MODE
         ENTITY _travels
         FIELDS ( BookingFee CurrencyCode )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travel_r).

    DELETE lt_travel_r WHERE CurrencyCode IS INITIAL.

    READ ENTITY IN LOCAL MODE zi_travel_mn BY \_booking
         FIELDS ( FlightPrice CurrencyCode )
         WITH CORRESPONDING #( lt_travel_r )
         RESULT DATA(lt_booking_r).

    READ ENTITY IN LOCAL MODE Zi_Booking_Mn BY \_Bookingsuppl
         FIELDS ( Price CurrencyCode )
         WITH CORRESPONDING #( lt_booking_r )
         RESULT DATA(lt_booksupp_r).

    LOOP AT lt_travel_r ASSIGNING FIELD-SYMBOL(<lfs_travel_r>).

      lt_total_amt = VALUE #( ( price = <lfs_travel_r>-BookingFee
                                curr  = <lfs_travel_r>-CurrencyCode ) ).

      LOOP AT lt_booking_r ASSIGNING FIELD-SYMBOL(<lfs_booking_r>)
           USING KEY entity
           WHERE     TravelId      = <lfs_travel_r>-TravelId
                 AND CurrencyCode IS NOT INITIAL.

        lt_total_amt = VALUE #( BASE lt_total_amt
                                ( price = <lfs_booking_r>-FlightPrice
                                  curr  = <lfs_booking_r>-CurrencyCode ) ).

        LOOP AT lt_booksupp_r ASSIGNING FIELD-SYMBOL(<lfs_bookingsupp>)
             USING KEY entity
             WHERE     TravelId      = <lfs_booking_r>-TravelId
                   AND BookingId     = <lfs_booking_r>-BookingId
                   AND CurrencyCode IS NOT INITIAL.
          lt_total_amt = VALUE #( BASE lt_total_amt
                                  ( price = <lfs_bookingsupp>-Price
                                    curr  = <lfs_bookingsupp>-CurrencyCode ) ).

        ENDLOOP.

      ENDLOOP.

      LOOP AT lt_total_amt ASSIGNING FIELD-SYMBOL(<lfs_tot_amt>).

        IF <lfs_tot_amt>-curr = <lfs_travel_r>-CurrencyCode.
          lv_converted_amt = <lfs_tot_amt>-price.
        ELSE.

*          zcl_flight_amdp_copy=>convert_currency(
*            EXPORTING
*              iv_amount               = <lfs_tot_amt>-price
*              iv_currency_code_source = <lfs_tot_amt>-curr
*              iv_currency_code_target = <lfs_travel_r>-CurrencyCode
*              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
*            IMPORTING
*              ev_amount               = lv_converted_amt
*              lt_data                 = data(lt_curr)
*          ).
*
*          lv_converted_amt = VALUE #( lt_curr[ 1 ]-target_value OPTIONAL ).

*          SELECT SINGLE FROM zrj_currency_convert( amount    = @<lfs_tot_amt>-price,
*                                            source_currency = @<lfs_tot_amt>-curr,
*                                            target_currency = @<lfs_travel_r>-CurrencyCode  )
*               FIELDS Targetgrosscollectoin
*               INTO @lv_converted_amt.

        ENDIF.

        <lfs_travel_r>-TotalPrice += lv_converted_amt.

      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_mn IN LOCAL MODE
           ENTITY _travels
           UPDATE FIELDS ( totalprice )
           WITH CORRESPONDING #( lt_travel_r ).
  ENDMETHOD.

  METHOD accepttravel.
    MODIFY ENTITIES OF ZI_Travel_Mn IN LOCAL MODE
           ENTITY _travels
           UPDATE FIELDS ( overallstatus )
           WITH VALUE #( FOR ls_key IN keys
                         ( %tky          = ls_key-%tky
                           OverallStatus = 'A' ) )
           REPORTED DATA(lt_travel).

    READ ENTITIES OF ZI_Travel_Mn IN LOCAL MODE
         ENTITY _travels
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travel_r).

    result = VALUE #( FOR ls_travel
                      IN lt_travel_r
                      ( %tky   = ls_travel-%tky
                        %param = ls_travel  ) ).
  ENDMETHOD.

  METHOD rejecttravel.
    MODIFY ENTITIES OF ZI_Travel_Mn IN LOCAL MODE
           ENTITY _travels
           UPDATE FIELDS ( overallstatus )
           WITH VALUE #( FOR ls_key IN keys
                         ( %tky          = ls_key-%tky
                           OverallStatus = 'X' ) )
           REPORTED DATA(lt_travel).

    READ ENTITIES OF ZI_Travel_Mn IN LOCAL MODE
         ENTITY _travels
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travel_r).

    result = VALUE #( FOR ls_travel
                      IN lt_travel_r
                      ( %tky   = ls_travel-%tky
                        %param = ls_travel   ) ).
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF ZI_Travel_Mn IN LOCAL MODE
         ENTITY _travels
         FIELDS ( TravelId overallstatus )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_Travels_r).

    RESUlt = VALUE #( FOR ls_travel IN lt_travels_r
                      ( %tky                           = ls_travel-%tky
                        %features-%action-accepttravel = COND #( WHEN ls_travel-OverallStatus = 'A'
                                                                 THEN if_abap_behv=>fc-o-disabled
                                                                 ELSE if_abap_behv=>fc-o-enabled )
                        %features-%action-rejecttravel = COND #( WHEN ls_travel-OverallStatus = 'X'
                                                                 THEN if_abap_behv=>fc-o-disabled
                                                                 ELSE if_abap_behv=>fc-o-enabled )
                        %features-%assoc-_booking      = COND #( WHEN ls_travel-OverallStatus = 'X'
                                                                 THEN if_abap_behv=>fc-o-disabled
                                                                 ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD ValidateCustomer.
    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    READ ENTITY IN LOCAL MODE ZI_Travel_Mn
         FIELDS ( CustomerId )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_Cust_tmp).

    lt_customer = CORRESPONDING #( lt_cust_tmp DISCARDING DUPLICATES MAPPING customer_id = CustomerId ).

    DELETE lt_customer WHERE customer_id IS INITIAL.

    IF lt_customer IS INITIAL.
      RETURN.
    ENDIF.

    SELECT FROM /dmo/customer
      FIELDS customer_id
      FOR ALL ENTRIES IN @lt_customer
      WHERE customer_id = @lt_customer-customer_id
      INTO TABLE @FINAL(lt_check).

    LOOP AT lt_Cust_tmp ASSIGNING FIELD-SYMBOL(<lfs_customer>).

      IF <lfs_customer> IS NOT INITIAL AND
         line_exists( lt_check[ customer_id = <lfs_customer>-CustomerId ] ).
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky = <lfs_customer>-%tky ) TO failed-_travels.

      APPEND VALUE #( %tky                = <lfs_customer>-%tky
                      %msg                = NEW /dmo/cm_flight_messages(
                                                    textid      = /dmo/cm_flight_messages=>customer_unkown
                                                    customer_id = <lfs_customer>-CustomerId
                                                    severity    = if_abap_behv_message=>severity-error )
                      %element-Customerid = if_abap_behv=>mk-on )
             TO reported-_travels.

    ENDLOOP.
  ENDMETHOD.

  METHOD Calctotprice.
    DATA lt_travel TYPE STANDARD TABLE OF ZI_Travel_Mn
                   WITH UNIQUE HASHED KEY key COMPONENTS TravelId.

    lt_travel = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING TravelId = TravelId ).

    MODIFY ENTITIES OF zi_travel_mn IN LOCAL MODE
           ENTITY _travels
           EXECUTE recalcTotprice
           FROM CORRESPONDING #( lt_travel ).
  ENDMETHOD.
ENDCLASS.


CLASS lsc_ZI_TRAVEL_MN DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified    REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.


CLASS lsc_ZI_TRAVEL_MN IMPLEMENTATION.
  METHOD save_modified.
    DATA lt_log_data   TYPE STANDARD TABLE OF zlog_tab.
    DATA lt_log_data_c TYPE STANDARD TABLE OF zlog_tab.
    DATA lt_log_data_u TYPE STANDARD TABLE OF zlog_tab.
    DATA lt_log_data_d TYPE STANDARD TABLE OF zlog_tab.
    DATA lt_booksupl   TYPE STANDARD TABLE OF zrj_booksupl_m.

    IF create-_travels IS NOT INITIAL.

      lt_log_data = CORRESPONDING #( create-_travels ).

      LOOP AT lt_log_data ASSIGNING FIELD-SYMBOL(<lfs_log_data>).

        <lfs_log_data>-changing_operation = 'Create'.

        GET TIME STAMP FIELD <lfs_log_data>-created_at.

        ASSIGN create-_travels[ KEY entity
                                TravelId = <lfs_log_data>-travelid ] TO FIELD-SYMBOL(<lfs_travel>).
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        IF <lfs_travel>-%control-BookingFee = cl_abap_behv=>flag_changed.

          <lfs_log_data>-changed_field_name = 'Booking Fee'.
          <lfs_log_data>-changed_value      = <lfs_travel>-BookingFee.

          TRY.
              <lfs_log_data>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
              " handle exception
          ENDTRY.

          APPEND <lfs_log_data> TO lt_log_data_c.

        ENDIF.
        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        IF <lfs_travel>-%control-OverallStatus = cl_abap_behv=>flag_changed.

          <lfs_log_data>-changed_field_name = 'Overall Status'.
          <lfs_log_data>-changed_value      = <lfs_travel>-OverallStatus.

          TRY.
              <lfs_log_data>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
              " handle exception
          ENDTRY.

          APPEND <lfs_log_data> TO lt_log_data_c.

        ENDIF.
      ENDLOOP.
      INSERT zlog_tab FROM TABLE @lt_log_data_c.
    ENDIF.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    IF update-_travels IS NOT INITIAL.

      lt_log_data = CORRESPONDING #( update-_travels ).

      LOOP AT lt_log_data ASSIGNING FIELD-SYMBOL(<lfs_log_data_u>).

        <lfs_log_data_u>-changing_operation = 'Update'.

        GET TIME STAMP FIELD <lfs_log_data_u>-created_at.

        ASSIGN update-_travels[ KEY entity
                                TravelId = <lfs_log_data_u>-travelid ] TO FIELD-SYMBOL(<lfs_travel_u>).
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        IF <lfs_travel_u>-%control-BookingFee = cl_abap_behv=>flag_changed.

          <lfs_log_data_u>-changed_field_name = 'Booking Fee'.
          <lfs_log_data_u>-changed_value      = <lfs_travel_u>-BookingFee.

          TRY.
              <lfs_log_data_u>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
              " handle exception
          ENDTRY.

          APPEND <lfs_log_data_u> TO lt_log_data_u.

        ENDIF.
        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        IF <lfs_travel_u>-%control-OverallStatus = cl_abap_behv=>flag_changed.

          <lfs_log_data_u>-changed_field_name = 'Overall Status'.
          <lfs_log_data_u>-changed_value      = <lfs_travel_u>-OverallStatus.

          TRY.
              <lfs_log_data_u>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
              " handle exception
          ENDTRY.

          APPEND <lfs_log_data_u> TO lt_log_data_u.

        ENDIF.
      ENDLOOP.
      INSERT zlog_tab FROM TABLE @lt_log_data_u.
    ENDIF.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    IF delete-_travels IS NOT INITIAL.

      lt_log_data = CORRESPONDING #( delete-_travels ).

      LOOP AT lt_log_data ASSIGNING FIELD-SYMBOL(<lfs_log_data_d>).

        <lfs_log_data_d>-changing_operation = 'Delete'.

        GET TIME STAMP FIELD <lfs_log_data_d>-created_at.

        ASSIGN delete-_travels[ KEY entity
                                TravelId = <lfs_log_data_d>-travelid ] TO FIELD-SYMBOL(<lfs_travel_d>).
        IF sy-subrc = 0.

          TRY.
              <lfs_log_data_d>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
              <lfs_log_data_d>-travelid  = <lfs_travel_d>-TravelId.
            CATCH cx_uuid_error.
              " handle exception
          ENDTRY.

          APPEND <lfs_log_data_d> TO lt_log_data_d.

        ENDIF.

      ENDLOOP.
      INSERT zlog_tab FROM TABLE @lt_log_data_d.
    ENDIF.

    " ---------------------------------------------------------------------

    IF create-_booking_supplement IS NOT INITIAL.

      lt_booksupl = CORRESPONDING #( create-_booking_supplement MAPPING
                                      travel_id             = TravelId
                                      booking_supplement_id = BookingSupplementId
                                      booking_id            = BookingId
                                      supplement_id         = SupplementId
                                      price                 = Price
                                      currency_code         = CurrencyCode
                                      last_changed_at       = LastChangedAt ).

      INSERT zrj_booksupl_m FROM TABLE @lt_booksupl.

    ENDIF.

    IF update-_booking_supplement IS NOT INITIAL.

      lt_booksupl = CORRESPONDING #( update-_booking_supplement MAPPING
                                travel_id             = TravelId
                                booking_supplement_id = BookingSupplementId
                                booking_id            = BookingId
                                supplement_id         = SupplementId
                                price                 = Price
                                currency_code         = CurrencyCode
                                last_changed_at       = LastChangedAt ).

      UPDATE zrj_booksupl_m FROM TABLE @lt_booksupl.

    ENDIF.

    IF delete-_booking_supplement IS NOT INITIAL.

      lt_booksupl = CORRESPONDING #( delete-_booking_supplement MAPPING
                                travel_id             = TravelId
                                booking_supplement_id = BookingSupplementId
                                booking_id            = BookingId ).

      DELETE zrj_booksupl_m FROM TABLE @lt_booksupl.

    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
