"! This is demo for FALV with redefinition of hotspot event handler
"! done by Lukasz Pegiel for http://abapblog.com
report zdemo_falv02.

data: sflight type standard table of sflight.


class lcl_test definition inheriting from zcl_falv.
  public section.

  protected section.
    "redefinition of event handler
    methods evf_hotspot_click redefinition.
    methods evf_top_of_page redefinition.
  private section.

endclass.

class lcl_test implementation.

  method evf_hotspot_click.
    case e_column_id-fieldname.
      when 'SEATSMAX'.
        call function 'POPUP_DISPLAY_MESSAGE'
          exporting
            titel = 'Hotspot is working'   " Title
            msgid = '00'
            msgty = 'I'
            msgno = '001'
            msgv1 = 'Yupi!'.
    endcase.
  endmethod.

  method evf_top_of_page.

    e_dyndoc_id->add_text( text = 'Top Of Page' sap_style = cl_dd_area=>heading ).

    e_dyndoc_id->new_line( repeat = 1 ).

    e_dyndoc_id->add_link(
      exporting
        name                   =  'ABAPBLOG.com'   " Name (You Can Use Any Name You Choose)
        url                    =   'http://abapblog.com'  " URL
        tooltip                =  'ABAPBLOG.com'   " Tool Tip
        text                   =  'ABAPBLOG.com'    " Text
    ).


  endmethod.

endclass.

start-of-selection.

  select * up to 100 rows
  into corresponding fields of table @sflight
  from sflight.

  "creation of falv with local redefinition
  data falv type ref to lcl_test.
  data(subcl) = cl_abap_classdescr=>describe_by_name( p_name = 'LCL_TEST' ).

  falv ?=  lcl_test=>create( exporting i_subclass = subcl changing ct_table = sflight ).


  "Add hotspot to column 'SEATSMAX'
  falv->column( 'SEATSMAX' )->set_hotspot( abap_true ).
  "Add title variable
  falv->title_v1 = 'ZDEMO_FALV02'.

  falv->top_of_page_height = 100. "absolute size
  "To enable top_of_page
  falv->show_top_of_page( ).

  "Display full screen grid
  falv->display( ).
