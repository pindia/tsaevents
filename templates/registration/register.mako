<%inherit file="../layout.mako" />

<%def name="title()">Create Account</%def>
<%def name="bigtitle()">${self.title()}</%def>


<div class="span-24 last" align="center">
    <h1>TSA Events - Create Account</h1>

    <form action="/accounts/create/" method='post'>
        
        <table class="layouttable aligner">     
            ${form.as_table()}
          <tr ><td colspan="2"><div align="center"><input type="submit" value="Create" /></div></td></tr>
        </table>

    </form>

</div>


