<%inherit file="../layout.mako" />

<%def name="title()">TSA Events - Create Account</%def>


<div class="span-24 last" align="center">

    <form action="/accounts/create/" method='post'>
        
        <table class="datatable">     
            ${form.as_table()}
          <tr ><td colspan="2"><div align="center"><input type="submit" value="Create" /></div></td></tr>
        </table>

    </form>

</div>


