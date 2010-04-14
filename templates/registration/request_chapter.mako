<%inherit file="../layout.mako" />

<%def name="title()">New Chapter</%def>
<%def name="bigtitle()">${self.title()}</%def>


<div class="span-24 last" align="center">
    <h1>TSA Events - Request New Chapter</h1>
    
    % if error_msg:
        <div class="error">${error_msg}</div>
    % endif
    
    <p>You are requesting the creation of a new chapter. We are only able to support chapters in Pennsylvania at the moment due to event differences. Enter the details for the new chapter, as well as the information for a new account that will be created as the first chapter administrator. Once the chapter is created, you will be sent an email and will be able to log in with the credentials supplied and open the chapter for general registration or create additional advisor accounts.</p>
    
    <p>Note: All chapter requests are manually reviewed and processed for security and abuse prevention reasons. </p>

    <form action="" method='post'>
        
        <table class="layouttable aligner">
            ${form.as_table()}
          <tr ><td colspan="2"><div align="center"><input type="submit" value="Submit" /></div></td></tr>
        </table>

    </form>
    

</div>



